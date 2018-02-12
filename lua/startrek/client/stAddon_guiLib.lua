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
if not StarTrek.GUI then StarTrek.GUI = {} end
StarTrek.GUI.Buttons = {}
STGUIButton = {}
STGUIButton.__index = STGUIButton
StarTrek.GUI.UseRange = 150

local function Intersect(Pos,Ang)
    local trace = util.IntersectRayWithPlane( LocalPlayer():EyePos(), LocalPlayer():GetAimVector(), Pos, Ang:Up() ) 
    if not trace then return end
    if LocalPlayer():GetPos():Distance(trace) > StarTrek.GUI.UseRange then return end
    local HitPos = WorldToLocal(trace, Angle(0,0,0),Pos,Ang)
    return {HitPos.x, -HitPos.y}
end

local function AddButton(Index, PPos, PAng, PScale ,BPos, BSize, Func)   
    if Index != nil then
        if StarTrek.GUI.Buttons[Index] then
            StarTrek.GUI.Buttons[Index] = setmetatable({
                PlanePosition = PPos,
                PlaneAngle = PAng,
                PlaneScale = PScale,
                ButtonPos = BPos,
                ButtonSize = BSize,
                Callback = Func,
                LastUsed = StarTrek.GUI.Buttons[Index].LastUsed
            },STGUIButton)
        else
            StarTrek.GUI.Buttons[Index] = setmetatable({
                PlanePosition = PPos,
                PlaneAngle = PAng,
                PlaneScale = PScale,
                ButtonPos = BPos,
                ButtonSize = BSize,
                Callback = Func,
                LastUsed = CurTime()
            },STGUIButton)
        end
    end
end

function StarTrek.GUI.ResetButtons()
    StarTrek.GUI.Buttons = {}
end

function StarTrek.GUI.DrawButton(Index, PPos, PAng, PScale ,BPos, BSize, Func,  DrawFunc)
    AddButton(Index, PPos, PAng, PScale ,BPos, BSize, Func)
    DrawFunc(BPos[1], BPos[2], BSize[1], BSize[2])
    if StarTrek.Debug then
        surface.SetDrawColor(255, 0, 0, 255)
        surface.DrawOutlinedRect(BPos[1], BPos[2], BSize[1], BSize[2])
    end
end

function STGUIButton:isPosInBounds(Cord)
    local x = self.ButtonPos[1]*self.PlaneScale
    local y = self.ButtonPos[2]*self.PlaneScale
    local x2 = x + self.ButtonSize[1]*self.PlaneScale
    local y2 = y + self.ButtonSize[2]*self.PlaneScale
    return (Cord[1]>=x and Cord[1] <= x2) and (Cord[2]>=y and Cord[2] <= y2)
end

function STGUIButton:Pressed()
    local CoordPressed = Intersect(self.PlanePosition, self.PlaneAngle)
    if not CoordPressed then return false end
    if not self:isPosInBounds(CoordPressed) then return false end
    return true
end

hook.Add("KeyPress", "GUI", function(Ply,Key)
    if Key == IN_USE then
        for i, v in pairs(StarTrek.GUI.Buttons) do
            if v:Pressed() and v.LastUsed+1 < CurTime() then
                v.Callback(LocalPlayer())
                v.LastUsed = CurTime()
            end
        end
    end
end)

net.Receive( "ST_GUI_ResetButtons", function()
    StarTrek.GUI.ResetButtons()
end )