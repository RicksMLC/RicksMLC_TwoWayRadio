-- -- Experimental code: Trying to show the radio scripts when the radio is on the belt.
-- -- The radios do not show the radio script when the radio is on the belt, so this script
-- -- simulates it by reading the current script and displaying it like the radio does.

-- -- FIXME: The OnTick() seems to be running before the RadioScriptManager is populated with the radio stations.


-- RicksMLC_RadioOnInHotbar = {}

-- RicksMLC_RadioOnInHotbar.checkChannels = {}

-- function RicksMLC_RadioOnInHotbar.OnTick()

--     for freq, checkChannel in RicksMLC_RadioOnInHotbar.checkChannels do
--         if checkChannel.isListening then
--             local airingBroadcast = checkChannel.radioChannel:getAiringBroadcast()
--             if airingBroadcast then
--                 local lastRadioLine = checkChannel.radioChannel:getLastAiredLine()
--                 if checkChannel.lastLine ~= lastRadioLine then
--                     DebugLog.log(DebugType.Mod, "RicksMLC_RadioOnInHotbar.OnTick() " .. lastRadioLine)
--                     checkChannel.lastLine = lastRadioLine
--                 end
--             else
--                 -- The broadcast has ended.
--                 Events.OnTick.Remove(RicksMLC_RadioOnInHotbar.OnTick)
--                 subscribeToOnTick = false
--             end
--         end
--     end
--     -- No match
--     Events.OnTick.Remove(RicksMLC_RadioOnInHotbar.OnTick)
--     subscribeToOnTick = false
-- end

-- local subscribeToOnTick = false
-- function RicksMLC_RadioOnInHotbar.OnEveryHours()
    
--     local hotbar = getPlayerHotbar(getPlayer():getPlayerNum())
--     if not hotbar then return end

--     local radioScriptManager = RadioScriptManager.getInstance()
--     if not radioScriptManager then return end

--     DebugLog.log(DebugType.Mod, "RicksMLC_RadioOnInHotbar.OnEveryHour()")

--     RicksMLC_RadioOnInHotbar.checkChannels = {}
--     local channelList =  radioScriptManager:getChannelsList()
--     for i = 0, channelList:size()-1 do
--         local channel = channelList:get(i)
--         DebugLog.log(DebugType.Mod, "    Channel: " .. channel:GetName() .. " " .. tostring(channel:GetFrequency()))
--         if not channel:IsTv() and not channel:GetPlayerIsListening() then
--             RicksMLC_RadioOnInHotbar.checkChannels[channel:GetFrequency()] = {radioChannel = channel, isListening = false,  isChecked = false}
--         end
--     end

--     subscribeToOnTick = false
--     for i, item in pairs(hotbar.attachedItems) do
--         if instanceof(item, "Radio") then
-- 		    local slot = hotbar.availableSlot[item:getAttachedSlot()];
-- 		    local slotIndex = item:getAttachedSlot();
--             if item:getDeviceData():getIsTurnedOn() then
--                 DebugLog.log(DebugType.Mod, "   Hotbar Radio: " .. tostring(item:getDeviceData():getChannel()))
--                 local checkChannel = RicksMLC_RadioOnInHotbar.checkChannels[item:getDeviceData():getChannel()]
--                 if checkChannel and not checkChannel.isChecked then
--                     DebugLog.log(DebugType.Mod, "    SetPlayerIsListening(true)")
--                     checkChannel.radioChannel:SetPlayerIsListening(true)        
--                     checkChannel.isListening = true
--                     checkChannel.isChecked = true
--                     checkChannel.radio = item
--                     checkChannel.lastLine = ""
--                     if not subscribeToOnTick then
--                         subscribeToOnTick = true
--                         Events.OnTick.Add(RicksMLC_RadioOnInHotbar.OnTick)
--                     end
--                 end
--             end
--         end
--     end
--     DebugLog.log(DebugType.Mod, "RicksMLC_RadioOnInHotbar.OnEveryHour() end")
-- end

-- Events.EveryHours.Add(RicksMLC_RadioOnInHotbar.OnEveryHours)
