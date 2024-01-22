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

-- Imported standard library functions
local insert, remove, unpack = table.insert, table.remove, table.unpack


Rewinder = function()
    local self = { }

    local history = { } -- Complete timeline of all paritions
    local now = { } -- Events which have occured only in the present
    local depth = 1 -- Number of partitions in the timeline
    local events = 0 -- Number of events in the timeline

    --[[
    -- Advances the timeline, creating a new moment in time
    --
    -- This fuction controls how historical events are partitoned into chunks
    ]]--
    function self.advance()
        now = { } -- Create a new moment in time
        insert(history, now) -- Add this moment to the history
        depth = depth + 1
    end

    --[[
    -- Rewinds the timeline, erasing all present events
    --
    -- This function may only be called if the timeline can be rewound
    ]]--
    function self.rewind()
        if depth == 1 then Error.ILLEGAL_STATE(ADDON_NAME, "Rewinder cannot rewind the timeline past the origin.") end
        for _, e in ipairs(now) do
            local action, payload = unpack(e, 4, 5) -- un-do function, un-do payload
            action(unpack(payload)) -- Formally undo the event
            events = events - 1
        end
        remove(history)
        now = history[1]
        depth = depth - 1
    end

    --[[
    -- Commits an event to history, dictating how it can be un-done
    --
    -- @param object [table] Object which event centered upon
    -- @param action [function] Function in which the action is performed with
    -- @param payload [table] Parameters passed into the action function
    -- @param undo_action [function] Function inw hich the action can be un-done with
    -- @param undo_payload [table] Parameters passed into the un-do function
    ]]--
    function self.commit(object, action, payload, undo_action, undo_payload)
        insert(now, { Type.TABLE(object), Type.FUNCTION(action), Type.TABLE(payload),
                      Type.FUNCTION(undo_action), Type.TABLE(undo_payload) })
        events = events + 1
    end

    --[[
    -- @return [number] Depth of the rewinder
    ]]--
    function self.depth()
        return depth
    end

    --[[
    -- @return [number] Number of recorded events
    ]]--
    function self.events()
        return events
    end

    --[[
    -- Returns a complete history of all events, in order of occurance
    --
    -- Returned timeline will not be partitioned. All events are returned.
    -- Each event is structured as: {
    --      [table] Object which the event centered upon
    --      [function] Action in which was taken upon the object
    --      [table] Parameters passed into the above function
    -- }
    --
    -- @return [table] Compelte history of all events
    ]]--
    function self.timeline()
        local timeline = { }
        local i = events
        for _, chunk in ipairs(history) do
            for _, event in ipairs(chunk) do
                timeline[i] = { unpack(event, 1, 3) }
                i = i - 1
            end
        end
        return timeline
    end
end
