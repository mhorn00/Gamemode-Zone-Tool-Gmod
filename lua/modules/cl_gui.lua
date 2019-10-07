AddCSLuaFile()

if SERVER then 
    util.AddNetworkString("gzt_receivecatagories")
    return 
end

local PANEL = {}

net.Receive("gzt_receivecatagories", function(len, ply)
    local CatagoryList = net.ReadTable()
    GZT_PANEL.CatagoryList = CatagoryList
    //print("panel", PANEL)
    //PrintTable(PANEL)
    -- print("cat list ")
    -- PrintTable(PANEL.CatagoryList)
end)

PANEL.CatagoryList = {}
PANEL.FirstSelected = false
PANEL.CurrentMode = nil

COLORS = {
    base = Color(75,75,75,255)
}

GZT_PANEL = nil

function PANEL:SetToolRef(tool)
    self.tool = tool
    net.Start("gzt_getcatagories")
    net.SendToServer()
end

function PANEL:PopulateUI()
    self:PopulateModeList()
    if(!self.FirstSelected) then
        self.FirstSelected = true
        self:SelectMode(self.tool:GetToolMode())
    end
end

function PANEL:Init()
    self:SetSize(ScrW()/2, ScrH()/1.5)
    self:AddTopbar()
    self:AddBasePanel()
    self:AddSidebar()
    self:AddBaseModePanel()
    self:AddProgramMode()
    self:AddCreateMode()
    self:MakePopup()
    self:SetPos(ScrW()/2 - self:GetWide()/2, ScrH()/2 - self:GetTall()/2)
end

function PANEL:AddTopbar()
    --Top Bar
    self.topbar = vgui.Create("EditablePanel", self)
    self.topbar:Dock(TOP)
    self.topbar:SetTall(self:GetTall()/40)
    self.topbar.Paint = function(self, width, height)
        surface.SetDrawColor(0, 0, 0, 255)
        draw.RoundedBoxEx(5, 0, 0, width, height, Color(100,100,100,255), true, true, false, false)
    end
    self.topbar.OnMousePressed = function(topbar)
        self.topbar.isDragging = true
        local x,y = self:GetPos()
        self.topbar.clickPos = {gui.MouseX()-x, gui.MouseY()-y}
    end
    self.topbar.OnMouseReleased = function(topbar)
        self.topbar.isDragging = false
        self.topbar.clickPos = nil
    end
    self.topbar.isDragging=false
    
    --Close Button
    self.closeBtn = vgui.Create("DButton", self.topbar)
    self.closeBtn.DoClick = function(self)
        GZT_PANEL:Hide()
    end
    self.closeBtn:SetPos(self:GetWide()-self.closeBtn:GetWide(), 0)
    self.closeBtn:SetText("")
    self.closeBtn:Dock(RIGHT)
    self.closeBtn:SetWide(30)
    self.closeBtn.Paint = function(self,w,h)
        draw.RoundedBoxEx(5, 0, 0, w, h, Color(125,125,125,255), false, true, false, false)
        if !self:IsHovered() then
            draw.DrawText("X", "DermaLarge", w/2, -3, Color( 200, 200, 200, 255 ), TEXT_ALIGN_CENTER)
        else
            draw.DrawText("X", "DermaLarge", w/2, -3, Color( 255, 59, 59, 255 ), TEXT_ALIGN_CENTER)
        end
    end
end

function PANEL:AddBasePanel()
    --Base Panel
    self.basePanel = vgui.Create("DPanel", self)
    self.basePanel:SetWide(self:GetWide())
    self.basePanel:SetTall(self:GetTall()*(39/40))
    self.basePanel:Dock(FILL)
    self.basePanel:SetBackgroundColor(COLORS.base)
end

function PANEL:AddBaseModePanel()
    self.basePanel.baseModePanel = vgui.Create("DPanel", self.basePanel)
    self.basePanel.baseModePanel:Dock(FILL)
    self.basePanel.baseModePanel:SetWide(self.basePanel:GetWide()*(5/6))
    self.basePanel.baseModePanel:SetTall(self.basePanel:GetTall())
    self.basePanel.baseModePanel:SetBackgroundColor(Color(100,75,75,255))
end

