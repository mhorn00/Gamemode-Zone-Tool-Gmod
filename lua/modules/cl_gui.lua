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
        print("dragging")
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
    for i,gm in pairs(engine.GetGamemodes()) do
        self.basePanel.baseModePanel.createPanelBase.gamemodeSelect:AddChoice(gm.name)
    end
    self.basePanel.baseModePanel.createPanelBase.gamemodeSelect.OnSelect = function(other_self, index, value, data)
        self:PopulateCatagoriesCreate(self.CatagoryList[value])
    end

    self.basePanel.baseModePanel.createPanelBase.catagoryView = vgui.Create("DTree", self.basePanel.baseModePanel.createPanelBase)
    self.basePanel.baseModePanel.createPanelBase.catagoryView:DockMargin(0, 20, 0, 0)
    self.basePanel.baseModePanel.createPanelBase.catagoryView:Dock(FILL)


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

function PANEL:PopulateCatagoriesCreate(catagories)
    self.basePanel.baseModePanel.createPanelBase.catagoryView.catNodes = {}
    for i,cat in pairs(catagories) do
        local stack = {} --useing stack based search rather than recursion bc i dont like recursion =)
        self.basePanel.baseModePanel.createPanelBase.catagoryView.catNodes[cat.name] = self.basePanel.baseModePanel.createPanelBase.catagoryView:AddNode(cat.name)
        stack[1] = cat
        while (#stack>0) do
            local cur = stack[1]
            table.remove(stack, 1)
            if cur.children && cur.children != {} then
                for k,child in pairs(cur.children) do
                    stack[#stack+1] = child
                    self.basePanel.baseModePanel.createPanelBase.catagoryView.catNodes[child.name] = self.basePanel.baseModePanel.createPanelBase.catagoryView.catNodes[cur.name]:AddNode(child.name)
                end
            end
        end
    end
end

function PANEL:FindChildren(node)

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
