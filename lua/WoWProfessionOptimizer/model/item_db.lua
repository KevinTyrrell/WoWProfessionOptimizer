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
local GetItemInfo = GetItemInfo

local EVENT_ITEM_INFO = "GET_ITEM_INFO_RECEIVED"

-- Parses GetItemInfo's payload, discarding excess information
local function item_info_to_record(info)
    Type.TABLE(info)
    return {
        name = Type.STRING(info[1]),
        link = Type.STRING(info[2]),
        quality = Type.NUMBER(info[3]),
        stack = Type.NUMBER(info[8]),
        texture_id = Type.NUMBER(info[10]),
        sell = Type.NUMBER(info[11])
    }
end


ItemDB = (function()
    local self = { }

    local db = { } -- Map[item_id, item_info]
    local waiting = { } -- Set[item_id]
    local num_waiting = 0 -- # of items waiting for server to reply with

    function Addon:GET_ITEM_INFO_RECEIVED(_, item_id, success)
        if success == nil or item_id == nil then return end -- Should never happen?
        if waiting[item_id] == true then
            waiting[item_id] = nil
            num_waiting = num_waiting - 1
            if success == true then
                Logger:Message("Item [%d] removed from queue. Currently [%d] items waiting.", item_id, num_waiting)
                if num_waiting <= 0 then
                    Logger:Message("Unsubscribing to [%s] for item [%d]", EVENT_ITEM_INFO, item_id)
                    Addon:UnregisterEvent(EVENT_ITEM_INFO) end
                local info = item_info_to_record({ GetItemInfo(item_id) }) -- should be safe
                db[item_id] = info
            else Logger:Message("Item [%d] DNE. Now [%d] items waiting.", item_id, num_waiting) end
        end
    end

    function self.get_item(item_id)
        local info = db[Type.NUMBER(item_id)]

        if info == nil then
            local payload = { GetItemInfo(item_id) }
            if payload[1] == nil then -- Response was nil, wait for server to reply
                if waiting[item_id] == true then
                    return Logger:Message("Item [%d] already in waiting list.", item_id) end
                waiting[item_id] = true
                if num_waiting <= 0 then
                    Logger:Message("Subscribing to [%s] for item [%d]", EVENT_ITEM_INFO, item_id)
                    Addon:RegisterEvent(EVENT_ITEM_INFO) end
                num_waiting = num_waiting + 1
                Logger:Message("Item [%d] added to queue. Currently [%d] items waiting.", item_id, num_waiting)
                return nil -- Item info unavilable
            else
                info = item_info_to_record(payload)
                db[item_id] = info
            end
        end

        return info
    end

    function self.waiting()
        return waiting
    end

    return Table.read_only(self)
end)()

_G.t = ItemDB
