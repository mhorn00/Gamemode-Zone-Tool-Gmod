AddCSLuaFile()
include("modules/cl_gui/gzt_topbar.lua")
include("modules/cl_gui/gzt_basemodePanel.lua")
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
    self:onOpen()
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
    self:MakePopup()
    self:SetPos(ScrW()/2 - self:GetWide()/2, ScrH()/2 - self:GetTall()/2)
end

function PANEL:AddSidebar()
    self.sidebar = vgui.Create("gzt_sidebar", self.basePanel)   
    self.sidebar:Dock(LEFT)
    self.sidebar:SetWide(self:GetWide()/6)
    self.sidebar:SetTall(self:GetTall())
    self.sidebar:SetBackgroundColor(COLORS.base)
end

function PANEL:AddTopbar()
    self.topbar = vgui.Create("gzt_topbar", self)
    self.topbar:SetTall(self:GetTall()/40)
    self.topbar:Dock(TOP)
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
    self.basePanel.baseModePanel = vgui.Create("gzt_basemodePanel", self.basePanel)
    self.basePanel.baseModePanel:Dock(FILL)
    self.basePanel.baseModePanel:SetWide(self.basePanel:GetWide()*(5/6))
    self.basePanel.baseModePanel:SetTall(self.basePanel:GetTall())
    self.basePanel.baseModePanel:SetBackgroundColor(Color(100,75,75,255))
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





function PANEL:Paint(width, height)
    draw.RoundedBox(5, 0, 0, width, height, COLORS.base)
end

function PANEL:Think()
    if(!GZT_PANEL) then
        self:Remove()
    end
	-- if ( self.topbar.isDragging ) then
    --     if(!input.IsMouseDown(MOUSE_LEFT)) then
    --         self.topbar.isDragging = false
    --         self.topbar.clickPos = nil
    --     else
    --         local x,y = self:GetPos()
    --         local mousex = math.Clamp( gui.MouseX(), 1, ScrW() - 1 )
	--         local mousey = math.Clamp( gui.MouseY(), 1, ScrH() - 1 )
    --         local panelx, panely = self:GetPos()
    --         local offsetx = mousex - panelx
	-- 	    local offsety = mousey - panely
    --         -- self:SetPos(x+offsetx-self.topbar.clickPos[1], y+offsety-self.topbar.clickPos[2])
    --         self:SetPos(math.Clamp(self.topbar.offset[1],0,ScrW()-self:GetWide()),math.Clamp(self.topbar.offset[2],0,ScrH()-self:GetTall()))
    --     end
	-- end
end



local OriginalDragNDropPaintHook = hook.GetTable()["DrawOverlay"]["DragNDropPaint"]
function EditedDragNDropPaintHook()

	if ( dragndrop.m_Dragging == nil ) then return end
	if ( dragndrop.m_DraggingMain == nil ) then return end
	if ( IsValid( dragndrop.m_DropMenu ) ) then return end

	local hold_offset_x = 2048
	local hold_offset_y = 2048

	-- Find the top, left most panel
	for k, v in pairs( dragndrop.m_Dragging ) do

		if ( !IsValid( v ) ) then continue end

		hold_offset_x = math.min( hold_offset_x, v.x )
		hold_offset_y = math.min( hold_offset_y, v.y )

	end

	DisableClipping( true )

		local Alpha = 0.7
		if ( IsValid( dragndrop.m_Hovered ) ) then Alpha = 0.8 end
		surface.SetAlphaMultiplier( Alpha )

			local ox = gui.MouseX() - hold_offset_x + 8
			local oy = gui.MouseY() - hold_offset_y + 8

			for k, v in pairs( dragndrop.m_Dragging ) do

				if ( !IsValid( v ) ) then continue end

				local dist = 512 - v:Distance( dragndrop.m_DraggingMain )

				if ( dist < 0 ) then continue end

				dist = dist / 512
				surface.SetAlphaMultiplier( Alpha * dist )

				v.PaintingDragging = true
				v:PaintAt( ox + v.x , oy + v.y) // fill the gap between the top left corner and the mouse position
				v.PaintingDragging = nil

			end

		surface.SetAlphaMultiplier( 1.0 )

	DisableClipping( false )

end 

function PANEL:onOpen()
    hook.Remove("DragNDropPaint")
    hook.Add("DrawOverlay", "DragNDropPaint", EditedDragNDropPaintHook)
end

function PANEL:onClose()
    hook.Remove("DragNDropPaint")
    hook.Add("DrawOverlay", "DragNDropPaint", OriginalDragNDropPaintHook)
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
