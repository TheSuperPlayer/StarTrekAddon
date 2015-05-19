--[[
Main Functions
]]--
	
	function StarTrek.NameIsAvailible(Name)
		local AllShips = ents.FindByClass("shuttle_*")
				for I = 1,#AllShips do
					if AllShips[I]:GetName() == Name then return false
					else
					return true
					end
				end
	
	end
	
	function StarTrek.SetShipName(Ent,Name)
		if IsValid(Ent) then
			if Ent:GetClass() == "shuttle_*" and StarTrek.NameIsAvailible( Name ) then
				Ent:SetName(Name)
			end
		end
	end
	
	function StarTrek.GetShipName(Ent)
		if IsValid(Ent) and Ent:GetClass() == "shuttle_*" then
			local Name = Ent:GetName()
			print(Name)
			return Name
		end
	end