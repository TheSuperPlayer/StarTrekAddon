//Based on the CDS_Disintegrate effect
//All credits go to the CDS team !!!
// BEAM FADE OUT
EFFECT.Material = Material("effects/phaserHeat.vmt")
function EFFECT:Init(data)
	self.entity = data:GetEntity()
	if(!self.entity:IsValid()) then return end
	self.mag = math.Clamp(self.entity:BoundingRadius()/8,1,99999) //Amount of Particles
	self.dur = data:GetScale()+CurTime()-1.5
	self.emitter = ParticleEmitter(self.entity:GetPos())
	self.amp = 255/data:GetScale()
end

function EFFECT:Think()
	if not self.entity:IsValid() then return false end
	local t = CurTime()
	local vOffset = self.entity:GetPos()
	local Low, High = self.entity:WorldSpaceAABB() //Size based on BoundingBox
	/*for i=1, self.mag do --don't fuck with this or you FPS dies
		local vPos = Vector(math.random(Low.x,High.x), math.random(Low.y,High.y), math.random(Low.z,High.z))
		local particle = self.emitter:Add("sprites/phaserMuzzle.vmt", vPos)
		if (particle) then
			particle:SetColor(255,150,0,255)
			particle:SetVelocity(Vector(0,0,0))
			particle:SetLifeTime(0)
			particle:SetDieTime(.5)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(20)
			particle:SetStartSize(20)
			particle:SetEndSize(1)
			particle:SetRoll(math.random(0, 360))
			particle:SetRollDelta(0)
			particle:SetAirResistance(100)
			particle:SetGravity(Vector(0, 0, 0))
			particle:SetBounce(0.5)
		end

	end*/
	//local tmp2 = math.Clamp(self.amp*((self.dur-t)))
	--self.entity:SetColor(Color(self.Color.r,self.Color.g,self.Color.b,1))
	self.Entity:SetMaterial("effects/Vaporise_1")
	
	if not (t < self.dur) then
		self.emitter:Finish()
		self.Entity:SetMaterial(nil)
	end
	return t < self.dur
/*
	Msg( t .. " < " .. self.dur2 .. "\n")
	Msg("Scale: " .. self.dur2 .. " Time: " .. CurTime() .. "\n")
	Msg("Curtime: " .. CurTime() .. "Func: " .. t < self.dur .. "\n")
*/
end

function EFFECT:Render()
end
