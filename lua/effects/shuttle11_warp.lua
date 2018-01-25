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
	self.Shuttle = data:GetEntity()	
	self.EndPos = data:GetStart()
	self.Entity:SetModel("models/type11shuttle/Type11/Type 11 Shuttle.mdl")
	self.Entity:SetPos(self.Shuttle:GetPos())
	self.Entity:SetAngles(self.Shuttle:GetAngles())
	self.modelScale = Vector(1,1,1)
	self.Progress = 0
	self.Step = 1
	self.NotEnd = true
	self.WarpFlashMat = Material("effects/warpFlash")
	self.Timing = CurTime()
	self.Shuttle.inWarp = 1
	self.Shuttle.warpEnd = self.EndPos
end

function EFFECT:Think( )
	if not IsValid(self.Shuttle) then return false end
	if self.Step == 1 and self.Progress > 10 then
		self.Progress = 0
		self.Step = 2
		self.Normal = self.Shuttle:GetForward()
		self.Step2Origin = self.Entity:GetPos() + Vector(0,0,200)
	elseif self.Step == 2 and self.Progress > 10 then
		self.Step = 3
		self.Progress = 0
	elseif self.Step == 3 and self.Progress >= 10 then
		self.Progress = 0
		self.Step = 4
		self.Entity:SetPos(self.EndPos + self.Shuttle:GetForward()*1000)
		self.Shuttle.inWarp = 2
	elseif self.Step == 4 and self.Progress >= 20 then
		self.Shuttle:EndWarp()
		self.NotEnd = false
	end
	return self.NotEnd
end

function EFFECT:Render()
	if self.Step == 1 then
		self.Progress = self.Progress + 0.05
		self.modelScale = Vector(1+self.Progress/10,1,1)
		local mat = Matrix()
		mat:Scale( self.modelScale )
		self.Entity:EnableMatrix( "RenderMultiply", mat )
		self:DrawModel()
	elseif self.Step == 2 then
		self.Progress = self.Progress + 0.5
		self.Entity:SetPos(self.Entity:GetPos() + self.Shuttle:GetForward()*-30)
		self:DrawModel()
	elseif self.Step == 3 then
		self.Progress = self.Progress + 0.1
		render.SetMaterial(self.WarpFlashMat)
		render.DrawSprite( self.Step2Origin + self.Shuttle:GetForward()*-1200, 1800-(180*self.Progress), 1800-(180*self.Progress), Color(0,0,255,255) )
	elseif self.Step == 4 then
		self.Progress = self.Progress + 0.08
		if self.Progress > 10 then
			self:DrawModel()
		else
			self.modelScale = Vector(2-self.Progress/10,1,1)
			local mat = Matrix()
			mat:Scale( self.modelScale )
			self.Entity:EnableMatrix( "RenderMultiply", mat )
			self.Entity:SetPos(self.EndPos + self.Shuttle:GetForward()*-60*self.Progress)
			self:DrawModel()
			render.SetMaterial(self.WarpFlashMat)
			render.DrawSprite( self.EndPos + Vector(0,0,200), 1800-(180*self.Progress), 1800-(180*self.Progress), Color(0,0,255,255) )
		end
	end
end