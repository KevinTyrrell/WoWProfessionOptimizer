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
-- Associates classes with their internal tables
--
-- Key: Class object reference
-- Value: ClassInternals table (see below)
--
-- Note: Base class 'object' is the only class which has `nil` field for super
--
-- @table ClassInternals
-- @field 1 [table] Virtual table of the classes' public members
-- @field 2 [table] Virtual table of the classes' private members
-- @field 3 [table] Virtual table of the classes' protected members
-- @field 4 [table] Reference to the super class
]]--
local cls_internals = { }

local function duplicate_checker(key, tbl_a, tbl_b) -- Used for duplicate name violations
    if rawget(tbl_a, key) ~= nil or rawget(tbl_b, key) ~= nil then
         Error.ILLEGAL_ARGUMENT(ADDON_NAME, "Class already has member defined: " .. tostring(key))
    end
end

--[[
-- Extends an existing class, creating a subclass
--
-- @param [table] Class object to be extended
-- @return [table] Subclass class object
-- @return [table] Non-iterable table for classes' public members
-- @return [table] Non-iterable table for classes' private members
-- @return [table] Non-iterable table for classes' protected members
-- @return [table] Reference to the superclass object TODO: Might need additional access privileges
-- TODO: If class.find_member(key) is implemented, 'super' is essentially extends.find_member(key)
-- TODO: Note that `super` CANNOT be chained together. Therefore `super.super.x` is impossible.
]]--
local function class(extends)
    -- Virtual tables in which class members are actually stored
    local vt_pub, vt_priv, vt_prot = { }, { }, { }

    --[[

    private table index:
        only search private table
    private table newindex
        only mutate private table

    protected table index:
        search our protected table
        differ search to above protected tables





    ]]--

end

--[[
TODO: How to handle the following scenario?
TODO: Class A { protected int x; }  Class B extends A {
TODO:     public static void test(A p1, B p2) {
TODO:       // how to access p1.x ?
TODO:   }
TODO: }

VTABLES
    When extending a class, copy its vtable and use it as the basis for this class.
    Any members which are defined in this class then overrides the existing vtable.
    Calls to super() simply defer searching to the above vtable.

    Private functions are NEVER put into vtables. When searching for an identifier,
    always check the private table first. Then check the classes vtable.

    Every class will have three provides tables. Public, private, and protected. All are empty.
    Each table has a different __index and __newindex, such that its optimized for searching.

    The return values for extending or creating a class are the following:
    * class object reference
    * public table reference
    * private table reference
    * protected table reference

    Class must provide a way to retrieve the furthest class table given a specified object.


]]--
