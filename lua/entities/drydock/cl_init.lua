include('shared.lua')

function ENT:Initialize()
	--Nothing here.
end

function ENT:Draw()      
	self.Entity:DrawModel()-- We want to see the model, right?
end

function ENT:Think()
	--We don't need to "think"! At least not yet
end

local VGUI = {}--Thats a table
function VGUI:Init()--Thats our VGUI or you can call it window
	local DermaPanel = vgui.Create( "DFrame" ) -- Thats the base frame
		DermaPanel:SetPos(  ScrW()/2 - 500,ScrH()/2 - 250 ) 
		DermaPanel:SetSize( 1000, 500 )
		DermaPanel:SetTitle( "Star Trek Drydock" )
		DermaPanel:SetVisible( true )
		DermaPanel:SetDraggable( false )
		DermaPanel:ShowCloseButton( false ) 
		DermaPanel:MakePopup()
		DermaPanel.Paint = function()
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawRect( 0, 0, DermaPanel:GetWide(), DermaPanel:GetTall() )
    end
	
	 local CloseButton = vgui.Create( "DButton", DermaPanel )-- Like the name says thats a close button
		 CloseButton:SetPos( 900,5 )
		 CloseButton:SetSize( 90, 45 )
		 CloseButton:SetText( "Close" )
		 CloseButton:SetTextColor( Color( 255, 255, 255 ) )
		 CloseButton.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 180, 0, 255 ) ) 
		end
		 CloseButton.DoClick = function()-- And what happens when we click the close button?
			DermaPanel:Remove()--We close the window!
		end
		
		local PropertySheet = vgui.Create( "DPropertySheet" ,DermaPanel)--Thats for our tabs.
			PropertySheet:SetPos( 10, 30 )
			PropertySheet:SetSize( 980, 450 )			
		----------------------------SHUTTLE TAB-----------------------
		local Sheet_Shuttles = vgui.Create("DPanel", PropertySheet);--Our first sheet will be the spawn a shuttle sheet
				Sheet_Shuttles:SetPos(0, 0);
				Sheet_Shuttles:SetSize(220, 450);
				Sheet_Shuttles.Paint = function( self, w, h )
					draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 150, 0, 255 ) ) 
				end
				--Now we have our Shuttle sheet so we need to make the rest
				local ComboShuttle = vgui.Create( "DListView", Sheet_Shuttles )
					ComboShuttle:SetPos( 0, 0 )
					ComboShuttle:SetSize( 220, 450 )
					ComboShuttle:SetMultiSelect( false )
					ComboShuttle.Paint = function()
						surface.SetDrawColor( 255, 255, 255, 255 )
						surface.SetFont( "default" )
						surface.SetTextColor( 0, 0, 0, 255 )
						surface.DrawRect( 0, 0, ComboShuttle:GetWide(), ComboShuttle:GetTall() )--Make it auto size
					end
					ComboShuttle:AddColumn("Select Shuttle Type")--All availible shuttle types
					ComboShuttle:AddLine( "Shuttle Type 6" )
					ComboShuttle:AddLine( "Shuttle Type 9" )
					ComboShuttle:AddLine( "Shuttle Type 11" )	
					ComboShuttle:SortByColumn(1,false)
					
				--Naming Box
				local ShuttleNaming = vgui.Create( "DTextEntry")--The Shuttles needs a name. Doesnt it?
					ShuttleNaming:SetParent( Sheet_Shuttles )
					ShuttleNaming:SetPos( 240,10 )
					ShuttleNaming:SetTall( 20 )
					ShuttleNaming:SetWide( 450 )
					ShuttleNaming:SetEnterAllowed( true )
					ShuttleNaming.OnEnter = function()
						Msg("You entered -"..ShuttleNaming:GetValue().."-!" ) 
					end
				--Create Button
				
				local ShuttleCreateButton = vgui.Create( "DButton" )--An other buttton; For creation this time
					ShuttleCreateButton:SetParent( Sheet_Shuttles )
					ShuttleCreateButton:SetText( "Create" )
					ShuttleCreateButton:SetSize( 730, 50 )
					ShuttleCreateButton:SetPos( 230, 350 )
					ShuttleCreateButton.Paint = function( self, w, h )
						draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 180, 0, 255 ) ) 
					end
					ShuttleCreateButton.DoClick = function ()
						if (ComboShuttle:GetSelected()[1] and ComboShuttle:GetSelected()) then--Is a shuttle type selected?
							local ShuttleType = ComboShuttle:GetSelected()[1]:GetValue(1)
							local ShuttleName = ShuttleNaming:GetValue()
							if ShuttleType != "" and ShuttleName != "" then--Is the shuttle named?
							MsgN(ShuttleType..", "..ShuttleName)--Debug
							
							net.Start("Drydock")--Everything is ok so lets create the Shuttle
							net.WriteEntity(self.Entity)--Needs to be there dont know why
							net.WriteString(ShuttleType)--What shuttle type we want create?
							net.WriteString(ShuttleName)--Whats its name?
							net.SendToServer();
							DermaPanel:Remove()--Close the window!
							else
								GAMEMODE:AddNotify("You have to select a Shuttle Type and you have to name it!", NOTIFY_ERROR, 5);--If not named return an ERROR!
							end
							else
							GAMEMODE:AddNotify("You have to select a Shuttle Type", NOTIFY_ERROR, 5);--If no shuttle type selected return an ERROR!
						end
					end
		----------------------------STARSHIP TAB-----------------------	
		local Sheet_Starships = vgui.Create("DPanel", PropertySheet);--The sheet for the big ships
				Sheet_Starships:SetPos(0, 0);
				Sheet_Starships:SetSize(220, 450);
				Sheet_Starships.Paint = function( self, w, h )
					draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 150, 0, 255 ) )
				end		
				
			local ComboStarShip = vgui.Create( "DListView", Sheet_Starships )
					ComboStarShip:SetPos( 0, 0 )
					ComboStarShip:SetSize( 220, 450 )
					ComboStarShip:SetMultiSelect( false )
					ComboStarShip.Paint = function()
						surface.SetDrawColor( 255, 255, 255, 255 )
						surface.SetFont( "default" )
						surface.SetTextColor( 0, 0, 0, 255 )
						surface.DrawRect( 0, 0, ComboStarShip:GetWide(), ComboStarShip:GetTall() )
					end
					ComboStarShip:AddColumn("Select Starship Class")--Here we put our classes
					ComboStarShip:AddLine( "Souvereign Class" )
					ComboStarShip:AddLine( "Galaxy Class" )
					ComboStarShip:AddLine( "Constitution Class" )	
					ComboStarShip:AddLine( "Intrepid Class" )	
					ComboStarShip:AddLine( "Defiant Class" )	
					ComboStarShip:SortByColumn(1,false)
					
				--Naming Box
				local StarshipNaming = vgui.Create( "DTextEntry", Sheet_Starships )--Starships need names
					StarshipNaming:SetPos( 240,10 )
					StarshipNaming:SetTall( 20 )
					StarshipNaming:SetWide( 450 )
					StarshipNaming:SetEnterAllowed( true )
					StarshipNaming.OnEnter = function()
						Msg("You entered -"..StarshipNaming:GetValue().."-!" ) 
					end
					
				local StarshipCreateButton = vgui.Create( "DButton" )--Lets create the thing
					StarshipCreateButton:SetParent( Sheet_Starships )
					StarshipCreateButton:SetText( "Create" )
					StarshipCreateButton:SetSize( 730, 50 )
					StarshipCreateButton:SetPos( 230, 350 )
					StarshipCreateButton.Paint = function( self, w, h )
						draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 180, 0, 255 ) ) 
					end
					StarshipCreateButton.DoClick = function ()
						if (ComboStarShip:GetSelected()[1] and ComboStarShip:GetSelected()) then
							local StarshipType = ComboStarShip:GetSelected()[1]:GetValue(1)
							local StarshipName = StarshipNaming:GetValue()
							print(StarshipType..", "..StarshipName)
							GAMEMODE:AddNotify("Starships are not invented yet. Choose a shuttle!", NOTIFY_ERROR, 5);--I havent coded starships yet so we have to return an ERROR!
							--DermaPanel:Remove()
						end
					end
		--------------------------------------------------------------------		
		 	PropertySheet:AddSheet("Shuttles", Sheet_Shuttles, "VGUI/tabs/logo16", false, false, "Create a Shuttle");--Add the Shuttle Tab
			PropertySheet:AddSheet("Spaceships", Sheet_Starships, "VGUI/tabs/logo16", false, false, "Create a Spaceship");	--Add the Starship tab
		
		
end	

vgui.Register( "DrydockPanel", VGUI )

function VGUI:SetEntity(e)
	self.Entity = e;
end

function Drydock(um)
	local e = um:ReadEntity();
	if(not IsValid(e)) then return end;
	local Window = vgui.Create( "DrydockPanel" )--Open the Window!
	Window:SetMouseInputEnabled( false )
	Window:SetVisible( true )
	Window:SetEntity(e)
	--VGUI:SetEntity(e)
end
usermessage.Hook("Drydock", Drydock)--If we get the signal run the Drydock function.