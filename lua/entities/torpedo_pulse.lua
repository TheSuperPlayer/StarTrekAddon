/*
	Staff Weapon for GarrysMod10
	Copyright (C) 2007  aVoN
	Rewrited by Madman07, 2011

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

ENT.Type = "anim"
ENT.Base = "base_anim"

if SERVER then

--################# HEADER #################

AddCSLuaFile();

ENT.CAP_NotSave = true;
ENT.Untouchable = true;
ENT.IgnoreTouch = true;
ENT.NoAutoClose = true; -- Will not cause an autoclose event on the stargates!
ENT.CDSIgnore = true; -- CDS Immunity
function ENT:gcbt_breakactions() end; ENT.hasdamagecase = true; -- GCombat invulnarability!

--################# SENT CODE ###############

--################### Init @aVoN, Madman07
function ENT:Initialize()
	-- this cause crash when shoot in water, when i set just same values for all shoots no crashes and everything work fine
	--self.Entity:PhysicsInitSphere(self.Size/10,"metal");
	--self.Entity:SetCollisionBounds(-1*Vector(1,1,1)*self.Size/10,Vector(1,1,1)*self.Size/10);
	self.Entity:PhysicsInitSphere(10,"metal");
	self.Entity:SetCollisionBounds(Vector(1,1,1)*-5,Vector(1,1,1)*5);
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self:DrawShadow(false)
	-- Config
	self.Radius = 100+3*self.Size;  --StarGate.CFG:Get("staff","radius",50);
	self.Damage = 30+40*self.Size;  --StarGate.CFG:Get("staff","damage",150);
	self.MaxPasses = 5; --StarGate.CFG:Get("staff","maxpasses",5);
	self.Passes = 1;
	self.Passed = {}; -- Necessary, so you can shoot out of Catdaemons shield
	local color = self.Entity:GetColor();
	local r,g,b = color.r,color.g,color.b;
	if(r == 255 and g == 255 and b == 255) then
		self.Entity:SetColor(Color(math.random(230,255),200,120,255));
	end
	self.Entity:SetRenderMode(RENDERMODE_TRANSALPHA)

	--PhysObject
	self:PhysWake()
	self.Phys = self.Entity:GetPhysicsObject();
	local vel = self.Direction*self.Speed+VectorRand()*self.Random;
	if(self.Phys and self.Phys:IsValid()) then
		self.Phys:SetMass(self.Size*10);
		self.Phys:EnableGravity(false);
		self.Phys:SetVelocity(vel);-- end
	end
	self.Entity:SetLocalVelocity(vel)
	self.Created = CurTime();

	self.CoreNotCollide = self.Owner.CoreNotCollide;
	self.CoreEntity = self.Owner.CoreEntity;
end

--################# Prevent PVS bug/drop of all networkes vars (Let's hope, it works) @aVoN
function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end;

--################# Think for physic @Mad
function ENT:PhysicsUpdate(phys)
	local vel = phys:GetVelocity();
	if (math.abs(vel.x)<500 and math.abs(vel.y)<500 and math.abs(vel.z)<500) then -- faster than length?
		self:Destroy();
	end
end

/*function ENT:CAPOnShieldTouch(shield)
	self:Blast("energy_impact",self:GetPos(),shield,Vector(1,1,1),false,self.Damage,self.Radius);
	if (self.Explosion) then self:Blast("energy_explosion",self:GetPos(),self,Vector(1,1,1),false,self.Damage,self.Radius); end
	self:Destroy();
end
*/
function ENT:Think(ply)
	local phys = self:GetPhysicsObject();
	if IsValid(phys) then phys:Wake(); end
end

function ENT:Explode()
	self:Blast("energy_explosion",self:GetPos(),self,Vector(1,1,1),false,self.Damage,self.Radius);
	self:Destroy();
end

