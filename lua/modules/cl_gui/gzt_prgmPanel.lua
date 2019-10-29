AddCSLuaFile()
if SERVER then return end

PANEL = {}

function PANEL:init()
    
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


vgui.Register("gzt_prgmPanel", PANEL, "DPanel")