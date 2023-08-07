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

-- All objects must inherit the same metatable in order to be compatible
local object_mt = {
    __metatable = false, -- Lock the metatable
    -- TODO: Finish metatable metamethods
}

--[[
-- Enforces the metatable contains only expected & supported meta-methods
--
-- The following meta-methods are forbidden:
-- * __metatable: User is not allowed to access the metatable directly
-- * __index: Already in-use. TODO: It is technically possible to implement this in a round-about way
-- * __newindex: Already in-use. TODO: It is technically possible to implement this in a round-about way
-- * __mode: No benefit can be gained as the object's exposed table is always empty
--
-- @param [table] Metatable to be validated
-- @return [table] Metatable instance
-- @raise ILLEGAL_ARGUMENT if the metatable violates the terms above
]]--
local validate_mt = (function()
    local valid_mt_methods = Table.set("__add", "__sub", "__mul", "__div", "__mod",
            "__pow", "__unm", "__concat","__eq", "__lt", "__le", "__call", "__tostring")
    return function(mt)
        for_each(Type.TABLE(mt), function(k, v)
            Type.FUNCTION(v)
            if not valid_mt_methods[Type.STRING(k)] then
                Error.ILLEGAL_ARGUMENT(ADDON_NAME, "Invalid meta-table method: " .. k) end
        end)
        return mt
    end
end)()

--[[
--
]]--
function class(public, private, protected, metatable)
    local pub, priv, prot, meta = { }, { }, { }, { }
    local self = { } -- Class instance

    function self.subclass(_public, _private, _protected, _metatable)
    end

    --[[
    to-be checked when new members are added

    * Base Class:
        * Public:
            check private & protected table
        * Private:
            N/A
        * Protected:
            N/A
    * Derived Class:
        * Public:
            check private, protected, and superclass public & protected tables
        * Private:
            check superclass public & protected tables
        * Protected:
            check superclass public & protected tables
    ]]--


    --[[

    class Creature
        pub { }
        prot { }
        priv { }

    class Person
        pub {
             index = Creature.pub        }
        prot { }, {
          }
        priv { }, {
            index =
        }

    class Student

    * ALL members must be defined in object's constructor



    ]]--








    local priv = { mode = "k" } -- Weak table
    local prot = { mode = "k" } -- Weak table
    local subclasses = { }

    --[[
    -- @param instance [table] Instance of this class
    -- @return [table] Private members of the specified instance
    ]]--
    local function private(instance)
        local t = private[Type.TABLE(instance)]
        if t == nil then
            Error.ILLEGAL_ARGUMENT(ADDON_NAME, "Table is not an instance of this class.") end
        return t
    end

    --[[
    -- Associates read-only objects with their internal member tables
    --
    -- Weak table, as to not memory leak objects instead of GC
    ]]--
    local instances = { mode = "k" } -- Weak table holding instances of this class

    function cls.instance()

    end

    --[[
    -- @param obj [table] Object to check
    -- @return [boolean] True if the table is an object of this class
    ]]--
    function cls.is_instance(obj)
        return instances[Type.TABLE(obj)] ~= nil
    end
end