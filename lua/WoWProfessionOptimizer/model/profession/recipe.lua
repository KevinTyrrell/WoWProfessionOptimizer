--[[
--    Copyright (C) 2024 Kevin Tyrrell
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]--

local ADDON_NAME, WPO = ...
setfenv(1, WPO) -- Change environment


Source = (function()
    local ids = { 2, 4, 5, 6 }
    return Enum({ "DROP", "QUEST", "VENDOR", "TRAINER" },
            function(instance, members)
                members.id = ids[instance.ordinal]
                members.formal = String.to_title_format(instance.name)
            end, { __tostring = function(tbl) return tbl.formal end})
end)()


-- Maps source ID's to their corresponding Source enum values
local source_by_id = collect(map(Source.stream(), function(_, e) return e.id, e end))

-- Parses, checks validity of, and tranforms sources
local parse_sources = (function()
    local ignored_sources = Table.set(16, 21) -- Likely Fishing & Pickpocketing

    return function(name, sources)
        if #Type.TABLE(sources) <= 0 then
            Error.ILLEGAL_STATE(ADDON_NAME, "Recipe has empty source data: " .. Type.STRING(name)) end
        return collect(map(filter(sources,
                function(_, e) return ignored_sources[Type.NUMBER(e)] ~= true end), -- Filter
                function(i, id) -- Map to enum
                    local source = source_by_id[id]
                    if src == nil then Error.ILLEGAL_STATE(ADDON_NAME, "Recipe has unrecognized source(s): " .. name)
                end end))
    end
end)()


--[[
-- Recipe class
--
-- JSON object format:
-- {
--      name:       string
--      product:    number
--      reagents:   { id: number --> quantity: number }
--      sources:    { id: number, ... }
--      levels:     { min: number, orange: number, yellow: number, green: number, grey: number }
--      (produces):   number
--      (spec):       string
-- }
--
-- Recipe instance:
-- @field name [string] Name of the recipe
-- @field product [number] Item ID of the product
-- @field yield [number] Amount produced per craft
-- @field orange [number] Level in which the recipe requires to be learned
-- @field yellow [number] Level in which further crafts begin decrementing level-up likelihood
-- @field grey [number] Level in which crafts will no longer grant level-ups
-- @field reagents [table] { id: number --> quantity: number, ... }
-- @field sources [table] { id: boolean, ... }
-- @field (spec) [string] Specialization requirement
--
-- @param [table] jso JSON recipe object
-- @return [table] Recipe instance
]]--
function Recipe(jso)
    local name = Type.STRING(Type.TABLE(jso).name)
    local levels = Type.TABLE(jso.levels)

    if #levels ~= 5 then
        Error.ILLEGAL_ARGUMENT(ADDON_NAME, "Recipe level table is invalid: " .. jso.name) end
    for_each(levels, function(_, e) -- Levels domain check
        if Type.NUMBER(e) < 1 or e >= 500 then Error.ILLEGAL_ARGUMENT(ADDON_NAME, string.format(
                "Recipe level(s) are out of bounds: %s[%s]", name, Table.concat(levels, ", "))) end end)
    for_each(num_stream(2, 5), function(n) -- Levels sorted check
        if levels[n - 1] > levels[n] then Error.ILLEGAL_ARGUMENT(ADDON_NAME, string.format(
                "Recipe level(s) are invalid: %s[%s]", name, Table.concat(levels, ", "))) end end)

    local yield = jso.produces == nil and 1 or Type.NUMBER(jso.produces) -- '1' is implied
    local spec = jso.spec == nil and nil or Type.STRING(jso.spec) -- Only some recipes have a spec
    local reagents = collect(map(Type.TABLE(jso.reagents),
            function(k, v) -- Item ID comes as a string, conver to number
                return tonumber(Type.STRING(k)), Type.NUMBER(v) end))

    return {
        name = name,
        product = Type.NUMBER(jso.product),
        yield = yield,
        orange = levels[1],
        yellow = levels[3],
        grey = levels[5],
        reagents = reagents,
        sources = parse_sources(jso.name, jso.sources),
        spec = spec,
    }
end
