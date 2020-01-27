AddCSLuaFile()
if SERVER then return end

include("modules/cl_gui/gzt_createTab.lua")
include("modules/cl_gui/gzt_editTab.lua")
include("modules/cl_gui/gzt_prgmTab.lua")

local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrW()/3, ScrH()/2.5)
    self:MakePopup()
    self:SetPos(ScrW()/2 - self:GetWide()/2, ScrH()/2 - self:GetTall()/2)
    self:MakeBasePanel()
end

function PANEL:MakeBasePanel()
    self.BasePanel = vgui.Create("DPanel", self, "BasePanel")
    self.BasePanel:Dock(FILL)
    self.BasePanel.Paint = nil --so it will be transparent
    self.BasePanel.TabPane = vgui.Create("DPropertySheet", self.BasePanel, "TabPane")
    self.BasePanel.TabPane:Dock(FILL)
    self:MakeTabs()
end

function PANEL:MakeTabs()
    self.BasePanel.TabPane.CreateTab = vgui.Create("gzt_CreateTab", self.BasePanel.TabPane, "CreateTab")
    self.BasePanel.TabPane.EditTab = vgui.Create("gzt_EditTab", self.BasePanel.TabPane, "EditTab")
    self.BasePanel.TabPane.PrgmTab = vgui.Create("gzt_PrgmTab", self.BasePanel.TabPane, "PrgmTab")
    self.BasePanel.TabPane:AddSheet("Create", self.BasePanel.TabPane.CreateTab, "icon16/add.png")
    self.BasePanel.TabPane:AddSheet("Edit", self.BasePanel.TabPane.EditTab, "icon16/pencil.png")
    self.BasePanel.TabPane:AddSheet("Program", self.BasePanel.TabPane.PrgmTab, "icon16/page_white_code.png") 
end

vgui.Register("gzt_gui", PANEL, "EditablePanel") --has to be EditablePanel or else text entry wont work (thanks garry)