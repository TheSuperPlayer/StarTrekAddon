if 1 == 1 then return end
if (CLIENT and GetConVarNumber("STA_UseTab") == 1) then TOOL.Tab = "Star Trek Addon" end
TOOL.Category="Weapons";
TOOL.Name="Phaser Emitter"
TOOL.Command = nil
TOOL.ConfigName = "Press Left Key to spawn a Ship Core" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 

						

if SERVER then

function TOOL:LeftClick( trace )
	
	
	if ( CLIENT ) then return true end
	print("ok")
	return true
end


function TOOL:CreateCore( ply, trace )

end
else
function TOOL.BuildCPanel( CPanel )
	-- Header stuff
	CPanel:AddControl("Header", { Text = "Phaser Emitter", Description = "Creates a Phaser EMitter a powerful energy weapon." })

end


end
	-- Ghost functions
	
	