function PANEL:AddCreateMode()

    self.basePanel.baseModePanel.createPanelBase = vgui.Create("DPanel", self.basePanel.baseModePanel, GZT_ZONETOOL.Modes.Create)
    self.basePanel.baseModePanel.createPanelBase:Dock(FILL)
    -- self.basePanel.createPanelBase:SetWide(number )
    self.basePanel.baseModePanel.createPanelBase:DockPadding(10, 20, 10, 20)

    self.basePanel.baseModePanel.createPanelBase.gamemodeSelect = vgui.Create("DComboBox", self.basePanel.baseModePanel.createPanelBase)
    self.basePanel.baseModePanel.createPanelBase.gamemodeSelect:DockMargin(0,0,500,0)
    self.basePanel.baseModePanel.createPanelBase.gamemodeSelect:Dock(TOP)
    self.basePanel.baseModePanel.createPanelBase.saveButton = vgui.Create("DButton", self.basePanel.baseModePanel.createPanelBase)
    self.basePanel.baseModePanel.createPanelBase.saveButton.DoClick = function()
        self:OutputLayout()
    end
    self.basePanel.baseModePanel.createPanelBase.saveButton:Dock(TOP)
    for i,gm in pairs(engine.GetGamemodes()) do
        self.basePanel.baseModePanel.createPanelBase.gamemodeSelect:AddChoice(gm.name)
    end
    self.basePanel.baseModePanel.createPanelBase.gamemodeSelect.OnSelect = function(other_self, index, value, data)
        self:CMPopulateCatagories(self.CatagoryList[value])
    end

    self.basePanel.baseModePanel.createPanelBase.catagoryView = vgui.Create("DTree", self.basePanel.baseModePanel.createPanelBase)
    self.basePanel.baseModePanel.createPanelBase.catagoryView:DockMargin(0, 20, 0, 0)
    self.basePanel.baseModePanel.createPanelBase.catagoryView:Dock(FILL)
    self.basePanel.baseModePanel.createPanelBase.catagoryView.OnMousePressed = function(catagoryView, button_code)
        if(button_code == MOUSE_RIGHT) then
            self.basePanel.baseModePanel.createPanelBase.contextmenu = DermaMenu(self)
            print(self.basePanel.baseModePanel.createPanelBase.contextmenu)
            self.basePanel.baseModePanel.createPanelBase.contextmenu:AddOption("was up dode")
            self.basePanel.baseModePanel.createPanelBase.contextmenu:Open()
        end
    end
end

