--[[
    Made by SuperPlayer
    Copyright[©] 2018 SuperPlayer
    All Rights Reserved

    This code was created by SuperPlayer for the addon "Star Trek Addon" for the game Garry's Mod.
    You may not use this code outside of this addon without written permission by me.
    If you want to use or modify this code, by parts OR as a whole, contact me first.
    Derivative works of this code are not allowed without permission.
    Do NOT distribute copies of this code in any form without permission by me.
    Under NO circumstances are you allowed to use this code to gain any kind of profit.

    If I find you breaking any of the statements above, I will take action accordingly.

    If you have any inquiries please contact me at:
    peterotto3475@gmail.com
    https://github.com/TheSuperPlayer
]]--
StarTrek.Menu = {}
hook.Add( "PopulateToolMenu", "PopulateStarTrek", function()
	spawnmenu.AddToolMenuOption( "Main", "Star Trek", "Menu_Info", "About", "", "", function(p)
        StarTrek.Menu.toolAbout(p)
	end )
end )

function StarTrek.Menu.toolAbout(P)
    P:ClearControls()
    local w,h = P:GetSize()
    local Logo = vgui.Create( "DImage", P ) 
    Logo:SetPos( 0, 0 )
    Logo:SetImage( "vgui/misc/logoNorm")
    Logo:SetSize(w,w)
	P:AddItem(Logo)	

    P:Help("Thank you for using the Star Trek Addon. This addon was made by SuperPlayer. If you you have any suggestions, feel free to contact me on github.")
    P:Help("Please find usual information below by clicking the buttons")
    P:Help("Current Version: "..tostring(StarTrek.Version))

    local helpButton = vgui.Create("DButton", P, "helpButton")
    helpButton:SetText("Help / Information")
    helpButton.DoClick = function()
	    StarTrek.Menu.HelpWindow()
    end
    P:AddItem(helpButton)

    local githubButton = vgui.Create("DButton", P, "gitButton")
    githubButton:SetText("Source Code / Download")
    githubButton.DoClick = function()
	    gui.OpenURL( "https://github.com/TheSuperPlayer/StarTrekAddon" )
    end
    P:AddItem(githubButton)

    local creditsButton = vgui.Create("DButton", P, "creditsButton")
    creditsButton:SetText("Credits & License")
    creditsButton.DoClick = function()
	    gui.OpenURL( "https://github.com/TheSuperPlayer/StarTrekAddon/blob/master/credits.txt" )
    end
    P:AddItem(creditsButton)
end

