AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound("mwc/mwc_on.wav")

include('shared.lua')
function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local ent = ents.Create( "type11shuttle" )
	ent:SetPos( tr.HitPos + Vector(0,0,-120) )
	ent:SetAngles(Angle(0,-ply:GetAimVector():Angle().Yaw,0));
	ent:Spawn()
	ent:SetVar("Owner",ply);
	return ent
end

function ENT:Initialize()
	self.PositionSet = false;
	self.Target = Vector(0,0,0)
	--self.BaseClass.Initialize(self)
	self.Entity:SetModel( "models/type11shuttle/Type11/Type 11 Shuttle.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow(true);
		local phys = self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:SetMass(60000)
		end
	self.Entity:StartMotionController()
	self.Entity:GetPhysicsObject():EnableMotion(false)
	self.Accel=0
	self.EngineOn = true
	self.DoorOpen = true
	self.CanExit = true
	self:SetVar("Owner",ply);
	self.EntHealth = 10000
	--self.SetHealth( 999999999 )
	self.TorpDelay = 99
	self:SetNetworkedInt("TorpLoad",self.TorpDelay)
	self.TorpChange = 1
	self.Torp2Delay = CurTime()
	self.PhaserCharge = 100
	self:SetNetworkedInt("phaserCharge",self.PhaserCharge)
	self.BeamPerson = self:GetOwner()
	self:SetNetworkedInt("health",self.EntHealth)
	self:SetNetworkedEntity("owner",self.Owner)
	self:SetNetworkedEntity("entity",self.Entity)

	self.NextDoorToggle = CurTime()
	
	self.HoverPos = self:GetPos();
	self.fwd = 0
	self.right = 0
	
	self.WireWarpDest = Vector(0,0,0)
	
	if not (WireAddon == nil) then
		--self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self.Entity, { "Self Destruct","Beam Up","Beam Down","Warp","Warp Destination [VECTOR]" })
		self.Outputs = Wire_CreateOutputs(self.Entity, { "Hull", "Output" }) 
	end

	
		
	self.Door = ents.Create("prop_physics")
		self.Door:SetModel("models/type11shuttle/Door/Door - Type 11 Shuttle.mdl")
		self.Door:SetPos(self:GetPos()+self:GetForward()*212.4+self:GetUp()*124.7)
		self.Door:SetAngles(self:GetAngles()+Angle(0,0,0))
		
		self.Door:Spawn()
		self.Door:Activate()
		self.Door:SetParent(self)
		--self:SetNetworkedEntity("door",Door)
	/*self.DoorContr = ents.Create("prop_physics")
		self.DoorContr:SetModel("models/LCARS/lcars_doorpanel_off.mdl")
		self.DoorContr:SetPos(self:GetPos()+self:GetForward()*-15+self:GetUp()*225)
		self.DoorContr:SetAngles(self:GetAngles()+Angle(90,0,0))
		self.DoorContr:Spawn()
		self.DoorContr:Activate()
		self.DoorContr:SetParent(self)
*/
end

function ENT:OnTakeDamage(dmg) --########## Darts aren't invincible are they? @RononDex

	local health=self:GetNetworkedInt("health")
	self:SetNetworkedInt("health",health-dmg:GetDamage()) -- Sets heath(Takes away damage from health)
	if dmg:GetDamage() > 2 then
		self.Entity:EmitSound("console_explo_01.mp3")
	end
	if((health-dmg:GetDamage())/10000*100<1) then
		self:Boom() -- Go boom
	end
end



function ENT:Use(ply,caller)
local pos = self:WorldToLocal(ply:GetPos()) - Vector(-220,0,120)
local pos2 = self:WorldToLocal(ply:GetPos()) - Vector(-15,0,120)
	if ((pos.x > -20 and pos.x < 30)and(pos.y > -30 and pos.y < 30)and(pos.z > -2 and pos.z < 80)) then
