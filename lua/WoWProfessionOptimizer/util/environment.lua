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

local ADDON_NAME, WPO = ... -- Implicit addon table provided by World of Warcraft

-- Import libraries
local FSL = LibStub("FadestormLib-7.0")

WPO._G = _G -- Maintain reference to the global table just in case
setmetatable(WPO, {
    __index = (function()
        local _G = _G
        return function(_, key)
            local v = FSL[key] -- Check FSL table first
            if v == nil then -- Check global table second
                v = _G[key] end
            return v
        end
    end)(),
    __tostring = function(_) return ADDON_NAME end,
    __metatable = false, -- Metatable protection
})
setfenv(1, WPO)

Env = (function()
    local cls = { }

    --[[
    -- Swaps the environment momentarily inside of a specified callback function
    --
    -- @param env [table] Environment to use as the new global environment for the function
    -- @param callback [function] Callback function
    -- @return Callback function return value(s)
    ]]--
    function cls.swap(env, callback)
        local old_env = getfenv(callback)
        setfenv(Type.FUNCTION(callback), Type.TABLE(env))
        local rval = { callback() }
        setfenv(callback, old_env)
        return unpack(rval)
    end

    return Table.read_only(cls)
end)()
