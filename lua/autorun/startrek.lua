--Gamemode functions
StarTrek = { }


local function CheckVersion()
	if (file.Exists("lua/cap_ver.lua","GAME")) then
		StarTrek.Version = tonumber(file.Read("lua/version.lua","GAME"));
	end
end

local function ValidToInclude(state)
	return (state == "server" and SERVER) or ((state == "client") and CLIENT) or state == "shared";
end
local function ValidToExecute(fl,state)
	return true;
end

local function AddFiles1( folder, files, N )
	for k,v in ipairs( files ) do
		if (N == 1) then
			AddCSLuaFile(folder..v)
			MsgN("Loading1:"..v);
		elseif (N == 2) then
			AddCSLuaFile(folder..v)
			include(folder..v)
			MsgN("Loading2:"..v);
		elseif (N == 3) then
			include(folder..v)
			MsgN("Loading3:"..v);
		end
	end
end

local function AddFiles2( folder, files )
		for k,v in ipairs( files ) do
			include(folder .. v)
		end
	end


function StarTrek.Load()
	CheckVersion()
	MsgN("=======================================================");
	MsgN("Loading Star Trek Addon");
	--MsgN("Current Version: "..StarTrek.Version);
	if (StarTrek.Version == nil) then
		MsgN("Current Version: ERROR");
	else
		MsgN("Current Version: "..StarTrek.Version);
	end
	MsgN("=======================================================");
	-- Addons check


AddFiles1( "startrek/server/", file.Find("startrek/server/*.lua", "LUA"), 3 )
AddFiles1( "startrek/shared/", file.Find("startrek/shared/*.lua", "LUA"), 2 )
AddFiles1( "startrek/client/", file.Find("startrek/client/*.lua", "LUA"), 1 )
	

	

	
AddFiles2( "startrek/client/", file.Find("startrek/client/*.lua", "LUA") )
AddFiles2( "startrek/shared/", file.Find("startrek/shared/*.lua", "LUA") )


	MsgN("=======================================================");
end
	

StarTrek.Load();