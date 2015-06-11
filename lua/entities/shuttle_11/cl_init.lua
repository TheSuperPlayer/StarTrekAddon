include('shared.lua')
surface.CreateFont("ScreenFont1", {
		size = 150, --Size
		weight = 900, --Boldness
		antialias = true,
		shadow = false,
		font = "Arial"})
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
function ENT:Draw()
	self.Entity:DrawModel() // Draw the model.
	local dev= self.Entity--LocalPlayer():GetNetworkedEntity("Shuttle11",LocalPlayer())
	
	local pos = self.Entity:LocalToWorld(Vector(-149.5, 73, 242));
	local ang = self.Entity:GetAngles();
	ang:RotateAroundAxis(ang:Up(), 0)
	ang:RotateAroundAxis(ang:Forward(),	78.8)
	local str = "Shuttle Type 11"
	local Hull  = math.Round(dev:GetNWInt("health")/10000*100) -- test fix
	local Time = string.FormattedTime(os.clock(), "%02i:%02i:%02i")
	local Timestamp = os.time()
	local TimeStr = os.date( "%X - %d/%m/%Y" , Timestamp )
	if Hull > 20 then
				HullCol = Color(255,255,255)
			elseif Hull <= 20 then
				HullCol = Color(255,0,0,255)
			end
		cam.Start3D2D(pos, ang, 0.05 )
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawRect(0-1790/2, 0, 1790, 610)
			surface.SetDrawColor( 255, 80, 0, 255 )
			surface.DrawRect(0-1790/2, 100, 1790, 50)
			draw.DrawText(str, "SandboxLabel", 0, 20, Color(255,255,255,255), TEXT_ALIGN_CENTER )
			draw.DrawText("Hull: "..Hull, "ScreenFont1", -600, 300, HullCol, TEXT_ALIGN_CENTER )
			draw.DrawText(TimeStr, "SandboxLabel", 600, 560, Color(255,255,255,255), TEXT_ALIGN_CENTER )
		cam.End3D2D()

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

function PrintHUD()
local dev=LocalPlayer():GetNetworkedEntity("Shuttle11",LocalPlayer())

	if LocalPlayer():GetNetworkedBool("isDriveShuttle11",false) and dev~=LocalPlayer() and dev:IsValid() then
			local Hull = math.Round(dev:GetNWInt("health")/10000*100) -- test fix
			local TorpType = dev:GetNWInt("TorpType")
			local TorpLoad = dev:GetNWInt("TorpLoad")
			local PhaserCharge = dev:GetNWInt("phaserCharge")
			if TorpLoad < 33 then
					--Torp2Col = Color(255,61,0,255)
					Torp2Charge = "0"
				elseif (TorpLoad >= 33 and TorpLoad < 66) then
					--Torp2Col = Color(255,61,0,255)
					Torp2Charge = "1"
				elseif (TorpLoad >= 66 and TorpLoad < 99) then
					--Torp2Col = Color(255,61,0,255)
					Torp2Charge = "2"
				elseif TorpLoad >= 99 then
					--Torp2Col = Color(255,61,0,255)
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


