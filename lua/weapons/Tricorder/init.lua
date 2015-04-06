AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
//resource.AddFile("materials/VGUI/entities/laserPointer.vmt")
//resource.AddFile("materials/VGUI/entities/laserPointer.vtf")
include('shared.lua')
util.PrecacheSound("stpack/com_hail.wav")
util.PrecacheSound("stpack/com_established.wav")
util.PrecacheSound("stpack/com_one2beam.wav")
SWEP.Weight = 8
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Receiver = nil
SWEP.Pointing = false
SWEP.ViewModel = "models/ef2weapons/tricorder_stx/tricorder.mdl";
SWEP.WorldModel = "models/ef2weapons/tricorder_stx/tricorder.mdl";

function SWEP:Initialize()
    self.Pointing = true
	self.Receiver = self.Weapon
end

function SWEP:Reload()
	
end


// Message
// Function taken from connas stools all credit for this function goes to him.
function SWEP:Message(Text,snd)
	if SERVER then
		if (snd == 1) then
			self.Owner:SendLua("GAMEMODE:AddNotify('"..Text.."', NOTIFY_GENERIC, 10)")
			self.Owner:SendLua("surface.PlaySound('console/beep0"..math.random(1, 6)..".wav')")
		elseif (snd == 0) then
			self.Owner:SendLua("GAMEMODE:AddNotify('"..Text.."', NOTIFY_GENERIC, 10)")
		end
	end
end

function SWEP:PrimaryAttack()
/*
    //Msg("Fire\n")
	//Msg("self.Pointing = " .. tostring(self.Pointing) .. "\n")
*/
	//self:Message("Initiating Transport",0)
	Msg("ComBadge Active - 1 Person to beam\n")
	self.Owner:EmitSound("stpack/com_one2beam.wav", 100, 100)
	self.Owner:StopSound("stpack/com_one2beam.wav", 100, 100)

		timer.Simple(1.3, 
					function()
						self.Receiver:SetNetworkedInt("Receive", 1);
						//Msg("NW - 1\n")
					end
		);
		timer.Simple(1.6, 
					function()
						self.Receiver:SetNetworkedInt("Receive", 0);
						//Msg("NW - 0\n")
					end
		);
/*
		timer.Simple(2.2,
					function()
						local player = self.Owner
						player:Freeze(false)
						//self:Message("Transport Complete",1)
					end
		);
*/
/*
	//self.Weapon:SetNWBool("Active", self.Pointing)
	//self:Message("Pointing on = "..tostring(self.Pointing),1)

	if(self.Pointing && self.Receiver && self.Receiver:IsValid())then
       Wire_TriggerOutput(self.Receiver,"Active",1)
    else
       Wire_TriggerOutput(self.Receiver,"Active",0)        
	end
*/
end

function SWEP:SecondaryAttack()
	--Msg("Secondary\n")
    local pos = self.Owner:GetShootPos()
    local tracedata = {}
	    tracedata.start = pos
	    tracedata.endpos = pos + self.Owner:GetAimVector() * 100000
	    tracedata.filter = self.Owner
    local trace = util.TraceLine(tracedata)
    	
    if (trace.Entity:GetClass() == "transporter_platform") then
        //Msg("Link\n")
        self.Receiver = trace.Entity
        self:Message("Communications Interlink Activated",0)
		self.Owner:EmitSound("stpack/com_established.wav", 100, 100)
		self.Receiver:SetNetworkedInt("comActive", 1)
        return true
    end
end


function SWEP:Think()
	self.Pointing = !self.Pointing

    if(self.Pointing && self.Receiver && self.Receiver:IsValid())then
        local pos = self.Owner:GetShootPos()
        local tracedata = {}
	        tracedata.start = pos
	        tracedata.endpos = pos + self.Owner:GetAimVector() * 100000
	        tracedata.filter = self.Owner
        local trace = util.TraceLine(tracedata)
	
        self.point = self.Owner:GetPos();
        //Wire_TriggerOutput(self.Receiver, "DestX", self.point.x)
        //Wire_TriggerOutput(self.Receiver, "DestY", self.point.y)
        //Wire_TriggerOutput(self.Receiver, "DestZ", self.point.z)

		self.DestSRC = Vector( self.point.x, self.point.y, self.point.z )
		self.Receiver:SetNetworkedVector("DestSRC", self.DestSRC)
		self.Receiver.VPos = self.point

        //Msg("Send!\n")
    end
end