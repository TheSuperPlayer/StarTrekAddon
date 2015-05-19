
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
function ENT:Initialize()
	self.Entity:SetModel("models/transporter/d12shieldemitter.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	--self.snd_ON = CreateSound(self.Entity, Sound("stpack/runloop.wav"))
	--self.snd_beamLanding = CreateSound(self.Entity, Sound("stpack/transporterBeam.wav"))
	
	self.Destination = Vector(0,0,0)
	self.Target = nil
	self.BeamInProgress = 0
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self.Entity, { "Target [ENTITY]","Destination [VECTOR]","Send","Beam to Pad" })
		self.Outputs = Wire_CreateOutputs(self.Entity, { "Beam in Progress" })
	end

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:SpawnFunction(p,t)
	if (not t.Hit) then return end
	local e = ents.Create("transporter_platform")
	e:SetPos( t.HitPos );
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:UpdateTransmitState() 
	return TRANSMIT_ALWAYS
end





function ENT:TriggerInput(k,v)
	if(k == "Target") then
		self.Target = v;
		print(v)
	elseif(k == "Destination") then
		self.Destination = v;
	elseif(k == "Send") then
		if v == 1 then
		self:Beam();
		--print(self.Target:GetClass())
		end
	elseif(k == "Beam to Pad") then
		if v == 1 then
			self:BeamToPad()
		end
			
			
	end
	
end

function ENT:Beam()
	if  IsValid(self.Target)  and util.IsInWorld(self.Destination) and  self.BeamInProgress == 0 and not self.Target:IsWorld() then
		local BeamObj = self.Target
				self.BeamInProgress = 1
				local Dest = self.Destination
					if BeamObj:IsPlayer() then
						BeamObj:Freeze( true )
						BeamObj:SetMoveType(MOVETYPE_NOCLIP)
					elseif BeamObj:GetClass() == "props_physic" then
						BeamObj:GetPhysicsObject():EnableMotion(false)
					end
					BeamObj:EmitSound("tng_transporter_out.mp3")
					BeamObj:SetCollisionGroup(COLLISION_GROUP_WORLD )
					local fx = EffectData()
						fx:SetEntity(BeamObj)
						fx:SetOrigin(BeamObj:GetPos())
						util.Effect("TransporterBeamOut",fx, true, true );
						timer.Simple(3.5,function()
							BeamObj:SetPos(self.Destination)
							BeamObj:SetAngles(Angle(0,0,0))
							BeamObj:EmitSound("tng_transporter_in.mp3")
							local fx2 = EffectData()
								fx2:SetEntity(BeamObj)
								fx2:SetOrigin(BeamObj:GetPos())
								util.Effect("TransporterBeamIn",fx2, true, true );
									timer.Simple(3.2,function()
											BeamObj:SetCollisionGroup(COLLISION_GROUP_NONE )
											self.BeamInProgress = 0
										if BeamObj:IsPlayer() then
											BeamObj:Freeze( false )
											BeamObj:SetMoveType(MOVETYPE_WALK)
											BeamObj:SetMaterial("")
										end
										
									end);
						end);
	else
		return
	end
	
end
function ENT:BeamToPad()
if  IsValid(self.Target)  and util.IsInWorld(self.Destination) and self.BeamInProgress==0 and not self.Target:IsWorld() then
		local BeamObj = self.Target
				self.BeamInProgress = 1
				local Pad = self.Entity:GetPos() +self:GetUp()*20
					if BeamObj:IsPlayer() then
						BeamObj:Freeze( true )
						BeamObj:SetMoveType(MOVETYPE_NOCLIP)
					elseif BeamObj:GetClass() == "props_physic" then
						BeamObj:GetPhysicsObject():EnableMotion(false)
					end
					BeamObj:EmitSound("tng_transporter_out.mp3")
					BeamObj:SetCollisionGroup(COLLISION_GROUP_WORLD )
					local fx = EffectData()
						fx:SetEntity(BeamObj)
						fx:SetOrigin(BeamObj:GetPos())
						util.Effect("TransporterBeamOut",fx, true, true );
						timer.Simple(3.5,function()
							BeamObj:SetPos(Pad)
							BeamObj:SetAngles(Angle(0,0,0))
							BeamObj:EmitSound("tng_transporter_in.mp3")
							local fx2 = EffectData()
								fx2:SetEntity(BeamObj)
								fx2:SetOrigin(BeamObj:GetPos())
								util.Effect("TransporterBeamIn",fx2, true, true );
									timer.Simple(3.2,function()
											BeamObj:SetCollisionGroup(COLLISION_GROUP_NONE )
											self.BeamInProgress = 0
										if BeamObj:IsPlayer() then
											BeamObj:Freeze( false )
											BeamObj:SetMoveType(MOVETYPE_WALK)
											BeamObj:SetMaterial("")
										end
										
									end);
						end);
	else
		return
	end
end
function ENT:Think()
	
	self:UpdateWireOutput()
	self.Entity:NextThink(CurTime()+0.3);
	return true;
end

function ENT:UpdateWireOutput()
if WireLib then
		WireLib.TriggerOutput( self.Entity, "Beam in Progress", self.BeamInProgress)
	end
end