AddCSLuaFile()
if SERVER then return end

local PANEL = {}
local selectedCatagoryConVar = CreateConVar("GZT_SelectedCatagory", "Root", FCVAR_USERINFO)
local variable = 5
local hasInit = false

function PANEL:ZoneCommitSuccessful()
    local catagoryName = GetConVar("GZT_SelectedCatagory"):GetString()
    local catagoryNode = GZT_PANEL.basePanel.baseModePanel.createMode.catViewScroll.catagoryView.catNodes[catagoryName]
    CMAddZoneNode(catagoryNode, net.ReadString())
end

function PANEL:Init()    
    hasInit = true
    -- self:InvalidateParent(true)
    self.gamemodeSelect = vgui.Create("DComboBox", self)
    self.gamemodeSelect:DockMargin(0,0,500,0)
    self.gamemodeSelect:Dock(TOP)
    self.saveButton = vgui.Create("DButton", self)
    self.saveButton:DockMargin(0,0,500,0)
    self.saveButton:Dock(TOP)
    self.saveButton:SetText("Save")
    self.saveButton.DoClick = function()
        self:OutputLayout()
    end
    self.saveButton:Dock(TOP)
    for i,gm in pairs(engine.GetGamemodes()) do
        self.gamemodeSelect:AddChoice(gm.name)
    end
    self.gamemodeSelect.OnSelect = function(other_self, index, value, data)
        self:CMPopulateCatagories(GZT_PANEL.CatagoryList[value])
    end
    
    
    self.catViewScroll = vgui.Create("DHorizontalScroller", self)
    self.catViewScroll:DockPadding(0, 0, self:GetWide()/2, 0)
    -- self.basePanel.baseModePanel.createPanelBase.catViewScroll:DockMargin(0, 0, self.basePanel.baseModePanel.createPanelBase:GetWide()/2, 0)
    self.catViewScroll:Dock(FILL)

    self.catViewScroll.catagoryView = vgui.Create("DTree", self.catViewScroll)
    self.catViewScroll.catagoryView.zoneNodes = {}
    self.catViewScroll.catagoryView:DockMargin(0, 20, 0, 0)
    self.catViewScroll.catagoryView:Dock(FILL)
    self.catViewScroll.catagoryView.OnMousePressed = function(catagoryView, button_code)
        if(button_code == MOUSE_RIGHT) then
            self.contextmenu = DermaMenu(self)
            self.contextmenu:AddOption("was up dode")
            self.contextmenu:Open()
        end
    end
    self.catViewScroll.catagoryView.OnNodeSelected = function(dtree, selectedNode)
        -- PrintTable(selectedNode)
        GZT_ZONETOOL.currentCatagory = self.catViewScroll.catagoryView.catNodes[selectedNode.Label:GetText()]
    end
    self.gamemodeSelect:SetValue(GAMEMODE.Name)
    
    -- PANEL = self
end

