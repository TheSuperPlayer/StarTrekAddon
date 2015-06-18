ENT.Type = "anim"
ENT.Base = "base_anim"

if SERVER then


AddCSLuaFile();

--################# SENT CODE ###############

--###################
function ENT:Initialize()
	self.Entity:PhysicsInitSphere(10,"metal");
	self.Entity:SetCollisionBounds(Vector(1,1,1)*-5,Vector(1,1,1)*5);
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self:DrawShadow(false)
	
	self:PhysWake()
	self.Phys = self.Entity:GetPhysicsObject();
	local vel = self.Direction*self.Speed;
	if(self.Phys and self.Phys:IsValid()) then
		self.Phys:SetMass((self.Size[1]+self.Size[2])*10);
		self.Phys:EnableGravity(false);
		self.Phys:SetVelocity(vel);-- end
	end
	
end

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end;

function ENT:Settings(dir,spd,dmg,size)
	self.Direction = dir;
	self.Speed = spd;
	self.Damage = dmg;
	self.Size = size;
	self.Entity:SetNetworkedVector("Size", Vector(size[1],size[2],0));
end
function ENT:Think(ply)
	local phys = self:GetPhysicsObject();
	if IsValid(phys) then phys:Wake(); end
end

function ENT:PhysicsCollide( data, physobj )
	local Ent = data.HitEntity;
		if Ent then
			local pos = data.HitPos;
			self:Explode(pos,self.Damage)
		end
end
function ENT:CAPOnShieldTouch(shield)
	self:Remove()
end
function ENT:Explode(pos,dmg)
	local col = self.Entity:GetColor()
	--print(col.r..col.g..col.b)
	--print(col.r..col.g..col.b)
	local HitEffect = EffectData()
			HitEffect:SetOrigin(pos)
			HitEffect:SetEntity(self.Entity)
			HitEffect:SetAngles(Angle(col.r,col.g,col.b))
			HitEffect:SetScale((self.Size[1]+self.Size[2])/2)
			util.Effect( "phaser_bullethit", HitEffect )
	util.ScreenShake(pos, 10, 5, 1, (self.Size[1]+self.Size[2])*2 )
	util.BlastDamage(self.Entity, self.Entity:GetOwner(), pos, (self.Size[1]+self.Size[2])*3, dmg ) 
	self:Remove()
end

end
if CLIENT then

ENT.Mat = Material("decals/weapons/phaser_bullet")

ENT.RenderGroup = RENDERGROUP_BOTH;


function ENT:Initialize()
	local size = self.Entity:GetNetworkedVector("Size", 0);
	self.Sizes={size.x,size.y,0}; 
	
end


function ENT:Draw()
	local start = self.Entity:GetPos();
	local color = self.Entity:GetColor();
	
	render.SetMaterial(self.Mat);
	for i =1,2 do
		render.DrawSprite(
			start,
			self.Sizes[1],self.Sizes[2],
			color
		);
	end
end

--################### 
function ENT:Think()
		local size = self.Entity:GetNetworkedVector("Size", 0);
		--print(size)
		self.Sizes={size.x,size.y,0}; 
		--print(size.x)
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
	
	end
	local time = CurTime();	
	self.Entity:NextThink(time);
	return true;
end

end