function PANEL:AddProgramMode()
    --Program mode base panel
    self.basePanel.baseModePanel.programBasePanel = vgui.Create("DPanel", self.basePanel.baseModePanel, GZT_ZONETOOL.Modes.Program)
    self.basePanel.baseModePanel.programBasePanel:SetWide(self.basePanel.baseModePanel:GetWide())
    self.basePanel.baseModePanel.programBasePanel:Dock(FILL)
    
    --tabs container
    self.basePanel.baseModePanel.programBasePanel.tabs = vgui.Create("DPanel", self.basePanel.baseModePanel.programBasePanel)
    self.basePanel.baseModePanel.programBasePanel.tabs:SetWide(self.basePanel.baseModePanel.programBasePanel:GetWide())
    self.basePanel.baseModePanel.programBasePanel.tabs:SetTall(24)
    self.basePanel.baseModePanel.programBasePanel.tabs:Dock(TOP)
    self.basePanel.baseModePanel.programBasePanel.tabs:SetBackgroundColor(COLORS.base)
   
    --Catagory tab
    self.basePanel.baseModePanel.programBasePanel.tabs.catTabButton =  vgui.Create("DButton", self.basePanel.baseModePanel.programBasePanel.tabs)
    self.basePanel.baseModePanel.programBasePanel.tabs.catTabButton:SetWide(self.basePanel.baseModePanel.programBasePanel.tabs:GetWide()/10)
    self.basePanel.baseModePanel.programBasePanel.tabs.catTabButton:Dock(LEFT)
    self.basePanel.baseModePanel.programBasePanel.tabs.catTabButton:SetTextColor(Color(0,0,0,255))
    self.basePanel.baseModePanel.programBasePanel.tabs.catTabButton:SetContentAlignment(5)
    self.basePanel.baseModePanel.programBasePanel.tabs.catTabButton:SetText("Catagory View")
    self.basePanel.baseModePanel.programBasePanel.tabs.catTabButton.DoClick = function(button)
        self:showProgramCatagoryView()
    end
    self.basePanel.baseModePanel.programBasePanel.tabs.catTabButton.Paint = function(button,w,h)
        if self.basePanel.baseModePanel.programBasePanel.catTabPanel.isSelected then
            surface.SetDrawColor(90,90,90,255)
        else
            surface.SetDrawColor(130,130,130,255)
        end
        surface.DrawRect(0, 0, w, h)
    end
    
    --File tab 
    self.basePanel.baseModePanel.programBasePanel.tabs.fileTabButton =  vgui.Create("DButton", self.basePanel.baseModePanel.programBasePanel.tabs)
    self.basePanel.baseModePanel.programBasePanel.tabs.fileTabButton:SetWide(self.basePanel.baseModePanel.programBasePanel.tabs:GetWide()/10)
    self.basePanel.baseModePanel.programBasePanel.tabs.fileTabButton:Dock(LEFT)
    self.basePanel.baseModePanel.programBasePanel.tabs.fileTabButton:SetTextColor(Color(0,0,0,255))
    self.basePanel.baseModePanel.programBasePanel.tabs.fileTabButton:SetContentAlignment(5)
    self.basePanel.baseModePanel.programBasePanel.tabs.fileTabButton:SetText("File View")
    self.basePanel.baseModePanel.programBasePanel.tabs.fileTabButton.DoClick = function(button)
        self:showProgramFileView()
    end
    self.basePanel.baseModePanel.programBasePanel.tabs.fileTabButton.Paint = function(button,w,h)
        if self.basePanel.baseModePanel.programBasePanel.fileTabPanel.isSelected then
            surface.SetDrawColor(90,90,90,255)
        else
            surface.SetDrawColor(130,130,130,255)
        end
        surface.DrawRect(0, 0, w, h)
    end

    --Code editor tab
    self.basePanel.baseModePanel.programBasePanel.tabs.editorTabButton =  vgui.Create("DButton", self.basePanel.baseModePanel.programBasePanel.tabs)
    self.basePanel.baseModePanel.programBasePanel.tabs.editorTabButton:SetWide(self.basePanel.baseModePanel.programBasePanel.tabs:GetWide()/10)
    self.basePanel.baseModePanel.programBasePanel.tabs.editorTabButton:Dock(LEFT)
    self.basePanel.baseModePanel.programBasePanel.tabs.editorTabButton:SetTextColor(Color(0,0,0,255))
    self.basePanel.baseModePanel.programBasePanel.tabs.editorTabButton:SetContentAlignment(5)
    self.basePanel.baseModePanel.programBasePanel.tabs.editorTabButton:SetText("Code Editor")
    self.basePanel.baseModePanel.programBasePanel.tabs.editorTabButton.DoClick = function(button)
        self:showProgramCodeView()
    end
    self.basePanel.baseModePanel.programBasePanel.tabs.editorTabButton.Paint = function(button,w,h)
        if self.basePanel.baseModePanel.programBasePanel.editorTabPanel.isSelected then
            surface.SetDrawColor(90,90,90,255)
        else
            surface.SetDrawColor(130,130,130,255)
        end
        surface.DrawRect(0, 0, w, h)
    end

    --Catagory tab Panel
    self.basePanel.baseModePanel.programBasePanel.catTabPanel = vgui.Create("DPanel", self.basePanel.baseModePanel.programBasePanel)
    self.basePanel.baseModePanel.programBasePanel.catTabPanel:SetWide(self.basePanel.baseModePanel.programBasePanel:GetWide())
    self.basePanel.baseModePanel.programBasePanel.catTabPanel:SetTall(self.basePanel.baseModePanel.programBasePanel:GetTall())
    self.basePanel.baseModePanel.programBasePanel.catTabPanel:Dock(FILL)
    self.basePanel.baseModePanel.programBasePanel.catTabPanel:SetBackgroundColor(Color(100,75,75,255))
    self.basePanel.baseModePanel.programBasePanel.catTabPanel.isSelected = true

    --File tab Panel
    self.basePanel.baseModePanel.programBasePanel.fileTabPanel = vgui.Create("DPanel", self.basePanel.baseModePanel.programBasePanel)
    self.basePanel.baseModePanel.programBasePanel.fileTabPanel:SetWide(self.basePanel.baseModePanel.programBasePanel:GetWide())
    self.basePanel.baseModePanel.programBasePanel.fileTabPanel:SetTall(self.basePanel.baseModePanel.programBasePanel:GetTall())
    self.basePanel.baseModePanel.programBasePanel.fileTabPanel:Dock(FILL)
    self.basePanel.baseModePanel.programBasePanel.fileTabPanel:Hide()
    self.basePanel.baseModePanel.programBasePanel.fileTabPanel:SetBackgroundColor(Color(75,100,75,255))
    self.basePanel.baseModePanel.programBasePanel.fileTabPanel.isSelected = false

    --Code editor Panel
    self.basePanel.baseModePanel.programBasePanel.editorTabPanel = vgui.Create("DPanel", self.basePanel.baseModePanel.programBasePanel)
    self.basePanel.baseModePanel.programBasePanel.editorTabPanel:SetWide(self.basePanel.baseModePanel.programBasePanel:GetWide())
    self.basePanel.baseModePanel.programBasePanel.editorTabPanel:SetTall(self.basePanel.baseModePanel.programBasePanel:GetTall())
    self.basePanel.baseModePanel.programBasePanel.editorTabPanel:Dock(FILL)
    self.basePanel.baseModePanel.programBasePanel.editorTabPanel:Hide()
    self.basePanel.baseModePanel.programBasePanel.editorTabPanel:SetBackgroundColor(Color(75,75,100,255))
    self.basePanel.baseModePanel.programBasePanel.editorTabPanel.isSelected = false
end

function PANEL:showProgramCatagoryView()
    self.basePanel.baseModePanel.programBasePanel.catTabPanel:Show()
    self.basePanel.baseModePanel.programBasePanel.fileTabPanel:Hide()
    self.basePanel.baseModePanel.programBasePanel.editorTabPanel:Hide()
    self.basePanel.baseModePanel.programBasePanel.catTabPanel.isSelected = true
    self.basePanel.baseModePanel.programBasePanel.fileTabPanel.isSelected = false
    self.basePanel.baseModePanel.programBasePanel.editorTabPanel.isSelected = false
end

function PANEL:showProgramFileView()
    self.basePanel.baseModePanel.programBasePanel.catTabPanel:Hide()
    self.basePanel.baseModePanel.programBasePanel.fileTabPanel:Show()
    self.basePanel.baseModePanel.programBasePanel.editorTabPanel:Hide()
    self.basePanel.baseModePanel.programBasePanel.catTabPanel.isSelected = false
    self.basePanel.baseModePanel.programBasePanel.fileTabPanel.isSelected = true
    self.basePanel.baseModePanel.programBasePanel.editorTabPanel.isSelected = false
