AddCSLuaFile()

include("modules/cl_gui/gzt_createTab.lua")
include("modules/cl_gui/gzt_editTab.lua")
include("modules/cl_gui/gzt_prgmTab.lua")

if SERVER then return end

CreateClientConVar("gzt_is_paused", 0, false, true, "Is player currently paused, used for input proccesing (Dont Touch)",0,1)
CreateClientConVar("gzt_in_menu", 0, false, true, "Is player currently in the gzt GUI, used for input proccesing (Dont Touch)",0,1)

local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrW()/3, ScrH()/2.5)
    self:MakePopup()
    self:SetPos(ScrW()/2 - self:GetWide()/2, ScrH()/2 - self:GetTall()/2)
    self:MakeBasePanel()
    --TODO:Hide on init
end

function PANEL:MakeBasePanel()
    self.BasePanel = vgui.Create("DPanel", self, "BasePanel")
    self.BasePanel:Dock(FILL)
    self.BasePanel:InvalidateParent(true)
    self.BasePanel.Paint = nil --so it will be transparent
    self.BasePanel.TabPane = vgui.Create("DPropertySheet", self.BasePanel, "TabPane")
    self.BasePanel.TabPane:Dock(FILL)
    self.BasePanel.TabPane:InvalidateParent(true)
    self.BasePanel.TabPane:SetupCloseButton(function() LocalPlayer():ConCommand("gzt_toggle_gui") end)
    self.BasePanel.TabPane.CloseButton:SetColor(Color(150,0,0,200))
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

function PANEL:OnKeyCodePressed(keyCode)
    if keyCode == KEY_H then
        --TODO: make this rebindable
        LocalPlayer():ConCommand("gzt_toggle_gui")
    end
end

vgui.Register("gzt_gui", PANEL, "EditablePanel") --has to be EditablePanel or else text entry wont work (thanks garry)