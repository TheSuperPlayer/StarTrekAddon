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
StarTrek.Debug = false
StarTrek.Shared = {}

--[[Based upon the shield of CAP Stargate Addon]]--
hook.Add("EntityFireBullets", "ST_Shield_Bullet_Handler", function( shooter, bulletData ) 
    if not bulletData then return end
    local pos = bulletData.src or shooter:GetPos()
    local dir = bulletData.Dir or Vector(0,0,0)
    local originalSpread = bulletData.Spread or Vector(0,0,0)
    bulletData.Spread = Vector(0,0,0)
    local finalDir = Vector(dir.x,dir.y,dir.z)
    if originalSpread and originalSpread != Vector(0,0,0) then
        local additionRndm = {math.random(-1,1),math.random(-1,1)}
        local v1 = (dir:Cross(Vector(1,1,1))):GetNormalized();
		local v2 = (dir:Cross(v1)):GetNormalized();
		finalDir = finalDir + v1*originalSpread.x*additionRndm[1] + v2*originalSpread.y*additionRndm[2];
        bulletData.Dir = finalDir;
    end

    local traceTable = {
        start = pos,
        endpos = pos + finalDir *10^14,
        filter = {shooter, shooter:GetParent()}
    }
    local bulletTrace = util.TraceLine(traceTable)

    if hook.Call("ST_Shield_Handler", GAMEMODE, shooter, bulletData, bulletTrace) then
        return false
    end
end)