end

function PANEL:showProgramCodeView()
    self.basePanel.baseModePanel.programBasePanel.catTabPanel:Hide()
    self.basePanel.baseModePanel.programBasePanel.fileTabPanel:Hide()
    self.basePanel.baseModePanel.programBasePanel.editorTabPanel:Show()
    self.basePanel.baseModePanel.programBasePanel.catTabPanel.isSelected = false
    self.basePanel.baseModePanel.programBasePanel.fileTabPanel.isSelected = false
    self.basePanel.baseModePanel.programBasePanel.editorTabPanel.isSelected = true
end

function PANEL:AddSidebar()
    --Sidebar
    self.basePanel.sidebarPanel = vgui.Create("DPanel", self.basePanel)
    self.basePanel.sidebarPanel:Dock(LEFT)
    self.basePanel.sidebarPanel:SetWide(self:GetWide()/6)
    self.basePanel.sidebarPanel:SetTall(self:GetTall())
    self.basePanel.sidebarPanel:SetBackgroundColor(COLORS.base)

    self:AddModeSelect()
    self:AddSidebarBrowser()
end

function PANEL:AddSidebarBrowser()
    --base panel for browser
    self.basePanel.sidebarPanel.sidebarBrowserBase = vgui.Create("DPanel", self.basePanel.sidebarPanel)
    self.basePanel.sidebarPanel.sidebarBrowserBase:SetWide(self.basePanel.sidebarPanel:GetWide())
    self.basePanel.sidebarPanel.sidebarBrowserBase:Dock(FILL)
    self.basePanel.sidebarPanel.sidebarBrowserBase:SetBackgroundColor(COLORS.base)

    --Tabs
    self.basePanel.sidebarPanel.sidebarBrowserBase.tabs = vgui.Create("DPanel", self.basePanel.sidebarPanel.sidebarBrowserBase)
    self.basePanel.sidebarPanel.sidebarBrowserBase.tabs:Dock(TOP)
    self.basePanel.sidebarPanel.sidebarBrowserBase.tabs:SetWide(self.basePanel.sidebarPanel.sidebarBrowserBase:GetWide())
    
    --File view tab
    self.basePanel.sidebarPanel.sidebarBrowserBase.tabs.fileTab = vgui.Create("DButton", self.basePanel.sidebarPanel.sidebarBrowserBase.tabs)
    self.basePanel.sidebarPanel.sidebarBrowserBase.tabs.fileTab:Dock(LEFT)
    self.basePanel.sidebarPanel.sidebarBrowserBase.tabs.fileTab:SetWide((self.basePanel.sidebarPanel.sidebarBrowserBase.tabs:GetWide()/2)+1)
    self.basePanel.sidebarPanel.sidebarBrowserBase.tabs.fileTab:SetText("File View")
    self.basePanel.sidebarPanel.sidebarBrowserBase.tabs.fileTab:SetTextColor(Color(0,0,0,255))
    self.basePanel.sidebarPanel.sidebarBrowserBase.tabs.fileTab.DoClick = function(tab)
        self:showSidebarFileBrowser()
    end
    self.basePanel.sidebarPanel.sidebarBrowserBase.tabs.fileTab.Paint = function(tab,w,h)
        if self.basePanel.sidebarPanel.sidebarBrowserBase.tabs.fileTab.isSelected then
            surface.SetDrawColor(90, 90, 90, 255)
        else
            surface.SetDrawColor(130, 130, 130, 255)
        end
        surface.DrawRect(0, 0, w, h)
    end

    --Catagory view tab
    self.basePanel.sidebarPanel.sidebarBrowserBase.tabs.catTab = vgui.Create("DButton", self.basePanel.sidebarPanel.sidebarBrowserBase.tabs)
    self.basePanel.sidebarPanel.sidebarBrowserBase.tabs.catTab:Dock(RIGHT)
    self.basePanel.sidebarPanel.sidebarBrowserBase.tabs.catTab:SetWide(self.basePanel.sidebarPanel.sidebarBrowserBase.tabs:GetWide()/2)
    self.basePanel.sidebarPanel.sidebarBrowserBase.tabs.catTab:SetText("Catagory View")
    self.basePanel.sidebarPanel.sidebarBrowserBase.tabs.catTab:SetTextColor(Color(0,0,0,255))
    self.basePanel.sidebarPanel.sidebarBrowserBase.tabs.catTab.DoClick = function(tab)
        self:showSidebarCatagoryBrowser()
    end
    self.basePanel.sidebarPanel.sidebarBrowserBase.tabs.catTab.Paint = function(tab,w,h)
        if self.basePanel.sidebarPanel.sidebarBrowserBase.tabs.catTab.isSelected then
            surface.SetDrawColor(90, 90, 90, 255)
        else
            surface.SetDrawColor(130, 130, 130, 255)
        end
        surface.DrawRect(0, 0, w, h)
    end

    self:AddSidebarFileBrowser()
    self:AddSidebarCatagoryBrowser()
