AddCSLuaFile()

if SERVER then return end

local PANEL = {}

function PANEL:Init()
    self:DockPadding(20, 10, 20, 10)
    
    self.GamemodeSelect = vgui.Create("DComboBox", self, "GamemodeSelect")
    self.GamemodeSelect:DockMargin(0,0,500,0)
    self.GamemodeSelect:Dock(TOP)
    for _,gm in pairs(engine.GetGamemodes()) do
        self.GamemodeSelect:AddChoice(gm.name)
    end
    self.GamemodeSelect:SetValue(engine.ActiveGamemode())

    self.TreeView = vgui.Create("DTree", self, "TreeView")
    self.TreeView:DockMargin(0, 10, 0, 0)
    self.TreeView:Dock(FILL)

    self:InvalidateParent(true)
end

vgui.Register("gzt_CreateTab", PANEL, "DPanel")