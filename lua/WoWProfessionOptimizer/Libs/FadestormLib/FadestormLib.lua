--[[
--    Copyright (C) 2023 Fadestorm-Faerlina (Discord: hatefiend)
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

-- LibStub library library initialization
local ADDON_NAME = "FadestormLib"
local MAJOR, MINOR = ADDON_NAME .. "-6.0", 1
if not LibStub then return end
local FSL = LibStub:NewLibrary(MAJOR, MINOR)
if not FSL then return end -- Newer or same version is already loaded
local env = setmetatable({ _G = _G },
		{
			__newindex = FSL,
			__index = (function()
				local _G = _G
				return function(_, key)
					local v = FSL[key] -- Check FSL table first
					if v == nil then -- Check global table second
						v = _G[key] end
					return v
				end
			end)(),
			__metatable = false
		})
setfenv(1, env) -- Switch environment to FSL

-- Imported standard library functions
local upper, lower, format = string.upper, string.lower, string.format

-- Forward declarations for circular function dependencies
local Type = {
	TABLE = setmetatable({}, { __call = function(_, x) return x end }),
	STRING = setmetatable({}, { __call = function(_, x) return x end }),
	FUNCTION = setmetatable({}, { __call = function(_, x) return x end })
}
local Error = {
	TYPE_MISMATCH = setmetatable({}, { __call = function() end }),
	UNSUPPORTED_OPERATION = setmetatable({}, { __call = function() end }),
}

--[[
-- Constructs a new meta-table, creating a read-only table when set as a metatable
--
-- TODO: Replace other read-only MT functions using this helper function
--
-- @param [meta_methods] [table] (Optional) Meta-methods to be copied into the resulting meta table
-- @return [table] Read-only meta-table
]]--
local init_read_only_mt = (function()
	local function read_only_error()
		Error.UNSUPPORTED_OPERATION(ADDON_NAME, "Ready-only table cannot be modified.") end
	return function(meta_methods)
		local mt = {
			__newindex = read_only_error,
			__metatable = false, -- Protect metatable
		}
		if meta_methods ~= nil then
			for k, v in pairs(meta_methods) do -- Add any meta method that isn't already reserved
				if mt[k] == nil then mt[k] = v end end
		end
		return mt
	end
end)()

local read_only_meta_table = (function()
	local function __newindex()
		Error.UNSUPPORTED_OPERATION(ADDON_NAME, "Ready-only table cannot be modified.") end
	return function(private)
		return {
			__newindex = __newindex, -- Reject any mutations to the read-only table
			-- Redirect lookups to the private table without exposing the table itself
			__index = function(_, index) return private[index] end,
			-- Prevent access to the metatable but work-around for Lua 5.1 no '__len' metamethod
			__metatable = function() return #private end
		}
	end
end)()


local __Table = (function()
	local self = { }

	--[[
	-- Constructs a read-only view into a private table
	--
	-- Read-only tables cannot be modified.
	-- An error will be thrown upon __newindex being called.
	-- Read-only tables do not support the length operator '#' (Lua 5.1 limitation)
	-- Calling 'getmetatable(...)' will retrieve the length of the underlying table.
	--
	-- Meta-methods may be provided in order to further customize the read-only table.
	-- '__metatable', '__index', and '__newindex' meta-methods are ignored.
	--
	-- @param private [table] Map of fields
	-- @param metamethods [table] (optional) Metamethods to be included into the table
	-- @return [table] Read-only variant of the private table
	]]--
	function self.read_only(private, metamethods)
		local mt = read_only_meta_table(Type.TABLE(private))
		if metamethods ~= nil then -- User wants additional meta-methods included
			for k, v in pairs(Type.TABLE(metamethods)) do
				if mt[k] == nil then -- Existing meta-methods cannot be overwritten
					mt[k] = v end end
		end
		return setmetatable({}, mt)
	end

	--[[
	-- Associates the key with the default value, if said key has no existing pairing, then returns the current value
	--
	-- @param tbl [table] Table to query
	-- @param key [?] Key of the pairing
	-- @param default_value [?] Value to be paired if the key is not present
	-- @return [?] Resulting value of the key-value pairing
	]]--
	function self.put_default(tbl, key, default_value)
		local v = Type.TABLE(tbl)[key]
		if v == nil then
			tbl[key] = default_value
			return default_value end
		return v
	end

	--[[
	-- Associates the key with a computed value, if said key has no existing pairing, then returns the current value
	--
	-- @param tbl [table] Table to query
	-- @param key [?] Key of the pairing
	-- @param computer [function] Value to be paired if the key is not present
	-- @return [?] Resulting value of the key-value pairing
	]]--
	function self.put_compute(tbl, key, computer)
		local v = Type.TABLE(tbl)[key]
		if v == nil then
			v = Type.FUNCTION(computer)(key)
			tbl[key] = v
		end
		return v
	end

	--[[
	-- Constructs a set of specified values
	--
	-- Each value of the set is associated with boolean 'true'
	--
	-- @param [varargs] Values of the set
	-- @return [table] Set of values
	]]--
	function self.set(...)
		local t = { }
		for _, e in ipairs({ ... }) do
			t[e] = true end
		return t
	end

	--[[
	-- Sorts a table, using a custom comparator
	--
	-- Implementation uses a 2-partition Quicksort
	--
	-- @param tbl [table] Table to be sorted
	-- @param comparator [function] Compares two elements, returning domain [-1, 1]
	]]--
	self.sort = (function()
		local function swap(tbl, i, j) -- Swaps two indexes of a table
			local temp = tbl[i] tbl[i] = tbl[j] tbl[j] = temp end

		local function part(tbl, comparator, a, b)
			local pivot = tbl[b] -- Pivot is always the right-hand element
			local wall = a - 1 -- Divides the table into partitions

			for i = a, b - 1 do -- Don't iterate on the pivot
				if Type.NUMBER(comparator(tbl[i], pivot)) <= 0 then
					wall = wall + 1
					swap(tbl, wall, i) -- Add element to left partition
				end
			end

			wall = wall + 1
			swap(tbl, wall, b) -- Place pivot in its solved index
			return wall
		end

		local function quick(tbl, comparator, a, b)
			if a < b then -- Table is not yet sorted
				local pivot = part(tbl, comparator, a, b)
				quick(tbl, comparator, a, pivot - 1)
				quick(tbl, comparator, pivot + 1, b)
			end
		end

		return function(tbl, comparator)
			quick(Type.TABLE(tbl), Type.FUNCTION(comparator), 1, #tbl)
		end
	end)()

	return self
end)() Table = __Table.read_only(__Table)


--[[
-- Defines an enumeration
--
-- Enum Class Members
-- =======================
-- * size [number]: Number of declared enumeration constants
-- * Enum constants access [i] , where `i` is the ordinal of the constant
-- * Enum constants access s, where `s` is the identifier of the constant
--
-- Enum Constants Members
-- =======================
-- * ordinal [number]: Position of the instance within the enum's natural order
-- * name [string]: Name of the enum constant, automatically capitalized
-- * function __lt(value): Returns `true` if the instance's ordinal is lesser
-- * function __lte(value): Returns `true` if the instance's ordinal not greater
-- * function __tostring(): Returns the string representation of the instance
--
-- @param values [table] Constants (strings) of the enum
-- @param callback [function] Constructor for each enum instance
-- @param [meta_methods] [table] (Optional) Meta-methods to attach to instances
-- @return [table] Enum read-only class members
-- @return [table] Enum mutable class members
]]--
function Enum(values, callback, meta_methods)
	local cls_members = { } -- Entry point to declare and mutate class members
	-- Class members which cannot be overridden
	local cls_reserved = setmetatable({
		size = #Type.TABLE(values) -- Number of enumeration instances
	}, { __index = cls_members })
	local cls_read_only = setmetatable({ }, init_read_only_mt({
		__index = cls_reserved -- Defer all searching to the reserved members table
	}))

	local ro_to_reserved = { } -- Map[Read Only Table] --> Reserved Table
	for ordinal, name in ipairs(Type.TABLE(values)) do
		name = upper(Type.STRING(name))
		local reserved = { -- Instance members which cannot be overridden
			ordinal = ordinal,
			name = name
		}
		local ro_instance = { } -- Create a read-only entry point into the instance

		ro_to_reserved[ro_instance] = reserved -- Needed for __index in instance meta-table
		cls_reserved[name] = ro_instance -- Allow name -> Enum Instance queries
		cls_reserved[ordinal] = ro_instance -- Allow ordinal -> Enum Instance queries
	end

	local instance_mt = init_read_only_mt({ -- -- Shared among all instances of the Enum
		__lt = function(t1, t2) return t1.ordinal < t2.ordinal end,
		__lte = function(t1, t2) return t1.ordinal <= t2.ordinal end,
		__tostring = function(tbl) return tbl.name end
	})

	if meta_methods ~= nil then -- Optional param, allow user to declare their own meta-methods
		for meta_method, func in pairs(Type.TABLE(meta_methods)) do
			instance_mt[meta_method] = Type.FUNCTION(func) end end
	instance_mt.__index = function(instance, key) -- All instances share meta-table, so perform a lookup on-the-fly
		return ro_to_reserved[instance][key] end -- Defer searching to the reserved table

	Type.FUNCTION(callback)
	for ordinal in ipairs(values) do
		-- Ensure all instances of the enum share the same meta-table
		local read_only = setmetatable(cls_reserved[ordinal], instance_mt)
		local members = { } -- Allows defining of members for the enum instance
		setmetatable(ro_to_reserved[read_only], {
			__index = members -- Defer searching to the members table if key not found
		})
		callback(read_only, members) -- Pseudo constructor for the user to define members
	end

	return cls_read_only, cls_members
end


--[[
-- Type Enum
--
-- Type Constants
-- =======================
-- * Type.NIL: Represents a nil value.
-- * Type.STRING: Represents a string.
-- * Type.BOOLEAN: Represents a boolean.
-- * Type.NUMBER: Represents a number.
-- * Type.FUNCTION: Represents a function.
-- * Type.USERDATA: Represents userdata.
-- * Type.THREAD: Represents a thread.
-- * Type.TABLE: Represents a table.
--
-- Type Constants Members
-- =======================
-- * type [string]: Type of the enum, same value as returned by Lua's type() function
-- * function match(value): Returns `true` if the type of the parameter matches the instance's type
-- * function __call(value): Type instances override `__call`
--   * @param value [?] Value to be type-checked
--   * @return [?] Value which was passed-in
--   * @error TYPE_MISMATCH If the parameter's type does not match the instance
--
]]--
Type = Enum({ "NIL", "STRING", "BOOLEAN","NUMBER", "FUNCTION", "USERDATA", "THREAD", "TABLE" },
		function(instance, members)
			members.type = lower(instance.name)

			function members.match(value) return members.type == type(value) end
		end, {
			__call = function(tbl, value)
				if tbl.type ~= type(value) then Error.TYPE_MISMATCH(ADDON_NAME,
						"Received " .. type(value) .. ", Expected: " .. tbl.type) end
				return value
			end
		})
FSL.Type = Type -- Mandatory because 'Type' was pre-declared


--[[
-- Error Enum
--
-- Defines an error throwing interface
--
-- Supported error constants are as follows:
--
-- [*] UNSUPPORTED_OPERATION : Function is not supported or implemented
-- [*] TYPE_MISMATCH : Function was provided with unexpected types
-- [*] NIL_POINTER : Expected non-nil reference was nil
-- [*] ILLEGAL_ARGUMENT : Function argument was not within expected bounds
-- [*] ILLEGAL_STATE : Function cannot continue left in its current state
--
-- __call meta-method
-- Throws an error to the chat window and error frame
-- @param source [string] Source name of the error (addon, weak aura, macro, etc)
-- @param msg [string] Message providing details of the error
]]--
Error = (function()
	local src_color, msg_color = "ECBC2A", "FF0000" -- Gold, Red

	local c_ret, c_prefix = "\124r", "\124cFF" -- \124 => '|', cFF => 100% Opacity
	src_color, msg_color = c_prefix .. src_color, c_prefix .. msg_color

	local values = { "UNSUPPORTED_OPERATION", "TYPE_MISMATCH", "NIL_POINTER", "ILLEGAL_ARGUMENT", "ILLEGAL_STATE" }
	local formals =  { "Unsupported Operation", "Type Mismatch", "Nil Pointer", "Illegal Argument", "Illegal State" }
	-- e.g. "[FadestormLib] Type Mismatch: Expected String, Received Number"
	local ERROR_FMT = c_ret .. "[" .. src_color .. "%s" .. c_ret .. "] %s: " .. msg_color .. "%s" .. c_ret

	local instances, internals = Enum(values, {
		__tostring = function(tbl) return tbl.formal end,
		__call = function(tbl, source, msg)
			msg = format(ERROR_FMT, Type.STRING(source), tostring(tbl), Type.STRING(msg))
			print(msg) error(msg)
		end
	})

	for i = 1, getmetatable(instances)() do
		local instance = instances[i]
		local e = internals[instance]
		e.formal = formals[i]
	end
	return instances
end)() FSL.Error = Error -- Mandatory because 'Error' was pre-declared


--[[
-- Ensures a specified parameter is non-nil
--
-- An argument whose value is nil will result in an NIL_POINTER error
--
-- TODO: Determine if this should go into Type
--
-- @param [?] x Parameter to check
-- @return [?] x
]]--
function req_non_nil(x)
	if x == nil then
		Error.NIL_POINTER(ADDON_NAME, "Required non-nil argument was nil") end
	return x
end


--[[
-- Color Enum
--
-- Defines a text color interface (enum constants found below)
--
-- Determines the complementary color of a specified color hex string
--
-- __call meta-method
-- Wraps the specified string with the color
-- @param value [string] String to be colored
-- @return [string] Colored string
--
-- complement method
-- @return [string] Hex color which is a complement of the color
]]--
Color = (function()
	local C_NAMES = {
		"WARRIOR", "WARLOCK", "SHAMAN", "ROGUE", "PRIEST", "PALADIN", "MAGE", "HUNTER", "DRUID", "DEATHKNIGHT", -- Class
		"CHANNEL", "SYSTEM", "GUILD", "OFFICER", "PARTY", "SAY", "WHISPER", "YELL", "EMOTE", "RAID", "RAIDW", "BNET", -- Chat
		"POOR", "COMMON", "UNCOMMON", "RARE", "EPIC", "LEGENDARY", "HEIRLOOM", -- Item Quality
		"WHITE", "BLACK", "RED", "BLUE", "YELLOW", "GREEN", "ORANGE", "PURPLE", "AMBER", "VERMILLION", "MAGENTA", "VIOLET", "TEAL", "CHARTREUSE", -- Wheel
	}
	local C_CODES = {
		"C69B6D", "8788EE", "0070DD", "FFF468", "FFFFFF", "F48CBA", "3FC7EB", "AAD372", "FF7C0A", "C41E3A", -- Class
		"FEC1C0", "FFFF00", "3CE13F", "40BC40", "AAABFE", "FFFFFF", "FF7EFF", "FF3F40", "FF7E40", "FF7D01", "FF4700", "00FAF6", -- Chat
		"889D9D", "FFFFFF", "1EFF0C", "0070FF", "A335EE", "FF8000", "E6CC80", -- Item Quality
		"FFFFFF", "000000", "FF0000", "0000FF", "FFFF00", "00FF00", "FFA500", "A020F0", "FFBF00", "E34234", "FF00FF", "8F00FF", "008080", "7FFF00", -- Wheel
	}

	local Color, private = Enum(C_NAMES,
			{
				__call = function(tbl, value)
					return "|cFF" .. tbl.code .. Type.STRING(value) .. "|r"
				end,
				__tostring = function(tbl)
					return "|cFF" .. tbl.code .. tbl.name .. "|r"
				end
			})

	for i = 1, getmetatable(Color)() do
		local c, h = Color[i], C_CODES[i]
		private[c].code = h
		private[c].complement = function()
			-- '%X' Converts to hex. '16777215'b10 = FFFFFFb16. FFFFFF-Color=Complement Color.
			return format('%X', 16777215 - tonumber(h, 16)) end
	end

	return Color
end)()


--[[
-- ==========================
-- ======= Stream API =======
-- ==========================
]]--

local function stream(iterable) -- Helper function
	return Type.TABLE.match(iterable) and next or Type.FUNCTION(iterable)
end


--[[
-- Filters an iterable stream, iterating over a designated subset of elements
--
-- @param iterable [table][function] Stream in which to iterate
-- @param callback [function] Callback filter function
-- @return [function] Iterator
]]--
function filter(iterable, callback)
	Type.FUNCTION(callback)
	local iterator = stream(iterable)
	local key -- Iterator key parameter cannot be trusted due to key re-mappings
	return function()
		local value
		repeat key, value = iterator(iterable, key)
		until key == nil or callback(key, value) == true
		return key, value
	end
end


--[[
-- Maps an iterable stream, translating elements into different elements
--
-- @param iterable [table][function] Stream in which to iterate
-- @param callback [function] Callback mapping function
-- @return [function] Iterator
]]--
function map(iterable, callback)
	Type.FUNCTION(callback)
	local iterator = stream(iterable)
	local key -- Iterator key parameter cannot be trusted due to key re-mappings
	return function()
		local value
		key, value = iterator(iterable, key)
		if key ~= nil then return callback(key, value) end
	end
end


--[[
-- Merges two iterable streams together
--
-- The resulting combined stream will have the same
-- number of elements as the largest of the two streams.
-- Streams of mismatched sizes can be merged but will partially yield
-- nil for the callback key/value parameters of the smaller stream.
--
-- @param iter1 [table][function] Stream in which to iterate
-- @param iter2 [table][function] Stream in which to iterate
-- @param callback [function] Callback mapping function: (k1,v1,k2,v2) --> (key,value)
-- @return [function] Iterator
]]--
function merge(iter1, iter2, callback)
	Type.FUNCTION(callback)
	local i1 = stream(iter1)
	local i2 = stream(iter2)
	local iterator, k1, v1, k2, v2

	local function yield_left()
		k1, v1 = i1(iter1, k1)
		return k1 end
	local function yield_right()
		k2, v2 = i2(iter2, k2)
		return k2 end
	-- Pull elements from both streams, or switch to just one
	iterator = function()
		k1, v1 = i1(iter1, k1)
		k2, v2 = i2(iter2, k2)
		if k1 ~= nil and k2 == nil then
			iterator = yield_left
		elseif k2 ~= nil and k1 == nil then
			iterator = yield_right
			return k2 -- k1 is nil, return k2 so iteration continues
		end
		return k1
	end

	return function()
		if iterator() then -- Callback only if another element exists
			return callback(k1, v1, k2, v2) end
	end
end


-- Helper function for iterating through streams
local function explore(iterable)
	local iterator = stream(iterable)
	local key, value
	return function()
		key, value = iterator(iterable, key)
		if key ~= nil then return key, value end
	end
end


--[[
-- Creates an additional dimension of the stream, then flattens it into one stream
--
-- @param [table][function] Stream in which to iterate
-- @param [function] Callback function which defines a new stream dimension per element.
				The callback should invoke a new stream, per element of the original stream.
				The returned value should be a new stream. See @usage below for an example.
				@param key [?] Key of the key/value pair currently being streamed
				@param value [?] Value of the key/value pair currently being streamed
				@return [table][function] Stream
-- @return [function] Stream
--
-- @usage
-- local function callback(key, value) -- e.g. `value` is a table
		-- Create a new stream for every single element of the original stream
		return map(value, function(k, v) return k .. v, true end)
-- end
]]--
function flat_map(iterable, callback)
	local outer = explore(iterable)
	local k, v = outer()
	if k == nil then return function()end end -- Stream was empty
	local inner = explore(Type.FUNCTION(callback)(k, v))

	return function()
		while true do
			k, v = inner()
			if k == nil then
				k, v = outer() -- Stream exhausted, move to the next inner stream
				if k == nil then return end -- All inner streams exhausted
				inner = explore(callback(k, v))
			else return k, v end
		end
	end
end


--[[
-- Peeks an iterable stream, viewing each element
--
-- @param iterable [table][function] Stream in which to iterate
-- @param callback [function] Callback peeking function
-- @return [function] Iterator
]]--
function peek(iterable, callback)
	Type.FUNCTION(callback)
	local iterator = stream(iterable)
	local key -- Iterator key parameter cannot be trusted due to key re-mappings
	return function()
		local value
		key, value = iterator(iterable, key)
		if key ~= nil then
			callback(key, value)
			return key, value
		end
	end
end


--[[
-- Constructs an iterable stream of numbers
--
-- If no step is provided, step increment defaults to 1.
-- For positive steps, start <= stop must be true.
-- For negative steps, start >= stop must be true.
-- Steps of zero will result in an exception being thrown.
--
-- TODO: Appears to fail on decrementing number streams
--
-- @param start [number] Starting number (inclusive) to iterate
-- @param stop [number] Stopping number (inclusive) to iterate to
-- @param step [number] (optional) Amount to step by each iteration
-- @return [function] Iterator
]]--
function num_stream(start, stop, step)
	if step ~= nil then
		if Type.NUMBER(step) == 0 then
			Error.ILLEGAL_ARGUMENT(aura_env.id, "Number stream step must be non-zero") end
	else step = 1 end
	-- Seemingly decent way to check for valid range params
	if (Type.NUMBER(start) - Type.NUMBER(stop)) / step > 0 then
		Error.ILLEGAL_ARGUMENT(aura_env.id, "Number stream does not terminate: start=" ..
				tostring(start) .. ", stop=" .. tostring(stop) .. ", step=" .. tostring(step))
	end
	return function() -- Simple iterator function
		if start > stop then return nil end
		local v = start
		start = start + step
		return v, v
	end
end


--[[
-- Collects an iterator stream into a table
--
-- Collect is a terminating stream operation.
-- The stream is closed and no further stream operations are applicable.
-- The resulting table can be used for additional operations, however
-- doing so would be inefficient due to table overhead; use 'peek' instead.
--
-- This function doubles as a 'unique' stream call, eliminating duplicates.
--
-- @param iterable [table][function] Stream in which to iterate
-- @return [table] Elements of the stream
]]--
function collect(iterable)
	local iterator = stream(iterable)
	local tbl = { }
	local key, value
	while true do
		key, value = iterator(iterable, key)
		if key == nil then break end
		tbl[key] = value
	end
	return tbl
end


--[[
-- Iterates through elements of a stream
--
-- For-each is a terminating stream operation.
-- The stream is closed and no further stream operations are applicable.
--
-- @param iterable [table][function] Stream in which to iterate
-- @param callback [function] Callback for-each function
]]--
function for_each(iterable, callback)
	Type.FUNCTION(callback)
	local iterator = stream(iterable)
	local key, value
	while true do
		key, value = iterator(iterable, key)
		if key == nil then break end
		callback(key, value)
	end
end


--[[
-- Sorts the elements of the stream
--
-- Sort is a terminating stream operation.
-- The stream is closed and no further stream operations are applicable.
--
]]--
function sorted(iterable, comparator, callback)
	Type.FUNCTION(callback)
	local t = collect(iterable)
	Table.sort(t, Type.FUNCTION(comparator))
	return t
end
