AddCSLuaFile()
include("modules/cl_gui/gzt_createPanel.lua")
include("modules/cl_gui/gzt_editPanel.lua")
include("modules/cl_gui/gzt_prgmPanel.lua")
if SERVER then return end

PANEL = {}

function PANEL:Init()
    self.createMode = vgui.Create("gzt_createPanel", self, "create")
    self.editMode = vgui.Create("gzt_editPanel", self, "edit")
    self.prgmMode = vgui.Create("gzt_prgmPanel", self, "program")
    self.createMode:Show()
    self.editMode:Hide()
    self.prgmMode:Hide()
end

function PANEL:changeMode(mode)
    
end

vgui.Register("gzt_basemodePanel", PANEL, "DPanel")