-- RicksMLC_AEBSHack.lua
-- Hack the emergency broadcast to add the freq for the MP chat
-- Ordinary Radio 88MHz to 108MHz

require "radio/ISWeatherChannel"

local RicksMLC_AEBSHack = {}
local Override = {}
Override.WeatherChannel_FillBroadcast =  WeatherChannel.FillBroadcast

function WeatherChannel.FillBroadcast(_gametime, _bc)
    Override.WeatherChannel_FillBroadcast(_gametime, _bc)
    if not SandboxVars.RicksMLC_TwoWayRadio.HackAEBS then return end

    local colorWhite = { r = 1.0, g = 1.0, b = 1.0 }
    local colorOrange = { r = 0.86, g = 0.65, b = 0.02 }
    WeatherChannel.AddFuzz(colorOrange, _bc)
    RicksMLC_AEBSHack.AddHackMsg(colorOrange, _bc)
    WeatherChannel.AddFuzz(colorWhite, _bc)
end

function RicksMLC_AEBSHack.AddHackMsg(c, _bc)
    _bc:AddRadioLine( RadioLine.new(SandboxVars.RicksMLC_TwoWayRadio.HackAEBSMsg1, c.r, c.g, c.b) )
    WeatherChannel.AddFuzz(c, _bc)
    _bc:AddRadioLine( RadioLine.new(SandboxVars.RicksMLC_TwoWayRadio.HackAEBSMsg2, c.r, c.g, c.b) )
end

