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
function EFFECT:Init( data )
    self.Bubble = data:GetEntity()
    self.Len = 550
    self.createProgress = self.Len
    self.Step = 1
    self.Entity:SetPos(self.Bubble:GetPos())
    self.Entity:SetAngles(self.Bubble:GetAngles())
    self.Entity:SetModel("models/misc/shields/shuttle11shield.mdl")
    self.shieldMat = Material("effects/shield_mat", nil)
    self.Entity:SetRenderClipPlaneEnabled( true ) 
    self.parentShuttle = self.Bubble:GetParent()
    self.Entity:SetParent(self.parentShuttle)
    self.Pos = self.Bubble:GetPos()
    self.Mode = data:GetScale()
    if self.Mode == 1 then
        self.Normal = self.Bubble:GetForward()*-1
    else
        self.Normal = self.Bubble:GetForward()*-1
    end
    self.NotEnd = true
    self.alphaMat = 255
end

function EFFECT:Think( )
    if self.Step == 1 then
        self.createProgress = self.createProgress-8
        if self.createProgress < self.Len*-1 then
            self.Step = 2
            self.Entity:SetRenderClipPlaneEnabled( false ) 
            self.NotEnd = false
            if self.Mode == 2 then
                net.Start("shieldShuttle11Net")
                net.WriteEntity(self.Bubble)
                net.SendToServer()
            end
        end
    end
    return(self.NotEnd)
end

function EFFECT:Render( )
    if self.Mode == 1 then
        render.MaterialOverride(self.shieldMat)
        local dist = self.Normal:Dot(self.Entity:GetPos() + self.Entity:GetForward()*-self.createProgress)
        self.Entity:SetRenderClipPlane( self.Normal,dist )
        self:DrawModel()
        render.MaterialOverride(nil)
    elseif self.Mode == 2 then
        render.MaterialOverride(self.shieldMat)
        local dist = self.Normal:Dot(self.Entity:GetPos() - self.Entity:GetForward()*-self.createProgress)
        self.Entity:SetRenderClipPlane( self.Normal, dist )
        self:DrawModel()
        render.MaterialOverride(nil)
    end
end