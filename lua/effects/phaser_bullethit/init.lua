/*
	Staff Weapon for GarrysMod10
	Copyright (C) 2007  aVoN

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

EFFECT.LastPos = {}; -- Saves last positions so we wont draw too much smoke (which looks ugly!)
--################# Init @aVoN
function EFFECT:Init(data)
	local pos = data:GetOrigin();
	local e = data:GetEntity();
	local vel = Vector(0,0,0);
	if(e and e:IsValid()) then
		vel = e:GetVelocity();
	end
	local size = data:GetMagnitude()/2;
	local color = data:GetAngles();
	self.Color = Color(255,200,120);
	if(color ~= Angle(0,0,0)) then
		self.Color = Color(color.p,color.y,color.r);
	end
	local norm = data:GetNormal();
	local em = ParticleEmitter(pos);
	if (em==nil) then return end
	-- ######################## Sound
	sound.Play(Sound("weapons/mortar/mortar_explode"..math.random(1,3)..".wav"),pos,80,math.random(80,120));
	-- ######################## Glowing particles
	for i=1,128 do
		local pt = em:Add("sprites/gmdm_pickups/light",pos+VectorRand());
		pt:SetVelocity(norm*math.random(50,50)+VectorRand()*math.random(20,30)+vel/5);
		pt:SetDieTime(0.3);
		pt:SetStartAlpha(255);
		pt:SetEndAlpha(0);
		pt:SetStartSize(4);
		pt:SetEndSize(1);
		pt:SetColor(255,192,0);
		--pt:VelocityDecay(false);
	end
	for i =1,12 do
		local pt = em:Add("sprites/gmdm_pickups/light",pos+VectorRand()*math.random(4,6));
		pt:SetVelocity(VectorRand()*10+vel/10);
		pt:SetDieTime(1.5);
		pt:SetStartAlpha(255);
		pt:SetEndAlpha(0);
		pt:SetStartSize(20+size*5);
		pt:SetEndSize(20+size*5);
		pt:SetColor(self.Color.r,self.Color.g,self.Color.b);
		--pt:VelocityDecay(false);
	end
	
	-- ######################## Decal on the wall
	-- display red glow only if its ronon gun @ AlexALX
	
	util.Decal("SmallScorch",pos+norm*10,pos-norm*10);
	-- ######################## Smoke
	if(data:GetScale() ~= -1) then--and StarGate.VisualsWeapons("cl_staff_smoke")) then
		-- ######################## Smoke "AI" - do not add too much of long lasting smoke!
		local time = CurTime();
		local draw_smoke = true;
		for k,v in pairs(self.LastPos) do
			if(k+8 > time) then
				if((v-pos):Length() < 40) then
					draw_smoke = false;
					break;
				end
			else
				self.LastPos[k] = nil;
			end
		end
		-- Short lasting smoke
		local pt = em:Add("particles/smokey",pos+norm);
		//pt:SetVelocity(norm*100);
		pt:SetDieTime(0.8);
		pt:SetStartAlpha(200);
		pt:SetStartSize(10);
		pt:SetEndSize(38);
		pt:SetRoll(0);
		pt:SetColor(255,92,0);
		
	end
	em:Finish();
	-- ######################## Dynamic light
	--if(StarGate.VisualsWeapons("cl_staff_dynlights")) then
		local dynlight = DynamicLight(0);
		dynlight.Pos = pos;
		dynlight.Size = 100;
		dynlight.Decay = 0;
		dynlight.R = self.Color.r;
		dynlight.G = self.Color.g;
		dynlight.B = self.Color.b;
		dynlight.DieTime = CurTime()+1;
	--end
end

function EFFECT:Think() return false end; -- Make it die instantly
function EFFECT:Render() end
