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

function ENT:Draw()
    self.Entity:DrawModel()

	local openDoorOutsidePos = self.Entity:LocalToWorld(Vector(97, 57, 60))
	local openDoorOutsideAng = self.Entity:GetAngles()
	openDoorOutsideAng:RotateAroundAxis(openDoorOutsideAng:Up(),90)
	openDoorOutsideAng:RotateAroundAxis(openDoorOutsideAng:Forward(),90)

	cam.Start3D2D(openDoorOutsidePos, openDoorOutsideAng, 0.2)
		StarTrek.GUI.DrawButton("Shuttle6DoorOut_"..tostring(self.Entity:EntIndex()), openDoorOutsidePos, openDoorOutsideAng, 0.2 ,{0,0}, {95,25}, 
		function(Ply) 
			net.Start( "ST_Shuttle6_NetHook")
			net.WriteUInt(1, 4)
			net.WriteEntity(self.Entity)
			net.SendToServer()
		end,  
		function(x,y,w,h) 
			surface.SetDrawColor( 50, 50, 50, 70 )
			surface.DrawRect(0,0,90,25)
			draw.DrawText("TOGGLE", "MenuNormal", 12, 4, Color(0,0,0,200), TEXT_ALIGN_LEFT )
		end)
	cam.End3D2D()
	local openDoorInsidePos = self.Entity:LocalToWorld(Vector(19, 13, 102))
	local openDoorInsideAng = self.Entity:GetAngles()
	openDoorInsideAng:RotateAroundAxis(openDoorInsideAng:Up(),90)
	openDoorInsideAng:RotateAroundAxis(openDoorInsideAng:Right(),180)
	cam.Start3D2D(openDoorInsidePos, openDoorInsideAng, 0.2)
		StarTrek.GUI.DrawButton("Shuttle6DoorIn_"..tostring(self.Entity:EntIndex()), openDoorInsidePos, openDoorInsideAng, 0.2 ,{2,2}, {126,30}, 
		function(Ply) 
			net.Start( "ST_Shuttle6_NetHook")
			net.WriteUInt(1, 4)
			net.WriteEntity(self.Entity)
			net.SendToServer()
		end,  
		function(x,y,w,h) 
			draw.RoundedBox(10, x ,y ,w ,h , Color(80, 108, 168, 255))
			draw.DrawText("Toggle Door", "MenuBold", w/2, 10, Color(0,0,0,200), TEXT_ALIGN_CENTER )
		end)
	cam.End3D2D()
	local enterShuttlePos = self.Entity:LocalToWorld(Vector(-120, 0, 60))
	local enterShuttleAng = self.Entity:GetAngles()
	enterShuttleAng:RotateAroundAxis(enterShuttleAng:Up(),90)
	enterShuttleAng:RotateAroundAxis(enterShuttleAng:Forward(),90)

	cam.Start3D2D(enterShuttlePos, enterShuttleAng, 0.2)
		StarTrek.GUI.DrawButton("Shuttle6Enter_"..tostring(self.Entity:EntIndex()), enterShuttlePos, enterShuttleAng, 0.2 ,{-40,0}, {80,20}, 
		function(Ply) 
			net.Start( "ST_Shuttle6_NetHook")
			net.WriteUInt(2, 4)
			net.WriteEntity(self.Entity)
			net.WriteEntity(Ply)
			net.SendToServer()
		end,  
		function(x,y,w,h) 
			draw.RoundedBox(10, x ,y ,w ,h , Color(80, 108, 168, 255))
			draw.DrawText("Enter", "HelmEnterFont", x+w/2, 2.5, Color(0,0,0,200), TEXT_ALIGN_CENTER )
		end)
	cam.End3D2D()
end

aimOutlineMat = Material("vgui/misc/aim_outline")
function PrintHUD()
	local shuttle = LocalPlayer():GetNWEntity("Shuttle6",LocalPlayer())
	if LocalPlayer():GetNWBool("isDriveShuttle6",false) and shuttle~=LocalPlayer() and IsValid(shuttle) then
		local Hull = math.Round(shuttle:GetNWInt("Health", 100) / shuttle.MaxHull * 100)
		local phaserHeat = 100 -shuttle:GetNWInt("phaserCharge")
		local shieldCharge =  math.Round(shuttle:GetNWInt("ShieldCharge",shuttle.MaxShield) / shuttle.MaxShield*100)
		local shieldOn =  shuttle:GetNWBool("ShieldOn", false)
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

		local filterEnts = {shuttle}
		for k,v in pairs(shuttle:GetChildren()) do
			filterEnts[k+1] = v
		end

		local tr = util.TraceLine( {
			start = shuttle:GetPos() + shuttle:GetForward()*-60 + shuttle:GetUp()*25,
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
hook.Add("HUDPaint","Shuttle6HUD",PrintHUD)

function ViewPoint( ply, origin, angles, fov )
	local shuttle=LocalPlayer():GetNWEntity("Shuttle6",LocalPlayer())
	local dist= -750
	local add=Vector(0,0,0)
	if LocalPlayer():GetNWBool("isDriveShuttle6",false) and shuttle~=LocalPlayer() and IsValid(shuttle) then
		local view = {}
		local inWarp = 0
		local warpEnd = Vector(0,0,0)
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
hook.Add("CalcView", "Shuttle6View", ViewPoint)