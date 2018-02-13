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
StarTrek = { }

local function CheckVersion()
	if (file.Exists("lua/startrek/version.lua","GAME")) then
		StarTrek.Version = file.Read("lua/startrek/version.lua","GAME")
	end
end

local function GetVersion()
	if StarTrek.Version == nil then CheckVersion() end
	print("Star Trek Addon Version: "..StarTrek.Version)
end
concommand.Add( "STA_version", GetVersion)

local function loadFiles( Folder, Files, Env )
	for k,v in ipairs( Files ) do
		if Env == "sh" or Env == "cl" then
			AddCSLuaFile(Folder..v)
			include(Folder..v)
			MsgN("Loading SHARED file:"..v)
		elseif Env == "s" then
			include(Folder..v)
			MsgN("Loading SERVER file:"..v)
		end
	end
end

function StarTrek.Load()
	CheckVersion()
	MsgN("=======================================================")
	MsgN("---------------Loading Star Trek Addon-----------------")
	MsgN("=======================================================")
	MsgN("Author: SuperPlayer")

	if (StarTrek.Version == nil) then
		MsgN("Current Version: ERROR")
	else
		MsgN("Current Version: "..StarTrek.Version)
	end

	loadFiles( "startrek/server/", file.Find("startrek/server/*.lua", "LUA"), "s" )
	loadFiles( "startrek/shared/", file.Find("startrek/shared/*.lua", "LUA"), "sh" )
	loadFiles( "startrek/client/", file.Find("startrek/client/*.lua", "LUA"), "cl" )

	if SERVER then
		StarTrek.CheckForLS()
	end
	MsgN("=======================================================")
end
	
concommand.Add( "STA_reload", StarTrek.Load)

function GetMeshCmd()
	if not StarTrek.Debug then return end
	models = ents.FindByModel( "models/myproject/sphere.mdl" ) 
	local phys = models[1]:GetPhysicsObject()
	local t = phys:GetMesh()
	for i=1,#t,1 do
		for _, vertex in pairs(t[i]) do
			print(vertex)
			if i == 1 then
				file.Write( "verts.txt", tostring(vertex).."\n")
			else
				file.Append( "verts.txt",  tostring(vertex).."\n" )
			end
		end
	end

end

concommand.Add( "STA_MeshOfObj", GetMeshCmd)
StarTrek.Load()