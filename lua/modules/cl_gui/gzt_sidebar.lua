AddCSLuaFile()

if SERVER then return end

local PANEL = {}

function PANEL:Init()
    self:AddModeSelect()
end

function PANEL:AddModeSelect()
    --Mode select
   self.modeSelect = vgui.Create("DPanel",self)
   self.modeSelect:Dock(FILL)

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

function PANEL:SelectMode(mode)
    self.CurrentMode = mode
    GZT_ZONETOOL:SetToolMode(mode)
    PrintTable(self:GetParent().baseModePanel:GetChildren())
    for k,v in pairs(self:GetParent().baseModePanel:GetChildren()) do
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
    if self.modeSelect.modeSelectElements.populated then return end
    self.modeSelect.modeSelectElements.modeContainer = {}
    for k,v in pairs(GZT_ZONETOOL.ModeList) do
        if k==1 then continue end
        self.modeSelect.modeSelectElements.modeContainer[k] = vgui.Create("DPanel", self.modeSelect.modeSelectElements)
        self.modeSelect.modeSelectElements.modeContainer[k]:Dock(TOP)
        self.modeSelect.modeSelectElements.modeContainer[k]:DockPadding(5, 0, 5, 0)
        self.modeSelect.modeSelectElements.modeContainer[k]:SetTall(self.modeSelect.modeSelectElements:GetTall()/1.4)
        self.modeSelect.modeSelectElements.modeContainer[k].Paint = function(self,w,h)
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
        self.modeSelect.modeSelectElements.modeContainer[k].label = vgui.Create("DLabel", self.modeSelect.modeSelectElements.modeContainer[k], v)
        self.modeSelect.modeSelectElements.modeContainer[k].label:SetText(v)
        self.modeSelect.modeSelectElements.modeContainer[k].label:Dock(FILL)
        self.modeSelect.modeSelectElements.modeContainer[k]:SetTall(self.modeSelect.modeSelectElements.modeContainer[k]:GetTall())
        self.modeSelect.modeSelectElements.modeContainer[k].label:SetTextColor(Color(0,0,0,255))
        self.modeSelect.modeSelectElements.modeContainer[k].label:SetMouseInputEnabled(true)
        self.modeSelect.modeSelectElements.modeContainer[k].label.DoClick = function(label)
            self:SelectMode(GZT_ZONETOOL.ModeList[k])
        end
    end
    self.modeSelect.modeSelectElements.populated=true
end


vgui.Register("gzt_sidebar", PANEL, "DPanel")