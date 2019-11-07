AddCSLuaFile()
include("modules/cl_gui/gzt_createPanel.lua")
include("modules/cl_gui/gzt_editPanel.lua")
include("modules/cl_gui/gzt_prgmPanel.lua")
if SERVER then return end

PANEL = {}

function PANEL:Init()
    self.createMode = vgui.Create("gzt_createPanel", self, GZT_ZONETOOL.Modes.Create)
    self.editMode = vgui.Create("gzt_editPanel", self, GZT_ZONETOOL.Modes.Edit)
    self.prgmMode = vgui.Create("gzt_prgmPanel", self, GZT_ZONETOOL.Modes.Program)
    self.createMode:Show()
    self.createMode:Dock(FILL)
    self.createMode:DockPadding(20, 20, 20, 20)
    local x,y = self:GetParent():GetParent():GetPos()
    self.editMode:Hide()
    self.editMode:Dock(FILL)
    self.prgmMode:Hide()
    self.prgmMode:Dock(FILL)
end

function PANEL:changeMode(mode)
    
end

vgui.Register("gzt_basemodePanel", PANEL, "DPanel")