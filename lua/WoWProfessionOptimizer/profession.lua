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

Profession = (function()
    local cls = { } -- Class instance

    --[[
    -- Expansion Enum
    --
    -- @field max_skill [number] Max amount of skill points available in the expansion
    -- @field formal [string] Formal name of the expansion
    ]]--
    cls.Expac = (function()
        local value = { "WOTLK", "TBC", "VANILLA" }
        local max_skill = { 450, 375, 300 }
        local formal =  { "Wrath of the Lich King", "The Burning Crusade", "World of Warcraft" }

        local instances, internals = Enum(value, {
            __tostring = function(tbl) return tbl.formal end
        })
        for i = 1, getmetatable(instances)() do
            local e = internals[instances[i]]
            e.max_skill = max_skill[i]
            e.formal = formal[i]
        end
        return instances
    end)()

    --[[
    -- Profession Enum
    --
    -- @field expac [table] Expac enum instance for which expansion the profession was added in
    -- @field formal [string] Formal name of profession
    ]]--
    cls.Prof = (function()
        local value = { "ALCHEMY", "BLACKSMITHING", "COOKING", "ENCHANTING", "ENGINEERING",
                        "FIRST_AID", "INSCRIPTION", "JEWELCRAFTING", "LEATHERWORKING", "TAILORING" }
        local formal = { "Alchemy", "Blacksmithing", "Cooking", "Enchanting", "Engineering",
                         "First Aid", "Inscription", "Jewelcrafting", "Leatherworking", "Tailoring" }
        local expac = Env.swap(cls.Expac, function()
            return { VANILLA, VANILLA, VANILLA, VANILLA, VANILLA, VANILLA, WOTLK, TBC, VANILLA, VANILLA } end)
        local instances, internals = Enum(value, {
            __tostring = function(tbl) return tbl.formal  end
        })
        for i = 1, getmetatable(instances)() do
            local e = internals[instances[i]]
            e.formal = formal[i]
            e.expac = expac[i]
        end
        return instances
    end)()

    return Table.read_only(cls)
end)()