--################### Make the shot blast @aVoN, Madman07
function ENT:PhysicsCollide( data, physobj )
	local e = data.HitEntity;

	if (e) then
		if e.IgnoreTouch then return end; -- Gloabal for anyone, who want's to make his scripts "staff-passable"
		if self.Passed[e] then return end; -- We already passed this entity. Don't touch it again
		if (self.CoreNotCollide and self.CoreEntity == e) then return end; -- avoid owner shields

		local pos = data.HitPos;
		local world = e:IsWorld()
		local owner = self.Entity:GetOwner();
		if (owner == nil) then owner = self.Entity; end
		local hitnormal = data.HitNormal;
		local class = e:GetClass()

		if world then hitnormal = -1*hitnormal; end

		if (owner == e) then return end
		for _,v in pairs(self.Ignore) do
			if (v == e) then return end
		end

		-- Shield Thing
		if (not world and self.Passed[e] == nil) then
			if not e:GetPhysicsObject():IsValid() then self.Passed[e] = true return end; -- Invalid physics object?
			if (class == "ivisgen_collision") then self.Passed[e] = true return end; -- Catdaemon's cloaking device
			if e.nocollide then -- Catdaemon's and avon shield?
				if(e.nocollide[owner]) then
					e.nocollide[e] = true;
					self.Passed[e] = true;
					return;
				end
				self.Passed[e] = false;
			end
		end

		-- ######################## The blast
		local dir = self.Direction*10;
		local hitsmoke = true;
		if (hitnormal:Length() == 0) then hitsmoke = false end;

		local trace = util.TraceLine({start=pos-dir,endpos=pos+dir,filter={self.Entity,owner}});
		if trace then
			if trace.HitSky then self.Entity:Destroy() return end;
			if (trace.MatType == MAT_FLESH or trace.MatType == MAT_METAL or trace.MatType == MAT_GLASS) then hitsmoke = false end
		end

		hitsmoke = false

		if self.Stunner then
			self.Phys = self.Entity:GetPhysicsObject();
			if(self.Phys and self.Phys:IsValid()) then
				self.Phys:SetMass(1);
			end
			self.Entity:PhysicsInitSphere(1,"metal");
			self.Entity:SetCollisionBounds(-1*Vector(1,1,1),Vector(1,1,1));
			if e:IsPlayer() then
				e:Freeze(true)
				local phys = e:GetPhysicsObject()
				if phys and phys:IsValid() then
					phys:EnableMotion(false) -- Freezes the object in place.
				end
			end
			if e:IsNPC() then
				e:StopMoving()
				local phys = e:GetPhysicsObject()
				if phys and phys:IsValid() then
					phys:EnableMotion(false) -- Freezes the object in place.
				end
			end
			self:Blast("phaser_bullethit",pos,e,hitnormal,hitsmoke,0,0, data.OurOldVelocity);
		else
			self:Blast("phaser_bullethit",pos,e,hitnormal,hitsmoke,self.Damage,self.Radius, data.OurOldVelocity);
		end
		if (self.Explosion) then self:Blast("energy_explosion",pos,self,Vector(1,1,1),false,self.Damage,self.Radius); end

		self:Destroy();

	end
end

-- ########################  TELEPORT
function ENT.FixAngles(self,pos,ang,vel,old_pos,old_ang,old_vel,ang_delta)
	self:PhysWake()
	self.Direction = vel:GetNormalized();
	local vel2 = self.Direction*self.Speed+VectorRand()*self.Random;
	if(self.Phys and self.Phys:IsValid()) then
		self.Phys:SetVelocity(vel2);
	end
	self.Entity:SetLocalVelocity(vel2)
end
--StarGate.Teleport:Add("energy_pulse",ENT.FixAngles);