if not self.In then
	ply:Spectate( OBS_MODE_ROAMING ) -- OBS_MODE_ROAMING, OBS_MODE_IN_EYE
	ply:StripWeapons()
	self.Entity:GetPhysicsObject():Wake()
	self.Entity:GetPhysicsObject():EnableMotion(true)
	self.In=true
	self:SetNetworkedInt("PilotHealth",ply:Health())
	ply:DrawViewModel(false)
	ply:DrawWorldModel(false)
	ply:SetNetworkedBool("isDriveShuttle11",true)
	ply:SetNetworkedEntity("Shuttle11",self.Entity)
	--ply:SetViewAngles(self:GetAngles.Pitch,self:GetAngles.Yaw,self:GetAngles.Roll)
	self.Pilot=ply	
	self.EngineOn = true
	self.NextExit = CurTime()+1;
	end
	elseif((pos2.x > -20 and pos2.x < 30)and(pos2.y > -30 and pos2.y < 30)and(pos2.z > -2 and pos2.z < 80)and self.NextDoorToggle < CurTime()+2) then
		if self.DoorOpen == true then
			self.DoorOpen = false
			self:CloseDoor()
			self.NextDoorToggle = CurTime()
		elseif self.DoorOpen == false then
			self.DoorOpen = true
			self:OpenDoor()
			self.NextDoorToggle = CurTime()
		end
	end
	
end

function ENT:CloseDoor()
	--self.Door:SetPos(self:GetPos()+self:GetForward()*212.4+self:GetUp()*124.7)
		self.Door:SetAngles(self:GetAngles()+Angle(0,0,0))
	print("Close")
end

function ENT:OpenDoor()
		--self.Door:SetPos(self.Entity:GetPos()+self.Entity:GetForward()*195+self.Entity:GetUp()*90)
		self.Door:SetAngles(self:GetAngles()+Angle(20,0,0))
	print("Open")
end

function ENT:PhysicsCollide(cdat, phys)

	if cdat.DeltaTime > 0.5 then --0.5 seconds delay between taking physics damage
		local mass = (cdat.HitEntity:GetClass() == "worldspawn") and 2000 or cdat.HitObject:GetMass(); --if it's worldspawn use 1000 (worldspawns physobj only has mass 1), else normal mass
		local PysCollDamage = (cdat.Speed*cdat.Speed*math.Clamp(mass, 0, 1000))/9000000
		self:TakeDamage((cdat.Speed*cdat.Speed*math.Clamp(mass, 0, 1000))/9000000);
		if PysCollDamage > 100 then 
			if self.EngineOn then
			--self.EngineOn = false
			self.fwd = self.fwd/2
			timer.Simple(1.5,
			function()
				self.EngineOn = true
			end);
			end
		end
	end
end



function ENT:OnRemove() 
	if self.In then
	self.Pilot:UnSpectate()
	self.Pilot:DrawViewModel(true)
	self.Pilot:DrawWorldModel(true)
	self.Pilot:Spawn()
	self.Pilot:SetNetworkedBool("isDriveShuttle11",false)
	self.Pilot:SetPos(self.Entity:GetPos()+Vector(0,0,100))
	end
end


local ZAxis = Vector(0,0,1);
function ENT:PhysicsSimulate( phys, deltatime )
self.Hover = true
local UP = ZAxis;
local FWD = self.Entity:GetForward();
local RIGHT = FWD:Cross(UP):GetNormalized();
	if self.In and self.EngineOn then
		if (self.Pilot:KeyDown(IN_FORWARD) and self.Pilot:KeyDown(IN_SPEED) ) then
            self.fwd=-3000
			

		elseif self.Pilot:KeyDown(IN_BACK) then
            self.fwd=1500
			


		elseif self.Pilot:KeyDown(IN_FORWARD) then
            self.fwd=-1500
			


		else
		self.fwd = 0
		end
			
		self.Accel=math.Approach(self.Accel,self.fwd,10)
		 
		
		
		local move={}
			move.secondstoarrive	= 1
			move.pos = self.Entity:GetPos()+self.Entity:GetForward()*self.Accel
				if self.Pilot:KeyDown( IN_DUCK ) then
                   move.pos = move.pos+self.Entity:GetUp()*-400
               elseif self.Pilot:KeyDown( IN_JUMP ) then
                   move.pos = move.pos+self.Entity:GetUp()*400
				end
				
				if self.Pilot:KeyDown( IN_MOVERIGHT ) then
					move.pos = move.pos+self.Entity:GetRight()*-400
				elseif self.Pilot:KeyDown( IN_MOVELEFT ) then
					move.pos = move.pos+self.Entity:GetRight()*400
				end
			local pos = self:GetPos()
			local aim = self.Pilot:GetAimVector();
			local ang = aim:Angle();
			local ExtraRoll = math.Clamp(math.deg(math.asin(self:WorldToLocal(pos + aim).y)),-25,25);
            			
			move.maxangular		= 2000
			move.maxangulardamp	= 10000
			move.maxspeed			= 1000000
			move.maxspeeddamp		= 10000
			move.dampfactor		= 0.7
			local ang = Angle(-self.Pilot:GetAimVector():Angle().Pitch,self.Pilot:GetAimVector():Angle().Yaw+180,-ExtraRoll/2000*-self.Accel)
			move.angle			= ang -- Angle(0,180,0)
			move.deltatime		= deltatime
			phys:ComputeShadowControl(move)
		else
		
	end
