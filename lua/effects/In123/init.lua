/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )

	self.Position = data:GetOrigin()
	local Pos = self.Position
	local Dest = Pos + Vector(0,0,100)
	self.Emitter = ParticleEmitter( Pos )

	  
			
			for k=1,70 do--Dest
			local particle = self.Emitter:Add( "particles/flamelet"..math.random(1,5), Dest)
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