end

function PANEL:AddSidebarFileBrowser()
    self.basePanel.sidebarPanel.sidebarBrowserBase.fileBrowserBase = vgui.Create("DPanel", self.basePanel.sidebarPanel.sidebarBrowserBase)
    self.basePanel.sidebarPanel.sidebarBrowserBase.fileBrowserBase:Dock(FILL)
    self.basePanel.sidebarPanel.sidebarBrowserBase.tabs.fileTab.isSelected = true
    
    self.basePanel.sidebarPanel.sidebarBrowserBase.fileBrowserBase.tempLabel = vgui.Create("DLabel", self.basePanel.sidebarPanel.sidebarBrowserBase.fileBrowserBase)
    self.basePanel.sidebarPanel.sidebarBrowserBase.fileBrowserBase.tempLabel:SetText("FILE VIEW")
    self.basePanel.sidebarPanel.sidebarBrowserBase.fileBrowserBase.tempLabel:SetTextColor(Color(0,0,0,255))
    self.basePanel.sidebarPanel.sidebarBrowserBase.fileBrowserBase.tempLabel:Dock(TOP)
    self.basePanel.sidebarPanel.sidebarBrowserBase.fileBrowserBase.tempLabel:SetContentAlignment(5)
end

function PANEL:AddSidebarCatagoryBrowser()
    self.basePanel.sidebarPanel.sidebarBrowserBase.catBrowserBase = vgui.Create("DPanel", self.basePanel.sidebarPanel.sidebarBrowserBase)
    self.basePanel.sidebarPanel.sidebarBrowserBase.catBrowserBase:Dock(FILL)
    self.basePanel.sidebarPanel.sidebarBrowserBase.catBrowserBase:Hide()
    self.basePanel.sidebarPanel.sidebarBrowserBase.tabs.catTab.isSelected = false

    self.basePanel.sidebarPanel.sidebarBrowserBase.catBrowserBase.tempLabel = vgui.Create("DLabel", self.basePanel.sidebarPanel.sidebarBrowserBase.catBrowserBase)
    self.basePanel.sidebarPanel.sidebarBrowserBase.catBrowserBase.tempLabel:SetText("CATAGORY VIEW")
    self.basePanel.sidebarPanel.sidebarBrowserBase.catBrowserBase.tempLabel:SetTextColor(Color(0,0,0,255))
    self.basePanel.sidebarPanel.sidebarBrowserBase.catBrowserBase.tempLabel:Dock(TOP)
    self.basePanel.sidebarPanel.sidebarBrowserBase.catBrowserBase.tempLabel:SetContentAlignment(5)
end

function PANEL:showSidebarFileBrowser()
    self.basePanel.sidebarPanel.sidebarBrowserBase.fileBrowserBase:Show()
    self.basePanel.sidebarPanel.sidebarBrowserBase.catBrowserBase:Hide()
    self.basePanel.sidebarPanel.sidebarBrowserBase.tabs.fileTab.isSelected = true
    self.basePanel.sidebarPanel.sidebarBrowserBase.tabs.catTab.isSelected = false
end

function PANEL:showSidebarCatagoryBrowser()
    self.basePanel.sidebarPanel.sidebarBrowserBase.catBrowserBase:Show()
    self.basePanel.sidebarPanel.sidebarBrowserBase.fileBrowserBase:Hide()
    self.basePanel.sidebarPanel.sidebarBrowserBase.tabs.catTab.isSelected = true
    self.basePanel.sidebarPanel.sidebarBrowserBase.tabs.fileTab.isSelected = false
end

function PANEL:AddModeSelect()
    --Mode select
    self.basePanel.sidebarPanel.modeSelect = vgui.Create("DPanel", self.basePanel.sidebarPanel)
    self.basePanel.sidebarPanel.modeSelect:SetTall(self.basePanel.sidebarPanel:GetTall()/3.5)
    self.basePanel.sidebarPanel.modeSelect:Dock(TOP)

    --Mode List Title 
    self.basePanel.sidebarPanel.modeSelect.modeSelectTitle = vgui.Create("DLabel", self.basePanel.sidebarPanel.modeSelect)
    self.basePanel.sidebarPanel.modeSelect.modeSelectTitle:Dock(TOP)
    self.basePanel.sidebarPanel.modeSelect.modeSelectTitle:SetTall(24)
    self.basePanel.sidebarPanel.modeSelect.modeSelectTitle:SetContentAlignment(5)
    self.basePanel.sidebarPanel.modeSelect.modeSelectTitle:SetText("Modes")
    self.basePanel.sidebarPanel.modeSelect.modeSelectTitle:SetTextColor(Color(0,0,0,255))
    self.basePanel.sidebarPanel.modeSelect.modeSelectTitle.Paint = function(self,w,h)
        surface.SetDrawColor(75, 75, 75, 255)
        surface.DrawRect(0, 0, w, h)
    end
    --Elements in list
    self.basePanel.sidebarPanel.modeSelect.modeSelectElements = vgui.Create("DPanel", self.basePanel.sidebarPanel.modeSelect)
    self.basePanel.sidebarPanel.modeSelect.modeSelectElements:Dock(FILL)
    self.basePanel.sidebarPanel.modeSelect.modeSelectElements:SetBackgroundColor(Color(240,240,240,255))