end

function ENT:BeamUp()
	if not self.In then
		self.Owner:EmitSound("tng_transporter_out.mp3")
		local dest = self.Entity:GetPos()+self:GetForward()*-45+self:GetUp()*170
		local fx = EffectData()
				fx:SetEntity(self.Owner)
				fx:SetOrigin(self.Owner:GetPos())
				util.Effect("TransporterBeamOut",fx, true, true );
				self.Owner:Freeze( true )
				self.Owner:SetMoveType(MOVETYPE_NOCLIP)
				self.Owner:SetCollisionGroup(COLLISION_GROUP_WORLD )
			timer.Simple(3.3,function()
				self.Owner:EmitSound("tng_transporter_in.mp3")
				self.Owner:SetPos(dest)
				self.Owner:SetEyeAngles(self.Entity:GetAngles())
				local fx = EffectData()
				fx:SetEntity(self.Owner)
				fx:SetOrigin(self.Owner:GetPos())
				util.Effect("TransporterBeamIn",fx, true, true );
					timer.Simple(3,function()
						self.Owner:Freeze( false )
						self.Owner:SetMoveType(MOVETYPE_WALK)
						self.Owner:SetCollisionGroup(COLLISION_GROUP_NONE )
					end);
				end);
	else
		PrintMessage(HUD_PRINTTALK,"[Shuttle_11]You can't beam while you are flying!")
	end
end

function ENT:BeamDown()
	if not self.In then
		self.Owner:EmitSound("tng_transporter_out.mp3")
		local trace = {}
			trace.start = self.Entity:GetPos()
			trace.endpos = self.Entity:GetPos()+self:GetForward()*-45+self:GetUp()*-10^14
			trace.filter = self.Owner
		local tr = util.TraceLine(trace)
		local dest = tr.HitPos
		local fx = EffectData()
				fx:SetEntity(self.Owner)
				fx:SetOrigin(self.Owner:GetPos())
				util.Effect("TransporterBeamOut",fx, true, true );
				self.Owner:Freeze( true )
				self.Owner:SetMoveType(MOVETYPE_NOCLIP)
			timer.Simple(3.3,function()
				self.Owner:EmitSound("tng_transporter_in.mp3")
				self.Owner:SetPos(dest)
				self.Owner:SetEyeAngles(self.Entity:GetAngles())
				local fx = EffectData()
				fx:SetEntity(self.Owner)
				fx:SetOrigin(self.Owner:GetPos())
				util.Effect("TransporterBeamIn",fx, true, true );
					timer.Simple(3,function()
						self.Owner:Freeze( false )
						self.Owner:SetMoveType(MOVETYPE_WALK)
					end);
				end);
	else
		PrintMessage(HUD_PRINTTALK,"[Shuttle_11]You can't beam while you are flying!")
	end
end


function ENT:Exit()
if self.EngineOn then
self.Entity:GetPhysicsObject():EnableMotion(false)
self.Entity:SetAngles(Angle(0,self:GetAngles().Yaw,0))
			self.Pilot:SetHealth(self:GetNetworkedInt("PilotHealth"))
			self.Pilot:UnSpectate()
			self.Pilot:DrawViewModel(true)
			self.Pilot:DrawWorldModel(true)
			self.Pilot:Spawn()
			self.Pilot:SetNetworkedBool("isDriveShuttle11",false)
			self.Pilot:SetPos(self.Entity:GetPos()+self:GetForward()*-180+self:GetUp()*180)
			self.In = false
			self.Accel = 0
else
			self.Pilot:SetHealth(self:GetNetworkedInt("PilotHealth"))
			self.Pilot:UnSpectate()
			self.Pilot:DrawViewModel(true)
			self.Pilot:DrawWorldModel(true)
			self.Pilot:Spawn()
			self.Pilot:SetNetworkedBool("isDriveShuttle11",false)
			self.Pilot:SetPos(self.Entity:GetPos()+self:GetForward()*-180+self:GetUp()*180)
			--self.Pilot:Give("phaser")
			--self.Pilot:SelectWeapon("phaser")
			self.In = false
			self.Accel = 0
