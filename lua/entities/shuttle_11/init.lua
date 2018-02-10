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
function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local ent = ents.Create( "shuttle_11" )
	ent:SetPos( tr.HitPos + Vector(0,0,-120) )
	ent:SetAngles(Angle(0,ply:GetAimVector():Angle().Yaw+180,0))
	ent:Spawn()
	ent:SetVar("Owner",ply)
	return ent
end

function ENT:Initialize()
	self.PositionSet = false
	self.Target = Vector(0,0,0)
	self.Entity:SetModel( "models/apwninthedarks_starship_pack/shuttlecraft/type_11_shuttle.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow(true)
		local phys = self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:SetMass(60000)
		end
	self.Entity:SetUseType( SIMPLE_USE )
	self.Entity:StartMotionController()
	self.Entity:GetPhysicsObject():EnableMotion(false)
	self.Accel = {F = 0,R = 0,U = 0}
	self.HoverPos = self.Entity:GetPos()
	self.DoorOpen = false
	self.CanExit = true
	self.Owner = self.Entity:GetOwner()
	self:SetVar("Owner",self.Owner)
	self.EntHealth = 10000
	self.TorpDelay = 3
	self.TorpRefreshTime = CurTime()
	self:SetNWInt("TorpLoad",self.TorpDelay)
	self.TorpChange = 1
	self.Torp2Delay = CurTime()
	self.PhaserCharge = 100
	self:SetNWInt("phaserCharge",self.PhaserCharge)
	self.BeamPerson = self:GetOwner()
	self:SetNWInt("health",self.EntHealth)
	self.shieldCharge = 5000
	self:SetNWInt("shieldCharge",self.shieldCharge)
	self.lastShieldToggle = CurTime()
	self:SetNWEntity("owner",self.Owner)
	self:SetNWEntity("entity",self.Entity)
	self.PhaserBeam = nil

	self.ShieldHealth = 1000
	self.ShieldOn = false
	self:SetNWBool("shieldOn", self.ShieldOn)
	self.NextDoorToggle = CurTime()
	self.TimeSinceFired = CurTime()
	self.fwd = 0
	self.right = 0
	self.WireWarpDest = Vector(0,0,0)
	
	if not (WireAddon == nil) then
		self.Inputs = Wire_CreateInputs(self.Entity, { "Self Destruct","Beam Up","Beam Down","Warp","Warp Destination [VECTOR]" })
		self.Outputs = Wire_CreateOutputs(self.Entity, { "Hull","Shield" }) 
	end
	
	self.Door = ents.Create("prop_physics")
		self.Door:SetModel("models/apwninthedarks_starship_pack/doors/door___type_11_shuttle.mdl")
		self.Door:SetPos(self:GetPos()+self:GetForward()*212.4+self:GetUp()*124.7)
		self.Door:SetAngles(self:GetAngles()+Angle(0,0,0))
		
		self.Door:Spawn()
		self.Door:Activate()
		self.Door:SetParent(self)
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
	if math.Round(self:GetNWInt("health")/10000*100) <=0 then
		self:SetNWInt("health",0) 
		self:Boom()
	end
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
		ply:SetNWBool("isDriveShuttle11",true)
		ply:SetNWEntity("Shuttle11",self.Entity)
		if self.DoorOpen then
			self:ToggleDoor()
		end
		self.Pilot=ply	
		self.NextExit = CurTime()+1
	else
		ply:ChatPrint(self.Pilot:Name().." is already flying this shuttle!")
	end
end
net.Receive( "ST_Shuttle11_NetHook", function( Len, Ply )
	local Id = net.ReadUInt(4)
	local shuttle = net.ReadEntity()
	if not IsValid(shuttle) or shuttle:GetClass() != "shuttle_11" then return end
	if Id == 1 then
		local toEnter = net.ReadEntity()
		if toEnter != Ply then return end
		shuttle:Enter(toEnter)
	elseif Id == 2 then
		if shuttle.NextDoorToggle < CurTime() and not shuttle.In then shuttle:ToggleDoor() end
	elseif Id == 3 then
		shuttle:ToggleShield()
	elseif Id == 4 then
		shuttle:EndWarp()
	end
end )

function ENT:ToggleDoor(Ply)
	if not IsValid(self.Door) then return end
 	if self.DoorOpen then
	 	local fx = EffectData()
		fx:SetScale(1)
		fx:SetEntity(self.Entity)
		util.Effect("shuttle11Door", fx, true)
		self.DoorOpen = false
		self.Door:SetParent(nil)
		self.Door:SetPos(self:GetPos()+self:GetForward()*212.4+self:GetUp()*124.7)
		self.Door:SetAngles(self:GetAngles()+Angle(0,0,0))
		self.Door:SetParent(self.Entity)
		timer.Create("shuttle11door_"..self.Entity:EntIndex(), 1.5, 1, function()
			self.Door:SetNoDraw(false)
		end)
	else
		local fx = EffectData()
		fx:SetScale(2)
		fx:SetEntity(self.Entity)
		util.Effect("shuttle11Door", fx, true)
		self.DoorOpen = true
		self.Door:SetParent(nil)
		self.Door:SetPos(self.Entity:GetPos()+self.Entity:GetForward()*195+self.Entity:GetUp()*90)
		self.Door:SetAngles(self:GetAngles()+Angle(20,0,0))
		self.Door:SetParent(self.Entity)
		timer.Create("shuttle11door_"..self.Entity:EntIndex(), 1.5, 1, function()			
			self.Door:SetNoDraw(false)
		end)
	end
	self.Door:SetNoDraw(true)
	self.NextDoorToggle = CurTime()+3
end

function ENT:PhysicsCollide(Data, Phys)
	if Data.DeltaTime > 0.5 then
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

function ENT:UpdateTransmitState() 
	return TRANSMIT_ALWAYS
end

function ENT:OnRemove() 
	if self.In then
		self.Pilot:UnSpectate()
		self.Pilot:DrawViewModel(true)
		self.Pilot:DrawWorldModel(true)
		self.Pilot:Spawn()
		self.Pilot:SetNWBool("isDriveShuttle11",false)
		self.Pilot:SetPos(self.Entity:GetPos()+Vector(0,0,100))
	end
	if self.transportInProgress then
		self.Owner:Freeze( false )
		self.Owner:SetMoveType(MOVETYPE_WALK)
		self.Owner:SetCollisionGroup(COLLISION_GROUP_NONE )
	end
	timer.Remove("shuttle11beam1_"..self.Entity:EntIndex())
	timer.Remove("shuttle11beam2_"..self.Entity:EntIndex())
	timer.Remove("ShuttlePhaserHeater_"..self.Entity:EntIndex())
	timer.Remove("shuttle11door_"..self.Entity:EntIndex())

	if IsValid(self.PhaserBeam) then self.PhaserBeam:Remove() end
	if IsValid(self.Shield) then self.Shield:Remove() end
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
		self.Accel = {
			F = math.Approach(self.Accel.F, 0, 10),
			R = math.Approach(self.Accel.R, 0, 10),
			U = math.Approach(self.Accel.U, 0, 10)
		}	
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

function ENT:Warp()
	if (util.IsInWorld(self.WireWarpDest)) then
		self.jumpPoint = self.WireWarpDest
		self.CanExit = false
		self.Entity:StopMotionController()
		self.Entity:GetPhysicsObject():EnableMotion(false)
		self.Entity:SetNoDraw(true)
		self.Door:SetNoDraw(true)
		local WarpOut = EffectData()
		WarpOut:SetEntity(self.Entity)
		WarpOut:SetStart(self.jumpPoint + self.Entity:GetForward()*600)
		util.Effect( "shuttle11_warp", WarpOut )
	end
end

function ENT:EndWarp()
	self.Entity:SetPos(self.jumpPoint)
	self.HoverPos = self.jumpPoint
	self.CanExit = true
	self.Entity:StartMotionController()
	self.Entity:GetPhysicsObject():EnableMotion(true)
	self.Entity:GetPhysicsObject():Wake()
	self.Entity:SetNoDraw(false)
	self.Door:SetNoDraw(false)
end
function ENT:BeamUp()
	if self.transportInProgress then return end
	if not self.In and IsValid(self.Owner) then
		self.transportInProgress = true
		self.Owner:EmitSound("beamOutSound.mp3")
		local dest = self.Entity:GetPos()+self:GetForward()*-45+self:GetUp()*170
		local fx = EffectData()
			fx:SetEntity(self.Owner)
			fx:SetOrigin(self.Owner:GetPos())
			util.Effect("TransporterBeamOut",fx, true, true )
			self.Owner:Freeze( true )
			self.Owner:SetMoveType(MOVETYPE_NOCLIP)
			self.Owner:SetCollisionGroup(COLLISION_GROUP_WORLD )
			timer.Create("shuttle11beam1_"..self.Entity:EntIndex(), 3.3, 1, function()
				self.Owner:EmitSound("beamInSound.mp3")
				self.Owner:SetPos(dest)
				self.Owner:SetEyeAngles(self.Entity:GetAngles())
				local fx = EffectData()
				fx:SetEntity(self.Owner)
				fx:SetOrigin(self.Owner:GetPos())
				util.Effect("TransporterBeamIn",fx, true, true )
				timer.Create("shuttle11beam2_"..self.Entity:EntIndex(), 3, 1, function()
					self.Owner:Freeze( false )
					self.Owner:SetMoveType(MOVETYPE_WALK)
					self.Owner:SetCollisionGroup(COLLISION_GROUP_NONE )
					self.transportInProgress = false
				end)
			end)
	else
		PrintMessage(HUD_PRINTTALK,"[Shuttle_11]You can't beam while you are flying!")
	end
end

function ENT:BeamDown()
	if self.transportInProgress then return end
	if not self.In and IsValid(self.Owner) then
		self.transportInProgress = true
		self.Owner:EmitSound("beamOutSound.mp3")
		local trace = {}
			trace.start = self.Entity:GetPos()
			trace.endpos = self.Entity:GetPos()+self:GetForward()*-45+self:GetUp()*-10^14
			trace.filter = self.Owner
		local tr = util.TraceLine(trace)
		local dest = tr.HitPos
		local fx = EffectData()
				fx:SetEntity(self.Owner)
				fx:SetOrigin(self.Owner:GetPos())
				util.Effect("TransporterBeamOut",fx, true, true )
				self.Owner:Freeze( true )
				self.Owner:SetMoveType(MOVETYPE_NOCLIP)
				timer.Create("shuttle11beam1_"..self.Entity:EntIndex(), 3.3, 1, function()
				self.Owner:EmitSound("beamInSound.mp3")
				self.Owner:SetPos(dest)
				self.Owner:SetEyeAngles(self.Entity:GetAngles())
				local fx = EffectData()
				fx:SetEntity(self.Owner)
				fx:SetOrigin(self.Owner:GetPos())
				util.Effect("TransporterBeamIn",fx, true, true )
				timer.Create("shuttle11beam2_"..self.Entity:EntIndex(), 3, 1, function()
						self.Owner:Freeze( false )
						self.Owner:SetMoveType(MOVETYPE_WALK)
						self.transportInProgress = false
					end)
				end)
	else
		self.Pilot:ChatPrint("[Shuttle_11]You can't beam while you are flying!")
	end
end


function ENT:Exit()
	if IsValid(self.PhaserBeam) then
		self.PhaserBeam:Remove()
	end
	self.Pilot:SetHealth(self:GetNWInt("PilotHealth"))
	self.Pilot:UnSpectate()
	self.Pilot:DrawViewModel(true)
	self.Pilot:DrawWorldModel(true)
	self.Pilot:Spawn()
	self.Pilot:SetNWBool("isDriveShuttle11",false)
	self.Pilot:SetPos(self.Entity:GetPos()+self:GetForward()*-180+self:GetUp()*180)
	self.In = false
	self.Accel = {
	F = 0,
	R = 0,
	U = 0
	}		
	self.HoverPos = self.Entity:GetPos()
	self.shouldExit = false
end

function ENT:LSSupport()
	
end

function ENT:Think()
	if (self.In and self.NextExit<CurTime()) then
		if self.Pilot:KeyDown(IN_USE) then	
			if self.CanExit then
				self.shouldExit = true
			end
		end
	end
	if self.In then
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

		if self.In and IsValid(self.Pilot) then
			self.Pilot:SetPos(self.Entity:GetPos()+self:GetForward()*-180+self:GetUp()*180)
		end

		if self.Pilot:KeyDown(IN_ATTACK2) then
			if self.TorpDelay > 0 then
				self:Shoot2()
			end
		end
		if self.Pilot:KeyDown(IN_RELOAD) then
			self:ToggleShield()
		end
	end
	if not (WireAddon == nil) then
		self:TriggerOutput()
	end
	if self.TorpDelay<3 and self.TorpRefreshTime + 5 < CurTime() then
		self.TorpDelay = self.TorpDelay+1
		self.TorpRefreshTime = CurTime()
		self:SetNWInt("TorpLoad",self.TorpDelay)
	end
	if self.TorpDelay == 3 then
		self.TorpRefreshTime = CurTime()
	end
	if self.PhaserCharge<100 and not IsValid(self.PhaserBeam) and self.TimeSinceFired+2 < CurTime() then
		self.PhaserCharge = self.PhaserCharge+4
		if self.PhaserCharge > 100 then self.phaserCharge = 100 end
	end
	self:SetNWInt("phaserCharge",self.PhaserCharge)

	if self.shieldCharge < 5000 then
		self.shieldCharge = self.shieldCharge + 5
		if self.shieldCharge > 5000 then
			self.shieldCharge = 5000
		end
	end
	self:SetNWInt("shieldCharge", self.shieldCharge)

	if self.shouldExit and self.Accel.F == 0 and self.Accel.R == 0 and self.Accel.U == 0 then
		self:Exit()
	end
	self.Entity:NextThink(CurTime()+0.05)
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
function ENT:ToggleShield()
	if not (self.lastShieldToggle+1 < CurTime()) then return end
	if self.ShieldOn == true then
		self.ShieldOn = false
		if IsValid(self.Shield) then
			self.Shield:Deactivate()
		end
		self:SetNWBool("shieldOn", self.ShieldOn)
		self.lastShieldToggle = CurTime()
	else
		if IsValid(self.Shield) then return end
		if self.shieldCharge < 500 then return end
		self.Shield = ents.Create("shield_shuttle_bubble")
		self.Shield:SetAngles(self.Entity:GetAngles())
		self.Shield:SetPos( self.Entity:GetPos() + self.Entity:GetUp()*170 )
		self.Shield:Spawn()
		self.Shield:SetupProperties(Vector(25,25,15))
		self.Shield:SetParent(self)
		self.ShieldOn = true
		self:SetNWBool("shieldOn", self.ShieldOn)
		self.lastShieldToggle = CurTime()
	end
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
		effect:SetOrigin( self.Entity:GetPos() + self.Entity:GetUp()*230)
		util.Effect( "shuttle_boom", effect )
		self:Remove()
	else
		local effect = EffectData()
		effect:SetOrigin( self.Entity:GetPos() + self.Entity:GetUp()*230)
		util.Effect( "shuttle_boom", effect )
		self:Remove()
	end
end

function ENT:Shoot1()
	if not IsValid(self.PhaserBeam) then
		self.PhaserBeam = ents.Create("phaser_beam_shuttle")
		self.PhaserBeam:SetPos(self.Entity:GetPos())
		self.PhaserBeam:Spawn()
		self.PhaserBeam:Activate()
		self.PhaserBeam:Setup(self.Entity,20,60)
		self.PhaserBeam:SetParent(self.Entity)
	end
end

function ENT:Shoot2()
	self.TorpDelay = self.TorpDelay-1
	self:SetNWInt("TorpLoad",self.TorpDelay)
	self.Entity:EmitSound("photonTorpedoSound.wav")
	--self.Pilot:EmitSound("photonTorpedoSound.mp3")
	local torp1 = ents.Create("torpedo_pulse")
	torp1:SetPos(self.Entity:GetPos()+ self.Entity:GetUp()*190 + self.Entity:GetForward()*-360)
	torp1:SetOwner(self.Entity:GetOwner())
	torp1.FiredFrom = self.Entity
	torp1:Spawn()
	torp1:Settings(self:GetForward()*-1, 1500, 350, Vector(20,20,20))
	torp1:Activate()
end

function ENT:TriggerInput(k,v)
	if(k=="Self Destruct") then
		if v == 1 then
			self:Boom()
		end
	elseif(k=="Beam Up") then
		if v == 1 then
			self:BeamUp()
		end
	elseif(k=="Beam Down") then
		if v == 1 then
		self:BeamDown()
		end
	elseif(k=="Warp") then
		if v == 1 then
			self:Warp()
		end
	elseif(k=="Warp Destination") then
		self.WireWarpDest = v
		self.WarpDest = true
	end
		
end	

function ENT:TriggerOutput()
	if WireLib then
		WireLib.TriggerOutput( self.Entity, "Hull", self:GetNWInt("health")/10000*100)
		WireLib.TriggerOutput( self.Entity, "Shield", self.shieldCharge)
	end
end