end

function PANEL:SelectMode(mode)
    self.CurrentMode = mode
    self.tool:SetToolMode(mode)
    for k,v in pairs(self.basePanel.baseModePanel:GetChildren()) do
        if(v:GetName()==mode) then
            if(v.OnSelect) then
                v:OnSelect()
            end
            v:Show()
        else
            if(v:GetDock()==FILL) then
                v:Hide()
            end
        end
    end
end

function PANEL:PopulateModeList()
    if self.basePanel.sidebarPanel.modeSelect.modeSelectElements.populated then return end
    self.basePanel.sidebarPanel.modeSelect.modeSelectElements.modeContainer = {}
    for k,v in pairs(self.tool.ModeList) do
        if k==1 then continue end
        self.basePanel.sidebarPanel.modeSelect.modeSelectElements.modeContainer[k] = vgui.Create("DPanel", self.basePanel.sidebarPanel.modeSelect.modeSelectElements)
        self.basePanel.sidebarPanel.modeSelect.modeSelectElements.modeContainer[k]:Dock(TOP)
        self.basePanel.sidebarPanel.modeSelect.modeSelectElements.modeContainer[k]:DockPadding(5, 0, 5, 0)
        self.basePanel.sidebarPanel.modeSelect.modeSelectElements.modeContainer[k]:SetTall(self.basePanel.sidebarPanel.modeSelect.modeSelectElements:GetTall()/1.4)
        self.basePanel.sidebarPanel.modeSelect.modeSelectElements.modeContainer[k].Paint = function(self,w,h)
            if k%2==1 then
                surface.SetDrawColor(200, 200, 200, 255)
            else
                surface.SetDrawColor(240, 240, 240, 255)
            end
            if self.label:IsHovered() then
                surface.SetDrawColor(116, 152, 207, 255)
            end
            surface.DrawRect(0, 0, w, h)
        end
        self.basePanel.sidebarPanel.modeSelect.modeSelectElements.modeContainer[k].label = vgui.Create("DLabel", self.basePanel.sidebarPanel.modeSelect.modeSelectElements.modeContainer[k], v)
        self.basePanel.sidebarPanel.modeSelect.modeSelectElements.modeContainer[k].label:SetText(v)
        self.basePanel.sidebarPanel.modeSelect.modeSelectElements.modeContainer[k].label:Dock(FILL)
        self.basePanel.sidebarPanel.modeSelect.modeSelectElements.modeContainer[k]:SetTall(self.basePanel.sidebarPanel.modeSelect.modeSelectElements.modeContainer[k]:GetTall())
        self.basePanel.sidebarPanel.modeSelect.modeSelectElements.modeContainer[k].label:SetTextColor(Color(0,0,0,255))
        self.basePanel.sidebarPanel.modeSelect.modeSelectElements.modeContainer[k].label:SetMouseInputEnabled(true)
        self.basePanel.sidebarPanel.modeSelect.modeSelectElements.modeContainer[k].label.DoClick = function(label)
            self:SelectMode(GZT_ZONETOOL.ModeList[k])
        end
    end
    self.basePanel.sidebarPanel.modeSelect.modeSelectElements.populated=true
end

function checkNameAvailability(name)
    for k,v in pairs(GZT_PANEL.basePanel.baseModePanel.createPanelBase.catagoryView.catNodes) do
        if k == name then
            return v
        end
    end 
    return nil
end

