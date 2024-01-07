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


Catalog = function(prof, race, expac, start, target)
    if Type.NUMBER(start) >= Type.NUMBER(target) then
        Error.ILLEGAL_ARGUMENT(ADDON_NAME, "Skill [start, target] domain is non-contiguous: ["
                .. tostring(start) .. ", " .. tostring(target) .. "]") end

    local json = prof.load(Expansion.assert_instance(expac))
    local recipes = collect(map(json, (function()
        local i = 0
        return function(_, e) i = i + 1; return i, e end
    end)()))
    local bonus = Race.assert_instance(race).bonus(Profession.assert_instance(prof))

    print("Bonus: ", bonus)
    for k, v in pairs(recipes) do
        print(k, v)
    end
end

Catalog(Profession.ENGINEERING, Race.ORC, Expansion.WOTLK, 1, 450)