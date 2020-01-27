AddCSLuaFile()

if SERVER then return end

local PANEL = {}

function PANEL:Init()
    self.Paint = function(self, width, height)
        surface.SetDrawColor(0, 0, 0, 255)
        draw.RoundedBoxEx(5, 0, 0, width, height, Color(100,100,100,255), true, true, false, false)
    end
    self.OnMousePressed = function(topbar)
        self.isDragging = true
        local x,y = self:GetParent():GetPos()
        self.clickPos = {gui.MouseX()-x, gui.MouseY()-y}
    end
    self.OnMouseReleased = function(topbar)
        self.isDragging = false
        self.clickPos = nil
    end
    self.isDragging=false
    
    --Close Button
    self.closeBtn = vgui.Create("DButton", self)
    self.closeBtn.DoClick = function(closeBtn)
        self:GetParent():onClose()
        self:GetParent():Hide()
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

function PANEL:Think()
	if ( self.isDragging ) then
        if(!input.IsMouseDown(MOUSE_LEFT)) then
            self.isDragging = false
            self.clickPos = nil
        else
            local x,y = self:GetParent():GetPos()
            local mousex = math.Clamp( gui.MouseX(), 1, ScrW() - 1 )
	        local mousey = math.Clamp( gui.MouseY(), 1, ScrH() - 1 )
            local panelx, panely = self:GetParent():GetPos()
            local offsetx = mousex - panelx
		    local offsety = mousey - panely
            -- LocalPlayer():ChatPrint(offsetx..","..offsety)
            self:GetParent():SetPos(math.Clamp(x+offsetx-self.clickPos[1], 0, ScrW()-self:GetParent():GetWide()), math.Clamp(y+offsety-self.clickPos[2],0, ScrH()-self:GetParent():GetTall()))
        end
	end
end

vgui.Register("gzt_topbar", PANEL, "EditablePanel")