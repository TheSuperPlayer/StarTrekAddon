include('shared.lua')

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

//local LASER = Material('cable/redlaser')

function SWEP:Initialize()
    local ply = LocalPlayer()
    self.VM = ply:GetViewModel()
    local attachmentIndex = self.VM:LookupAttachment("muzzle")
    if attachmentIndex == 0 then attachmentIndex = self.VM:LookupAttachment("1") end
	self.Attach = attachmentIndex
end

function SWEP:ViewModelDrawn()
	/*
	if(self.Weapon:GetNWBool("Active")) then
	--[[
	    local pos = self.Owner:GetShootPos()
	    local tracedata = {}
			tracedata.start = pos
			tracedata.endpos = pos + self.Owner:GetAimVector() * 100000
			tracedata.filter = self.Owner
	    local trace = util.TraceLine(tracedata)
		]]--
        //Draw the laser beam.
        //render.SetMaterial( LASER )
	    //render.DrawBeam(trace.StartPos, trace.HitPos, 6, 0, 10, Color(255,0,0,255))
		//render.DrawBeam(self.VM:GetAttachment(self.Attach).Pos, self.Owner:GetEyeTrace().HitPos, 2, 0, 12.5, Color(255, 0, 0, 255))
        //Msg("Laser\n")
    end
	*/
end
