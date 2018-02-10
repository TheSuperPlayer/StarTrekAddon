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

	self.Position = data:GetOrigin()
	self.Emitter = ParticleEmitter( self.Position )
	for i=1,1000 do
		local rdmVec = VectorRand()*math.Rand(-10,10)
		local particle = self.Emitter:Add( "effects/explosionp_1", self.Position)
		particle:SetVelocity(rdmVec*math.Rand(50,100))
		particle:SetDieTime(3)
		particle:SetStartAlpha( math.Rand(230, 250) )
		particle:SetStartSize( math.Rand( 10,13 ) )
		particle:SetEndSize( math.Rand( 1,3 ) )
	end

	for i=1,20 do
		local rdmVec = VectorRand()*math.Rand(-10,10)
		local particle = self.Emitter:Add( "particles/flamelet"..math.random(1,5), self.Position)
		particle:SetDieTime( math.Rand( 3, 5 ) )
		particle:SetVelocity(rdmVec*math.Rand(10,30))
		particle:SetStartAlpha( 200 )
		particle:SetEndAlpha(0)
		particle:SetStartSize(50 )
		particle:SetEndSize( 400 )
		particle:SetRoll( math.Rand( 20, 80 ) )
		particle:SetRollDelta( math.random( -1, 1 ) )
		particle:SetColor(math.Rand( 180, 255 ),math.Rand( 200, 255 ),200)
	end

	for i=-180,180 do
		local yNew = math.sin( math.rad( i )  ) 
		local xNew = math.cos( math.rad( i )  ) 
		local rdmVec = Vector(xNew, yNew ,0)*500
		local particle = self.Emitter:Add( "particles/flamelet"..math.random(1,5), self.Position)
		particle:SetDieTime( 4 )
		particle:SetVelocity(rdmVec)
		particle:SetStartAlpha( 200 )
		particle:SetEndAlpha(0)
		particle:SetStartSize(50 )
		particle:SetEndSize( 90 )
		particle:SetColor(0,120,255)
	end
end
