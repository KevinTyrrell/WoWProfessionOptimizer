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

local ADDON_NAME, WSO = ...
--local lib = LibStub("LibParse")
local FSL = LibStub("FadestormLib-5.1")


--local s = '[{"name":"Rough Blasting Powder","levels":[1,1,20,30,40],"reagents":{"2835":1},"product":4357}]'
--local u = lib:JSONDecode(s)
--print(u)
--print(u[1]["levels"][3])

--print(WSO.data["WOTLK-Engineering"])
--local t = lib:JSONDecode(WSO.data["WOTLK-Engineering"])
--print(t)

local t = { 14, 47, 86, 71, 5, 18, 10, 62, 19, 0, 34 }
local function cmp(a, b)
    print("waffle", a, b)
    if a < b then return -1 end
    return a > b and 1 or 0
end

FSL.Table.sort(t, cmp)
local s = ""
for i, e in ipairs(t) do
    if i ~= 1 then s = s .. ", " end
    s = s .. tostring(e)
end
print(s)

