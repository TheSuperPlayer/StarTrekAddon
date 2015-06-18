
function EFFECT:Init(data)
	Pos = data:GetOrigin();
	self.Ent = data:GetEntity()
	--local Col = Ent:GetColor()
	local scale = data:GetScale()
	local color = data:GetAngles();
	self.Color = Color(color.p,color.y,color.r);

	Emitter = ParticleEmitter(Vector(0,0,0));
	

	for k=1,70 do--Left
			local particle = Emitter:Add( "particles/flamelet"..math.random(1,5), Pos)
			particle:SetDieTime( 1 )
			--particle:SetLifeTime( 1 )
			particle:SetStartAlpha( 200 )
			particle:SetEndAlpha(0)
			particle:SetStartSize( scale/2 )
			particle:SetEndSize( scale/2 )
			particle:SetRoll( math.Rand( 20, 80 ) )
			particle:SetRollDelta( math.random( -1, 1 ) )
			particle:SetColor(self.Color.r,self.Color.g,self.Color.b)
			
			end

			
	
	
		local dynlight = DynamicLight(0);
		dynlight.Pos = Pos;
		dynlight.Size = 100;
		dynlight.Decay = 0;
		dynlight.R = self.Color.r;
		dynlight.G = self.Color.g;
		dynlight.B = self.Color.b;
		dynlight.DieTime = CurTime()+1;
	--end
end

function EFFECT:Think() end; -- Make it die instantly


function EFFECT:Render() end
