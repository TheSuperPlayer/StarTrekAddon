if (CLIENT and GetConVarNumber("STA_UseTab") == 1) then TOOL.Tab = "Star Trek Addon" end
TOOL.Category="Weapons";
TOOL.Name="Phaser Emitter"
TOOL.Command = nil
TOOL.ConfigName = "Press Left Key to spawn a Ship Core" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 
cleanup.Register("phaser_emitter")




						
if (SERVER) then
	AddCSLuaFile("phaser_emitter.lua")
	CreateConVar("sbox_maxphaser_emitter", 6)

	function TOOL:CreateCore( ply, trace )
		local ent = ents.Create( "phaser_emitter" )
		if (!ent:IsValid()) then return end
		ent:SetPos( trace.HitPos - trace.HitNormal * ent:OBBMins().z )
		ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0) )
		ent:Spawn()
		ent:Activate()
		return ent
	end
	
	function TOOL:LeftClick( trace )
		if (!trace) then return end
		local ply = self:GetOwner()
		if (!ply:CheckLimit("phaser_emitter")) then return end
		local ent = self:CreateCore( ply, trace )
		if (!ent) then return end
		
		local traceent = trace.Entity
		
		
		if (!traceent:IsWorld() and !traceent:IsPlayer()) then
			local weld = constraint.Weld( ent, trace.Entity, 0, trace.PhysicsBone, 0 )
			local nocollide = constraint.NoCollide( ent, trace.Entity, 0, trace.PhysicsBone )
		
		end
			
		ply:AddCount("phaser_emitter",ent)
		ply:AddCleanup ( "phaser_emitters", ent )

		undo.Create( "phaser_emitter" )
			undo.AddEntity( ent )
			undo.AddEntity( weld )
			undo.AddEntity( nocollide )
			undo.SetPlayer( ply )
		undo.Finish()
	end

else
	language.Add( "Tool.phaser_emitter.name", "Phaser Emitter" )
	language.Add( "Tool.phaser_emitter.desc", "Used to spawn Phaser." )
	language.Add( "Tool.phaser_emitter.0", "Primary: Spawn a Phaser Emitter and weld it." )
	language.Add( "undone_phaser_emitters", "Undone Phaser Emitter" )
	language.Add( "Cleanup_phaser_emitters", "Phaser Emitter" )
	language.Add( "Cleaned_phaser_emitters", "Cleaned up all Phaser Emitter" )
	language.Add( "SBoxLimit_maxphaser_emitters", "You've reached the Phaser Emitter limit!" )
	
	function TOOL.BuildCPanel( CPanel )
		-- Header stuff
		CPanel:AddControl("Header", { Text = "Phaser Emitter", Description = "Creates a Phaser EMitter a powerful energy weapon." })
	
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
	

end