end
			
end

function ENT:LSSupport()

	local ent_pos = self:GetPos();

	if(IsValid(self)) then
		for _,p in pairs(player.GetAll()) do -- Find all players
			local pos = (p:GetPos()-ent_pos):Length(); -- Where they are in relation to the jumper
			if(pos<800 and p.suit) then -- If they're close enough
				if(not(StarGate.RDThree())) then
					p.suit.air = 100; -- They get air
					p.suit.energy = 100; -- and energy
					p.suit.coolant = 100; -- and coolant
				else
					p.suit.air = 200; -- We need double the amount of LS3(No idea why)
					p.suit.coolant = 200;
					p.suit.energy = 200;
				end
			end
		end
	end
end

function ENT:Think()
	if (self.In and self.NextExit<CurTime()) then
	--self.Entity:EmitSound("shuttlecraft/shuttle_interior_loop2.wav")
		if self.Pilot:KeyDown(IN_USE) then	
			if self.CanExit then
				self:Exit(true);
			end
		end

		if self.Pilot:KeyDown(IN_ATTACK) then
			if self.PhaserCharge > 1 then
				--self:Shoot1();
				timer.Create("PhaserShoot",0.1,0,self:Shoot1())
				self.PhaserCharge = self.PhaserCharge--2.8
			end
		elseif self.Pilot:KeyDown(IN_ATTACK2) then
			if self.TorpDelay >= 33 and self.Torp2Delay < CurTime() then
				local torp = math.Round(math.random(1,4))
					self.Torp2Delay = CurTime()+1
					if ( torp == 1 or torp == 2 or torp == 3 )then
						self:Shoot2()
					elseif torp == 4 then
						self:Shoot3()
					end
			end
		
		end
		if self.Pilot:KeyDown(IN_RELOAD) then
			if self.EngineOn then
				self.EngineOn = false
				self.fwd = 0
			else
				self.EngineOn = true
			end
		end
	end
	if not (WireAddon == nil) then
		self:TriggerOutput()
	end
	if self.HasRD then
		self:LSSupport()
	end
	if self.TorpDelay<100 then
	self.TorpDelay = self.TorpDelay+1
	self:SetNetworkedInt("TorpLoad",self.TorpDelay)
	end
	if self.PhaserCharge<100 then
	self.PhaserCharge = self.PhaserCharge+0.7
	self:SetNetworkedInt("phaserCharge",self.PhaserCharge)
	end

	self.Entity:NextThink(CurTime()+2)
end

function ENT:Boom()
	
	if self.In then
		self.CanExit = false
		self.EngineOn = false
		timer.Simple(3.0,function()
			self:Exit(true);
			self.Pilot:Kill();
			self.Entity:Remove();
			local effect = EffectData()
			effect:SetOrigin( self:GetPos() )
			effect:SetNormal( self:GetUp() )
			util.Effect( "shuttle_boom", effect )
			
			--util.BlastDamage( self.Entity, self.Entity, self:GetPos()+Vector(0,0,220), 1000, 120 );
		
		end);
		
		else
		local effect = EffectData()
			effect:SetOrigin( self:GetPos() )
			effect:SetNormal( self:GetUp() )
			util.Effect( "shuttle_boom", effect )
			self.Entity:Remove();
			util.BlastDamage( self.Entity, self.Entity, self:GetPos()+Vector(0,0,220), 1000, 120 );
	end

end

function ENT:Shoot1()
	if self.Pilot:KeyDown(IN_ATTACK) then
	print("ok")
		self.Pilot:EmitSound("pulse_weapons/phaser.mp3")

