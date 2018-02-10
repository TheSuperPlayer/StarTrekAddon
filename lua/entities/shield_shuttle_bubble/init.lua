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
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.ST_DisablePickup = true
function ENT:Initialize()
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self.Entity:SetRenderMode(RENDERMODE_NONE)
	self.Entity:SetTrigger(true)
	self.Entity:DrawShadow(false)
	self:SetupProperties(Vector(1,1,1))
end


function ENT:SetupProperties(type)
	self.Entity:SetModel("models/misc/shields/shuttle11shield.mdl")
	local fx = EffectData()
	fx:SetEntity(self.Entity)
	fx:SetScale(1)
	util.Effect("shieldShuttleStatusChange",fx,true,true)
end

function ENT:UpdateTransmitState() 
	return TRANSMIT_ALWAYS
end

function ENT:StartTouch(Ent)
	if Ent:GetParent() == self.Entity:GetParent() then return end
	if Ent:GetClass() == "torpedo_pulse" and Ent.FiredFrom == self.Entity:GetParent() then return end
	self:Repell(Ent)
	self:DrawHit(Ent:GetPos())
end

function ENT:DrawHit(Pos)
	local fx = EffectData()
		fx:SetOrigin(Pos)
		fx:SetEntity(self.Entity)
		fx:SetMagnitude(50)
		util.Effect("shieldShuttleHit",fx,true,true)
end

function ENT:Repell(Ent)
	if Ent:IsPlayer() then return end
	if Ent:IsNPC() then return end
	local collidePos = Ent:GetPos()
	local Normal = (self.Entity:GetPos()-collidePos):GetNormalized()
	local Class = Ent:GetClass()
	local PhyObj = Ent:GetPhysicsObject()
	local Velocity = Ent:GetVelocity()
	if Velocity == Vector(0,0,0) then return end
	
	local actualDmg = (math.abs((Velocity.x + Velocity.y + Velocity.z)/3) * PhyObj:GetMass())*0.1
	local damageToTake = math.Clamp(actualDmg, 0, 200)

	if Ent.PhysicsSimulate and not Ent.STShieldHitOverwriteInProgress then
		local originalSimulation = Ent.PhysicsSimulate
		Ent.STShieldHitOverwriteInProgress = true
		Ent.PhysicsSimulate = function() end
		timer.Simple(1, function() 
			Ent.PhysicsSimulate = originalSimulation
			Ent.STShieldHitOverwriteInProgress = nil
		end)
	end
	if Ent.CAPOnShieldTouch then
		Ent:CAPOnShieldTouch(self.Entity)
	end
	--[[
	if Ent.StartTouch then
		Ent:StartTouch(self.Entity:GetParent())
	end
	if Ent.Touch then
		Ent:Touch(self.Entity)
	end
	if Ent.EndTouch then
		Ent:EndTouch(self.Entity)
	end
	if Ent.PhysicsCollide then
		local collideTable = {
			HitPos = collidePos,
			HitEntity = self.Entity,
			OurOldVelocity = Velocity,
			HitObject = self.Entity:GetParent():GetPhysicsObject(),
			DeltaTime = CurTime(),
			TheirOldVelocity = self.Entity:GetVelocity(),
			Speed = (Velocity.x + Velocity.y + Velocity.z)/3,
			HitNormal = Normal,
			PhysObject = PhyObj
		}
		Ent:PhysicsCollide(collideTable, self.Entity:GetPhysicsObject())
	end]]--
	
	if IsValid(Ent) and IsValid(PhyObj) and not Ent:IsNPC() and not Ent:IsPlayer() and not Ent:IsWorld() then
		if Ent:IsPlayerHolding() then
			PhyObj:EnableMotion(false)
			timer.Simple(0.3, function() 
				PhyObj:EnableMotion(true)
				PhyObj:Wake()
			end)
		end
		PhyObj:EnableMotion(false)
		PhyObj:EnableMotion(true)
		PhyObj:Wake()
		PhyObj:ApplyForceOffset(-Normal*PhyObj:GetMass()*1000,collidePos+20*Normal)
	end
	self.Entity:GetParent():TakeShieldDamage(damageToTake)
end

function ENT:OnTakeDamage(dmg)
	self.Entity:GetParent():TakeShieldDamage(dmg:GetDamage())
end

function ENT:Think()
	if not IsValid(self.Entity:GetParent()) then self:Remove() end
	self.Entity:Extinguish()
	self.Entity:GetParent():Extinguish()
end

function ENT:Deactivate()
	local fx = EffectData()
	fx:SetEntity(self.Entity)
	fx:SetScale(2)
	util.Effect("shieldShuttleStatusChange",fx,true,true)
	self.shouldTerminate = true
end

net.Receive("shieldShuttle11Net", function( Len, Ply )
	local bubble = net.ReadEntity()
	if IsValid(bubble) and bubble:GetClass() == "shield_shuttle_bubble" and bubble.shouldTerminate then
		bubble:Remove()
	end
end)
