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

setfenv(1, select(2, ...)) -- Change environment

-- Import libraries
local Addon = LibStub("AceAddon-3.0"):NewAddon("WoWProfessionOptimizer", "AceConsole-3.0")



data = { } -- Prepare table for loaded JSON data

function Addon:OnInitialize()
    print("OnInitialize")
end
