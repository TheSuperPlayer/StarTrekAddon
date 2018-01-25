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
function EFFECT:Init(data)
    self.Shuttle = data:GetEntity()
    self.Mode = data:GetScale() 
    if self.Mode == 1 then
        self.Entity:SetPos(self.Shuttle:GetPos()+self.Shuttle:GetForward()*195+self.Shuttle:GetUp()*90)
		self.Entity:SetAngles(self.Shuttle:GetAngles()+Angle(20,0,0))
        self.Entity:SetModel("models/type11shuttle/Door/Door - Type 11 Shuttle.mdl")
        self.FwdDif = 17.4
        self.UpDif = 34.7
        self.AngDif = -20
    elseif self.Mode == 2 then
        self.Entity:SetPos(self.Shuttle:GetPos()+self.Shuttle:GetForward()*212.4+self.Shuttle:GetUp()*124.7)
		self.Entity:SetAngles(self.Shuttle:GetAngles()+Angle(0,0,0))
        self.Entity:SetModel("models/type11shuttle/Door/Door - Type 11 Shuttle.mdl")
        self.FwdDif = -17.4
        self.UpDif = -34.7
        self.AngDif = 20
    end
    self.OrignialPos = self.Entity:GetPos()
    self.OrginialAngle = self.Entity:GetAngles()
    self.Progress = 0
end

function EFFECT:Think()
    self.Progress = self.Progress + 0.5
    
    local FwdM = self.FwdDif/100*self.Progress
    local UpM = self.UpDif/100*self.Progress
    local AngM = self.AngDif/100*self.Progress
    
    self.Entity:SetPos(self.OrignialPos + self.Shuttle:GetForward()*FwdM + self.Shuttle:GetUp()*(UpM))
    self.Entity:SetAngles(self.OrginialAngle + Angle(AngM,0,0))
    return self.Progress <= 100
end
