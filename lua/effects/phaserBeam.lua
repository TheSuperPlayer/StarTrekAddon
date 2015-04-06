
//EFFECT.Mat = Material( "effects/MuzzleEffect" )
EFFECT.Mat = Material( "trails/plasma" )
EFFECT.Mat2 = Material( "trails/laser" )
EFFECT.Mat3 = Material( "trails/electric" )



function EFFECT:Init( data )

	self.texcoord = 100 --math.Rand( 0, 20 )/2
	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()
	--self.Attachment = data:GetAttachment()
	

	--self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	--self.EndPos = data:GetOrigin()
	

	self.Entity:SetCollisionBounds( self.StartPos -  self.EndPos, Vector( 110, 110, 110 ) )
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos, Vector()*8 )
	
	--self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	
	self.Alpha = 255
	self.FlashA = 255
	
end


function EFFECT:Think( )

	--self.FlashA = self.FlashA - 2050 * FrameTime()
	--if (self.FlashA < 0) then self.FlashA = 0 end

	self.Alpha = self.Alpha - 2050 * FrameTime()
	if (self.Alpha < 0) then return false end
	
	return true

end


function EFFECT:Render( )
	
	self.Length = (self.StartPos - self.EndPos):Length()
	
	local texcoord = self.texcoord
	
		render.SetMaterial( self.Mat )
		render.DrawBeam( self.StartPos, 										// Start
					 self.EndPos,											// End
					 60,													// Width
					 texcoord,														// Start tex coord
					 texcoord + self.Length / 256,									// End tex coord
					 Color( 255, 150, 0, 255 ))		// Color (optional)'
					 
	
		render.SetMaterial( self.Mat2 )
		render.DrawBeam( self.StartPos, 										// Start
					 self.EndPos,											// End
					 50,													// Width
					 texcoord,														// Start tex coord
					 texcoord + self.Length / 256,									// End tex coord
					 Color( 225, 100, 0, 255) )		// Color (optional)'
					 
		
	
		render.SetMaterial( self.Mat3 )
		render.DrawBeam( self.StartPos, 										// Start
					 self.EndPos,											// End
					 80,													// Width
					 texcoord,														// Start tex coord
					 texcoord + self.Length / 256,									// End tex coord
					 Color( 255, 0, 0, 255) )		// Color (optional)'				 
end
