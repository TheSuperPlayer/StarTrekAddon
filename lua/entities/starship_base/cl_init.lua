--[[
    Made by SuperPlayer
    Copyright[©] 2018 SuperPlayer
    All Rights Reserved

    This code was created by SuperPlayer for the addon "Star Trek Addon" for the game Garry's Mod.
    You may not use this code outside of this addon without written permission by me.
    If you want to use or modify this code, by parts OR as a whole, contact me first.
    Derivative works of this code are not allowed without permission.
    Do NOT distribute copies of this code in any form without permission by me.
    Under NO circumstances are you allowed to use this code to gain any kind of profit.

    If I find you breaking any of the statements above, I will take action accordingly.

    If you have any inquiries please contact me at:
    peterotto3475@gmail.com
    https://github.com/TheSuperPlayer
]]--
include('shared.lua')

function ENT:Initialize()
    self.ScreenNoDraw = false
    self.ShouldDrawModel = true
    self:SpecificInitialize()
end

function ENT:SpecificInitialize()

end

function ENT:Draw()
    if not self.ScreenNoDraw then
        self:DrawFrontScreen()
        self:DrawHelmScreen()
        self:DrawTacticalScreen()
    end

    self:CustomDraw()

    if self.ShouldDrawModel then
        self:DrawModel()
    end
    
end

function ENT:CustomDraw()
end

function ENT:DrawFrontScreen()
end

function ENT:DrawHelmScreen()
end

function ENT:DrawTacticalScreen()
end