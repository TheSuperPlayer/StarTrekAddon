--[[
    Made by SuperPlayer
    Copyright[©] 2018 SuperPlayer
    All Rights Reserved

    This code was created by SuperPlayer for the addon "Star Trek Addon" for the game Garry's Mod.
    You may not use this code outside of this addon without written permission by me.
    If you want to use or modify this code, by parts OR as a whole, contact me first.
    Derivative works of this code are not allowed without permission.
    Do NOT distribute copies of this code in any form without permission by me.
    Under NO circumstances are you allowed to use this code to gain any kind of profit.

    If I find you breaking any of the statements above, I will take action accordingly.

    If you have any inquiries please contact me at:
    peterotto3475@gmail.com
    https://github.com/TheSuperPlayer
]]--

include('shared.lua')
local HelmPoly = {
	{x=15,y=72},
	{x=130,y=72},
	{x=120,y=92},
	{x=23,y=92}
}

ENT.inWarp = 0
ENT.warpEnd = Vector(0,0,0)
function ENT:EndWarp()
	self.inWarp = 0
	self.warpEnd = Vector(0,0,0)
	net.Start("ST_Shuttle11_NetHook")
	net.WriteUInt(4, 4)
	net.WriteEntity(self.Entity)
	net.SendToServer()
end
function ENT:Draw()
	self.Entity:DrawModel()
	local shuttle= self.Entity
	
	local pos = self.Entity:LocalToWorld(Vector(-149.5, 73, 242))
	local ang = self.Entity:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 0)
	ang:RotateAroundAxis(ang:Forward(),	78.8)
	local str = "Shuttle Type 11"
	local Hull  = math.Round(shuttle:GetNWInt("health")/10000*100)
	local shieldCharge  = shuttle:GetNWInt("shieldCharge")
	local shieldOn  = shuttle:GetNWBool("shieldOn")
	shieldCharge = math.Round(shieldCharge/5000 * 100)
	local Time = string.FormattedTime(os.clock(), "%02i:%02i:%02i")
	local Timestamp = os.time()
	local TimeStr = os.date( "%X - %d/%m/%Y" , Timestamp )
	if Hull > 20 then
		HullCol = Color(255,255,255)
	elseif Hull <= 20 then
		HullCol = Color(255,0,0,255)
	end
	if shieldCharge > 20 then
		ShieldCol = Color(255,255,255)
	elseif shieldCharge <= 20 then
		ShieldCol = Color(255,0,0,255)
	end
		
	cam.Start3D2D(pos, ang, 0.05 )
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawRect(0-1790/2, 0, 1790, 610)
		surface.SetDrawColor( 255, 80, 0, 255 )
		surface.DrawRect(0-1790/2, 100, 1790, 50)

		surface.SetDrawColor( 255, 255, 255, 150 )
		surface.DrawRect(0-1510/2, 225, 1510, 120)
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawRect(0-1500/2, 230, 1500, 110)
		surface.SetDrawColor( 255, 120, 0, 255 )
		surface.DrawRect(0-1500/2, 230, 1500/100*Hull, 110)-- Hull Line

		surface.SetDrawColor( 255, 255, 255, 150 )
		surface.DrawRect(0-1510/2, 375, 1510, 120)
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawRect(0-1500/2, 380, 1500, 110)
		surface.SetDrawColor( 0, 100, 255, 255 )
		surface.DrawRect(0-1500/2, 380, 1500/100*shieldCharge, 110)-- Shield Line

		draw.DrawText(str, "STFontBig", 0, 20, Color(255,255,255,255), TEXT_ALIGN_CENTER )
		draw.DrawText("Hull: "..Hull.."%", "ScreenFont1", -750, 225, HullCol, TEXT_ALIGN_LEFT )
		if shieldOn then
			draw.DrawText("Shield: "..shieldCharge.."% Online", "ScreenFont1", -750, 375, ShieldCol, TEXT_ALIGN_LEFT )
		else
			if shieldCharge < 10 then
				draw.DrawText("Shield: "..shieldCharge.."% Recharging", "ScreenFont1", -750, 375, ShieldCol, TEXT_ALIGN_LEFT )
			else
				draw.DrawText("Shield: "..shieldCharge.."% Offline", "ScreenFont1", -750, 375, ShieldCol, TEXT_ALIGN_LEFT )
			end
		end

		StarTrek.GUI.DrawButton("Shuttle11ToggleShield_"..tostring(self.Entity:EntIndex()), pos, ang, 0.05 ,{-750,520}, {300,75}, 
		function(Ply) 
			net.Start( "ST_Shuttle11_NetHook")
			net.WriteUInt(3, 4)
			net.WriteEntity(self.Entity)
			net.SendToServer()
		end,  
		function(x,y,w,h) 
			surface.SetDrawColor( 255, 255, 255, 150 )
			surface.DrawRect(x, y, w, h)
			surface.SetDrawColor( 0, 100, 255, 255 )
			surface.DrawRect(x+2, y+2, w-4, h-4)
			draw.DrawText("Toggle Shield", "ToggleShieldFont", x+5, y+10, Color(255,255,255,200), TEXT_ALIGN_LEFT )
		end)
		draw.DrawText(TimeStr, "STFontSmall", 600, 560, Color(255,255,255,255), TEXT_ALIGN_CENTER )
		
	cam.End3D2D()
	
	local pos2 = self.Entity:LocalToWorld(Vector(-259, -31, 211))
	local ang2 = self.Entity:GetAngles()
	ang2:RotateAroundAxis(ang2:Up(), 90)
	ang2:RotateAroundAxis(ang2:Forward(),	44)

	cam.Start3D2D(pos2, ang2, 0.2)
		surface.SetDrawColor( 0, 0, 0, 255 )
		draw.NoTexture()
		surface.DrawPoly( HelmPoly )
		StarTrek.GUI.DrawButton("Shuttle11Pilot_"..tostring(self.Entity:EntIndex()), pos2, ang2, 0.2 ,{10,72}, {115,20}, 
		function(Ply) 
			net.Start( "ST_Shuttle11_NetHook")
			net.WriteUInt(1, 4)
			net.WriteEntity(self.Entity)
			net.WriteEntity(Ply)
			net.SendToServer()
		end,  
		function(x,y,w,h) 
			surface.SetDrawColor( 255, 80, 0, 255 )
			surface.DrawRect(x+5, y, w, 1)
			draw.DrawText("Enter", "HelmEnterFont", 72, 72, Color(255,255,255,200), TEXT_ALIGN_CENTER )
		end)
	cam.End3D2D()
	
	local pos3 = self.Entity:LocalToWorld(Vector(105, -64, 220))
	local ang3 = self.Entity:GetAngles()
	ang3:RotateAroundAxis(ang3:Up(), -90)
	ang3:RotateAroundAxis(ang3:Forward(), 90)

	cam.Start3D2D(pos3, ang3, 0.2)
		StarTrek.GUI.DrawButton("Shuttle11Indoor_"..tostring(self.Entity:EntIndex()), pos3, ang3, 0.2 ,{-2,-2}, {29,99}, 
		function(Ply) 
			net.Start( "ST_Shuttle11_NetHook")
			net.WriteUInt(2, 4)
			net.WriteEntity(self.Entity)
			net.SendToServer()
		end,  
		function(x,y,w,h) 
			surface.SetDrawColor( 255, 80, 0, 255 )
			surface.DrawRect(-2,-2,29,99)
			surface.SetDrawColor( 50, 50, 50, 255 )
			surface.DrawRect(0,0,25,95)
			draw.DrawText("T", "HelmEnterFont", 12, 0, Color(255,255,255,200), TEXT_ALIGN_CENTER )
			draw.DrawText("O", "HelmEnterFont", 12, 15, Color(255,255,255,200), TEXT_ALIGN_CENTER )
			draw.DrawText("G", "HelmEnterFont", 12, 30, Color(255,255,255,200), TEXT_ALIGN_CENTER )
			draw.DrawText("G", "HelmEnterFont", 12, 45, Color(255,255,255,200), TEXT_ALIGN_CENTER )
			draw.DrawText("L", "HelmEnterFont", 12, 60, Color(255,255,255,200), TEXT_ALIGN_CENTER )
			draw.DrawText("E", "HelmEnterFont", 12, 75, Color(255,255,255,200), TEXT_ALIGN_CENTER )
		end)
	cam.End3D2D()

	local pos4 = self.Entity:LocalToWorld(Vector(321, 45, 197))
	local ang4 = self.Entity:GetAngles()
	ang4:RotateAroundAxis(ang4:Up(), 90)
	ang4:RotateAroundAxis(ang4:Forward(), 135)

	cam.Start3D2D(pos4, ang4, 0.2)
		StarTrek.GUI.DrawButton("Shuttle11Outdoor_"..tostring(self.Entity:EntIndex()), pos4, ang4, 0.2 ,{0,0}, {95,25}, 
		function(Ply) 
			net.Start( "ST_Shuttle11_NetHook")
			net.WriteUInt(2, 4)
			net.WriteEntity(self.Entity)
			net.SendToServer()
		end,  
		function(x,y,w,h) 
			surface.SetDrawColor( 50, 50, 50, 100 )
			surface.DrawRect(0,0,95,25)
			draw.DrawText("TOGGLE", "HelmEnterFont", 12, 4, Color(255,255,255,200), TEXT_ALIGN_LEFT )
		end)
	cam.End3D2D()
