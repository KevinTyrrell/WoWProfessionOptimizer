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
local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local LibLogger = LibStub("LibLogger")

-- Setup addon table
Addon = AceAddon:NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0")
Logger = LibLogger:New() -- Logger made now, attach to 'SavedVariables' later on
Logger:SetSeverity(LibLogger.SEVERITY.TRACE)
Logger:SetPrefix(ADDON_NAME)
Profession = { } -- Prepare table for loaded JSON data

-- Called when the addon is completely initialized
function Addon:OnInitialize()
    AceDB = AceDB:New(ADDON_NAME .. "DB")
    local logger_db = { }
    AceDB.global.logger = logger_db -- Delete
    Logger:SetDatabase(logger_db)
    Logger:Info("Addon Initialized.")
end
