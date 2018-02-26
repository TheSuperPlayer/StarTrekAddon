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
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')
function ENT:Initialize()
    self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow(true)

    self.InFlight = false 
    self.Pilot = nil
    self.Crew = {}
    self.Accel = {
		F = 0,
		R = 0,
		U = 0
	}	
    self.Entity:StartMotionController()
	self.HoverPos = self.Entity:GetPos()

    self.Hull = self.MaxHull
	self:SetNWInt("Hull",self.Hull)
	self.ShieldCharge = self.MaxShield
	self:SetNWInt("ShieldCharge",self.ShieldCharge)
	self.ShieldOn = false
    self:SetNWBool("ShieldOn", self.ShieldOn)
	self.Shield = nil
	self.lastShieldToggle = CurTime() - 10

	self.WeaponsEnergy = self.MaxWeaponsEnergy
	self:SetNWInt("WeaponsEnergy",self.WeaponsEnergy)


    self:SpecificInitialize()
end

function ENT:SpecificInitialize()
    -- Entity specific Init override
end

function ENT:Think()
    print("Think")
    if StarTrek.LSInstalled then
		self:LSSupport()
	end
    self:TriggerOutput()
    self:SpecificThink()
end

function ENT:SpecificThink()
    -- Entity specific Think override
end

function ENT:TriggerOutput()
    if WireLib then
        self:TriggerWireOutPuts()
    end
end

function ENT:TriggerWireOutPuts()

end

function ENT:LSSupport()
	local CollisionBoundsMin, CollisionBoundsMax = self.Entity:GetCollisionBounds()
	local entsInShip = ents.FindInBox( self.Entity:GetPos() + CollisionBoundsMin, self.Entity:GetPos() + CollisionBoundsMax ) 
	for I = 1, #entsInShip do
		if entsInShip[I]:IsPlayer() then
			entsInShip[I]:LsResetSuit()
		end
	end
end

function ENT:OnTakeDamage(dmg) 
	local health = self:GetNWInt("Health")
	local maxDmg = dmg:GetDamage()
	local actualDmg = maxDmg
	if self.ShieldOn then
		actualDmg = maxDmg*0.05
	else
		actualDmg = maxDmg/2
	end
	self:SetNWInt("Health",health-actualDmg)
	if math.Round(self:GetNWInt("Health")/self.MaxHull*100) <=0 then
		self:SetNWInt("Health",0) 
		self:Boom()
	end
end

function ENT:TakeShieldDamage(Dmg)
	if IsValid(self.Shield) then
		self.ShieldCharge = self.ShieldCharge - math.Round(Dmg)
		if self.ShieldCharge <= 0 then
			self.Shield:Remove()
			self.ShieldOn = false
			self.ShieldCharge = 0
		end
		self:SetNWInt("ShieldCharge", self.ShieldCharge)
		self:SetNWBool("ShieldOn", self.ShieldOn)
	end
end

function ENT:ToggleShield()
	if not (self.lastShieldToggle+1 < CurTime()) then return end
	if self.ShieldOn == true then
		self.ShieldOn = false
		if IsValid(self.Shield) then
			self.Shield:Deactivate()
		end
		self:SetNWBool("ShieldOn", self.ShieldOn)
		self.lastShieldToggle = CurTime()
	else
		if IsValid(self.Shield) then return end
		if self.shieldCharge < self.MaxShield/100 then return end
		self.Shield = ents.Create("shield_shuttle_bubble")
		self.Shield:SetAngles(self.Entity:GetAngles())
		self.Shield:SetPos( self.Entity:GetPos() + self.Entity:GetUp()*50 )
		self.Shield:Spawn()
		self.Shield:SetParent(self)
		self.Shield:SetupProperties(ENT.StarShipClass)
		self.ShieldOn = true
		self:SetNWBool("ShieldOn", self.ShieldOn)
		self.lastShieldToggle = CurTime()
	end
end

function ENT:Boom()
	self.Entity:NextThink(CurTime()+10)

    local effect = EffectData()
    effect:SetOrigin( self.Entity:GetPos() + self.Entity:GetUp()*50)
    util.Effect( "shuttle_boom", effect )

	self:Remove()
end

function ENT:OnRemove()
    error("Needs specific on remove")
end

function ENT:PhysicsSimulate( phys, deltatime )
	local moveParameters = {}
	moveParameters.secondstoarrive = 1 // How long it takes to move to pos and rotate accordingly - only if it could move as fast as it want - damping and max speed/angular will make this invalid ( Cannot be 0! Will give errors if you do )
	moveParameters.maxangular = 5000 //What should be the maximal angular force applied
	moveParameters.maxangulardamp = 10000 // At which force/speed should it start damping the rotation
	moveParameters.maxspeed = 1000000 // Maximal linear force applied
	moveParameters.maxspeeddamp = 10000// Maximal linear force/speed before damping
	moveParameters.dampfactor = 0.8 // The percentage it should damp the linear/angular force if it reaches it's max amount
	moveParameters.teleportdistance = 0 // If it's further away than this it'll teleport ( Set to 0 to not teleport )
	moveParameters.deltatime = deltatime // The deltatime it should use - just use the PhysicsSimulate one
	moveParameters.pos = self.HoverPos
	moveParameters.angle = self.Entity:GetAngles()

    local newParameters = self:CustomPhysicsSimulate(phys, moveParameters)
    phys:ComputeShadowControl(newParameters)
end

function ENT:CustomPhysicsSimulate(phys, moveParameters)
    return moveParameters
end