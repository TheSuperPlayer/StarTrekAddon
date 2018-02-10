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
ENT.PrintName	= "Shuttle 11 Phaser Beam"
ENT.Author		= "SuperPlayer"
ENT.Category 	= "Star Trek"
ENT.Contact		= "peterotto3475@gmail.com"
ENT.Purpose		= "Destruction"
ENT.RenderGroup = RENDERGROUP_BOTH

if SERVER then
    AddCSLuaFile()

    function ENT:Initialize()
        self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
        self:DrawShadow(false)

        self.Start = Vector(0,0,0)
        self.EndPos = Vector(0,0,0)
        self.Trace = nil
        self.Parent = nil
        self.Damage = 10
        self.Entity:SetAngles( Angle(0,0,0) ) 
        self.soundEmitted = self.Entity:StartLoopingSound( "shuttle11_phaser_sound.mp3" ) 
    end

    function ENT:OnRemove()
        self.Entity:StopLoopingSound(self.soundEmitted)
    end
    
    function ENT:UpdateTransmitState() 
	    return TRANSMIT_ALWAYS
    end

    function ENT:Setup(parent, width, dmg)
        self.Parent = parent
        self.Start = self.Parent:GetPos()
        self.Entity:SetPos(self.Parent:GetPos()+ self.Parent:GetUp()*190 + self.Parent:GetForward()*-360)
        self.Entity:SetParent(self.Parent)
        self.Damage = dmg
    end

    function ENT:Think()
        if not IsValid(self.Parent) then self.Entity:Remove() end
        self:SetNetworkedEntity("parentShield", self.Parent.Shield or nil)
        self.Start = self.Entity:GetPos()
        self.Trace = util.TraceLine( {
            start = self.Start,
            endpos = self.Entity:GetPos()+self.Parent:GetForward()*-10^14,
            filter = {self.Parent,self.Entity,self.Parent.Shield}
        } )

        self.EndPos = self.Trace.HitPos
        util.BlastDamage( self.Entity, self.Entity, self.EndPos, 10, self.Damage ) 

        if self.Trace.Entity:GetClass() == "shield_shuttle_bubble" then
            self.Trace.Entity:DrawHit(self.EndPos,self.Damage)
        end
        local hitEffect = EffectData()
            hitEffect:SetOrigin(self.Trace.HitPos)
            hitEffect:SetNormal(self.Trace.HitNormal)
            hitEffect:SetScale(40)
            util.Effect("phaser_hit", hitEffect)

        self.Entity:NextThink(CurTime()+0.1)
        return true
    end
end
if CLIENT then
    function ENT:Initialize()
        self.startPos = self.Entity:GetPos()
        self.endPos = Vector(0,0,0)
        self.BeamMat = Material("effects/phaser_beam_orange")
    end

    function ENT:Draw()
        local matCord = CurTime()*-8
        render.SetMaterial(self.BeamMat)
        render.DrawBeam( self.startPos, self.endPos, 20,matCord, matCord + self.startPos:Distance(self.endPos)/256, Color(255,0,0) )
    end
    function ENT:Think()
        self.startPos = self.Entity:GetPos()
        self.parentShield = self:GetNWEntity("parentShield", nil)
        self.Trace = util.TraceLine( {
            start = self.Entity:GetPos(),
            endpos = self.Entity:GetPos()+self.Entity:GetParent():GetForward()*-10^14,
            filter = {self.Entity, self.Entity:GetParent(),self.parentShield}
        } )
        self.endPos = self.Trace.HitPos
        self.Entity:SetRenderBoundsWS( self.startPos, self.endPos,Vector( 0, 0, 0 ) ) 
    end
end