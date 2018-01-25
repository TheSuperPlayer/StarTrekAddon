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
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName	= "Photon Torpedo"
ENT.Author		= "SuperPlayer"
ENT.Category 	= "Star Trek"
ENT.Contact		= "peterotto3475@gmail.com"
ENT.Purpose		= "Destruction"


if SERVER then
    AddCSLuaFile()
    function ENT:Initialize()
        self.Entity:PhysicsInitSphere(10, "metal")
        self.Entity:SetCollisionBounds(Vector(1, 1, 1) * -5, Vector(1, 1, 1) * 5)
        self.Entity:PhysicsInit(SOLID_VPHYSICS)
        self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
        self.Entity:SetSolid(SOLID_VPHYSICS)
        self:DrawShadow(false)
        self.KillTheCat = false
    end

    function ENT:UpdateTransmitState()
        return TRANSMIT_ALWAYS
    end

    function ENT:Settings(dir, spd, dmg, size)
        self.Direction = dir
        self.Speed = spd
        self.Damage = dmg
        self.Size = size
        self:SetNetworkedVector("Size", size)

        self:PhysWake()
        self.Phys = self.Entity:GetPhysicsObject()
        local vel = self.Direction * self.Speed
        if (self.Phys and self.Phys:IsValid()) then
            self.Phys:SetMass((self.Size.x + self.Size.y + self.Size.z) * 10)
            self.Phys:EnableGravity(false)
            self.Phys:SetVelocity(vel)
        end
    end
    function ENT:Think(ply)
        if self.KillTheCat then self:Remove() end
        if IsValid(self.Phys) then
            self.Phys:Wake()
        end
    end

    function ENT:PhysicsCollide(data, physobj)
        local pos = data.HitPos
        self:Explode(pos, self.Damage)
        self.KillTheCat = true
    end
    function ENT:CAPOnShieldTouch(shield)
        if shield:GetParent() == self.FiredFrom then return end
        self:Explode(self:GetPos(), self.Damage)
        self.KillTheCat = true
    end
    function ENT:Explode(pos, dmg)
        self.Phys:Sleep()
        local HitEffect = EffectData()
        HitEffect:SetOrigin(pos)
        HitEffect:SetEntity(self.Entity)
        util.Effect("torpedo_photon_hit", HitEffect)
        util.ScreenShake(pos, 10, 5, 1, 70)
        util.BlastDamage(self.Entity, self.Entity, pos, (self.Size.x +self.Size.y), dmg)
    end
end
if CLIENT then
    function ENT:Initialize()
        local size = self:GetNetworkedVector("Size", Vector(3,3,3))
        self.Size = size
        self.Mat = Material("effects/torpedo_photon")
    end

    function ENT:Draw()
        local start = self.Entity:GetPos()
        render.SetMaterial(self.Mat)
        render.DrawSprite(start, 70, 70, Color(255,0,0))
    end

    function ENT:Think()
        self.Size = self:GetNetworkedVector("Size", Vector(3,3,3))
        return true
    end
end