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
    self.Pos = data:GetOrigin()
    self.Size = data:GetMagnitude()
    self.Bubble = data:GetEntity()
    self.Progress = 0
    self.Entity:SetPos(self.Bubble:GetPos())
    self.Entity:SetAngles(self.Bubble:GetAngles())
    self.Entity:SetParent(self.Bubble)
    self.Entity:SetModel("models/type11shuttle/Shield/shuttle11shield.mdl")
    self.shieldMat = Material("effects/shield_mat", nil)
    self.Entity:SetRenderClipPlaneEnabled( true ) 
    self.Normal = (self.Pos-self.Bubble:GetPos()):GetNormalized()
    self.Ang = self.Normal:Angle()
end

function EFFECT:Think( )
    self.Progress = self.Progress + 0.5
    if not IsValid(self.Bubble) then return false end
    return(self.Progress <= 100)
end

function EFFECT:Render( )
    if not IsValid(self.Bubble) then return end
    render.MaterialOverride(self.shieldMat)
    local dist = self.Bubble:GetPos():Distance(self.Pos)
    local offset = dist*0.8 + dist*0.2*(self.Progress/100)
    self.Entity:SetRenderClipPlane( self.Normal, self.Normal:Dot( self.Entity:GetPos()) + offset)
    self:DrawModel()
    render.MaterialOverride(nil)
end