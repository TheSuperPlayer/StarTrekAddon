--[[
Main Functions
]]--
function StarTrek.CheckVersion()
	if (file.Exists("lua/version.lua","GAME")) then
		local Version = tonumber(file.Read("lua/version.lua","GAME"));
		return Version
	end
end
function StarTrek.NameIsAvailible(Name)
	local AllShips = ents.FindByClass("shuttle_*")
	for I = 1,#AllShips do
		if AllShips[I].ST_ID_Name == Name then 
			return false
		end
	end
	return true
end

function StarTrek.SetShipName(Ent,Name)
	if IsValid(Ent) then
		if Ent:GetClass() == "shuttle_*" and StarTrek.NameIsAvailible( Name ) then
			Ent.ST_ID_Name(Name)
		end
	end
end

function StarTrek.GetShipName(Ent)
	if IsValid(Ent) and Ent:GetClass() == "shuttle_*" then
		if Ent.ST_ID_Name then
			return Ent.ST_ID_Name
		end
	end
end

function StarTrek.IsInShield(Ent)
	local trace = { start = Ent:GetPos(), endpos = Ent:GetPos(), filter = Ent }
	local tr = util.TraceEntity( trace, Ent )
	if tr.Hit then
		if tr.Entity:GetClass() == "shield_shuttle_bubble" then
			return true
		end
	end
	return false
end
hook.Add("EntityTakeDamage", "ST_TakeDamage_Override", function(Ent, dInfo)
	if StarTrek.IsInShield(Ent) then
		dInfo:SetDamage(0)
	end
end)

hook.Add("PhysgunPickup", "ST_DisablePickup", function(Ply, Ent)
	if Ent.ST_DisablePickup then return false end
end)

util.AddNetworkString( "ST_Shuttle11_NetHook")
