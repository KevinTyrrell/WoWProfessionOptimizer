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
    local max_skills = { 450, 375, 300 }
    local formals =  { "Wrath of the Lich King", "The Burning Crusade", "World of Warcraft" }
    local colors = { "74A7D6", "AAD46C", "FCDA2A" }

    return Enum({ "WOTLK", "TBC", "VANILLA" },
            function(instance, members)
        local ordinal = instance.ordinal
        members.max_skill = max_skills[ordinal]
        members.color = colors[ordinal]
        members.formal = formals[ordinal]
    end, { __tostring = function(tbl) return tbl.formal end })
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
    local expansions = Env.swap(Expansion, function()
        return { VANILLA, VANILLA, VANILLA, VANILLA, VANILLA, VANILLA, WOTLK, TBC, VANILLA, VANILLA } end)

    return Enum({ "ALCHEMY", "BLACKSMITHING", "COOKING", "ENCHANTING", "ENGINEERING",
                  "FIRST_AID", "INSCRIPTION", "JEWELCRAFTING", "LEATHERWORKING", "TAILORING" },
            function(instance, members)
        function members.loadable(expac)
            local key = Type.TABLE(expac).name .. "-" .. instance.formal
            return RAW_JSON_DATA[key] ~= nil
        end

        function members.load(expac)
            local key = Type.TABLE(expac).name .. "-" .. instance.formal
            local data = RAW_JSON_DATA[key]
            if data == nil then Error.ILLEGAL_ARGUMENT(ADDON_NAME, "Profession data does not exist: " .. key) end
            return LibParse:JSONDecode(data)
        end

        members.formal = String.to_title_format(instance.name)
        members.expansion = expansions[instance.ordinal]
    end, { __tostring = function(tbl) return tbl.formal end })
end)()


--[[
-- Race Enum
--
-- @field formal [string] Formal name of profession
--
-- @field bonus [function] Determines the race's bonus for a specified profession
-- @param [table] Profession enum instance
-- @return [number] Skill increase bonus given this race/profession combo
]]--
Race = (function()
    local function sentinel() return 0 end
    local func_tbl = collect(map(num_stream(1, 10),
            function(n) return n, sentinel end))
    func_tbl[1] = function(prof) return prof.ordinal == 4 and 10 or 0 end
    func_tbl[2] = function(prof) return prof.ordinal == 8 and 5 or 0 end
    func_tbl[4] = function(prof) return prof.ordinal == 5 and 15 or 0 end

    return Enum({ "BLOOD_ELF", "DRAENEI", "DWARF", "GNOME", "HUMAN",
                  "NIGHT_ELF", "ORC", "TAUREN", "TROLL", "UNDEAD" },
            function(instance, members)
        members.bonus = func_tbl[instance.ordinal]
        members.formal = String.to_title_format(instance.name)
    end, { __tostring = function(tbl) return tbl.formal end})
end)()
