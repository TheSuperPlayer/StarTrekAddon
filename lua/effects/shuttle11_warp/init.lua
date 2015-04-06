/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )

	self.Shuttle = data:GetEntity()	
	local Pos = self.Shuttle:GetPos()
	local LeftGond = self.Shuttle:GetPos() +self.Shuttle:GetForward()*160 + self.Shuttle:GetRight()*170 + self.Shuttle:GetUp()*150
	local RightGond = self.Shuttle:GetPos() +self.Shuttle:GetForward()*160 + self.Shuttle:GetRight()*-170 + self.Shuttle:GetUp()*150
	local Front = self.Shuttle:GetPos() +self.Shuttle:GetForward()*-900 + self.Shuttle:GetUp()*200
	self.Emitter = ParticleEmitter( Pos )

	  
		
			for k=1,70 do--Left
			local particle = self.Emitter:Add( "particles/flamelet"..math.random(1,5), LeftGond)
			particle:SetDieTime( 7 )
			particle:SetLifeTime( 2 )
			particle:SetStartAlpha( math.Rand(230, 250) )
			particle:SetStartSize( 40 )
			particle:SetEndSize( 90 )
			particle:SetRoll( math.Rand( 20, 80 ) )
			particle:SetRollDelta( math.random( -1, 1 ) )
			particle:SetColor(0,100, 255)
			
			end
			
			for k=1,70 do--Right
			local particle = self.Emitter:Add( "particles/flamelet"..math.random(1,5), RightGond)
			particle:SetDieTime( 7 )
			particle:SetLifeTime( 2 )
			particle:SetStartAlpha( math.Rand(230, 250) )
			particle:SetStartSize( 40 )
			particle:SetEndSize( 90 )
			particle:SetRoll( math.Rand( 20, 80 ) )
			particle:SetRollDelta( math.random( -1, 1 ) )
			particle:SetColor(0,100, 255)
			end
			
			for k=1,70 do--Front
			local particle = self.Emitter:Add( "particles/flamelet"..math.random(1,5), Front)
			particle:SetDieTime( 7 )
			particle:SetLifeTime( 2 )
			particle:SetStartAlpha( math.Rand(230, 250) )
			particle:SetStartSize( 10 )
			particle:SetEndSize( 800 )
			particle:SetRoll( math.Rand( 20, 80 ) )
			particle:SetRollDelta( math.random( -1, 1 ) )
			particle:SetColor(0,100, 255)
			end



	
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
		
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )
	

end
