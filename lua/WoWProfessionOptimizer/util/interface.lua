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


--[[
-- Defines a new interface, declaring a contract
--
-- TODO:
]]--
Interface = function(contract, mt)
    contract = collect(map(Type.TABLE(contract), function(_, e)
        return Type.STRING(e), true end)) -- Set

    local private = { } -- Members of the interface, editable but not iterable by the user

    local default_mt = {
        __metatable = false, -- Hide metatable
        __newindex = function(_, k, v) private[k] = v end,
        __index = function(_, key)
            local func = private[key]
            if contract[key] then -- Check if key is associated with an interface contract
                if func == nil then Error.UNSUPPORTED_OPERATION(ADDON_NAME,
                        "Interface member was not implemented: " .. Type.STRING(key))
                else Type.FUNCTION(func) end -- Ensure contract leads to a function
            end
            return func
        end
    }

    if mt ~= nil then
        for_each(Type.TABLE(mt), function(k, v)
            if default_mt[k] then
                Error.ILLEGAL_STATE(ADDON_NAME, "Interface metamethod is reserved: " .. k) end
            default_mt[k] = Type.FUNCTION(v)
        end)
    end

    return setmetatable({ }, default_mt)
end
