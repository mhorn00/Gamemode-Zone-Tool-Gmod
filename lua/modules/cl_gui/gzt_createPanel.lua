AddCSLuaFile()
if SERVER then return end

local PANEL = {}

function PANEL:Init()    
    self.gamemodeSelect = vgui.Create("DComboBox", self)
    self.gamemodeSelect:DockMargin(0,0,500,0)
    self.gamemodeSelect:Dock(TOP)
    self.gamemodeSelect.OnSelect = function(other_self, index, value, data)
        self:CMPopulateCatagories(GZT_PANEL.CatagoryList[value])
    end
    
    self.catViewScroll = vgui.Create("DHorizontalScroller", self)
    self.catViewScroll:DockPadding(0, 0, self:GetWide()/2, 0)
    self.catViewScroll:Dock(FILL)

    self.catViewScroll.catagoryView = vgui.Create("DTree", self.catViewScroll)
    self.catViewScroll.catagoryView.zoneNodes = {}
    self.catViewScroll.catagoryView:DockMargin(0, 20, 0, 0)
    self.catViewScroll.catagoryView:Dock(FILL)
    self.catViewScroll.catagoryView.OnMousePressed = function(catagoryView, button_code)
        if(button_code == MOUSE_RIGHT) then
            self.contextmenu = DermaMenu(self)
            self.contextmenu:AddOption("Placeholder")
            self.contextmenu:Open()
        end
    end
    self.catViewScroll.catagoryView.OnNodeSelected = function(dtree, selectedNode)
    GZT_ZONETOOL.currentCatagory = self.catViewScroll.catagoryView.catNodes[selectedNode.Label:GetText()]
    end
    self.gamemodeSelect:SetValue(GAMEMODE.Name)
end