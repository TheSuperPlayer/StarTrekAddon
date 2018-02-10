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

--Based on the CDS_Disintegrate effect
--All credits go to the CDS team.

function EFFECT:Init(data)
	self.entity = data:GetEntity()
	if(!self.entity:IsValid()) then return end
	self.mag = math.Clamp(self.entity:BoundingRadius()/8,1,9999999)
	self.dur = 3 +CurTime()
	self.emitter = ParticleEmitter(self.entity:GetPos())
	self.amp = 255/data:GetScale()
end

function EFFECT:Think()
	if not self.entity:IsValid() then return false end
	local t = CurTime()
	local vOffset = self.entity:GetPos()
	local Low, High = self.entity:WorldSpaceAABB()
	for i=1, self.mag do
		local vPos = Vector(math.random(Low.x,High.x), math.random(Low.y,High.y), math.random(Low.z,High.z))
		
		
		local particle = self.emitter:Add("effects/transport/beam_particle", vPos)
		if (particle) then
			particle:SetColor(0,0,255,255)
			particle:SetVelocity(Vector(0,0,0))
			particle:SetLifeTime(0)
			particle:SetDieTime(.5)
			particle:SetStartAlpha(172)
			particle:SetEndAlpha(0)
			particle:SetStartSize(1)
			particle:SetEndSize(2)
			particle:SetRoll(math.random(0, 360))
			particle:SetRollDelta(0)
			particle:SetAirResistance(100)
			particle:SetGravity(Vector(0, 0, 0))
			particle:SetBounce(0.3)
		end
	end
	local dlight = DynamicLight( LocalPlayer():EntIndex() )
	if ( dlight ) then
		dlight.pos = self.entity:GetPos()
		dlight.r = 0
		dlight.g = 50
		dlight.b = 200
		dlight.brightness = 7
		dlight.Decay = 1000
		dlight.Size = 300
		dlight.DieTime = CurTime() + 1
	end
	local dlight2 = DynamicLight( LocalPlayer():EntIndex() )
	if ( dlight2 ) then
		dlight2.pos = self.entity:GetPos()
		dlight2.r = 255
		dlight2.g = 255
		dlight2.b = 255
		dlight2.brightness = 20
		dlight2.Decay = 1000
		dlight2.Size = 10
		dlight2.DieTime = CurTime() + 1
	end

	if not (t < self.dur) then
		self.emitter:Finish()
		self.entity:SetMaterial(nil)
	end
	return t < self.dur
end

function EFFECT:Render()
end
