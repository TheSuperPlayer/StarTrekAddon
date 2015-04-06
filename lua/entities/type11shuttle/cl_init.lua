include('shared.lua')
	    
    function ENT:Draw()
    // self.BaseClass.Draw(self) -- We want to override rendering, so don't call baseclass.
	// Use this when you need to add to the rendering.
		//self:DrawEntityOutline( 0.0 ) // Draw an outline of 1 world unit.
		self.Entity:DrawModel() // Draw the model.

	end 
	
function ViewPoint( ply, origin, angles, fov )
local dev=LocalPlayer():GetNetworkedEntity("Shuttle11",LocalPlayer())
local dist= -1000
local add=Vector(0,0,300)

	if LocalPlayer():GetNetworkedBool("isDriveShuttle11",false) and dev~=LocalPlayer() and dev:IsValid() then
		local view = {}
			view.origin = dev:GetPos()+dev:GetUp()*250+add+ply:GetAimVector():GetNormal()*dist
			view.angles = angles
		return view
	end
end
hook.Add("CalcView", "Shuttle11View", ViewPoint)
surface.CreateFont("STFontBig", {
		size = 80, --Size
		weight = 900, --Boldness
		antialias = true,
		shadow = false,
		font = "Arial"})
		
surface.CreateFont("STFontSmall", {
		size = 30, --Size
		weight = 900, --Boldness
		antialias = true,
		shadow = false,
		font = "Arial"})
function PrintHUD()
local dev=LocalPlayer():GetNetworkedEntity("Shuttle11",LocalPlayer())

	if LocalPlayer():GetNetworkedBool("isDriveShuttle11",false) and dev~=LocalPlayer() and dev:IsValid() then
			local Hull = math.Round(dev:GetNWInt("health")/10000*100) -- test fix
			local TorpType = dev:GetNWInt("TorpType")
			local TorpLoad = dev:GetNWInt("TorpLoad")
			local PhaserCharge = dev:GetNWInt("phaserCharge")
			if TorpLoad < 33 then
					Torp2Col = Color(255,61,0,255)
					Torp2Charge = "0"
				elseif (TorpLoad >= 33 and TorpLoad < 66) then
					Torp2Col = Color(255,61,0,255)
					Torp2Charge = "1"
				elseif (TorpLoad >= 66 and TorpLoad < 99) then
					Torp2Col = Color(255,61,0,255)
					Torp2Charge = "2"
				elseif TorpLoad >= 99 then
					Torp2Col = Color(255,61,0,255)
					Torp2Charge = "3"
				end
			
			if Hull > 20 then
				HullCol = Color(255,255,255)
			elseif Hull <= 20 then
				HullCol = Color(255,0,0,255)
			end
				
			
			draw.RoundedBox( 0, ScrW()-ScrW(), ScrH()/1.25, 300, 100, Color(255, 100, 0, 255) ) //Hull hud
			draw.RoundedBox( 0, ScrW()/1.20, ScrH()/1.22, 300, 50, Color(255, 160, 0, 255) ) //Torpedo hud
			draw.SimpleText("Hull: "..Hull,"STFontBig",ScrW()-ScrW(), ScrH()/1.24, HullCol,0,0)//HUll
			draw.SimpleText("Torpedo "..Torp2Charge,"STFontSmall",ScrW()/1.2, ScrH()/1.2, Torp2Col,0,0)//Quantum Torp
			draw.RoundedBox( 0, ScrW()/1.20, ScrH()/1.12, 280, 25, Color(255, 160, 0, 255) ) //Phaser Charge hud
			draw.RoundedBox( 0, ScrW()/1.20, ScrH()/1.11, PhaserCharge*2.8, 10, Color(255, 0, 0, 255) ) //Phaser Charge hud
			--draw.SimpleText("Phaser "..PhaserCharge,"STFontSmall",ScrW()/2, ScrH()/1.2, Torp2Col,0,0)//Quantum Torp
			
			
			
	end
end
hook.Add("HUDPaint","Shuttle11HUD",PrintHUD)

