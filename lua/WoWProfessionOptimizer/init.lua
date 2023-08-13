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
local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local LibLogger = LibStub("LibLogger")

-- Setup addon table
addon = AceAddon:NewAddon(ADDON_NAME, "AceConsole-3.0")
logger = LibLogger:New() -- Logger made now, attach to 'SavedVariables' later on
logger:SetSeverity(LibLogger.SEVERITY.TRACE)
logger:SetPrefix(ADDON_NAME)
data = { } -- Prepare table for loaded JSON data

-- Called when the addon is completely initialized
function addon:OnInitialize()
    AceDB = AceDB:New(ADDON_NAME .. "DB")
    local logger_db = { }
    AceDB.global.logger = logger_db
    logger:SetDatabase(logger_db)
    logger:Info("Addon Initialized.")
end