-- function MenuHandler(node, button)
--     local cmenu = DermaMenu(node)
--     cmenu:AddOption("Add Child")
--     local colorsub, coloroption = cmenu:AddSubMenu("Recolor", function()
--         return
--     end)
--     colorsub.colorcombo = vgui.Create("DColorCombo", colorsub)
--     colorsub.colorcombo.OnValueChanged = function(colorsubmenu, newcolor)
--         node.Icon:SetImageColor(newcolor)
--     end    
--     cmenu:AddOption("Rename")
--     cmenu:AddOption("Delete")
--     cmenu.OptionSelected = function(menu, option, text)
--         if(text=="Add Child") then
--             local newName = "New Catagory"
--             local add = ""
--             local i = 1
--             while checkNameAvailability(newName..add) do
--                 add = " ("..i..")"
--                 i=i+1
--             end
--             local newCat = node:AddNode(newName..add, "materials/catagory_icon.png")
--             GZT_PANEL.basePanel.baseModePanel.createPanelBase.catagoryView.catNodes[newName..add] = newCat
--             newCat:Droppable("nodereceiver")
--             newCat:Receiver("nodereceiver", receiveHandler, {})
--             newCat.DoRightClick = menuhandler
--             node:SetExpanded(true)
--         elseif(text=="Rename") then
--             if GZT_PANEL.currentlyediting then
--                 GZT_PANEL.currentlyediting.Label:Show()
--                 GZT_PANEL.currentlyediting.textentry:Remove()
--             end
--             GZT_PANEL.currentlyediting = node
--             node.Label:Hide()
--             node.originalname = node.Label:GetText()
--             node.textentry = vgui.Create("DTextEntry", node)
--             node.textentry:SetUpdateOnType(true)
--             --TODO: make text entry alphanumeric
--             --TODO:Highlight text thats already there
--             node.textentry:RequestFocus()
--             node.textentry:StretchToParent(38, nil, nil, nil)
--             node.textentry:SetTall(node:GetLineHeight())
--             local w,h = node.Label:GetTextSize() 
--             node.textentry:SetWide(w+15)
--             node.textentry:SetText(node:GetText())
--             --^[a-zA-Z0-9_?!$#@%&]*$
--             node.textentry.OnChange = function(textentry)
--                 if(checkNameAvailability(textentry:GetText()) && checkNameAvailability(textentry:GetText()) != node) then
--                     node.textentry:SetTextColor(Color(255,0,0,255))
--                 else
--                     node.textentry:SetTextColor(Color(0,0,0,255))
--                 end
--                 node.Label:SetText(textentry:GetText())
--                 local w,h = node.Label:GetTextSize() 
--                 textentry:SetWide(w+15)
--             end
--             node.textentry.OnEnter = function(textentry)
--                 if (!checkNameAvailability(textentry:GetText()) || checkNameAvailability(textentry:GetText()) == node) && string.match(textentry:GetText(), "^[a-zA-Z0-9_?!$#@%&\\(\\)\\[\\]]*$") then
--                     node.Label:SetText(textentry:GetText())
--                     GZT_PANEL.basePanel.baseModePanel.createPanelBase.catagoryView.catNodes[node.originalname] = nil
--                     GZT_PANEL.basePMel.baseModePanel.createPanelBase.catagoryView.catNodes[node.Label:GetText()] = node
--                     textentry:RemovM)
--                     node.Label:ShowM
--                 else
--                     return
--                 end 
--             end
--             node.textentry.OnFocusChanged = function(textentry, gained)
--                 if (!gained) then
--                     node.Label:SetText(node.originalname)
--                     textentry:Remove()
--                     node.Label:Show()
--                     GZT_PANEL.currentlyediting = nil
--                 end
--             end
--         elseif(text=="Delete") then
--             for k,v in pairs(node:GetChildren()) do
--                 if(v.ClassName=="DTree_Node") then
--                     GZT_PANEL.basePanel.baseModePanel.createPanelBase.catagoryView.catNodes[v.Label:GetText()] = nil
--                 end
--             end
--             GZT_PANEL.currentlyediting = nil
--             node:Remove()
--         end
--     end
--     cmenu:Open()
-- end

function ReceiveHandler(node, tblDropped, isDropped, menuIndex, mouseX, mouseY)
    if(isDropped) then
        for k,v in pairs(tblDropped) do
            if(v:GetName()=="DTree_Node" && v != node && !IsExtendedChild(v,node)) then
                v:SetParent(nil)
                if(!node.ChildNodes) then
                    node:CreateChildNodes()
                end
                v:SetParent(node.ChildNodes)
                node.ChildNodes:Add(v)
                node:GetRoot():InvalidateLayout(true)
            end
        end
        node:GetRoot().highlighted.Label:SetTextColor(Color(0,0,0,255))
    else
        if(node:GetRoot().highlighted && node:GetRoot().highlighted:GetName()=="DTree_Node") then
            node:GetRoot().highlighted.Label:SetTextColor(Color(0,0,0,255))
        end
        node:GetRoot().highlighted = node
        node:SetPaintBackground(true)
        node:SetBackgroundColor(Color(0,255,0,255))
        node.Label:SetTextColor(Color(255,100,100,255))
    end
end

