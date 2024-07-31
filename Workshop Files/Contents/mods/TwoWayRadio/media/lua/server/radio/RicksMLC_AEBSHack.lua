-- RicksMLC_AEBSHack.lua
-- Hack the emergency broadcast to add the freq for the MP chat
-- Ordinary Radio 88MHz to 108MHz

require "radio/ISWeatherChannel"
require "RicksMLC_Time"

local RicksMLC_AEBSHack = {}
local Override = {}
Override.WeatherChannel_FillBroadcast =  WeatherChannel.FillBroadcast
function WeatherChannel.FillBroadcast(_gametime, _bc)
    Override.WeatherChannel_FillBroadcast(_gametime, _bc)

    local colorWhite = { r = 1.0, g = 1.0, b = 1.0 }
    local colorOrange = { r = 0.86, g = 0.65, b = 0.02 }

    if SandboxVars.RicksMLC_TwoWayRadio.HackAEBS then 
        WeatherChannel.AddFuzz(colorOrange, _bc)
        RicksMLC_AEBSHack.AddHackMsg(colorOrange, _bc)
        WeatherChannel.AddFuzz(colorWhite, _bc)
    end
    if SandboxVars.RicksMLC_TwoWayRadio.HackAEBSSchedule then
        RicksMLC_AEBSHack.AddRealTimeScheduledMessage(colorOrange, _bc)
        WeatherChannel.AddFuzz(colorWhite, _bc)
    end
end

function RicksMLC_AEBSHack.AddHackMsg(c, _bc)
    if SandboxVars.RicksMLC_TwoWayRadio.HackAEBSMsg1 then
        _bc:AddRadioLine( RadioLine.new(SandboxVars.RicksMLC_TwoWayRadio.HackAEBSMsg1, c.r, c.g, c.b) )
    end
    if SandboxVars.RicksMLC_TwoWayRadio.HackAEBSMsg2 then
        WeatherChannel.AddFuzz(c, _bc)
        _bc:AddRadioLine( RadioLine.new(SandboxVars.RicksMLC_TwoWayRadio.HackAEBSMsg2, c.r, c.g, c.b) )
    end
    RicksMLC_AEBSHack.AddRealTimeScheduledMessage(c, _bc)
end

local function GetGameTimeSeconds(hour, minute)
    return (hour * 3600) + (minute * 60)
end

function RicksMLC_AEBSHack.AddRealTimeScheduledMessage(c, _bc)
    -- Real time scheduled message handling: Publish a message coinsiding with a real-time event
    -- eg: A daily scheduled server shutdown.
    -- Uses the SandboxVars.DayLength to work out from the real-time hours how long before the event

    --DebugLog.log(DebugType.Mod, "RicksMLC_AEBSHack.AddRealTimeScheduledMessage()")

    local scheduledEventTime = SandboxVars.RicksMLC_TwoWayRadio.RealTimeScheduledTimeOfDay
    local scheduledEventName = SandboxVars.RicksMLC_TwoWayRadio.RealTimeScheduledEvent
    local numRealHoursNotice = SandboxVars.RicksMLC_TwoWayRadio.RealTimeHoursBefore
    local gameTimeSeconds = GetGameTimeSeconds(getGameTime():getHour(), getGameTime():getMinutes())

    local msg = RicksMLC_AEBSHack.MakeSheduledEventString(
        scheduledEventTime,
        numRealHoursNotice,
        Calendar.getInstance():getTime(),
        gameTimeSeconds,
        getSandboxOptions():getDayLengthMinutes() / 60, -- day length in hours
        scheduledEventName
     )

     if msg then
        WeatherChannel.AddFuzz(c, _bc)
        _bc:AddRadioLine( RadioLine.new(msg , c.r, c.g, c.b) )
        WeatherChannel.AddFuzz(c, _bc)
    end
end