-- ######################## Damage system
function ENT:Blast(effect,pos,ent,norm,smoke,dmg,rad,old_vel)
	local fx = EffectData();
	fx:SetOrigin(pos);
	fx:SetNormal(norm);
	fx:SetEntity(ent);
	if(not smoke) then
		fx:SetScale(-1);
	else
		fx:SetScale(1);
	end
	fx:SetMagnitude(self.Size);
	local c = self.Entity:GetColor();
	fx:SetAngles(Angle(c.r,c.g,c.b));
	util.Effect(effect,fx,true,true);
	local i = 1/math.sqrt(self.Passes); -- Intensity
	if(self.ExplosiveDamage) then
		dmg = math.Clamp(self.ExplosiveDamage*i,0,dmg); -- Necessary, or the powerfull shot won't go throug breakable stuff such good anymore
	end

	local attacker,owner = self:GetAttackerAndOwner(self.Entity);
	self:BlastDamage(attacker,owner,pos,rad,dmg*i);
	util.ScreenShake(pos,2,2.5,1,700);

	if (ent:GetClass() == "shield") then -- aVoN shield!
		ent:HitShield(ent,pos,self:GetPhysicsObject(),self:GetClass(),norm);
	end

	--local dmg;
	--dmg:SetInflictor(attacker)
	--dmg:SetAttacker(owner)
	--dmg:SetDamageType(DMG_BLAST)
	--rad = rad
	--pos = pos - old_vel


	-- for _,v in pairs(ents.FindInSphere(pos,rad)) do
		-- local phys = v:GetPhysicsObject();
		-- if phys:IsValid() then
			----local pos = self.Owner:GetShootPos()
			---local ang = self.Owner:GetAimVector()
			-- local tracedata = {}
			-- tracedata.start = pos
			-- tracedata.endpos = v:LocalToWorld(v:OBBCenter())
			-- tracedata.filter = self.Owner
			-- local trace = util.TraceLine(tracedata)
			-- if (trace.Entity and trace.Entity == v) then
				---dmg:SetDamageForce((pos-tracedata.endpos)*1000)
				---dmg:SetDamage(dmg*i*(1/(pos:Distance(tracedata.endpos)))
				-- local power = dmg*i*(1/(pos:Distance(tracedata.endpos)))*10000


				-- v:TakeDamage(power, owner, attacker)
				---util.BlastDamage(owner, attacker, v:GetPos(), 5, power)
			-- end
		-- end
	-- end

end

function ENT:GetAttackerAndOwner(e)
	-- Owner/Attacker
	if(not (e and e:IsValid())) then return NULL,NULL end;
	local owner = e:GetOwner();
	local attacker = e;
	if(owner and owner:IsValid()) then
		if(type(owner) == "Player") then
			attacker = owner:GetActiveWeapon();
		elseif(owner.Owner) then
			owner = owner.Owner;
		end
	end
	if(not (attacker and attacker:IsValid())) then attacker = e end;
	if(not (owner and owner:IsValid())) then owner = e end;
	return attacker,owner
end

function ENT:BlastDamage(attacker,owner,pos,rad,dmg)
	-- Freeze vehicles or they spazzout
	local vehicles = {};
	for _,v in pairs(ents.FindInSphere(pos,rad)) do
		if(v:IsVehicle()) then
			vehicles[v] = {Velocity = v:GetVelocity(),Bones = {}}; -- Save old velocity of the vehicle and the bones, so a hit car does not appruply stops driving!
			for k=0,v:GetPhysicsObjectCount()-1 do
				local phys = v:GetPhysicsObjectNum(k);
				if(phys:IsValid()) then
					vehicles[v].Bones[k] = phys:GetVelocity();
					phys:EnableMotion(false);
				end
			end
		end
	end
	-- GCombat compatibility (Make things burst, yarr harr!)
	if(gcombat) then
		gcombat.hcgexplode(pos,rad,dmg,4);
	end
	-- CombatDamageSystem - Basically does the same like the the upper code for GCombat
	if(cds_damagepos) then
		cds_damagepos(pos,dmg/100,50,rad,attacker);
	end
	-- The real blast damage
	util.BlastDamage(attacker,owner,pos,rad,dmg);
	-- fix for stargates @ AlexALX
	-- and i know, its ugly, but better that nothing
	if (rad<200) then
		local dmginfo = DamageInfo();
		dmginfo:SetDamage(dmg);
		dmginfo:SetAttacker(attacker);
		dmginfo:SetInflictor(owner);
		dmginfo:SetDamageType(DMG_BLAST);
		dmginfo:SetDamagePosition(pos);
		for _,v in pairs(ents.FindInSphere(pos,1)) do
			if (v.IsStargate) then
				v:TakeDamageInfo(dmginfo);
			end
		end
	end
	-- Unfreeze all previosly frozen vehicles. Nees to be in a null-timer, or the Blast above isn't completely faded out this Frame and will affect the vehicles accidently
	timer.Simple(0,
		function()
			for e,v in pairs(vehicles) do
				e:SetVelocity(v.Velocity);
				for k=0,e:GetPhysicsObjectCount()-1 do
					local phys = e:GetPhysicsObjectNum(k);
					if(phys:IsValid()) then
						phys:EnableMotion(true);
						phys:SetVelocity(v.Bones[k]);
					end
				end
			end
			if(table.Count(vehicles) > 0) then
				-- Add a slight BlastDamage to vehicles to make them fall upside down or somthing like that
				util.BlastDamage(attacker,owner,pos,rad,10);
			end
		end
	);
end

--################### Setup @Mad
function ENT:PrepareBullet(dir, rand, spd, size, ignore)
	self.Direction = dir;
	self.Random = rand;
	self.Speed = spd;
	self.Size = size;
	self.Entity:SetNetworkedInt("Size", size);
	self.Ignore = ignore or {};
end

--################### Destroys this entity without fearing to crash! @aVoN
function ENT:Destroy()
	-- May fix crash @ AlexALX
	self.Entity:SetCollisionGroup(COLLISION_GROUP_NONE);
	self.Entity:SetMoveType(MOVETYPE_NONE);
	self.Entity:SetSolid(SOLID_NONE);
	--
	self.PhysicsCollide = function() end; -- Dummy
	self.Touch = self.PhysicsCollide;
	self.StartTouch = self.Touch;
	self.EndTouch = self.Touch;
	self.Think = self.Touch;
	self.PhysicsUpdate = self.Touch;
	self:SetTrigger(false);
	local e = self.Entity;
	timer.Simple(0,
		function()
			if(IsValid(e)) then e:Remove() end;
		end
	);
end

--################### Earthquake! @aVoN
/*concommand.Add("_StarGate.StaffBlast.ScreenShake",
	function(p,_,arg)
		if(IsValid(p)) then
			util.ScreenShake(Vector(unpack(arg)),2,2.5,1,700);
		end
	end
);
*/
end

if CLIENT then


ENT.Glow = Material("sprites/phaserMuzzle.vmt")
ENT.Shaft = Material("effects/ar2ground2");
ENT.LightSettings = "cl_staff_dynlights_flight";

ENT.RenderGroup = RENDERGROUP_BOTH;

--################### Init @aVoN
function ENT:Initialize()
	self.Created = CurTime();
	self.DrawShaft = true;
	self.InstantEffect = not (self.Entity:GetClass() == "energy_pulse");
	self.Sounds = self.Sounds or {Sound("weapons/weps/sniperPhaser.wav"),Sound("weapons/weps/sniperPhaser.wav")};
	local snd = {}; -- Must be overwritten because garry's inheritance scripts interferes...
	for _,v in pairs(self.Sounds) do
		table.insert(snd,v);
	end
	self.Sounds = snd;
	local size = self.Entity:GetNetworkedInt("Size", 0);
	self.Sizes={10+size*3,10+size*3,180+size*10}; -- X,Y and shaft-leght!
end

--################### Draw the shot @aVoN
function ENT:Draw()
	if(not self.StartPos) then self.StartPos = self.Entity:GetPos() end; -- Needed for several workarounds
	local start = self.Entity:GetPos();
	local color = self.Entity:GetColor();
	if(self.DrawShaft) then
		local velo = self.Entity:GetVelocity();
		local dir = -1*velo:GetNormalized();
		-- Mainly a workaround for servers: The shots appeared to have their trails really late. Seems like the velocity simply was 0
		if(velo:Length() < 400) then
			if(self.StartPos) then
				dir = (self.StartPos-self.Entity:GetPos()):GetNormalized();
			end
		end
		local length = math.Clamp((self.Entity:GetPos()-self.StartPos):Length(),0,self.Sizes[1]);
		/*render.SetMaterial(self.Shaft);
		render.DrawBeam(
			self.Entity:GetPos(),
			self.Entity:GetPos()+dir*length,
			self.Sizes[1],
			0,
			0,
			color
		);*/
	end
	render.SetMaterial(self.Glow);
	for i =1,2 do
		render.DrawSprite(
			start,
			self.Sizes[2],self.Sizes[2],
			color
		);
	end
end

--################### Think: Play sounds! @aVoN
function ENT:Think()
	local size = self.Entity:GetNWInt("Size", 0);
	self.Sizes={20+size*3,20+size*3,180+size*10}; -- X,Y and shaft-leght!
	-- ######################## Flyby-light
	--if(StarGate.VisualsWeapons(self.LightSettings)) then
		local color = self.Entity:GetColor();
		local r,g,b = color.r,color.g,color.b;
		local dlight = DynamicLight(self:EntIndex());
		if(dlight) then
			dlight.Pos = self.Entity:GetPos();
			dlight.r = r;
			dlight.g = g;
			dlight.b = b;
			dlight.Brightness = 1;
			dlight.Decay = 300;
			dlight.Size = 300;
			dlight.DieTime = CurTime()+0.5;
		--end
	end
	local time = CurTime();
	-- ######################## Flyby-noise and screenshake!
	if((time-self.Created >= 0.1 or self.InstantEffect) and time-(self.Last or 0) > 0.3) then
		local p = LocalPlayer();
		local pos = self.Entity:GetPos();
		local norm = self.Entity:GetVelocity():GetNormal();
		local dist = p:GetPos()-pos;
		local len = dist:Length();
		local dot_prod = dist:DotProduct(norm)/len;
		if(math.abs(dot_prod) < 0.5 and dot_prod ~= 0) then
			-- Vector math: Get the distance from the player orthogonally to the projectil's velocity vector
			local intensity = math.sqrt(1 - dot_prod^2)*len;
			self.Entity:EmitSound(self.Sounds[math.random(1,#self.Sounds)],100*(1-intensity/2500),math.random(80,120));
			--p:ConCommand("_StarGate.StaffBlast.ScreenShake "..tostring(pos)); -- Sadly, util.ScreenShake fails clientside so we need to tell the server that we want screenshake!
			self.Last = time;
		end
	end
	self.Entity:NextThink(time);
	return true;
end

end