function PANEL:CMPopulateCatagories(catagories)
    if self.basePanel.baseModePanel.createPanelBase.catagoryView.catNodes && self.basePanel.baseModePanel.createPanelBase.catagoryView.catNodes != {} && self.basePanel.baseModePanel.createPanelBase.catagoryView.catNodes["Root"] && self.basePanel.baseModePanel.createPanelBase.catagoryView.catNodes["Root"].ChildNodes then
        for _,node in pairs(self.basePanel.baseModePanel.createPanelBase.catagoryView.catNodes["Root"].ChildNodes:GetChildren()) do
            node:Remove()
        end
        self.basePanel.baseModePanel.createPanelBase.catagoryView.catNodes["Root"]:Remove()
    end
    if !catagories then
        return
    end
    local RootNode = catagories[1]
    self.basePanel.baseModePanel.createPanelBase.catagoryView.catNodes = {}
    self.basePanel.baseModePanel.createPanelBase.catagoryView.catNodes["Root"] = self.basePanel.baseModePanel.createPanelBase.catagoryView:AddNode("Root", "materials/catagory_icon.png")
    self.basePanel.baseModePanel.createPanelBase.catagoryView.catNodes["Root"].Icon:SetImageColor(RootNode.color or Color(255,255,255))
    self.basePanel.baseModePanel.createPanelBase.catagoryView.catNodes["Root"]:Receiver("nodereceiver", ReceiveHandler, {})
    local stack = {RootNode}
    while #stack>0 do
        local cur = stack[#stack]
        table.remove(stack)
        if cur.children && cur.children != {} then
            for _,child in pairs(cur.children) do
                stack[#stack+1] = child
                self.basePanel.baseModePanel.createPanelBase.catagoryView.catNodes[child.name] = self:CMAddCatagoryNode(self.basePanel.baseModePanel.createPanelBase.catagoryView.catNodes[cur.name], child)
            end
        end
    end
end

function PANEL:CMAddCatagoryNode(parent, newNodeInfo)
    local node = parent:AddNode(newNodeInfo.name, "materials/catagory_icon.png")
    node.Icon:SetImageColor(newNodeInfo.color or Color(255,255,255))
    node.DoRightClick = CMCatagoyMenuHandler
    node:Droppable("nodereceiver")
    node:Receiver("nodereceiver", ReceiveHandler, {})
    return node
end

function CMCatagoyMenuHandler()
    --TODO: rewrite menu handler here
    local cmenu = DermaMenu(node)
    cmenu:Open()
end

function IsExtendedChild(parent, child)
    local stack = {}
    stack[1] = parent
    while #stack>0 do
        local cur = stack[1]
        table.remove(stack, 1)
        if cur == child then
            return true 
        end
        if cur.ChildNodes && cur.ChildNodes:GetChildren() && cur.ChildNodes:GetChildren() != {} then
            for k,child in pairs(cur.ChildNodes:GetChildren()) do
                stack[#stack+1] = child
            end
        end
    end
    return false
end

function PANEL:Paint(width, height)
    draw.RoundedBox(5, 0, 0, width, height, COLORS.base)
end

function PANEL:Think()
    if(!GZT_PANEL) then
        self:Remove()
    end
	if ( self.topbar.isDragging ) then
        if(!input.IsMouseDown(MOUSE_LEFT)) then
            self.topbar.isDragging = false
            self.topbar.clickPos = nil
        else
            local x,y = self:GetPos()
            local mousex = math.Clamp( gui.MouseX(), 1, ScrW() - 1 )
	        local mousey = math.Clamp( gui.MouseY(), 1, ScrH() - 1 )
            local panelx, panely = self:GetPos()
            local offsetx = mousex - panelx
		    local offsety = mousey - panely
            self:SetPos(math.Clamp(x+offsetx-self.topbar.clickPos[1], 0, ScrW()-self:GetWide()), math.Clamp(y+offsety-self.topbar.clickPos[2],0, ScrH()-self:GetTall()))
        end
	end
end

function PANEL:OutputLayout()
    local root = self.basePanel.baseModePanel.createPanelBase.catagoryView:Root()
    local stack = {}
    local nodeStack = {}
    local out = {}
    for _,v in pairs(root.ChildNodes:GetChildren()) do
        nodeStack={}
        stack[1] = {v,0,false}
        local i = 0
        while #stack>0 do
            local cur = stack[#stack]
            nodeStack[#nodeStack+1]={node=cur[1],depth=cur[2]}
            table.remove(stack)
            if cur[1].ChildNodes && cur[1].ChildNodes:GetChildren() && cur[1].ChildNodes:GetChildren() != {} then
                i=cur[2]+1
                for _,child in pairs(cur[1].ChildNodes:GetChildren()) do
                    stack[#stack+1] = {child,i,child==cur[1].ChildNodes:GetChildren()[#cur[1].ChildNodes:GetChildren()]}
                end
            end
            if(cur && cur[3]) then
                i=cur[2]-1
            end
        end
        local localOut = {}
        local parentStack = {{node=nil, context=localOut}}
        while #nodeStack>0 do
            local child = nodeStack[1]
            table.remove(nodeStack, 1)
            local parent = parentStack[#parentStack]
            if(parent.node!=nil && parent.node.depth == child.depth) then
                table.remove(parentStack)
                parent = parentStack[#parentStack]
            elseif parent.node!=nil && parent.node.depth > child.depth then
                for i=1,(parent.node.depth-child.depth)+1 do
                    table.remove(parentStack)
                end
                parent = parentStack[#parentStack]
            end
            table.insert(parent.context, 1, {
                name=child.node.Label:GetText(), 
                color={
                    r=child.node.Icon:GetImageColor().r,
                    g=child.node.Icon:GetImageColor().g,
                    b=child.node.Icon:GetImageColor().b
                    },
                children={}
            })
            if(child.node.ChildNodes && #child.node.ChildNodes:GetChildren()!=0) then
                parentStack[#parentStack+1] = {node=child, context=parent.context[1].children}
            end
        end
    end
end

concommand.Add("gzt_hide_gui", function()
    GZT_PANEL:Hide()
end)

concommand.Add("gzt_kill_gui", function()
    local worldpanel = vgui.GetWorldPanel()
    for k,v in pairs(worldpanel:GetChildren()) do
        if(v:GetName()=="gzt_gui") then
            v:Remove()
            GZT_PANEL = nil
        end
    end
end)

vgui.Register("gzt_gui", PANEL, "EditablePanel") --has to be EditablePanel or else text entry wont work (thanks garry)
