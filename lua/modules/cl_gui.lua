AddCSLuaFile()

if SERVER then return end

local PANEL = {}

GZT_PANEL = nil

function PANEL:SetToolRef(tool)
    self.tool = tool
    self:PopulateModeList()
end

function PANEL:Init()
    self:SetSize(ScrW()/2, ScrH()/1.5)
    self:AddTopbar()
    self:AddBasePanel()
    self:AddSidebar()
    self:AddProgramMode()
    self:MakePopup()
    self:SetPos(ScrW()/2 - self:GetWide()/2, ScrH()/2 - self:GetTall()/2)
end

function PANEL:AddTopbar()
    --Top Bar
    self.topbar = vgui.Create("DPanel", self)
    self.topbar:Dock(TOP)
    self.topbar.Paint = function(self, width, height)
        surface.SetDrawColor(0, 0, 0, 255)
        draw.RoundedBoxEx(5, 0, 0, width, height, Color(100,100,100,255), true, true, false, false)
    end
    
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
    self.basePanel:Dock(FILL)
    self.basePanel:SetBackgroundColor(Color(75,75,75,255))
end

function PANEL:AddProgramMode()
    self.program_mode = vgui.Create("DPanel", self.basePanel)
    self.tab_panel = vgui.Create("DPropertySheet", self.program_mode)
    self.program_mode:Dock(FILL)
    self.tab_panel:Dock(FILL)
    self.program_mode:SetBackgroundColor(Color(75,75,75,255))
    self.catagory_tab = vgui.Create("DPanel", self.tab_panel)
    self.file_tab = vgui.Create("DPanel", self.tab_panel)
    self.code_tab = vgui.Create("DPanel", self.tab_panel)
    self.tab_panel:AddSheet("Zone Catagories", self.catagory_tab)
    self.tab_panel:AddSheet("File Viewer", self.file_tab)
    self.tab_panel:AddSheet("Code Editor", self.code_tab)
    
    --code tab
    self.editor = vgui.Create("DTextEntry", self.code_tab)
    self.editor:Center()
    self.editor:Dock(FILL)
    self.editor:SetText("placeholder")
    self.editor:Dock(FILL)
    self.linenumbers = vgui.Create("DPanel", self.code_tab)
    self.linenumbers:Dock(LEFT)
end

function PANEL:AddSidebar()
    --Sidebar
    self.sidebarPanel = vgui.Create("DPanel", self.basePanel)
    self.sidebarPanel:Dock(LEFT)
    self.sidebarPanel:SetWide(self:GetWide()/6)
    self.sidebarPanel:SetTall(self:GetTall())
    self.sidebarPanel:SetBackgroundColor(Color(75,75,75,255))

    self:AddModeSelect()
    self:AddSidebarBrowser()
end

function PANEL:AddSidebarBrowser()
    --base panel for browser
    self.sidebarBrowserBase = vgui.Create("DPanel", self.sidebarPanel)
    self.sidebarBrowserBase:Dock(FILL)
    self.sidebarBrowserBase:SetBackgroundColor(Color(75,75,75,255))

    --tab pane
    self.sidebarBrowser = vgui.Create("DPropertySheet", self.sidebarBrowserBase)
    self.sidebarBrowser:Dock(FILL)
    self.sidebarBrowser.catagory_tab = vgui.Create("DPanel", self.sidebarBrowser)
    self.sidebarBrowser.file_tab = vgui.Create("DPanel", self.sidebarBrowser)
    self.sidebarBrowser:AddSheet("Zone Catagories", self.sidebarBrowser.catagory_tab)
    self.sidebarBrowser:AddSheet("File Viewer", self.sidebarBrowser.file_tab)
end

function PANEL:AddModeSelect()
    --Mode select
    self.modeSelect = vgui.Create("DPanel", self.sidebarPanel)
    self.modeSelect:SetTall(self.sidebarPanel:GetTall()/3.5)
    self.modeSelect:Dock(TOP)

    --Mode List Title 
    self.modeSelectTitle = vgui.Create("DLabel", self.modeSelect)
    self.modeSelectTitle:Dock(TOP)
    self.modeSelectTitle:SetContentAlignment(5)
    self.modeSelectTitle:SetText("Modes")
    self.modeSelectTitle:SetTextColor(Color(0,0,0,255))
    self.modeSelectTitle.Paint = function(self,w,h)
        surface.SetDrawColor(75, 75, 75, 255)
        surface.DrawRect(0, 0, w, h)
    end
    --Elements in list
    self.modeSelectElements = vgui.Create("DPanel", self.modeSelect)
    self.modeSelectElements:Dock(FILL)
    self.modeSelectElements:SetBackgroundColor(Color(240,240,240,255))
end

function PANEL:PopulateModeList()
    if self.modeSelectElements.populated then return end
    self.modeSelectElements.modeContainer = {}
    for k,v in pairs(self.tool.ModeList) do
        if k==1 then continue end
        self.modeSelectElements.modeContainer[k] = vgui.Create("DPanel", self.modeSelectElements)
        self.modeSelectElements.modeContainer[k]:Dock(TOP)
        self.modeSelectElements.modeContainer[k]:DockPadding(5, 0, 5, 0)
        self.modeSelectElements.modeContainer[k]:SetTall(self.modeSelectElements:GetTall()/1.4)
        self.modeSelectElements.modeContainer[k].Paint = function(self,w,h)
            if k%2==1 then
                surface.SetDrawColor(200, 200, 200, 255)
            else
                surface.SetDrawColor(240, 240, 240, 255)
            end
            if self:IsHovered() then
                surface.SetDrawColor(116, 152, 207, 255)
            end
            surface.DrawRect(0, 0, w, h)
        end
        self.modeSelectElements.modeContainer[k].label = vgui.Create("DLabel", self.modeSelectElements.modeContainer[k], v)
        self.modeSelectElements.modeContainer[k].label:SetText(v)
        self.modeSelectElements.modeContainer[k]:SetTall(self.modeSelectElements.modeContainer[k]:GetTall())
        self.modeSelectElements.modeContainer[k].label:Dock(FILL)
        self.modeSelectElements.modeContainer[k].label:SetTextColor(Color(0,0,0,255))
    end
    self.modeSelectElements.populated=true
end

function PANEL:Paint(width, height)
    draw.RoundedBox(5, 0, 0, width, height, Color(75,75,75,255))
end

function PANEL:Think()
    if(!GZT_PANEL) then
        self:Remove()
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

vgui.Register("gzt_gui", PANEL, "EditablePanel")
