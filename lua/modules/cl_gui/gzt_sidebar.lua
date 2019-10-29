AddCSLuaFile()

if SERVER then return end

local PANEL = {}

function PANEL:Init()
    --Sidebar


    self:AddModeSelect()
    --self:AddSidebarBrowser()
end

function PANEL:AddSidebarBrowser()
    --base panel for browser
    self.sidebarBrowserBase = vgui.Create("DPanel", self)
    self.sidebarBrowserBase:SetWide(self:GetWide())
    self.sidebarBrowserBase:Dock(FILL)
    self.sidebarBrowserBase:SetBackgroundColor(COLORS.base)

    --Tabs
    self.sidebarBrowserBase.tabs = vgui.Create("DPanel", self.sidebarBrowserBase)
    self.sidebarBrowserBase.tabs:Dock(TOP)
    self.sidebarBrowserBase.tabs:SetWide(self.sidebarBrowserBase:GetWide())
    
    --File view tab
    self.sidebarBrowserBase.tabs.fileTab = vgui.Create("DButton", self.sidebarBrowserBase.tabs)
    self.sidebarBrowserBase.tabs.fileTab:Dock(LEFT)
    self.sidebarBrowserBase.tabs.fileTab:SetWide((self.sidebarBrowserBase.tabs:GetWide()/2)+1)
    self.sidebarBrowserBase.tabs.fileTab:SetText("File View")
    self.sidebarBrowserBase.tabs.fileTab:SetTextColor(Color(0,0,0,255))
    self.sidebarBrowserBase.tabs.fileTab.DoClick = function(tab)
        self:showSidebarFileBrowser()
    end
    self.sidebarBrowserBase.tabs.fileTab.Paint = function(tab,w,h)
        if self.sidebarBrowserBase.tabs.fileTab.isSelected then
            surface.SetDrawColor(90, 90, 90, 255)
        else
            surface.SetDrawColor(130, 130, 130, 255)
        end
        surface.DrawRect(0, 0, w, h)
    end

    --Catagory view tab
    self.sidebarBrowserBase.tabs.catTab = vgui.Create("DButton", self.sidebarBrowserBase.tabs)
    self.sidebarBrowserBase.tabs.catTab:Dock(RIGHT)
    self.sidebarBrowserBase.tabs.catTab:SetWide(self.sidebarBrowserBase.tabs:GetWide()/2)
    self.sidebarBrowserBase.tabs.catTab:SetText("Catagory View")
    self.sidebarBrowserBase.tabs.catTab:SetTextColor(Color(0,0,0,255))
    self.sidebarBrowserBase.tabs.catTab.DoClick = function(tab)
        self:showSidebarCatagoryBrowser()
    end
    self.sidebarBrowserBase.tabs.catTab.Paint = function(tab,w,h)
        if self.sidebarBrowserBase.tabs.catTab.isSelected then
            surface.SetDrawColor(90, 90, 90, 255)
        else
            surface.SetDrawColor(130, 130, 130, 255)
        end
        surface.DrawRect(0, 0, w, h)
    end

    -- self:AddSidebarFileBrowser()
    -- self:AddSidebarCatagoryBrowser()
end

function PANEL:AddModeSelect()
    --Mode select
   self.modeSelect = vgui.Create("DPanel",self)
   self.modeSelect:SetTall(self.basePanel.sidebarPanel:GetTall()/3.5)
   self.modeSelect:Dock(TOP)

    --Mode List Title 
   self.modeSelect.modeSelectTitle = vgui.Create("DLabel",self.modeSelect)
   self.modeSelect.modeSelectTitle:Dock(TOP)
   self.modeSelect.modeSelectTitle:SetTall(24)
   self.modeSelect.modeSelectTitle:SetContentAlignment(5)
   self.modeSelect.modeSelectTitle:SetText("Modes")
   self.modeSelect.modeSelectTitle:SetTextColor(Color(0,0,0,255))
   self.modeSelect.modeSelectTitle.Paint = function(self,w,h)
        surface.SetDrawColor(75, 75, 75, 255)
        surface.DrawRect(0, 0, w, h)
    end
    --Elements in list
   self.modeSelect.modeSelectElements = vgui.Create("DPanel",self.modeSelect)
   self.modeSelect.modeSelectElements:Dock(FILL)
   self.modeSelect.modeSelectElements:SetBackgroundColor(Color(240,240,240,255))
end

--[[function PANEL:AddSidebarFileBrowser()
   self.sidebarBrowserBase.fileBrowserBase = vgui.Create("DPanel",self.sidebarBrowserBase)
   self.sidebarBrowserBase.fileBrowserBase:Dock(FILL)
   self.sidebarBrowserBase.tabs.fileTab.isSelected = true
    
   self.sidebarBrowserBase.fileBrowserBase.tempLabel = vgui.Create("DLabel",self.sidebarBrowserBase.fileBrowserBase)
   self.sidebarBrowserBase.fileBrowserBase.tempLabel:SetText("FILE VIEW")
   self.sidebarBrowserBase.fileBrowserBase.tempLabel:SetTextColor(Color(0,0,0,255))
   self.sidebarBrowserBase.fileBrowserBase.tempLabel:Dock(TOP)
   self.sidebarBrowserBase.fileBrowserBase.tempLabel:SetContentAlignment(5)
end

function PANEL:AddSidebarCatagoryBrowser()
   self.sidebarBrowserBase.catBrowserBase = vgui.Create("DPanel",self.sidebarBrowserBase)
   self.sidebarBrowserBase.catBrowserBase:Dock(FILL)
   self.sidebarBrowserBase.catBrowserBase:Hide()
   self.sidebarBrowserBase.tabs.catTab.isSelected = false

   self.sidebarBrowserBase.catBrowserBase.tempLabel = vgui.Create("DLabel",self.sidebarBrowserBase.catBrowserBase)
   self.sidebarBrowserBase.catBrowserBase.tempLabel:SetText("CATAGORY VIEW")
   self.sidebarBrowserBase.catBrowserBase.tempLabel:SetTextColor(Color(0,0,0,255))
   self.sidebarBrowserBase.catBrowserBase.tempLabel:Dock(TOP)
   self.sidebarBrowserBase.catBrowserBase.tempLabel:SetContentAlignment(5)
end

function PANEL:showSidebarFileBrowser()
   self.sidebarBrowserBase.fileBrowserBase:Show()
   self.sidebarBrowserBase.catBrowserBase:Hide()
   self.sidebarBrowserBase.tabs.fileTab.isSelected = true
   self.sidebarBrowserBase.tabs.catTab.isSelected = false
end

function PANEL:showSidebarCatagoryBrowser()
   self.sidebarBrowserBase.catBrowserBase:Show()
   self.sidebarBrowserBase.fileBrowserBase:Hide()
   self.sidebarBrowserBase.tabs.catTab.isSelected = true
   self.sidebarBrowserBase.tabs.fileTab.isSelected = false
end]]

vgui.Register("gzt_sidebar", PANEL, "DPanel")