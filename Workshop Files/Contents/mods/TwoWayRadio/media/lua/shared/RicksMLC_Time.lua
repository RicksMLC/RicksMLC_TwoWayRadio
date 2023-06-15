-- RicksMLC_Time
-- Simple time related operations

require "ISBaseObject"
RicksMLC_Time = ISBaseObject:derive("RicksMLC_Time")

function RicksMLC_Time:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self
    
    o.numDays = 0
    o.numHours = 0
    o.numMinutes = 0
    o.numSeconds = 0

    o.origSeconds = 0

    return o
end

function RicksMLC_Time:add(seconds)
    self:set(self.origSeconds + seconds)
end

function RicksMLC_Time:subtract(seconds)
    self:add(-seconds)
end

function RicksMLC_Time:set(numSeconds)
    self.origSeconds = numSeconds
    if numSeconds >= 86400 then
        self.numDays = PZMath.fastfloor(numSeconds / 86400)
        numSeconds = numSeconds - (self.numDays * 86400)
    end
    if numSeconds >= 3600 then
        self.numHours = PZMath.fastfloor(numSeconds / 3600)        
        numSeconds = numSeconds - (self.numHours * 3600)
    end
    if numSeconds >= 60 then
        self.numMinutes = PZMath.fastfloor(numSeconds / 60)
        numSeconds = numSeconds - (self.numMinutes * 60)
    end
    self.numSeconds = numSeconds
end

function RicksMLC_Time:timeOfDayAsString(bIncludeSeconds)
    local ret = string.format("%02d:%02d", self.numHours, self.numMinutes)
    if bIncludeSeconds then
        ret = ret .. string.format("%02d", self.numSeconds)
    end
    return ret
end

function RicksMLC_Time:toString(bIncludeSeconds) 
    period = ""
    if self.numDays > 0 then
        period = period .. tostring(self.numDays) .. " Days"
    end
    if self.numHours > 0 then
        if period ~= "" then
            period = period .. " "
        end
        period = period .. tostring(self.numHours) .. " Hours"
    end
    if self.numMinutes > 0 then
        if period ~= "" then
            period = period .. " "
        end
        period = period .. tostring(self.numMinutes) .. " Minutes"
    end
    if bIncludeSeconds and self.numSeconds > 0 then
        if period ~= "" then
            period = period .. " "
        end
        period = period .. tostring(self.numSeconds) .. " Seconds"
    end
    return period
end
