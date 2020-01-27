AddCSLuaFile()
if SERVER then return end

local PANEL = {}

function PANEL:Init() 
    --TODO: Add close button
end

vgui.Register("gzt_TabPanel", PANEL, "DPanel")