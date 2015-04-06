function EFFECT:Init( data )
	
	local vOffset = data:GetOrigin()
		self.Origin = data:GetOrigin()
	self.DirVec = data:GetNormal()
	self.Scale = data:GetScale()
		self.Magnitude = data:GetMagnitude()
	self.Emitter = ParticleEmitter( self.Origin )

	local emitter = ParticleEmitter( vOffset )

			/*	for i=1,5 do 
			local Flash = self.Emitter:Add( "effects/combinemuzzle1_dark", self.Origin )
			if (Flash) then
				Flash:SetVelocity( VectorRand() )
				Flash:SetAirResistance( 200 )
				Flash:SetDieTime( 0.15 )
				Flash:SetStartAlpha( 255 )
				Flash:SetEndAlpha( 100 )
				Flash:SetStartSize( 50 )
				Flash:SetEndSize( 25 )
				Flash:SetRoll( math.Rand(180,480) )
				Flash:SetRollDelta( math.Rand(-1,1) )
				Flash:SetColor(255,0,0)	
			end
		end
*/

		for i=1,2 do 
			local particle = emitter:Add( "trails/smoke", vOffset )

				particle:SetVelocity( 10 * data:GetNormal() )
				particle:SetAirResistance( 600 )

				particle:SetDieTime( 0.4 )

				particle:SetStartAlpha( math.Rand(0, 55) )
				particle:SetEndAlpha( 0 )

				particle:SetStartSize( 5 * i )
				particle:SetEndSize( 8 * i )

				particle:SetRoll( math.Rand(180,480) )
				particle:SetRollDelta( math.Rand(-1,1) )

				particle:SetColor(255,92,0)	
				particle:SetGravity( Vector( math.Rand(-100, 100) * self.Scale, math.Rand(-100, 100) * self.Scale, math.Rand(0, -100) ) ) 		
		end
		
	
			local particle = emitter:Add( "effects/combinemuzzle1_dark", vOffset )

				particle:SetVelocity( 80 * data:GetNormal() + 20 * VectorRand() )
				particle:SetAirResistance( 200 )

				particle:SetDieTime( math.Rand(0.2, 0.25) )

				particle:SetStartSize( math.random(15,20) )
				particle:SetEndSize( 3 )


				particle:SetRoll( math.Rand(180,480) )
				particle:SetRollDelta( math.Rand(-1,1) )
				particle:SetColor(255,192,0)	
				

	emitter:Finish()
end

function EFFECT:Think( )

	return false
end

function EFFECT:Render()

end
