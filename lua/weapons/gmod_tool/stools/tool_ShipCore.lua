if (CLIENT and GetConVarNumber("STA_UseTab") == 1) then TOOL.Tab = "Star Trek Addon" end
TOOL.Category="Entities";
TOOL.Name="Ship Core"
TOOL.Command = nil
TOOL.ConfigName = "Press Left Key to spawn a Ship Core" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 
TOOL.ClientConVar[ "model" ] = "models/entities/shipcore/d12siesmiccharge.mdl"
TOOL.ClientConVar["autoweld"] = 1;
cleanup.Register("shipcore")

local ShipCoreModels = {
	["models/entities/shipcore/d12siesmiccharge.mdl"] = {},
	["models/microWarpCore/microwarpcore.mdl"] = {}, 
	["models/entities/shipcore/ls_gen11a.mdl"] = {},
	["models/entities/shipcore/toesmall.mdl"] = {}
}


-- This needs to be shared...
function TOOL:GetCoreModel()
	local mdl = self:GetClientInfo("model")
	if (!util.IsValidModel(mdl) or !util.IsValidProp(mdl)) then return "models/entities/shipcore/d12siesmiccharge.mdl" end
	return mdl
end
						
if (SERVER) then
	AddCSLuaFile("ShipCore.lua")
	CreateConVar("sbox_maxshipcore", 6)

	function TOOL:CreateCore( ply, trace, model )
		local ent = ents.Create( "ShipCore" )
		if (!ent:IsValid()) then return end
		ent:SetOptions( ply )
		ent:SetModel( model )
		ent:SetPos( trace.HitPos - trace.HitNormal * ent:OBBMins().z )
		ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0) )
		ent:Spawn()
		ent:Activate()
		return ent
	end
	
	function TOOL:LeftClick( trace )
		if (!trace) then return end
		local ply = self:GetOwner()
		if (!ply:CheckLimit("shipcore")) then return end
		local model = self:GetCoreModel()
		if (!model) then return end
		local ent = self:CreateCore( ply, trace, model )
		if (!ent) then return end
		
		local traceent = trace.Entity
		
		
		if (!traceent:IsWorld() and !traceent:IsPlayer()) then
			local weld = constraint.Weld( ent, trace.Entity, 0, trace.PhysicsBone, 0 )
			local nocollide = constraint.NoCollide( ent, trace.Entity, 0, trace.PhysicsBone )
		
		end
			
		ply:AddCount("shipcore",ent)
		ply:AddCleanup ( "shipcore", ent )

		undo.Create( "shipcore" )
			undo.AddEntity( ent )
			undo.AddEntity( weld )
			undo.AddEntity( nocollide )
			undo.SetPlayer( ply )
		undo.Finish()
	end
	
	

	
	function TOOL:Reload( trace )
		if (trace.Hit) then
			if (trace.Entity and IsValid(trace.Entity)) then
				self:GetOwner():ConCommand("shipcore_model " .. trace.Entity:GetModel())
				self:GetOwner():ChatPrint("Ship Core model set to: " .. trace.Entity:GetModel())
			end
		end
	end	
else--CLIENT
	language.Add( "Tool.shipcore.name", "Ship Cores" )
	language.Add( "Tool.shipcore.desc", "Used to spawn Ship cores." )
	language.Add( "Tool.shipcore.0", "Primary: Spawn a Ship core and weld it, Secondary: Spawn a Ship core and don't weld it, Reload: Change the model of the core." )
	language.Add( "Tool.shipcore", "Undone Ship core" )
	language.Add( "Cleanup_shipcores", "Ship Cores" )
	language.Add( "Cleaned_shipcore", "Cleaned up all Ship Cores" )
	language.Add( "SBoxLimit_sshipcore", "You've reached the Ship Core limit!" )
	
	
	function TOOL.BuildCPanel( CPanel )
		-- Header stuff
		CPanel:AddControl("Header", { Text = "Ship Core", Description = "Creates a Ship Core" })
		-- Models
		CPanel:AddControl("ComboBox", {
			Label = "#Presets",
			--MenuButton = "1",
			--Folder = "pewpew",

			Options = {
				Default = {
					shipcore_model = "models/entities/shipcore/d12siesmiccharge.mdl"
				}
			},

			CVars = {
				[0] = "shipcore_model"
			}
		})
		
		-- (Thanks to Grocel for making this selectable icon thingy)
		CPanel:AddControl( "PropSelect", {
			Label = "#Models (Or click Reload to select a model)",
			ConVar = "shipcore_model",
			Category = "Star Trek",
			Models = ShipCoreModels
		})
	end

	-- Ghost functions
	function TOOL:UpdateGhostCore( ent, player )
		if (!ent or !ent:IsValid()) then return end
		local trace = player:GetEyeTrace()
		
		if (!trace.Hit or trace.Entity:IsPlayer()) then
			ent:SetNoDraw( true )
			return
		end
		
		ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0) )
		ent:SetPos( trace.HitPos - trace.HitNormal * ent:OBBMins().z )
		
		ent:SetNoDraw( false )
	end
	
	function TOOL:Think()
		local model = self:GetCoreModel()
		if (!self.GhostEntity or !self.GhostEntity:IsValid() or self.GhostEntity:GetModel() != model) then
			local trace = self:GetOwner():GetEyeTrace()
			self:MakeGhostEntity( Model(model), trace.HitPos, trace.HitNormal:Angle() + Angle(90,0,0) )
		end
		self:UpdateGhostCore( self.GhostEntity, self:GetOwner() )
	end
	
	function TOOL:DrawToolScreen(width, height)
	local BackCol = Color(255,255,255,255)
	local BackTex = surface.GetTextureID("materials/VGUI/toolgun/sgu_screen.vtf")
	surface.CreateFont("BigFont", {
		size = 50, --Size
		weight = 900, --Boldness
		antialias = true,
		shadow = false,
		font = "Arial"})
		surface.CreateFont("SmallFont", {
		size = 25, --Size
		weight = 900, --Boldness
		antialias = true,
		shadow = false,
		font = "Arial"})
		
		surface.SetDrawColor(10, 134, 217, 255)
		surface.DrawRect(0, 0, 256, 256)
		surface.SetTexture(BackTex)
		surface.SetDrawColor(Color(1,1,1,255))
		surface.DrawTexturedRect(128, 128, 256, 256)
		--surface.SetDrawColor(1, 1, 1, 255)
		--draw.SimpleText("Ship Core", "BigFont", 128, 50, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		--draw.SimpleText("Creates a Ship Core", "SmallFont", 128, 200, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end