function StarTrek.Menu.HelpWindow()
    local frame = vgui.Create( "DFrame" )
    frame:SetSize( ScrW() /2 ,ScrH()/2  )
    frame:Center()
    frame:SetTitle( "Informations" )
    StarTrek.Menu.PaintFrame(frame)
    frame:MakePopup()

    local container = vgui.Create("DPanel", frame, "containerPanel")
    container:SetPos(4,35)
    container:SetSize((ScrW() /2)- 8, (ScrH() /2)- 39)

    local objectList = vgui.Create( "DListView", container )
    objectList:SetPos( 0, 0 )
    objectList:SetSize( 200, (ScrH() /2)- 39 )
    objectList:SetMultiSelect( false )
    objectList.Paint = function()
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetFont( "default" )
        surface.SetTextColor( 0, 0, 0, 255 )
        surface.DrawRect( 0, 0, objectList:GetWide(), objectList:GetTall() )
    end
    
    objectList:AddColumn("Shuttles")
    for k,v in pairs(StarTrek.Menu.InfoSheets) do
        local line = objectList:AddLine( v.printName )
        line.infoID = k
    end  
    
    local rowSelectedInfo = StarTrek.Menu.InfoSheets["shuttle6"]

    local infoView = vgui.Create("DPanel", container, "infoViewPanel")
    infoView:SetPos(objectList:GetWide()+5,0)
    infoView:SetSize((ScrW() /2)- objectList:GetWide()-13,objectList:GetTall())
    infoView.Paint = function(b,w,h)
        surface.SetDrawColor(255, 255, 255,255 )
        surface.DrawRect( 0, 0, w, h )
        if not rowSelectedInfo then return end

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( rowSelectedInfo.image )
        surface.DrawTexturedRect( 2, 2, w*0.3, w*0.3 )
        surface.SetDrawColor( 255, 120, 0, 255 )
        surface.DrawOutlinedRect( 2, 2, w*0.3, w*0.3 )

        draw.DrawText(rowSelectedInfo.printName, "MenuBig", w*0.3 + 5, h*0.01, Color(0,0,0,255), TEXT_ALIGN_LEFT )

        surface.DrawRect( w*0.3 + 5, h*0.09 , w*0.7 - 10 , h*0.03 )

        draw.DrawText("Hull Health: "..rowSelectedInfo.hullHealth, "MenuNormal", w*0.3 + 5, h*0.14, Color(0,0,0,255), TEXT_ALIGN_LEFT )
        draw.DrawText("Shield Strength: "..rowSelectedInfo.shieldStrength, "MenuNormal", w*0.3 + 5, h*0.18, Color(0,0,0,255), TEXT_ALIGN_LEFT )
        draw.DrawText("Weapon placements: "..tostring(#rowSelectedInfo.weaponInfo), "MenuNormal", w*0.3 + 5, h*0.23, Color(0,0,0,255), TEXT_ALIGN_LEFT )

        local offset = 0
        for k,v in pairs(rowSelectedInfo.weaponInfo) do
            draw.DrawText("Type: "..v[1].." | Damage: "..v[2].." | Amount: "..v[3], "MenuNormal", w*0.3 + 5, h*(0.23 + 0.04*k), Color(0,0,0,255), TEXT_ALIGN_LEFT )
            offset = h*(0.23 + 0.04*k)
        end

        draw.DrawText("Max. Speed: "..rowSelectedInfo.maxSpeed, "MenuNormal", w*0.3 + 5, offset + h*0.05, Color(0,0,0,255), TEXT_ALIGN_LEFT )
    end

    local w,h = ((ScrW() /2)- objectList:GetWide()-13),objectList:GetTall()
    local infoList = vgui.Create( "DListView", infoView )
    infoList:SetPos(2,w*0.31)
    infoList:SetSize(w,h*0.69)
    infoList:SetMultiSelect( false )
    infoList:AddColumn( "Function" )
    infoList:AddColumn( "Usage" )
    infoList:AddColumn( "Additional Information" )

    objectList.OnRowSelected = function( listView, row )
        local rowSelected = listView:GetLine(listView:GetSelectedLine()).infoID
        rowSelectedInfo = StarTrek.Menu.InfoSheets[rowSelected]
        infoList:Clear()
        for k,v in pairs(rowSelectedInfo.instructions) do
            infoList:AddLine(v[1],v[2],v[3])
        end
    end
end

function StarTrek.Menu.PaintFrame(P)
    local w,h = P:GetSize()
    P:ShowCloseButton(false)
    
    local closeButton = vgui.Create("DButton", P)
    closeButton:SetPos( w-50, 2.5 )
    closeButton:SetSize( 45, 25 )
    closeButton:SetText( "Close" )
    closeButton.Paint = function(b,w,h)
        surface.SetDrawColor(255, 0, 0,255 )
        surface.DrawRect( 0, 0, w, h )
    end
    closeButton.DoClick = function()
	    P:Close()
    end
    
    P.Paint = function(p,w,h)
        surface.SetDrawColor(255, 120, 0,180 )
        surface.DrawRect( 0, 0, w, h )

        surface.SetDrawColor(200, 200, 200, 255)
        surface.DrawRect( 4, 4, w-8, h-8 )

        surface.SetDrawColor(255, 120, 0, 255)
        surface.DrawRect( 0, 0, w, 30 )

        draw.DrawText( p:GetTitle() or "Window", "Default", 5,5, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT )
        p:SetTitle("")
    end
end

StarTrek.Menu.InfoSheets = {}
StarTrek.Menu.InfoSheets["shuttle11"] = {
    image = Material("vgui/entities/shuttle_11"),
    printName = "Shuttle Type 11",
    hullHealth = 10000,
    shieldStrength = 5000,
    weaponInfo = {
        {"Phaser","90/s",1},
        {"Photon Torpedo", "300",1}
    },
    maxSpeed = 1000,
    description = "Best Description",
    instructions = {
        {"Move Forward", "Forward Key (Usually W)", ""},
        {"Move Backward", "Forward Key (Usually S)", ""},
        {"Move Left", "Left Key (Usually A)", ""},
        {"Move Right", "Right Key (Usually D)", ""},
        {"Toggle Shield", "R Key OR Screen Usage", "Only works while piloting"},
        {"Toggle Door", "Buttons inside and outside", "Press use when close and aiming to them"},
        {"Warp", "Use Wire Addon", "If you dont have the wire addon, get it"},
        {"Beaming", "Use Wire Addon", "If you dont have the wire addon, get it"}
    }
}
StarTrek.Menu.InfoSheets["shuttle6"] = {
    image = Material("vgui/entities/shuttle_6"),
    printName = "Shuttle Type 6",
    hullHealth = 7500,
    shieldStrength = 3500,
    weaponInfo = {
        {"Phaser","45/s",1}
    },
    maxSpeed = 1000,
    description = "Best Description",
    instructions = {
        {"Move Forward", "Forward Key (Usually W)", ""},
        {"Move Backward", "Forward Key (Usually S)", ""},
        {"Move Left", "Left Key (Usually A)", ""},
        {"Move Right", "Right Key (Usually D)", ""},
        {"Toggle Shield", "R Key", "Only works while piloting"},
        {"Toggle Door", "Buttons inside and outside", "Press use when close and aiming to them"}
    }
}