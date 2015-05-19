local usetab = CreateClientConVar("STA_UseTab", "1", true, false)
local function STATab()
			spawnmenu.AddToolTab("Star Trek Addon", "StarTrek","VGUI/tabs/logo16")
end
hook.Add("AddToolMenuTabs", "STATab", STATab)