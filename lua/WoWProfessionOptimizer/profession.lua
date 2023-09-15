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

-- Import libraries
local LibParse = LibStub("LibParse")

local RAW_JSON_DATA = Profession -- JSON profession data


--[[
-- Expansion Enum
--
-- @field max_skill [number] Max amount of skill points available in the expansion
-- @field formal [string] Formal name of the expansion
]]--
Expansion = (function()
    local value = { "WOTLK", "TBC", "VANILLA" }
    local max_skills = { 450, 375, 300 }
    local formals =  { "Wrath of the Lich King", "The Burning Crusade", "World of Warcraft" }
    local colors = { "74A7D6", "AAD46C", "FCDA2A" }

    local instances, internals = Enum(value, {
        __tostring = function(tbl) return tbl.formal end
    })
    for i = 1, getmetatable(instances)() do
        local e = internals[instances[i]]
        e.max_skill = max_skills[i]
        e.formal = formals[i]
        e.color = colors[i]
    end
    return instances
end)()


--[[
-- Profession Enum
--
-- @field expansion [table] Expansion enum instance for which expansion the profession was added in
-- @field formal [string] Formal name of profession
--
-- @field load [function] Loads the profession from its profession JSON data
-- @param expac [table] Expansion enum instance, to determine which version to load
-- @return [table] Profession data object
]]--
Profession = (function()
    local values = { "ALCHEMY", "BLACKSMITHING", "COOKING", "ENCHANTING", "ENGINEERING",
                    "FIRST_AID", "INSCRIPTION", "JEWELCRAFTING", "LEATHERWORKING", "TAILORING" }
    local formals = { "Alchemy", "Blacksmithing", "Cooking", "Enchanting", "Engineering",
                     "First Aid", "Inscription", "Jewelcrafting", "Leatherworking", "Tailoring" }
    local expansions = Env.swap(Expansion, function()
        return { VANILLA, VANILLA, VANILLA, VANILLA, VANILLA, VANILLA, WOTLK, TBC, VANILLA, VANILLA } end)

    -- Returns Profession-EXPAC if profession data is available, otherwise nil
    local function loadable(prof, expac)
        prof = Type.TABLE(prof).formal
        expac = Type.TABLE(expac).name
        local key = prof .. "-" .. expac
        return RAW_JSON_DATA[key] and key or nil
    end

    -- Loads a profession from the storage medium, parsing it accordingly
    local function load_profession(prof, expac)

    end

    local instances, internals = Enum(values, {
        __tostring = function(tbl) return tbl.formal  end
    })
    for i = 1, getmetatable(instances)() do
        local instance = instances[i]
        local e = internals[instance]
        e.formal = formals[i]
        e.expansion = expansions[i]
        e.load = function(expac)
            return load_profession(instance, Type.TABLE(expac))
        end
        e.loadable = function(expac)
            local key = Type.TABLE(expac).name .. "-" .. e.formal
            return RAW_JSON_DATA[key] and key or false
        end
    end
    return instances
end)()

--[[
for k, v in flat_map(
        map(num_stream(1, getmetatable(Expansion)()), function(i) return i, Expansion[i] end),
        function(_, cv)
            return map(num_stream(1, getmetatable(Profession)()),
                    function(i) return cv, Profession[i] end)
        end) do
    print(k, v)
end
]]--

local t = {
    { "Here", "is", "an" },
    { },
    { "example" },
    { },
    { },
    { "long", "sentence" },
    { }
}

for k, v in flat_map(
        t,
        function(i, e)
            return e
        end) do
    print(k, v)
end
