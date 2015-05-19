--Made by SuperPlayer 2015
if 1 == 1 then return end

if (CLIENT and GetConVarNumber("STA_UseTab") == 1) then TOOL.Tab = "Star Trek Addon" end
TOOL.Category="Entities";
TOOL.Name="Warp Core"
TOOL.Command = nil
TOOL.ConfigName = "Press Left Key to spawn a Ship Core"




	function TOOL:CreateCore( ply, trace, model )
		local ent = ents.Create( "warp_core" )
		if (!ent:IsValid()) then return end
		--ent:SetOptions( ply )
		ent:SetModel( "models/microWarpCore/microwarpcore.mdl" )
		ent:SetPos( trace.HitPos - trace.HitNormal * ent:OBBMins().z )
		ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0) )
		ent:Spawn()
		ent:Activate()
		return ent
	end
	
	function TOOL:LeftClick( trace )
		if (!trace) then return end
		local ply = self:GetOwner()
		--if (!ply:CheckLimit("pewpew_cores")) then return end
		--local model = self:GetCoreModel()
		--if (!model) then return end
		local ent = self:CreateCore( ply, trace, "models/microWarpCore/microwarpcore.mdl" )
		if (!ent) then return end
		
		local traceent = trace.Entity
					
		if (!traceent:IsWorld() and !traceent:IsPlayer()) then
			local weld = constraint.Weld( ent, trace.Entity, 0, trace.PhysicsBone, 0 )
			local nocollide = constraint.NoCollide( ent, trace.Entity, 0, trace.PhysicsBone )
		end
		
		ply:AddCount("warp_core",ent)
		ply:AddCleanup ( "warp_core", ent )

		undo.Create( "warp_core" )
			undo.AddEntity( ent )
			undo.AddEntity( weld )
			undo.AddEntity( nocollide )
			undo.SetPlayer( ply )
		undo.Finish()

	
	end
	

	language.Add( "Tool.warp_core.name", "Warp Cores" )
	language.Add( "Tool.warp_core.desc", "Used to spawn Warp cores." )
	language.Add( "Tool.warp_core.0", "Primary: Spawn a Warp core and weld it, Secondary: Spawn a Warp core and don't weld it, Reload: Change the model of the core." )
	language.Add( "undone_warp_core", "Undone Warp core" )
	language.Add( "Cleanup_warp_core", "Warp Cores" )
	language.Add( "Cleaned_warp_core", "Cleaned up all Warp Cores" )
	language.Add( "SBoxLimit_warp_core", "You've reached the Warp Core limit!" )

function TOOL.BuildCPanel( CPanel )
	-- Header stuff
	CPanel:AddControl("Header", { Text = "Phaser Emitter", Description = "Creates a Warp Core." })

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
		
		  draw.SimpleText( "Warp Core", "BigFont", 128, 70, Color(0,0,0,255), 1, 1 ) 

end

	-- Ghost functions
	


