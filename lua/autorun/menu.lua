local TD = CreateClientConVar( "STA_TakeDamage", "1", true, false )



function TheMenu( Panel )
	Panel:ClearControls()
		local Logo = vgui.Create( "DImageButton", DermaPanel ) 
		Logo:SetPos( 25, 50 )
		Logo:SetImage( "VGUI/tabs/logoNorm" ) -- Set your .vtf image
		Logo:SizeToContents()
		Logo.DoClick = function(self)
			local window = vgui.Create( "DFrame" )
			window:SetSize( 415,220 )
			window:Center()
			window:SetTitle( "Star Trek Addon Info" )
			window:MakePopup()

			local DLabel = vgui.Create( "DLabel", window )
			DLabel:SetPos(7.5,30)
			DLabel:SetText(
				[[
				Welcome to the Star Trek Addon.
				
				This Addon is made by SuperPlayer.
				Here is some small info:
				
				1. The Addon is still in developing if you want to contribute please contact me.
				
				Live long and prosper!
				]]
			)
			DLabel:SizeToContents()
		end
	Panel:AddItem(Logo)
	
	local TakeDamageCB = vgui.Create( "DCheckBoxLabel", DermaPanel )
		TakeDamageCB:SetPos( 10,50 )
		TakeDamageCB:SetText( "Take Damage?" )
		TakeDamageCB:SetConVar( "STA_TakeDamage" ) -- ConCommand must be a 1 or 0 value
		TakeDamageCB:SetValue( "1" )
		TakeDamageCB:SizeToContents() -- Make its size to the contents. Duh?
	Panel:AddItem(TakeDamageCB) 
	
	
end
	

 
function CreateMenu()
	spawnmenu.AddToolMenuOption( "Star Trek Addon",
			"Config",   
			"Config",  
			 "Config",    "",    "",    
			TheMenu,
			{SwitchConVar="sv_cheats"} )
end
hook.Add( "PopulateToolMenu", "Config", CreateMenu )