/*
local phaser = ents.Create("phaser_pulse");
	phaser:PrepareBullet(self:GetForward()*-1, 0, 12000, 50, {self.Entity});
	phaser:SetPos(self.Entity:GetPos()+self.Entity:GetUp()*220);
	phaser:SetOwner(self);
	phaser.Owner = self;
	phaser:Spawn();	
	phaser.Damage = 140;
	phaser:Activate();
	phaser:SetRenderMode(RENDERMODE_TRANSALPHA)
	phaser:SetColor(Color(255,120,0,255));
*/
	local trace = {}
			trace.start = self.Entity:GetPos()+self:GetForward()*-150+self:GetUp()*-180
			trace.endpos = self.Entity:GetPos()+self:GetForward()*-100000+self:GetUp()*-180
			trace.filter = self.Owner
		local tr = util.TraceLine(trace)
	
	local beameffect = EffectData()
		beameffect:SetStart(self.Entity:GetPos()+self:GetForward()*-150+self:GetUp()*180)
		beameffect:SetOrigin(tr.HitPos)
		util.Effect( "phaserBeam", beameffect )
	end
end
function ENT:Shoot2()
self.TorpDelay = self.TorpDelay-33
self.Pilot:EmitSound("photorp.wav")
local torp1 = ents.Create("torpedo_pulse");
	torp1:PrepareBullet(self:GetForward()*-1, 0, 5000, 180, {self.Entity});
	torp1:SetPos(self.Entity:GetPos()+self.Entity:GetUp()*220);
	torp1:SetOwner(self);
	torp1.Owner = self;
	torp1:Spawn();
	torp1.Damage = 240;
	torp1:Activate();
	torp1:SetRenderMode(RENDERMODE_TRANSALPHA)
	torp1:SetColor(Color(255,0,0,255));
	
end

function ENT:Shoot3()
self.TorpDelay = self.TorpDelay-33
self.Pilot:EmitSound("quanttorp.mp3")
local torp2 = ents.Create("torpedo_pulse");
	torp2:PrepareBullet(self:GetForward()*-1, 0, 4000, 220, {self.Entity});
	torp2:SetPos(self.Entity:GetPos()+self.Entity:GetUp()*220);
	torp2:SetOwner(self);
	torp2.Owner = self;
	torp2:Spawn();
	torp2.Damage = 3100;
	torp2:Activate();
	torp2:SetRenderMode(RENDERMODE_TRANSALPHA)
	torp2:SetColor(Color(80,100,255,255));
	
end



function ENT:Warp()
	if (self.In) then 
		if (util.IsInWorld(self.WireWarpDest)) then
			self.CanExit = false
			self.Entity:GetPhysicsObject():EnableMotion(false)
			self.EngineOn = false
			self.fwd = 0
			self.Owner:EmitSound("shuttlecraft/transwarp.mp3")
			self.Entity:EmitSound("shuttlecraft/transwarp.mp3")
			local WarpOut = EffectData()
				WarpOut:SetEntity(self.Entity)
				util.Effect( "shuttle11_warp", WarpOut )
				
			timer.Simple(3.0,function()
				self.Entity:SetMaterial("models/props_combine/portalball001_sheet")
				self.Door:SetMaterial("models/props_combine/portalball001_sheet")
				--DoorContr:SetMaterial("models/props_combine/portalball001_sheet")
					timer.Simple(0.5,function()
						self.Entity:SetPos(self.WireWarpDest)
							timer.Simple(0.5,function()
							self.Entity:SetMaterial(nil)
							self.Door:SetMaterial(nil)
							--DoorContr:SetMaterial(nil)
							self.Entity:GetPhysicsObject():Wake()
							self.Entity:GetPhysicsObject():EnableMotion(true)
							self.EngineOn = true
							self.CanExit = true
							end);
					end);
						
			end);
			
				
			
		else
			PrintMessage(HUD_PRINTTALK,"[Shuttle_11]You can't warp to these coordinates!")
		end
	
	else
	PrintMessage(HUD_PRINTTALK,"[Shuttle_11]You can't warp without flying!")
end
end

function ENT:TriggerInput(k,v)
	if(k=="Self Destruct") then
		if v == 1 then
		self:Boom()
		end
	elseif(k=="Beam Up") then
		if v == 1 then
		self:BeamUp()
		self.Owner:EmitSound("stpack/com_one2beam.wav")
		end
	elseif(k=="Beam Down") then
		if v == 1 then
		self:BeamDown()
		self.Owner:EmitSound("stpack/com_hail.wav")
		end
	elseif(k=="Warp") then
		if v == 1 then
		self:Warp()
		end
	elseif(k=="Warp Destination") then
		self.WireWarpDest = v;
		self.WarpDest = true;
	
	end
		
end	

function ENT:TriggerOutput()
	if WireLib then
		WireLib.TriggerOutput( self.Entity, "Hull", self:GetNetworkedInt("health")/10000*100)
	end
end


