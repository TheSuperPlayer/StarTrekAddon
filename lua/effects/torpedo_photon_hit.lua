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
	Pos = data:GetOrigin()
	self.Ent = data:GetEntity()
	local scale = 70
	self.Color = Color(255,150,0)
	Emitter = ParticleEmitter(Vector(0,0,0))
	
	for k=1,40 do
		local rdmOffset = VectorRand()*30
		local particle = Emitter:Add( "particles/flamelet"..math.random(1,5), Pos-rdmOffset)
		particle:SetDieTime( math.Rand( 2, 4 ) )
		particle:SetStartAlpha( 200 )
		particle:SetEndAlpha(0)
		particle:SetStartSize( scale/4 )
		particle:SetEndSize( scale/4 )
		particle:SetRoll( math.Rand( 20, 80 ) )
		particle:SetRollDelta( math.random( -1, 1 ) )
		particle:SetColor(self.Color.r-math.Rand( 1, 60 ),self.Color.g-math.Rand( 1, 60 ),self.Color.b)
	end

	local dLight = DynamicLight(0)
	dLight.Pos = Pos
	dLight.Size = 100
	dLight.Decay = 0
	dLight.R = self.Color.r
	dLight.G = self.Color.g
	dLight.B = self.Color.b
	dLight.DieTime = CurTime()+math.Rand( 2, 4 )
end
