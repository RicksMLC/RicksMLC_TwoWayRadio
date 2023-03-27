-- RicksMLC_TwoWayRadio

-- Tweak the ISRadioWindow so the radio still works when on the belt.  Putting inside a bag/pack will turn it off.
-- The idea comes from "Keep That Radio On", but with less copying of the original code.

require "RadioCom/ISRadioWindow"
require "Hotbar/ISHotbar"
require "UI/TheStarHotbar"

RicksMLC_TwoWayRadio = ISRadioWindow:derive("RicksMLC_TwoWayRadio")

--Override the radio and hotbar methods
local Override = {}
Override.ISRadioWindow_update = ISRadioWindow.update
function ISRadioWindow.update(self)

    local holdDeviceData = nil
    if self.deviceData and self.deviceType=="InventoryItem" then -- was: conveniently turn off radio when unequiped to prevent accidental loss of power.
        -- If it is in the hand, do nothing else to replicate the logic in the overridden method for a radio in the player inventory ie: do nothing
        -- We need to do this because the deviceData is temporarily nulled out to avoid the radio turning off, and if the early return is not
        -- done the radio window pops open and closes immediately after.
        if self.device and self.player then
            if self.player:getPrimaryHandItem() == self.device or self.player:getSecondaryHandItem() == self.device then
                return
            end
        end
        -- Dodgy hack: The overridden code checks if it has self.deviceData to turn off the item if it is in the inventory.
        -- So we just temporarily remove the deviceData so it won't trigger the turn off.
        local holdDeviceData = self.deviceData
        self.deviceData = nil
    end

    Override.ISRadioWindow_update(self)

    if holdDeviceData then
        self.deviceData = holdDeviceData
    end
    --  DebugLog.log(DebugType.Mod, "OverrideISRadioWindow_update: postOverride device is " .. ((self.deviceData:getIsTurnedOn() and "on") or "off") )
end

-- Override the ISHotbar.render so it will draw a green dot if the radio is still on while in the hotbar.
local radioOnTexture = getTexture("media/ui/iconInHotbar.png")
Override.ISHotbar_render = ISHotbar.render
function ISHotbar.render(self)

    Override.ISHotbar_render(self)

    for i, item in pairs(self.attachedItems) do
        if instanceof(item, "Radio") then
		    local slot = self.availableSlot[item:getAttachedSlot()];
		    local slotIndex = item:getAttachedSlot();
            if item:getDeviceData():getIsTurnedOn() then
                local slotX = self.margins + ((slotIndex - 1) * (self.slotWidth + self.slotPad))
                local x = slotX + self.slotWidth - (radioOnTexture:getWidth() + self.margins)
                local y = self.height - self.slotHeight + self.margins - radioOnTexture:getHeight()
                self:drawTexture(radioOnTexture, x, y, 1, 1, 1, 1);
            end
        end
    end
end

-- Override the ISHotbar remove item so it turn of the radio if it is removed from the hotbar
Override.ISHotbar_removeItem = ISHotbar.removeItem
function ISHotbar.removeItem(self, item, doAnim)
    DebugLog.log(DebugLog.Mod, "Override.ISHotbar_removeItem")
    if instanceof(item, "Radio") then
        item:getDeviceData():setIsTurnedOn(false)
    end
    Override.ISHotbar_removeItem(self, item, doAnim)
end
