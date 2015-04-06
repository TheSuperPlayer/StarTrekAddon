include('shared.lua')
	    
    function ENT:Draw()
    // self.BaseClass.Draw(self) -- We want to override rendering, so don't call baseclass.
	// Use this when you need to add to the rendering.
		//self:DrawEntityOutline( 0.0 ) // Draw an outline of 1 world unit.
		self.Entity:DrawModel() // Draw the model.

		if ( LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance( self.Entity:GetPos() ) < 512 ) then
			//local pos = self.Entity:GetPos()
			//local TransporterPos = self.Entity:GetPos()
			//self.Origin = Vector( math.Round(TransporterPos.x*1000)/1000, math.Round(TransporterPos.y*1000)/1000, (math.Round(TransporterPos.z*1000)/1000)+18.3 )
			//AddWorldTip(self.Entity:EntIndex(),"Origin: \nX:"..tostring(self.Origin.x).."\nY: "..tostring(self.Origin.y).."\nZ: "..tostring(self.Origin.z) ,0.5,self.Entity:GetPos(),self.Entity)
			//AddWorldTip(self.Entity:EntIndex(),"Origin: \nXYZ:"..tostring(self.Origin).."\nSRC XYZ:"..tostring(self.Entity:GetPos()) ,0.5,self.Entity:GetPos(),self.Entity)
			//AddWorldTip(self.Entity:EntIndex(),"Origin: \nXYZnet:"..tostring(self.Entity:GetNetworkedVector("OriginSRC",0)).."\nSRC XYZ:"..tostring(self.Entity:GetPos()) ,0.5,self.Entity:GetPos(),self.Entity)
			//AddWorldTip(self.Entity:EntIndex(),"Dest: \nXYZ:"..tostring(self.Entity:GetNetworkedVector("DestSRC",0)) ,0.5,self.Entity:GetPos(),self.Entity)
		end
	end    
