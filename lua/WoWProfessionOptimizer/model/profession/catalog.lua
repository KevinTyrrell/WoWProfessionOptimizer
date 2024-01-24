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


-- Caches all items into the item database
-- Returns Map[item_id, List[Recipe]]
local function load_craftables(recipes)
end


Catalog = function(prof, race, expac, start, target)
    if Type.NUMBER(start) >= Type.NUMBER(target) then
        Error.ILLEGAL_ARGUMENT(ADDON_NAME, "Skill domain is non-contiguous: [", start, ",", target, "]") end
    local json = prof.load(Expansion.assert_instance(expac))
    local recipes = collect(map(json, function(k, v)
        return k, Recipe(v) end))
    local bonus = Race.assert_instance(race).bonus(Profession.assert_instance(prof))

    print("Bonus: ", bonus)
    for i = 1, 3 do
        print(recipes[i])
    end
end

Catalog(Profession.ENGINEERING, Race.GNOME, Expansion.WOTLK, 1, 450)