function RicksMLC_AEBSHack.MakeSheduledEventString(eventScheduledRealTime, numRealHoursNotice, currentRealTime, gameTimeSeconds, dayLength, eventName)
    local msg = nil

    local sdf = SimpleDateFormat.new("HH:mm:ss")
    local curTimeAsString = sdf:format(currentRealTime)
    local hourNum, minuteNum, secondsNum = string.match(curTimeAsString, "(%d+):(%d+):(%d+)")
    local currentSeconds = tonumber(hourNum) * 3600 + tonumber(minuteNum) * 60 + tonumber(secondsNum)

    local sHourNum, sMinuteNum, sSecondNum = string.match(eventScheduledRealTime, "(%d+):(%d+):(%d+)")
    local eventInSeconds = tonumber(sHourNum) * 3600 + tonumber(sMinuteNum) * 60
    if sSecondNum then
        eventInSeconds = eventInSeconds + tonumber(sSecondNum)
    end

    if eventInSeconds < currentSeconds then
        eventInSeconds = eventInSeconds + 86400
    end

    local numSecondsBeforeEvent = numRealHoursNotice * 3600
    local triggerMsgTimeSeconds = eventInSeconds - numSecondsBeforeEvent

    --DebugLog.log(DebugType.Mod, "RicksMLC_AEBSHack.MakeSheduledEventString() dayLength: " .. tostring(dayLength) .. " dayLengthMinutes(): " .. tostring(getSandboxOptions():getDayLengthMinutes()))

    if currentSeconds < triggerMsgTimeSeconds then
        --DebugLog.log(DebugType.Mod, "  Too late. CurrentSeconds " .. tostring(currentSeconds) .. " > eventSeconds " .. tostring(eventSeconds))
        return msg
    end

    if currentSeconds >= triggerMsgTimeSeconds then
        -- It's time to broadcast message
        local dayLengthInSeconds = dayLength * 3600
        local gameTimeSecondsPerRealTimeSeconds = 86400 / dayLengthInSeconds
        local secondsToEvent = eventInSeconds - currentSeconds
        if secondsToEvent < 0 then
            secondsToEvent = secondsToEvent + 86400
        end
        local inGameSecondsTilEvent = secondsToEvent * gameTimeSecondsPerRealTimeSeconds

        local gameTimeTilEvent = RicksMLC_Time:new()
        gameTimeTilEvent:set(inGameSecondsTilEvent)
        local gameEventTime = RicksMLC_Time:new()
        gameEventTime:set(gameTimeSeconds)
        gameEventTime:add(inGameSecondsTilEvent)

        msg = eventName
        if gameEventTime.numDays > 1 then
            msg = "NOTE: " .. msg .. " ETA " .. gameTimeTilEvent:toString(false)
        else
            -- It is tomorrow or today in-game
            msg = "WARNING: " .. msg .. " ETA " .. gameTimeTilEvent:toString(false) .. "."
            if gameEventTime.numDays == 1 then
                msg = msg .. " Tomorrow at " .. gameEventTime:timeOfDayAsString(false)
            else
                msg = msg .. " Today at " .. gameEventTime:timeOfDayAsString(false)
            end
        end
        --DebugLog.log(DebugType.Mod, "   Broadcast Message:" .. msg)
    end
    return msg
end