end    

function ViewPoint( ply, origin, angles, fov )
	local shuttle=LocalPlayer():GetNWEntity("Shuttle11",LocalPlayer())
	local dist= -1000
	local add=Vector(0,0,300)
	if LocalPlayer():GetNWBool("isDriveShuttle11",false) and shuttle~=LocalPlayer() and IsValid(shuttle) then
		local view = {}
		local inWarp = shuttle.inWarp
		local warpEnd = shuttle.warpEnd
		if inWarp > 0 then
			if inWarp == 1 then
				view.origin = shuttle:GetPos()+shuttle:GetUp()*250+add+ply:GetAimVector():GetNormal()*dist
				view.angles = angles
			elseif inWarp == 2 then
				view.origin = warpEnd+shuttle:GetForward()*-2500+ shuttle:GetUp()*500
				local toVec = (warpEnd - (warpEnd+shuttle:GetForward()*-2500+ shuttle:GetUp()*500) ):GetNormalized()
				view.angles = toVec:Angle()
			end
		else
			view.origin = shuttle:GetPos()+shuttle:GetUp()*250+add+ply:GetAimVector():GetNormal()*dist
			view.angles = angles
		end
		return view
	end
end
hook.Add("CalcView", "Shuttle11View", ViewPoint)

function PrintHUD()
	local shuttle = LocalPlayer():GetNWEntity("Shuttle11",LocalPlayer())
	if LocalPlayer():GetNWBool("isDriveShuttle11",false) and shuttle~=LocalPlayer() and IsValid(shuttle) then
			local Hull = math.Round(shuttle:GetNWInt("health")/10000*100)
			local TorpType = shuttle:GetNWInt("TorpType")
			local TorpLoad = shuttle:GetNWInt("TorpLoad")
			local phaserHeat = 100 -shuttle:GetNWInt("phaserCharge")
			local shieldCharge =  shuttle:GetNWInt("shieldCharge")
			shieldCharge = math.Round(shieldCharge/5000 * 100)
			local shieldOn =  shuttle:GetNWBool("shieldOn")
			local screenW = ScrW()
			local screenH = ScrH()

			local function xCord(num)
				return screenW/100*num
			end
			local function yCord(num)
				return screenH/100*num
			end

			surface.SetFont( "STFontBig" )
			surface.SetTextColor( 255, 255, 255, 255 )
			if Hull <= 20 then
				surface.SetTextColor( 255,0, 0, 255 )
			end
			local w,hHullT = surface.GetTextSize("Hull 100")
			surface.SetTextPos( xCord(1) , yCord(80) )

			surface.SetDrawColor( 255, 80, 0, 255 )
			surface.DrawRect(xCord(0), yCord(80), xCord(2)+w, yCord(1)+hHullT)
			surface.DrawText( "Hull "..tostring(Hull) )
			
			surface.SetDrawColor( 0, 100, 255, 255 )
			surface.SetTextColor( 255, 255, 255, 255 )
			local w,h = surface.GetTextSize("Shield 100")
			surface.DrawRect(xCord(0), yCord(80)+hHullT, xCord(2)+w, yCord(3)+h)
			surface.SetTextPos( xCord(1) , yCord(80)+hHullT )
			surface.DrawText( "Shield "..tostring(shieldCharge) )

			surface.SetFont( "STFontSmall" )
			surface.SetTextPos( xCord(1) , yCord(79)+hHullT+h )
			if shieldOn then
				surface.DrawText( "Online" )
			else
				if shieldCharge < 10 then
					surface.DrawText( "Recharging" )
				else
					surface.DrawText( "Offline" )
				end
			end


			surface.SetDrawColor(0,0,0) 
			surface.DrawRect(xCord(94), yCord(40), xCord(4), yCord(40))
			surface.SetDrawColor( 255, 80, 0, 255 )
			surface.DrawOutlinedRect(xCord(94), yCord(40), xCord(4), yCord(40))
			surface.SetDrawColor( 2.55*phaserHeat, 255-2.2*phaserHeat, 0, 255 )
			surface.DrawRect(xCord(94.2), yCord((80-0.5)-0.4*phaserHeat), xCord(3.6), yCord(40.2-(shuttle:GetNWInt("phaserCharge")*0.4)))
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawRect(xCord(93), yCord((80-0.5)-0.4*phaserHeat), xCord(6), yCord(1))


			if phaserHeat > 75 then
				surface.SetFont( "STFontBig" )
				surface.SetTextColor( 255, 0, 0, 200 )
				local w,h = surface.GetTextSize("WARNING! PHASER OVERHEATING")
				surface.SetTextPos( xCord(50) - w/2, yCord(15) )
				surface.DrawText( "WARNING! PHASER OVERHEATING" )
			end

			surface.SetDrawColor( 255, 80, 0, 255 )
			surface.SetFont( "STFontSmall" )
			surface.SetTextColor( 255, 255, 255, 255 )
			local w,h = surface.GetTextSize("Torpedos: "..tostring(TorpLoad))
			surface.DrawRect(xCord(98.5) - w, yCord(90), xCord(2)+w, yCord(1)+h)

			surface.SetTextPos( xCord(99) - w, yCord(91) )
			surface.DrawText( "Torpedos: "..tostring(TorpLoad ))

			local filterEnts = {shuttle}
			for k,v in pairs(shuttle:GetChildren()) do
				filterEnts[k+1] = v
			end

			local tr = util.TraceLine( {
				start = shuttle:GetPos()+ shuttle:GetUp()*190 + shuttle:GetForward()*-360,
				endpos = shuttle:GetPos() + shuttle:GetForward()*-10000,
				filter = filterEnts
			} )
		
		local screenCord = tr.HitPos:ToScreen()
		if screenCord.visible then
			surface.SetMaterial(aimOutlineMat)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(screenCord.x - xCord(7)/2, screenCord.y-yCord(7)/2, xCord(7),yCord(7))
		end
	end
end
hook.Add("HUDPaint","Shuttle11HUD",PrintHUD)