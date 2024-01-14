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


local huge = math.huge -- Used as 'infinity' (unlimited)

--[[
-- Limiter class
--
-- Constructs a limiter instance which dictates whether recipes are permitted to be crafted
--
-- @param recipes [table] List of all recipe instances available
-- @param forbidden [table] List of recipes which are not permitted to be crafted
-- @param restricted [table] Table of recipes, corresponding to their craft limit
]]--
Limiter = function(recipes, forbidden, restricted)
    forbidden = Table.set(Type.TABLE(forbidden)); Type.TABLE(restricted)
    recipes = collect(map(filter(Type.TABLE(recipes),
            function(_, e) return not forbidden[Type.TABLE(e)] end), -- Filter
    function(_, e)
        local limit = restricted[e]
        if limit == nil then return e, huge end -- Unlimited crafts allowed
        if Type.NUMBER(limit) <= 0 then Error.ILLEGAL_STATE(ADDON_NAME, "Recipe restriction must be positive:", e) end
        return e, limit
    end))

    local self = { }

    --[[
    -- @return [table] List of recipes which are monitored
    ]]--
    function self.recipes()
        local i = 0
        return collect(map(recipes, function(k, v)
            i = i + 1
            return i, k
        end))
    end

    --[[
    -- @param recipe [table] Recipe to check the crafting limit
    -- @param crafts [number] Amount of desired crafts
    -- @return [boolean] True if the crafts of the recipe exceeds the limit
    ]]--
    function self.limited(recipe, crafts)
        local limit = recipes[Type.TABLE(recipe)]
        if limit == nil then Error.ILLEGAL_ARGUMENT(ADDON_NAME, "Uncraftable recipe cannot have a limit:", recipe) end
        if Type.NUMBER(crafts) <= 0 then Error.ILLEGAL_ARGUMENT(ADDON_NAME, "Craft count must be positive:", recipe) end
        return limit - crafts < 0
    end

    --[[
    -- @param recipe [table] Recipe to adjust crafting limit
    -- @param crafts [number] Amount of crafts to confirm or undo
    ]]--
    function self.craft(recipe, crafts)
        local limit = recipes[Type.TABLE(recipe)]
        if limit == nil then Error.ILLEGAL_ARGUMENT(ADDON_NAME, "Uncraftable recipe cannot have a limit:", recipe) end
        if limit == huge then return end -- No adjusting an infinite limit
        local adjusted = limit - Type.NUMBER(crafts)
        if adjusted < 0 then Error.ILLEGAL_ARGUMENT(ADDON_NAME, "Recipe has exceeded its limit:", recipe, adjusted) end
        recipes[recipe] = adjusted
    end

    return self
end
