--[[
--    Copyright (C) 2023 Kevin Tyrrell
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


Recipe = (function()
    local cls = { }

    --[[
    -- @param [table] jso JSON object detailing all fields of the recipe
    -- @return [table] Formalized table describing the recipe
    ]]--
    function cls.new(jso)
        local obj = {
            name = Type.STRING(Type.TABLE(jso).name),
            product = tonumber(Type.STRING(jso.product)),
            reagents = collect(map(Type.TABLE(jso.reagents),
                    function(k, v) -- Map "id": quantity -> { id, quantity }
                        return { tonumber(Type.STRING(k)), Type.NUMBER(v) }
                    end)),
        }
        -- Recipe sources
        local sources = Type.TABLE(jso.source)
        if #sources <= 0 then
            Error.ILLEGAL_ARGUMENT(ADDON_NAME, "Recipe has invalid source data: " .. obj.name) end
        obj.sources = sources
        -- Recipe yield
        local yield = jso.produces
        if yield == nil then obj.produces = 1 -- Most recipes produce a singular item
        else obj.yield = Type.NUMBER(yield) end
        -- Recipe specialization
        local spec = jso.spec
        if spec ~= nil then -- Not all recipes have specializations
            obj.spec = Type.NUMBER(spec) end
        -- Recipe levels
        local levels = Type.TABLE(jso.levels)
        if #levels ~= 5 then
            Error.ILLEGAL_ARGUMENT(ADDON_NAME, "Recipe has invalid level data: " .. obj.name) end
        obj.learned = levels[1]
        obj.levels = collect(map(num_stream(2, 5),
                function(i) return Type.NUMBER(levels[i]) end))
        return obj
    end

    return Table.read_only(cls)
end)()

local jso = Profession.ENGINEERING.load(Expansion.WOTLK)
for_each(jso, function(k, v)
    local r = Recipe.new(v)
    logger:Trace(k .. ", " .. r.name .. ", " .. r.learned .. ", " .. tostring(spec))
end)

