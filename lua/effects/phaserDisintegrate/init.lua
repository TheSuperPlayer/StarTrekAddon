//phaserDisintegrate
function EFFECT:Init(data)
	
	self.Position = data:GetOrigin()
	self.Normal = data:GetNormal()
	//self.KillTime = CurTime() + 0.65
	self.KillTime = CurTime() + 10.65
	self:SetRenderBoundsWS(self.Position + Vector()*280,self.Position - Vector()*280)
	
	local ang = self.Normal:Angle():Right():Angle() -- D :
	local emitter = ParticleEmitter(self.Position)
	
	local dynlight = DynamicLight(600);
	dynlight.Pos = self.Position
	dynlight.Size = 500;
	dynlight.Decay = 500;
	dynlight.R = 255;
	dynlight.G = 255;
	dynlight.B = 255;
	dynlight.DieTime = CurTime()+20;

	for i=1,2 do
		//local vec = (self.Normal + 1.2*VectorRand()):GetNormalized()
		local velos = Vector(math.Rand(-15, 15),math.Rand(-15, 15),math.Rand(15, 25))
		//local velos = Vector(5,5,10)

		/* DEBUG PURPOSE */

		//local test_var = math.Clamp((math.sin( CurTime() ) * 16),1,16)
		//Msg("SIN: " .. test_var .. "\n")
		//"sprites/heatwave"
		local particle = emitter:Add("sprites/heatwave", self.Position)
		particle:SetVelocity(velos)
		particle:SetDieTime(math.Rand(1.2, 1.8))
		particle:SetStartAlpha(128)
		particle:SetEndAlpha(0)
		//particle:SetStartSize(test_var)
		particle:SetStartSize(math.Rand(16, 19))
		particle:SetEndSize(0)
		particle:SetRoll(math.random(0, 360))
		particle:SetRollDelta(math.random(0.1, 1.0))
		//particle:SetStartLength(0)
		//particle:SetEndLength(0)
		//particle:SetColor(255,255,255)
		particle:SetGravity(Vector(0,0,0))
		particle:SetAirResistance(0)
		particle:SetCollide(false)
		particle:SetBounce(0.0)
	end

	for i=1,10 do
		ang:RotateAroundAxis(self.Normal,math.Rand(0,360))
		local vec = ang:Forward()
		local particle = emitter:Add("particle/particle_smokegrenade", self.Position)
		particle:SetVelocity(math.Rand(600,1200)*vec)
		particle:SetDieTime(math.Rand(2.2,2.7))
		particle:SetStartAlpha(math.Rand(21,32))
		particle:SetStartSize(math.Rand(30,40))
		particle:SetEndSize(math.Rand(50,60))
		particle:SetColor(255,241,232)
		particle:SetAirResistance(600)
	end
	
	

	emitter:Finish()
	

end


function EFFECT:Think()

	if CurTime() > self.KillTime then return false end
	return true
	
end


function EFFECT:Render()

end
