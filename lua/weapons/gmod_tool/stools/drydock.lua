--Made by SuperPlayer 2015
--die_rlrp

if (CLIENT and GetConVarNumber("STA_UseTab") == 1) then TOOL.Tab = "Star Trek Addon"  end
TOOL.Category="Entities";
TOOL.Name="Drydock"
TOOL.Command = nil
TOOL.ConfigName = "Press Left Key to spawn a Drydock"
TOOL.ClientConVar[ "model" ] = "Drydock (NX-01).mdl"
local DrydockModels = {
	["models/Drydock (NX-01).mdl"] = {},
	["models/Drydock (Type 1).mdl"] = {}, 
	["models/Drydock (Type 4).mdl"] = {},
}


	function TOOL:CreateDock( ply, trace, model )
		local ent = ents.Create( "drydock" )
		if (!ent:IsValid()) then return end
		--ent:SetOptions( ply )
		ent:SetModel( model )
		ent:SetPos( trace.HitPos - trace.HitNormal * ent:OBBMins().z )
		ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0) )
		ent:Spawn()
		ent:Activate()
		return ent
	end
	
	function TOOL:GetCoreModel()
		local mdl = self:GetClientInfo("model")
			if (!util.IsValidModel(mdl) or !util.IsValidProp(mdl)) then return "models/Drydock (NX-01).mdl" end
		return mdl
	end
	
	function TOOL:LeftClick( trace )
		if (!trace) then return end
		local ply = self:GetOwner()
		local model = self:GetCoreModel()
		if (!model) then return end
		local ent = self:CreateDock( ply, trace, model )
		if (!ent) then return end
		
		local traceent = trace.Entity
					
		--if (!traceent:IsWorld() and !traceent:IsPlayer()) then
		--	local weld = constraint.Weld( ent, trace.Entity, 0, trace.PhysicsBone, 0 )
		--	local nocollide = constraint.NoCollide( ent, trace.Entity, 0, trace.PhysicsBone )
		--end
		
		ply:AddCount("drydock",ent)
		ply:AddCleanup ( "drydock", ent )

		undo.Create( "drydock" )
			undo.AddEntity( ent )
			undo.AddEntity( weld )
			undo.AddEntity( nocollide )
			undo.SetPlayer( ply )
		undo.Finish()

	
	end
	
if CLIENT then
	language.Add( "Tool.drydock.name", "Drydocks" )
	language.Add( "Tool.drydock.desc", "Used to spawn Drydocks." )
	language.Add( "Tool.drydock.0", "Primary: Spawn a Drydock and weld it, Secondary: Spawn a Warp core and don't weld it, Reload: Change the model of the core." )
	language.Add( "undone_drydock", "Undone Drydock" )
	language.Add( "Cleanup_drydock", "Drydocks" )
	language.Add( "Cleaned_drydock", "Cleaned up all Drydocks" )
	language.Add( "SBoxLimit_drydock", "You've reached the Drydock limit!" )

function TOOL.BuildCPanel( CPanel )
	-- Header stuff
	CPanel:AddControl("Header", { Text = "Drydock", Description = "Creates a Drydock to create ships." })
	
	CPanel:AddControl( "PropSelect", {
			Label = "#Select a model!",
			ConVar = "drydock_model",
			Category = "StarTrek",
			Models = DrydockModels
		})
end
	
function TOOL:DrawToolScreen()--@SuperPlayer
		self.BigFont = surface.CreateFont("BigFont", {
		size = 45,
		weight = 900,
		antialias = true,
		shadow = false,
		font = "Arial"})
	
		
		
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawRect(0, 0, 256, 256)
		
		surface.SetDrawColor(255, 120, 0, 255)
		surface.DrawRect(0, 20, 256, 80)
		
		  draw.SimpleText( "Drydock", "BigFont", 128, 70, Color(0,0,0,255), 1, 1 ) 

end
end
	-- Ghost functions
	


