AddCSLuaFile()

if SERVER then 
    util.AddNetworkString("gzt_get_parent_uuid")
    util.AddNetworkString("gzt_createPanel_receiveallzones")
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

    self.populated=false//TODO make this pop cats and pop zones

    self.TreeView = vgui.Create("DTree", self, "TreeView")
    self.TreeView:DockMargin(0, 10, 0, 0)
    self.TreeView:Dock(FILL)
    self.TreeView.nodes = {}
    self.TreeView.OnNodeSelected = function(self, node)
        local uuid = table.KeyFromValue(self.nodes, node)
        if uuid == "Root" then return end
        if(node.isCategory) then
            GZT_WRAPPER:GetCategoryUUID(uuid,"gzt_get_parent_uuid")
        end
    end

    self:InvalidateParent(true)
end

net.Receive("gzt_get_parent_uuid", function()
    local cat = net.ReadTable()
    if ConVarExists("gzt_selected_category_uuid") then
        GetConVar("gzt_selected_category_uuid"):SetString(cat.gzt_uuid)
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

function getIndexByUUID(cats, uuid)
    for k,v in pairs(cats) do
        if v.gzt_uuid == uuid then
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

function CategorySort(a,b)
    --Sorts categories by smallest number of parents first and alpebetical by name if same parents length
    if #a.gzt_parents > #b.gzt_parents then
        return false
    elseif #a.gzt_parents < #b.gzt_parents then
        return true
    else 
        local aName = a.gzt_internalname
        local bName = b.gzt_internalname
        if a.gzt_displayName != nil && a.gzt_displayName != "" then
            bName = b.gzt_displayName
        end
        if b.gzt_displayName != nil && b.gzt_displayName != "" then
            bName = b.gzt_displayName
        end
        if string.compare(aName,bName) > 0 then
            return false
        elseif string.compare(aName,bName) < 0 then
            return true
        else
            return true
        end
    end
    return false
end

function PANEL:PopulateCategories()
    local t = util.TableToJSON(self.gzt_categories) 
    print("Len t",#t)
    local comp = util.Compress(t)
    print("Len comp",#comp)
    print(t)
    print("===========================================")
    print(comp)
    self.cat_wait = false
    self.populated = true
    self.TreeView.nodes["Root"] = self.TreeView:AddNode("Root","materials/catagory_icon.png")
    local cur_parents = {}
    local parent_queue = {}
    local parent_node = self.TreeView.nodes["Root"]
    local node_count = 0
    local iter = 1
    local indexed_list = {}
    for k,v in pairs(self.gzt_categories) do
        indexed_list[#indexed_list+1]=v
    end
    table.sort(indexed_list, CategorySort)
    while node_count < #indexed_list do
        if TableEq(indexed_list[iter].gzt_parents, cur_parents) then
            self.TreeView.nodes[indexed_list[iter].gzt_uuid] = parent_node:AddNode(indexed_list[iter].gzt_internalname, "materials/catagory_icon.png") //TODO: use display name if available
            self.TreeView.nodes[indexed_list[iter].gzt_uuid].isCategory = true
            parent_queue[#parent_queue+1] = indexed_list[iter].gzt_uuid
            node_count=node_count+1
        end
        if iter >= #indexed_list then
            local i = getIndexByUUID(indexed_list,parent_queue[1])
            cur_parents = table.Copy(indexed_list[i].gzt_parents)
            cur_parents[#cur_parents+1] = parent_queue[1]
            parent_node = self.TreeView.nodes[indexed_list[i].gzt_uuid]
            table.remove(parent_queue, 1)
            iter = 1
        else
            iter = iter + 1
        end
    end
    self:GetZones()
end

function PANEL:UpdateCategory(catName, catObj)

end

net.Receive("gzt_updateclientcategory", function(len)
    local uuid = net.ReadString()
    local catObj = net.ReadTable()
    GZT_GUI.BasePanel.TabPane.CreateTab:UpdateCategory(uuid, catObj)
end)

hook.Add("gzt_createPanel_receiveallcats","somthing",function(tbl)
    GZT_GUI.BasePanel.TabPane.CreateTab.gzt_categories = tbl
    GZT_GUI.BasePanel.TabPane.CreateTab:PopulateCategories()
    print("HOOK RECIVED!!!!!!!!!")
end)

function PANEL:GetZones()
    self.zone_wait = true
    GZT_WRAPPER:GetAllZones("gzt_createPanel_receiveallzones")
end

function PANEL:PopulateZones()
    self.zone_wait = false
    for uuid,zone in pairs(self.gzt_zones) do
        if zone.gzt_parent then
            self.TreeView.nodes[uuid] = self.TreeView.nodes[zone.gzt_parent]:AddNode(zone.gzt_internalname,"materials/zone_icon.png") //TODO: use display name
            if zone.gzt_color then
                self.TreeView.nodes[uuid].Icon:SetImageColor(zone.gzt_color)
            else
                self.TreeView.nodes[uuid].Icon:SetImageColor(Color(0,0,0,255))
            end
        else 
            self.TreeView.nodes[uuid] = self.TreeView.nodes["Root"]:AddNode(zone.gzt_internalname,"materials/zone_icon.png") //TODO: use display name
            if zone.gzt_color then
                self.TreeView.nodes[uuid].Icon:SetImageColor(zone.gzt_color)
            else
                self.TreeView.nodes[uuid].Icon:SetImageColor(Color(0,0,0,255))
            end
        end
    end
end

function PANEL:UpdateZone(zoneName,zone)

end

net.Receive("gzt_updateclientzone", function(len)
    local uuid = net.ReadString()
    local zone = net.ReadTable()
    GZT_GUI.BasePanel.TabPane.CreateTab:UpdateCategory(uuid, zone)
end)

net.Receive("gzt_createPanel_receiveallzones", function(len)
    GZT_GUI.BasePanel.TabPane.CreateTab.gzt_zones = net.ReadTable()
    GZT_GUI.BasePanel.TabPane.CreateTab:PopulateZones()
end)

vgui.Register("gzt_CreateTab", PANEL, "DPanel")