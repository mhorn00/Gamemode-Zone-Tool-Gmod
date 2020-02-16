AddCSLuaFile()

if SERVER then 
    util.AddNetworkString("gzt_createPanel_receiveallcats")
    return 
end

local PANEL = {}

function PANEL:Init()
    self:DockPadding(20, 10, 20, 10)
    
    self.GamemodeSelect = vgui.Create("DComboBox", self, "GamemodeSelect")
    self.GamemodeSelect:DockMargin(0,0,500,0)
    self.GamemodeSelect:Dock(TOP)
    for _,gm in pairs(engine.GetGamemodes()) do
        self.GamemodeSelect:AddChoice(gm.name)
    end
    self.GamemodeSelect:SetValue(engine.ActiveGamemode())

    self.testBtn = vgui.Create("DButton", self, "testbtn")
    self.testBtn:DockMargin(500, 0, 0, 0)
    self.testBtn:Dock(TOP)
    self.testBtn.DoClick = function()
        self:GetCategories()
    end

    self.TreeView = vgui.Create("DTree", self, "TreeView")
    self.TreeView:DockMargin(0, 10, 0, 0)
    self.TreeView:Dock(FILL)
    self.TreeView.nodes = {}
    self.TreeView.OnNodeSelected = function(self, node)
        GZT_WRAPPER:GetCategoryUUID(table.KeyFromValue(self.nodes, node),"gzt_get_get_parent_uuid")
    end

    self:InvalidateParent(true)
end

    net.Receive("gzt_get_get_parent_uuid", function()
        local cat = net.ReadTable()
        local parents = ""
        for i,parent in pairs(cat.gzt_parents) do
            parents = parents + parent
            if i < #cat.gzt_parents then
                parents = parents + ","
            end
        end
        print(parents)
        if ConVarExists("gzt_selected_category_parents") then
            GetConVar("gzt_selected_category_parents"):SetString(parents)
        end
    end)

function PANEL:Think()
    if self.cat_wait then
        //TODO do loading anim here
    end
end

function PANEL:GetCategories()
    self.cat_wait = true
    GZT_WRAPPER:GetAllCategories("gzt_createPanel_receiveallcats")
end

function getIndexByName(cats, name)
    for k,v in pairs(cats) do
        if(v.name==name) then
            return k
        end
    end
    return -1 
end

function TableEq(t1,t2)
    if table.IsEmpty(t1) && table.IsEmpty(t2) then
        return true
    end
    if #t1 == #t2 then
        for k,v in pairs(t1) do
            if v != t2[k] then
                return false
            end
        end
    else 
        return false
    end
    return true
end

function PANEL:PopulateCategories()
    self.cat_wait = false
    self.TreeView.nodes["Root"] = self.TreeView:AddNode("Root","materials/catagory_icon.png")
    local cur_parents = {}
    local parent_queue = {}
    local parent_node = self.TreeView.nodes["Root"]
    local node_count = 0
    local iter = 1
    local indexed_list = {}
    for k,v in pairs(self.gzt_categories) do
        v["name"]=k
        indexed_list[#indexed_list+1]=v
    end
    while node_count < #indexed_list do
        if TableEq(indexed_list[iter].gzt_parents, cur_parents) then
            self.TreeView.nodes[indexed_list[iter].gzt_uuid] = parent_node:AddNode(indexed_list[iter].name, "materials/catagory_icon.png") //TODO: use display name if available
            parent_queue[#parent_queue+1] = indexed_list[iter].name
            node_count=node_count+1
        end
        if iter >= #indexed_list then
            cur_parents = table.Copy(indexed_list[getIndexByName(indexed_list,parent_queue[1])].gzt_parents)
            cur_parents[#cur_parents+1] = parent_queue[1]
            parent_node = self.TreeView.nodes[indexed_list[getIndexByName(indexed_list,parent_queue[1])].gzt_uuid]
            table.remove(parent_queue, 1)
            iter = 1
        else
            iter = iter + 1
        end
    end
end

function PANEL:RefreshCategory(catName, catObj)

end

net.Receive("gzt_category_refresh", function(len)
    local catName = net.ReadString()
    local catObj = net.ReadTable()
    GZT_GUI.BasePanel.TabPane.CreateTab:RefreshCategory(catName, catObj)
end)

net.Receive("gzt_createPanel_receiveallcats", function(len)
    local received = net.ReadTable()
    GZT_GUI.BasePanel.TabPane.CreateTab.gzt_categories = received
    GZT_GUI.BasePanel.TabPane.CreateTab:PopulateCategories()
end)

vgui.Register("gzt_CreateTab", PANEL, "DPanel")