function PANEL:CMPopulateCatagories(catagories)
    if self.catViewScroll.catagoryView.catNodes && self.catViewScroll.catagoryView.catNodes != {} && self.catViewScroll.catagoryView.catNodes["Root"] && self.catViewScroll.catagoryView.catNodes["Root"].ChildNodes then
        for _,node in pairs(self.catViewScroll.catagoryView.catNodes["Root"].ChildNodes:GetChildren()) do
            node:Remove()
        end
        self.catViewScroll.catagoryView.catNodes["Root"]:Remove()
    end
    if !catagories then
        return
    end
    local RootNode = catagories[1]
    self.catViewScroll.catagoryView.catNodes = {}
    self.catViewScroll.catagoryView.catNodes["Root"] = self.catViewScroll.catagoryView:AddNode("Root", "materials/catagory_icon.png")
    self.catViewScroll.catagoryView.catNodes["Root"].Icon:SetImageColor(RootNode.color or Color(255,255,255))
    self.catViewScroll.catagoryView.catNodes["Root"]:Receiver("nodereceiver", ReceiveHandler, {})
    self.catViewScroll.catagoryView.catNodes["Root"].DoRightClick = CMNodeMenuHandler
    self.catViewScroll.catagoryView.catNodes["Root"].DoClick = SetPlayerCatagory
    self.catViewScroll.catagoryView.catNodes["Root"].isRoot = true
    
    local stack = {RootNode}
    while #stack>0 do
        local cur = stack[#stack]
        table.remove(stack)
        if cur.children && cur.children != {} then
            for _,child in pairs(cur.children) do
                stack[#stack+1] = child
                self.catViewScroll.catagoryView.catNodes[child.name] = self:CMAddCatagoryNode(self.catViewScroll.catagoryView.catNodes[cur.name], child)
            end
        end
    end
end

function SetPlayerCatagory(node)
    print(node.Label:GetText())
    selectedCatagoryConVar:SetString(node.Label:GetText())
end

function PANEL:CMAddCatagoryNode(parent, newNodeInfo)
    local node = parent:AddNode(newNodeInfo.name, "materials/catagory_icon.png")
    node.Icon:SetImageColor(newNodeInfo.color or Color(255,255,255))
    node.DoClick = SetPlayerCatagory
    node.DoRightClick = CMNodeMenuHandler
    node:Droppable("nodereceiver")
    node:Receiver("nodereceiver", ReceiveHandler, {})
    node.isRoot = false
    return node
end

function CMenuAddCurrentZone(self, node, currentbox)
    if(currentbox.MinBound != nil && currentbox.MaxBound != nil) then
        local name, node = CMAddZoneNode(node, currentbox)
        node.DoRightClick = CMNodeMenuHandler
        node.nodeType ="zone"
        self.catViewScroll.catagoryView.zoneNodes[name] = node 
        currentbox.catagory = node.Label:GetName()
    end
end

function CMAddZoneNode(catagory, zoneId)
    local newName = catagory.Label:GetText().." Zone "
    local i = 1
    while !IsZoneNameAvailable(newName..i) do
        i=i+1
    end
    local node = catagory:AddNode(newName..i,"materials/zone_icon.png")
    node.Icon:SetImageColor(Color(0,0,0,255))
    node:Droppable("nodereceiver")
    node.zoneId = zoneId
    catagory:SetExpanded(true)
    return newName..i,node
end

function IsZoneNameAvailable(name)
    for k,v in pairs(GZT_PANEL.basePanel.baseModePanel.createMode.catViewScroll.catagoryView.zoneNodes) do
        if k == name then
            return false
        end
    end 
    return true
end

function ReceiveHandler(node, tblDropped, isDropped, menuIndex, mouseX, mouseY)
    if(isDropped) then
        for k,v in pairs(tblDropped) do
            if(v:GetName()=="DTree_Node" && v != node && !IsExtendedChild(v,node)) then
                v:SetParent(nil)
                if(!node.ChildNodes) then
                    node:CreateChildNodes()
                end
                v:SetParent(node.ChildNodes)
                node.ChildNodes:Add(v)
                node:GetRoot():InvalidateLayout(true)
            end
        end
        node:GetRoot().highlighted.Label:SetTextColor(Color(0,0,0,255))
    else
        if(node:GetRoot().highlighted && node:GetRoot().highlighted:GetName()=="DTree_Node") then
            node:GetRoot().highlighted.Label:SetTextColor(Color(0,0,0,255))
        end
        node:GetRoot().highlighted = node
        node:SetPaintBackground(true)
        node:SetBackgroundColor(Color(0,255,0,255))
        node.Label:SetTextColor(Color(255,100,100,255))
    end
end

function CMNodeMenuHandler(node, button)
    local cmenu = DermaMenu(node)
    cmenu:AddOption("Add Catagory")
    cmenu:AddOption("Add Current Zone")
    cmenu.colorsub, cmenu.coloroption = cmenu:AddSubMenu("Recolor", function() return end)
    cmenu.colorsub.colorcombo = vgui.Create("DColorCombo", cmenu.colorsub)
    cmenu.colorsub.colorcombo.OnValueChanged = function(colorsubmenu, newcolor)
        node.Icon:SetImageColor(newcolor)
    end
    if(cut_node) then
        cmenu:AddOption("Paste")
    end
    if(!node.isRoot) then
        cmenu:AddOption("Cut")
        cmenu:AddOption("Rename")
        cmenu:AddOption("Delete")
    end
    if(node.nodeType == "zone") then
        cmenu:AddOption("Select Zone")
    end
    cmenu.OptionSelected = function(menu, option, text)
        if text == "Add Catagory" then
            CMMenuAddCatagoryChild(GZT_PANEL.basePanel.baseModePanel.createMode, node)
        elseif text=="Add Current Zone" then
            CMenuAddCurrentZone(GZT_PANEL.basePanel.baseModePanel.createMode, node, GZT_PANEL.tool.CurrentBox)
        elseif text == "Cut" then
            node:Hide()
            node:SetParent(nil)
            cut_node = node
            node:GetRoot():InvalidateLayout(true)
        elseif text == "Paste" then
            if(!node.ChildNodes) then
                node:CreateChildNodes()
            end
            cut_node:SetParent(node)
            cut_node:Show()
            node.ChildNodes:Add(cut_node)
            node:GetRoot():InvalidateLayout(true)

            cut_node = nil
        elseif text == "Rename" then
            CMMenuRenameCatagoryNode(GZT_PANEL.basePanel.baseModePanel.createMode, node)
        elseif text == "Delete" then
            CMMenuDeleteCatagoryNode(GZT_PANEL.basePanel.baseModePanel.createMode, node)
        elseif text=="Select Zone" then
            local id = node.zoneId
            net.Start("gzt_EditZone")
                net.WriteString(id)
            net.SendToServer()
        end
    end
    cmenu:Open()
end

function CMMenuAddCatagoryChild(self, parent)
    local newName = "New Catagory"
    local add = ""
    local i = 1
    while !self:IsNameCatagoryAvailable(newName..add) do
        add = " ("..i..")"
        i=i+1
    end
    self.catViewScroll.catagoryView.catNodes[newName..add] = self:CMAddCatagoryNode(parent, {name=newName..add})
    parent:SetExpanded(true)
end

function PANEL:IsNameCatagoryAvailable(name)
    for k,v in pairs(self.catViewScroll.catagoryView.catNodes) do
        if k == name then
            return false
        end
    end 
    return true
end

function CMMenuRenameCatagoryNode(self, node)
    if self.catViewScroll.catagoryView.currentlyEditing then
        self.catViewScroll.catagoryView.currentlyEditing.Label:SetText(self.catViewScroll.catagoryView.currentlyEditing.oldName)
        self.catViewScroll.catagoryView.currentlyEditing.Label:Show()
        self.catViewScroll.catagoryView.currentlyEditing.textEntry:Remove()
    end 
    self.catViewScroll.catagoryView.currentlyEditing = node
    node.Label:Hide()
    node.oldName = node.Label:GetText()
    node.oldNameW = node.Label:GetTextSize()
    node.textEntry = vgui.Create("DTextEntry", node)
    node.textEntry:SetUpdateOnType(true)
    node.textEntry:SetText(node.oldName)
    node.textEntry:SetPlaceholderText(node.oldName)
    node.textEntry:RequestFocus()
    node.textEntry:SelectAllOnFocus()
    node.textEntry:StretchToParent(38, nil, nil, nil)
    node.textEntry:SetTall(node:GetLineHeight())
    local w,h = node.Label:GetTextSize() 
    node.textEntry:SetWide(w+15)
    node.textEntry:SetEnterAllowed(false)
    node.textEntry.OnChange = function(textentry)
        if !self:IsNameCatagoryAvailable(textentry:GetText()) && textentry:GetText() != node.oldName then
            textentry:SetTextColor(Color(255,0,0,255))
        else
            textentry:SetTextColor(Color(0,0,0,255))
        end
        node.Label:SetText(textentry:GetText())
        local w,h = node.Label:GetTextSize() 
        textentry:SetWide(math.max(w+15, node.oldNameW+15))
    end

    node.textEntry.OnKeyCodeTyped = function(textentry, KeyCode)
        if KeyCode == KEY_ENTER then
            if (self:IsNameCatagoryAvailable(textentry:GetText()) || textentry:GetText()==node.oldName) && string.match(textentry:GetText(), "^[a-zA-Z0-9 _!@#$&()"..string.PatternSafe("[]").."]*$")==textentry:GetText() then
                if textentry:GetText() != "" then
                    node.Label:SetText(textentry:GetText())
                else
                    node.Label:SetText(node.oldName)
                end
                self.catViewScroll.catagoryView.catNodes[node.oldName] = nil
                self.catViewScroll.catagoryView.catNodes[node.Label:GetText()] = node
                textentry:Remove()
                node.Label:Show()
                self.catViewScroll.catagoryView.currentlyEditing = nil
            end
        end
        node.lastKey = KeyCode
    end

    node.textEntry.OnLoseFocus = function(textentry)
        if(node.lastKey == KEY_ENTER) then
            node.lastKey = nil
            return
        end
        node.Label:SetText(node.oldName)
        textentry:Remove()
        node.Label:Show()
        self.catViewScroll.catagoryView.currentlyEditing = nil
    end
end

function CMMenuDeleteCatagoryNode(self, node)
    for k,v in pairs(GetExtendedChildren(node)) do
        self.catViewScroll.catagoryView.catNodes[v.Label:GetText()] = nil
        v:Remove()
    end
end

function GetExtendedChildren(parent)
    local stack = {}
    local out = {}
    stack[1] = parent
    while #stack>0 do
        local cur = stack[#stack]
        table.remove(stack)
        out[#out+1] = cur
        if cur.ChildNodes && cur.ChildNodes:GetChildren() && cur.ChildNodes:GetChildren() != {} then
            for k,child in pairs(cur.ChildNodes:GetChildren()) do
                stack[#stack+1] = child
            end
        end
    end
    return out
end

function IsExtendedChild(parent, child)
    local stack = {}
    stack[1] = parent
    while #stack>0 do
        local cur = stack[1]
        table.remove(stack, 1)
        if cur == child then
            return true 
        end
        if cur.ChildNodes && cur.ChildNodes:GetChildren() && cur.ChildNodes:GetChildren() != {} then
            for k,child in pairs(cur.ChildNodes:GetChildren()) do
                stack[#stack+1] = child
            end
        end
    end
    return false
end

function PANEL:OutputLayout()
    local root = self.catViewScroll.catagoryView.catNodes["Root"]
    local stack = {}
    local nodeStack = {}
    local out = {}
    nodeStack={}
    stack[1] = {root,0,false}
    local i = 0
    while #stack>0 do
        local cur = stack[#stack]
        nodeStack[#nodeStack+1]={node=cur[1],depth=cur[2]}
        table.remove(stack)
        if cur[1].ChildNodes && cur[1].ChildNodes:GetChildren() && cur[1].ChildNodes:GetChildren() != {} then
            i=cur[2]+1
            for _,child in pairs(cur[1].ChildNodes:GetChildren()) do
                stack[#stack+1] = {child,i,child==cur[1].ChildNodes:GetChildren()[#cur[1].ChildNodes:GetChildren()]}
            end
        end
        if(cur && cur[3]) then
            i=cur[2]-1
        end
    end
    local parentStack = {{node=nil, context=out}}
    while #nodeStack>0 do
        local child = nodeStack[1]
        table.remove(nodeStack, 1)
        if(child.node.ent) then
            continue
        end
        local parent = parentStack[#parentStack]
        if(parent.node!=nil && parent.node.depth == child.depth) then
            table.remove(parentStack)
            parent = parentStack[#parentStack]
        elseif parent.node!=nil && parent.node.depth > child.depth then
            for i=1,(parent.node.depth-child.depth)+1 do
                table.remove(parentStack)
            end
            parent = parentStack[#parentStack]
        end
        table.insert(parent.context, 1, {
            name=child.node.Label:GetText(), 
            color={
                r=child.node.Icon:GetImageColor().r,
                g=child.node.Icon:GetImageColor().g,
                b=child.node.Icon:GetImageColor().b
                },
            children={}
        })
        if(child.node.ChildNodes && #child.node.ChildNodes:GetChildren()!=0) then
            parentStack[#parentStack+1] = {node=child, context=parent.context[1].children}
        end
    end
    self:PrintOutput(out)
end

function indt(i)
    local ret = ""
    for j = 1,i do
        ret = ret .. "\t"
    end
    return ret
end

function PANEL:PrintOutput(nodesTbl)
    local out = "GZT_CATDEF = {\n"
    local stack = {{node=nodesTbl[1]}}
    local bracketStack = {#stack[1].node.children}
    while #stack>0 do
        local cur = stack[#stack]
        table.remove(stack)
        --Bracket stack has a counter for each object of when we need to close its brackets  
        for k = 1, #bracketStack do
            bracketStack[k] = bracketStack[k] + #cur.node.children
        end
        local curIndents = #bracketStack*2
        out = out..indt(curIndents-1).."{\n"
        out = out..indt(curIndents).."name=\""..cur.node.name.."\",\n"
        out = out..indt(curIndents).."color={".."r="..cur.node.color.r..",".."g="..cur.node.color.g..",".."b="..cur.node.color.b.."},\n"
        out = out..indt(curIndents).. (#cur.node.children!=0 and "children={\n" or "children={")
        --Add current nodes children into the stack
        if #cur.node.children != 0 then
            for cIndex = #cur.node.children, 1, -1 do
                stack[#stack+1] = {node=cur.node.children[cIndex]}
            end
        end
        --Decrement the everything in the bracket stack
        for i = 1, #bracketStack do
            bracketStack[i] = bracketStack[i]-1
        end
        local whileIter = 0
        while (bracketStack[#bracketStack] == 0) do
            if #cur.node.children == 0 && whileIter == 0 then
                --close the empty children then close the object
                out = out.."}\n"..indt(curIndents-1).."},\n"
            else
                --close the children then the object
                out = out..indt(curIndents-(2*whileIter)).."}\n"..indt(curIndents-((2*whileIter)+1)).."},\n"
            end
            whileIter = whileIter+1
            table.remove(bracketStack)
        end
    end
    out=out.."}"
    print(out)
    file.Write("TESTOUT.txt", out)
end


vgui.Register("gzt_createPanel", PANEL, "DPanel")