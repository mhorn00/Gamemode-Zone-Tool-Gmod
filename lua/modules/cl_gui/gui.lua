AddCSLuaFile()
include("modules/cl_gui/gzt_topbar.lua")
include("modules/cl_gui/gzt_basemodePanel.lua")
include("modules/cl_gui/gzt_sidebar.lua")
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
    self.basePanel.sidebarPanel:PopulateModeList()
    if(!self.FirstSelected) then
        self.FirstSelected = true
        self.basePanel.sidebarPanel:SelectMode(self.tool:GetToolMode())
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
    self.basePanel.sidebarPanel = vgui.Create("gzt_sidebar", self.basePanel) 
    self.basePanel.sidebarPanel:Dock(LEFT)
    self.basePanel.sidebarPanel:SetWide(self:GetWide()/6)
    self.basePanel.sidebarPanel:SetTall(self:GetTall())
    self.basePanel.sidebarPanel:SetBackgroundColor(COLORS.base)
end

function PANEL:AddTopbar()
    self.topbar = vgui.Create("gzt_topbar", self)
    self.topbar:SetTall(self:GetTall()/40)
    self.topbar:Dock(TOP)
end

function PANEL:AddBasePanel()
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
