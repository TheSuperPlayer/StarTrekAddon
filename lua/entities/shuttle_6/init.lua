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
    self.Entity:SetModel( "models/apwninthedarks_starship_pack/shuttlecraft/type_6_shuttle.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow(true)
    local phys = self.Entity:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:SetMass(100000)
    end

	self.In = false 
	self.Pilot = nil
	self.shouldExit = false
	self.Accel = {
		F = 0,
		R = 0,
		U = 0
	}	
	self.Entity:SetUseType( SIMPLE_USE )
	self.Entity:StartMotionController()
	self.HoverPos = self.Entity:GetPos()


	self.Hull = self.MaxHull
	self:SetNWInt("Health",self.Hull)
	self.shieldCharge = self.MaxShield
	self:SetNWInt("ShieldCharge",self.shieldCharge)
	self.ShieldOn = false
	self.Shield = nil
	self.lastShieldToggle = CurTime() -10
	self:SetNWBool("ShieldOn", self.ShieldOn)

	self.PhaserCharge = 100
	self.TimeSinceFired = CurTime() - 10
	self:SetNWInt("phaserCharge",self.PhaserCharge)

    if not (WireAddon == nil) then
		WireLib.CreateInputs(self.Entity, {"Self Destruct" })
		self.Outputs = WireLib.CreateOutputs(self.Entity, { "Hull","Shield" }) 
	end

	if StarTrek.LSInstalled then
		self.grav_plate = 1
	end
	self:SpawnDoor()
	self:SpawnChairs()
	self.doorCoroutine = nil
end

function ENT:SpawnChairs()

	for I =1,4,1 do
		local chair = ents.Create("prop_vehicle_prisoner_pod")
		chair:SetPos(self:GetPos() + self:GetForward()*-15 + self:GetForward()*20*I + self:GetRight()*42 + Vector(0,0,32))
		chair:SetAngles(self:GetAngles()+ Angle(0,0,0))
		chair:SetModel("models/nova/airboat_seat.mdl")
		chair:Spawn()
		chair:Activate()
		chair:SetParent(self)
		chair.Shuttle6Seat = true
		chair:SetNoDraw(true)
	end

	for I =1,4,1 do
		local chair = ents.Create("prop_vehicle_prisoner_pod")
		chair:SetPos(self:GetPos() + self:GetForward()*-15 + self:GetForward()*20*I + self:GetRight()*-42 + Vector(0,0,32))
		chair:SetAngles(self:GetAngles()+ Angle(0,180,0))
		chair:SetModel("models/nova/airboat_seat.mdl")
		chair:Spawn()
		chair:Activate()
		chair:SetParent(self)
		chair.Shuttle6Seat = true
		chair:SetNoDraw(true)
	end

end

hook.Add("PlayerLeaveVehicle", "Shuttle6LeaveChair", function(ply, vehicle)
	if not IsValid(ply) or not IsValid(vehicle) or not vehicle.Shuttle6Seat then return end
	local shuttle = vehicle:GetParent()
	if not IsValid(shuttle) then return end
	ply:SetNWBool("inShuttle6", nil)
	ply:SetNWEntity("Shuttle6", nil)
	ply:SetNWInt("inShuttle6Type", nil)
	ply:SetPos(vehicle:GetPos() + vehicle:GetForward()*40+ vehicle:GetUp()*-15)

end)

function ENT:SpawnDoor()
	self.Door = ents.Create("prop_physics")
	self.Door:SetModel("models/apwninthedarks_starship_pack/doors/door___type_6_shuttle.mdl")
	self.Door:SetPos(self:GetPos())
	self.Door:SetAngles(self:GetAngles())
	
	self.Door:Spawn()
	self.Door:Activate()
	self.Door:SetParent(self.Entity)
	self.Door:CallOnRemove( "shuttle6_respawndoor_"..self.Entity:EntIndex(), function()
		if not IsValid(self.Entity) then return end
		self:SpawnDoor()
	end) 
	self.NextDoorToggle = CurTime()
	timer.Remove("shuttle6_door_"..self.Entity:EntIndex())
end

function ENT:ToggleDoor(Ply)
	if not IsValid(self.Door) then return end
 	if self.DoorOpen then
	 	if not self.doorCoroutine or not coroutine.resume( self.doorCoroutine ) then
			self.doorCoroutine = coroutine.create( SC6CloseDoor )
			coroutine.resume( self.doorCoroutine, self.Entity, self.Door )
			timer.Create("shuttle6_door_"..self.Entity:EntIndex(), 0.01, 100, function() 
				coroutine.resume( self.doorCoroutine, self.Entity, self.Door )
			end)
		end
	else
		if not self.doorCoroutine or not coroutine.resume( self.doorCoroutine ) then
			self.doorCoroutine = coroutine.create( SC6OpenDoor )
			coroutine.resume( self.doorCoroutine, self.Entity, self.Door )
			timer.Create("shuttle6_door_"..self.Entity:EntIndex(), 0.01, 100, function() 
				coroutine.resume( self.doorCoroutine, self.Entity, self.Door )
			end)
		end
	end
	self.NextDoorToggle = CurTime()+1
end

function SC6OpenDoor(Entity, Door)
	if not IsValid(Entity) or not IsValid(Door) then return end
	local OrignialPos = Door:GetPos()
    local OrginialAngle = Door:GetAngles()

	local FwdDif = 80
	local UpDif = 109
	local AngDif = 90

	for I = 0, 100 do
		local FwdM = FwdDif/100*I
		local UpM = UpDif/100*I
		local AngM = AngDif/100*I
		Door:SetParent(nil)
		Door:SetPos(OrignialPos + Entity:GetForward()*FwdM + Entity:GetUp()*(UpM))
		Door:SetAngles(OrginialAngle + Angle(AngM,0,0))
		Door:SetParent(Entity)
		coroutine.yield()
	end
	Entity.DoorOpen = true
end

function SC6CloseDoor(Entity, Door)
	if not IsValid(Entity) or not IsValid(Door) then return end
	local OrignialPos = Door:GetPos()
    local OrginialAngle = Door:GetAngles()
	local FwdDif = -80
	local UpDif = -109
	local AngDif = -90
	for I = 0, 100 do
		local FwdM = FwdDif/100*I
		local UpM = UpDif/100*I
		local AngM = AngDif/100*I
		Door:SetParent(nil)
		Door:SetPos(OrignialPos + Entity:GetForward()*FwdM + Entity:GetUp()*(UpM))
		Door:SetAngles(OrginialAngle + Angle(AngM,0,0))
		Door:SetParent(Entity)
		coroutine.yield()
	end
	Entity.DoorOpen = false
end

function ENT:Enter(ply)
	if not self.In then
		ply:Spectate( OBS_MODE_ROAMING )
		ply:StripWeapons()
		self.Entity:GetPhysicsObject():Wake()
		self.Entity:GetPhysicsObject():EnableMotion(true)
		self.In=true
		self:SetNWInt("PilotHealth",ply:Health())
		ply:DrawViewModel(false)
		ply:DrawWorldModel(false)
		ply:SetNWBool("isDriveShuttle6",true)
		ply:SetNWEntity("Shuttle6",self.Entity)
		
		self.Pilot=ply	
		self.NextExit = CurTime()+1
	else
		ply:ChatPrint(self.Pilot:Name().." is already flying this shuttle!")
	end
end

function ENT:Exit()
	if not (self.NextExit < CurTime()) then return end
	self.Pilot:SetHealth(self:GetNWInt("PilotHealth"))
	self.Pilot:UnSpectate()
	self.Pilot:DrawViewModel(true)
	self.Pilot:DrawWorldModel(true)
	self.Pilot:Spawn()
	self.Pilot:SetNWBool("isDriveShuttle6",false)
	self.Pilot:SetPos(self.Entity:GetPos()+self:GetForward()*-55+self:GetUp()*22)
	self.In = false
	self.Accel = {
		F = 0,
		R = 0,
		U = 0
	}	
	self.HoverPos = self.Entity:GetPos()
	if IsValid(self.PhaserBeam) then self.PhaserBeam:Remove() end
end

function ENT:Think()
	if self.In then
		if not IsValid(self.Pilot) then return end
		if self.Pilot:KeyDown(IN_USE) and self.NextExit<CurTime() then	
			self:Exit()
		end

		if self.Pilot:KeyDown(IN_RELOAD) then
			self:ToggleShield()
		end
		
		if self.Pilot:KeyDown(IN_ATTACK) then
			if self.PhaserCharge > 12 then
				if not IsValid(self.PhaserBeam) then
					self:Shoot1()
				end
				if not timer.Exists("ShuttlePhaserHeater_"..self.Entity:EntIndex()) then
					timer.Create( "ShuttlePhaserHeater_"..self.Entity:EntIndex(), 0.1, 0, function() 
						if self.PhaserCharge > 4 then
							self.PhaserCharge = self.PhaserCharge - 2
						else
							self.PhaserBeam:Remove()
							self.TimeSinceFired = CurTime()
							self.PhaserCharge = 0
							timer.Remove("ShuttlePhaserHeater_"..self.Entity:EntIndex())
						end
					end)
				end
					
			end
		else
			if IsValid(self.PhaserBeam) then
				self.PhaserBeam:Remove()
				if timer.Exists("ShuttlePhaserHeater_"..self.Entity:EntIndex()) then
					timer.Remove("ShuttlePhaserHeater_"..self.Entity:EntIndex())
				end
				self.TimeSinceFired = CurTime()
			end
		end
	end

	if self.PhaserCharge<100 and not IsValid(self.PhaserBeam) and self.TimeSinceFired+2 < CurTime() then
		self.PhaserCharge = self.PhaserCharge+4
		if self.PhaserCharge > 100 then self.phaserCharge = 100 end
	end
	self:SetNWInt("phaserCharge",self.PhaserCharge)

	if self.shieldCharge < self.MaxShield then
		self.shieldCharge = self.shieldCharge + 3
		if self.shieldCharge > self.MaxShield then
			self.shieldCharge = self.MaxShield
		end
	end
	self:SetNWInt("shieldCharge", self.shieldCharge)

    if not (WireAddon == nil) then
        self:TriggerOutput()
	end

	if StarTrek.LSInstalled then
		self:LSSupport()
	end
end

function ENT:Shoot1()
	if not IsValid(self.PhaserBeam) then
		self.PhaserBeam = ents.Create("phaser_beam_shuttle")
		self.PhaserBeam:SetPos(self.Entity:GetPos())
		self.PhaserBeam:Spawn()
		self.PhaserBeam:Activate()
		local posMod = Vector(0,0,0) + self:GetForward()*-60 + self:GetUp()*25
		self.PhaserBeam:Setup(self.Entity, posMod, 10, 40)
		self.PhaserBeam:SetParent(self.Entity)
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
		self.Shield:SetupProperties("shuttle_6")
		self.ShieldOn = true
		self:SetNWBool("ShieldOn", self.ShieldOn)
		self.lastShieldToggle = CurTime()
	end
end

function ENT:TakeShieldDamage(Dmg)
	if IsValid(self.Shield) then
		self.shieldCharge = self.shieldCharge - math.Round(Dmg)
		if self.shieldCharge <= 0 then
			self.Shield:Remove()
			self.ShieldOn = false
			self.shieldCharge = 0
		end
		self:SetNWInt("shieldCharge", self.shieldCharge)
		self:SetNWBool("shieldOn", self.ShieldOn)
	end
end

function ENT:OnTakeDamage(dmg) 
	local health=self:GetNWInt("health")
	local maxDmg = dmg:GetDamage()
	local actualDmg = maxDmg
	if self.ShieldOn then
		actualDmg = maxDmg*0.05
	else
		actualDmg = maxDmg/2
	end
	self:SetNWInt("health",health-actualDmg)
	if math.Round(self:GetNWInt("health")/self.MaxHull*100) <=0 then
		self:SetNWInt("health",0) 
		self:Boom()
	end
end

function ENT:PhysicsCollide(Data, Phys)
	if Data.DeltaTime > 0.5 then
		local hitObj = Data.HitEntity
		local hitClass = hitObj:GetClass()
		if hitClass == "player" or hitObj:GetParent() == self.Entity then return end
		local mass = self.Entity:GetPhysicsObject():GetMass()
		local hitDamage = Data.Speed / 2
		if self.ShieldOn and Data.Speed > 100 then
			self.Entity:TakeShieldDamage(hitDamage*0.2)
			hitDamage = 0
			if self.Shield then
				self.Shield:DrawHit(Data.HitPos,hitDamage)
			end
		elseif self.ShieldOn then
			hitDamage = 0
		end
		self.Entity:TakeDamage(hitDamage, game.GetWorld() , game.GetWorld() )
	end
end

function ENT:OnRemove()
	if self.In then
		self:Exit()
	end
	if IsValid(self.Door) then self.Door:RemoveCallOnRemove("shuttle6_respawndoor_"..self.Entity:EntIndex()) self.Door:Remove() end
	timer.Remove("ShuttlePhaserHeater_"..self.Entity:EntIndex())
	timer.Remove("shuttle6_door_"..self.Entity:EntIndex())
	if IsValid(self.PhaserBeam) then self.PhaserBeam:Remove() end
	if IsValid(self.Shield) then self.Shield:Remove() end
end

function ENT:Boom()
	if IsValid(self.Door) then self.Door:Remove() end
	if IsValid(self.Shield) then self.Shield:Remove() end
	self.Entity:NextThink(CurTime()+10)
	if self.In then
		if IsValid(self.Pilot) then
			self:Exit()
			self.Pilot:Kill()
		end
		local effect = EffectData()
		effect:SetOrigin( self.Entity:GetPos() + self.Entity:GetUp()*50)
		util.Effect( "shuttle_boom", effect )
	else
		local effect = EffectData()
		effect:SetOrigin( self.Entity:GetPos() + self.Entity:GetUp()*50)
		util.Effect( "shuttle_boom", effect )
	end
	self:Remove()
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

	local dirFwd = self.Entity:GetForward()*-1
	local accelFwd = 1500
	local dirRight = self.Entity:GetRight()*-1
	local accelRight = 750
	local dirUp = self.Entity:GetUp()
	local accelUp = 750
	local movePos = self.Entity:GetPos()
	local moveAng = Angle(0,0,0)	
	
	if self.In and not self.shouldExit then
		if self.Pilot:KeyDown(IN_FORWARD) and not self.Pilot:KeyDown(IN_BACK) then
			self.Accel.F = math.Approach(self.Accel.F, accelFwd, 10)
		elseif self.Pilot:KeyDown(IN_BACK) and not self.Pilot:KeyDown(IN_FORWARD) then
			self.Accel.F = math.Approach(self.Accel.F, -accelFwd, 10)
		else
			self.Accel.F = math.Approach(self.Accel.F, 0, 10)
		end

		if self.Pilot:KeyDown(IN_MOVERIGHT) and not self.Pilot:KeyDown(IN_MOVELEFT) then
			self.Accel.R = math.Approach(self.Accel.R, accelRight, 10)
		elseif self.Pilot:KeyDown(IN_MOVELEFT) and not self.Pilot:KeyDown(IN_MOVERIGHT) then
			self.Accel.R = math.Approach(self.Accel.R, -accelRight, 10)
		else
			self.Accel.R = math.Approach(self.Accel.R, 0, 10)
		end

		if self.Pilot:KeyDown(IN_JUMP) and not self.Pilot:KeyDown(IN_DUCK) then
			self.Accel.U = math.Approach(self.Accel.U, accelUp, 10)
		elseif self.Pilot:KeyDown(IN_DUCK) and not self.Pilot:KeyDown(IN_JUMP) then
			self.Accel.U = math.Approach(self.Accel.U, -accelUp, 10)
		else
			self.Accel.U = math.Approach(self.Accel.U, 0, 10)
		end

		movePos = movePos + (dirFwd*self.Accel.F) + (dirRight*self.Accel.R) + (dirUp*self.Accel.U)
		local aimVec = self.Pilot:GetAimVector()
		local pilotAim = aimVec:Angle()
		local extraRoll = math.Clamp(360+(self.Entity:GetAngles().Yaw - (pilotAim.Yaw+180)),-30,30)*(self.Accel.F/accelFwd)
		moveAng = Angle(-pilotAim.Pitch,pilotAim.Yaw+180,-extraRoll)
		moveParameters.pos = movePos
		moveParameters.angle = moveAng

	else
		if self.shouldExit then
			self.Accel = {
				F = math.Clamp(self.Accel.F-10, 0, 1000),
				R = math.Clamp(self.Accel.R-10, 0, 1000),
				U = math.Clamp(self.Accel.U-10, 0, 1000)
			}	
		end
		movePos = movePos + (dirFwd*self.Accel.F) + (dirRight*self.Accel.R) + (dirUp*self.Accel.U)
		if self.Accel.F == 0 and self.Accel.R == 0 and self.Accel.U == 0 then
			movePos = self.HoverPos
		end
		moveParameters.pos = movePos
		local currentAng = self.Entity:GetAngles()
		moveAng = Angle(0,currentAng.Yaw,0)
		moveParameters.angle = moveAng
	end
	phys:ComputeShadowControl(moveParameters)
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

function ENT:TriggerInput(k,v)
	if k== "Self Destruct" then
		if v == 1 then
			self:Boom()
		end
	end	
end	

function ENT:TriggerOutput()
	if WireLib then
		WireLib.TriggerOutput( self.Entity, "Hull", math.Round(self:GetNWInt("Health", 100) / self.MaxHull * 100))
		WireLib.TriggerOutput( self.Entity, "Shield", self.shieldCharge)
	end
end

net.Receive( "ST_Shuttle6_NetHook", function( Len, Ply )
	local Id = net.ReadUInt(4)
	local shuttle = net.ReadEntity()
	if not IsValid(shuttle) or shuttle:GetClass() != "shuttle_6" then return end
	if Id == 1 then
		if shuttle.NextDoorToggle < CurTime() and not shuttle.In then shuttle:ToggleDoor() end
	elseif Id == 2 then
		local toEnter = net.ReadEntity()
		if toEnter != Ply then return end
		shuttle:Enter(toEnter)
	end
end )