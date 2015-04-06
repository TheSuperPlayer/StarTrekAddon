local usetab = CreateClientConVar("STA_UseTab", "1", true, false)

local function STATab()
			spawnmenu.AddToolTab("Star Trek Addon", "STA")
end
hook.Add("AddToolMenuTabs", "STATab", STATab)



