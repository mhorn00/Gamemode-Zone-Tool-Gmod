AddCSLuaFile()

if SERVER then return end

local PANEL = {}

GZT_PANEL = nil



function PANEL:Init()
    self:SetSize(ScrW()/2, ScrH()/1.5)
    self:SetPos(ScrW()/2 - self:GetWide()/2, ScrH()/2 - self:GetTall()/2)
    self:MakePopup()
     --Top Bar
    topbar = vgui.Create("DPanel", self)
    topbar:Dock(TOP)
    topbar.Paint = topbarPaint
    --Close Button
    local closeBtn = vgui.Create("DButton", topbar)
    closeBtn.DoClick = closeBtnClick
    closeBtn:SetPos(self:GetWide()-closeBtn:GetWide(), 0)
    closeBtn:SetText("")
    closeBtn:Dock(RIGHT)
    closeBtn:SetWide(30)
    closeBtn.Paint=closeBtnPaint
    --Pgrm Mode
    local program_mode = vgui.Create("DPanel", self)
    local tab_panel = vgui.Create("DPropertySheet", program_mode)
    program_mode:Dock(FILL)
    tab_panel:Dock(FILL)
    program_mode:SetBackgroundColor(Color(70,70,70,255))
    --Sidebar
    local sidebarPanel = vgui.Create("DPanel", self)
    sidebarPanel:Dock(LEFT)
    sidebarPanel:SetWide(self:GetWide()/6)
    sidebarPanel:SetTall(self:GetTall())
    sidebarPanel:SetBackgroundColor(Color(75,75,75,255))
    --Mode select
    local modeSelect = vgui.Create("DListView", sidebarPanel)
    modeSelect:SetTall(sidebarPanel:GetTall()/2)
    modeSelect:Dock(TOP)
    print(sidebarPanel:GetTall()/2)
    --Tab Pane
    local catagory_tab = vgui.Create("DPanel", tab_panel)
    local file_tab = vgui.Create("DPanel", tab_panel)
    local code_tab = vgui.Create("DPanel", tab_panel)
    tab_panel:AddSheet("Zone Catagories", catagory_tab)
    tab_panel:AddSheet("File Viewer", file_tab)
    tab_panel:AddSheet("Code Editor", code_tab)
    --code tab
    local editor = vgui.Create("DTextEntry", code_tab)
    editor:MakePopup()
    editor:SetText("placeholder")
    editor:SetUpdateOnType(true)
    editor.AllowInput = function()
        return false
    end
    editor:Dock(FILL)
    function editor:OnEnter()
        print("enter")
    end
    local linenumbers = vgui.Create("DPanel", code_tab)
    linenumbers:Dock(LEFT)
end

function PANEL:Think()
    if(!GZT_PANEL) then
        self:Remove()
    end
end

--Top bar paint
topbarPaint = function(self, width, height)
    surface.SetDrawColor(0, 0, 0, 255)
    draw.RoundedBoxEx(5, 0, 0, width, height, Color(100,100,100,255), true, true, false, false)
end

--CloseBtn DoClick
closeBtnClick = function()
    GZT_PANEL:Hide()
end

--Close Button Paint
closeBtnPaint = function(self,w,h)
    surface.SetDrawColor(125, 125, 125, 255)
    surface.DrawRect(0, 0, w, h)
    if !self:IsHovered() then
        draw.DrawText("X", "DermaLarge", w/2, -3, Color( 200, 200, 200, 255 ), TEXT_ALIGN_CENTER)
    else
        draw.DrawText("X", "DermaLarge", w/2, -3, Color( 255, 59, 59, 255 ), TEXT_ALIGN_CENTER)
    end
end


function PANEL:Paint(width, height)
    draw.RoundedBox(5, 0, 0, width, height, Color(75,75,75,255))
end


concommand.Add("gzt_hide_gui", function()
    GZT_PANEL:Hide()
end)

concommand.Add("gzt_kill_gui", function()
    GZT_PANEL:Remove()
    GZT_PANEL = vgui.Create("gzt_gui")
end)

vgui.Register("gzt_gui", PANEL, "DPanel")
