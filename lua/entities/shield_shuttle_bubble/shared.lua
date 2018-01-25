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
ENT.Type 		= "anim"
ENT.Base 		= "base_gmodentity"

ENT.PrintName	= "Shuttlle 11 Shield Bubble"
ENT.Author		= "SuperPlayer"
ENT.Category 	= "Star Trek"
ENT.Contact		= "peterotto3475@gmail.com"
ENT.Purpose			= "Protection"
ENT.Spawnable			= false
ENT.AdminSpawnable		= false

--[[Based upon the shield of CAP Stargate Addon]]--
hook.Add("ST_Shield_Handler", "Shuttle11_Shield", function(shooter, bulletData, traceData)
	if not bulletData then return end
	if not IsValid(traceData.Entity) or traceData.Entity:GetClass() != "shield_shuttle_bubble" then return end

	local shield = traceData.Entity
	if bulletData.Callback then
		local dmg = DamageInfo()
		dmg:SetDamage(bulletData.Damage or 0)
		bulletData.Callback(shooter,traceData,dmg)
	end

	if SERVER then
		shield:DrawHit(traceData.HitPos,bulletData.Damage or 5)
	end
	return true
end)