function RicksMLC_AEBSHack.Test()
    DebugLog.log(DebugType.Mod, "RicksMLC_AEBSHack.Test()")
    DebugLog.log(DebugType.Mod, "math.floor(1.1):" .. tostring(PZMath.fastfloor(1.1)) )
    DebugLog.log(DebugType.Mod, "math.floor(0.9):" .. tostring(PZMath.fastfloor(0.9)) )

    local sdf = SimpleDateFormat.new("yyyy-MM-dd hh:mm:ss")
    DebugLog.log(DebugType.Mod, "Calendar: " .. sdf:format(Calendar.getInstance():getTime()))
    local gameTime = getGameTime()
    DebugLog.log(DebugType.Mod, "GameTime: " .. string.format("%04d-%02d-%02d %02d:%02d", gameTime:getYear(), gameTime:getMonth(), gameTime:getDay(), gameTime:getHour(), gameTime:getMinutes()))
    local calendar = Calendar.getInstance()
    calendar:set(2023, 6, 1, 20, 00)
    DebugLog.log(DebugType.Mod, "Updated:  " .. sdf:format(calendar:getTime()))

    local cases = {}
    -- case1: Event 2:50:00 from calendar 20:00:00 = 10200 sec. (rs)
    --        a game day is 3 * 3600rs = 10800rs => 86400gs / 10800rs = 8gs/1rs
    --        => 8gs/1rs * 10200rs = 81600gs
    --        game time = 10:00gt = 36000gs since 00:00, therefore event time in gt is 36000gs + 81600gs = 117600gs
    --        117600gs from 00:00 is 32 hours => 1.36 days => 1 Day + 31200 sec => 1 Day 8.66 hours => 1 Day 8:39
    cases.case1 = { eventTime = "22:50:00", hoursNotice = 3, realTime = calendar:getTime(), gameTime = GetGameTimeSeconds(10, 0), dayLength = 3, eventName = "Automated System (Tomorrow 8:39) Restart" }
    -- case2: Event 1:50:00 from calendar 20:00:00 = 6600 sec. (rs)
    --        a game day is 3 * 3600rs = 10800rs => 86400gs / 10800rs = 8gs/1rs
    --        => 8gs/1rs * 6600 = 52800gs
    --        game time = 00:00gt = 36000gs since 00:00, therefore event time in gt is 0gt + 52800gs = 52800gt
    --        gt from 00:00 is 14 hours 39.9 minutes => 14:39
    cases.case2 = { eventTime = "21:50:00", hoursNotice = 2, realTime = calendar:getTime(), gameTime = GetGameTimeSeconds( 0, 0), dayLength = 3, eventName = "Automated System (Today 14:39) Restart" }
    calendar:set(2023, 6, 1, 02, 01)

    cases.case3 = { eventTime = "03:00:00", hoursNotice = 2, realTime = calendar:getTime(), gameTime = GetGameTimeSeconds( 0, 0), dayLength = 2, eventName = "Automated System Restart" }
    cases.case4 = { eventTime = "04:02:00", hoursNotice = 2, realTime = calendar:getTime(), gameTime = GetGameTimeSeconds( 0, 0), dayLength = 1, eventName = "Automated System (nil) Restart" }
    calendar:set(2023, 6, 1, 21, 20)
    -- case5: Event 59:00 from calendar 21:20:00 = 3540 sec. (rs)
    --        a game day is 1 * 3600rs = => 86400gs / 3600rs = 24gs/1rs
    --        => 24gs/1rs * 3540rs = 84960gs
    --        game time = 13:00gt = 46800gs since 00:00, therefore event time in gt is 46800gt + 84960gs = 131700gt
    --        gt from 00:00 is 1 day + 45300 -> 1 Day 12 hours 34 minutes
    cases.case5 = { eventTime = "22:19:00", hoursNotice = 24, realTime = calendar:getTime(), gameTime = GetGameTimeSeconds(13,  0), dayLength = 1, eventName = "Automated System (Tomorrow 12:34) Restart" }
    calendar:set(2023, 6, 1, 22, 34)
    cases.case6 = { eventTime = "22:10:00", hoursNotice = 24, realTime = calendar:getTime(), gameTime = GetGameTimeSeconds(09, 40), dayLength = 1, eventName = "Automated System Restart" }
    calendar:set(2023, 6, 1, 22, 38)
    cases.case7 = { eventTime = "01:00:00", hoursNotice = 24, realTime = calendar:getTime(), gameTime = GetGameTimeSeconds(09, 25), dayLength = 1, eventName = "Automated System Restart" }
    calendar:set(2023, 6, 1, 01, 20)
    cases.case8 = { eventTime = "01:00:00", hoursNotice = 12, realTime = calendar:getTime(), gameTime = GetGameTimeSeconds(09, 25), dayLength = 1, eventName = "Mandatory Brief Curfew" }
    calendar:set(2023, 6, 1, 13, 10)
    cases.case9 = { eventTime = "01:00:00", hoursNotice = 12, realTime = calendar:getTime(), gameTime = GetGameTimeSeconds(09, 25), dayLength = 1, eventName = "Mandatory Brief Curfew" }


    for i, v in pairs(cases) do
        local msg = RicksMLC_AEBSHack.MakeSheduledEventString(v.eventTime, v.hoursNotice, v.realTime, v.gameTime, v.dayLength, v.eventName)
        DebugLog.log(DebugType.Mod, "   Case: " .. tostring(i) .. " msg: '"  .. tostring(msg) .. "'")
    end

    DebugLog.log(DebugType.Mod, "RicksMLC_AEBSHack.Test() end")
end

function RicksMLC_AEBSHack.DumpChannels()
    DebugLog.log(DebugType.Mod, "RicksMLC_AEBSHack.DumpChannels()")
    local radioScriptManager = RadioScriptManager.getInstance()
    local channelList =  radioScriptManager:getChannelsList()
    for i = 0, channelList:size()-1 do
        local channel = channelList:get(i)
        DebugLog.log(DebugType.Mod, "    Channel: " .. channel:GetName() .. " " .. tostring(channel:GetFrequency()))
    end
end

function RicksMLC_AEBSHack.OnKeyPressed(key)
    if key == Keyboard.KEY_F9 then
        RicksMLC_AEBSHack.Test()
    end
end

-- Commented Code: Uncomment to run the test
--Events.OnKeyPressed.Add(RicksMLC_AEBSHack.OnKeyPressed)