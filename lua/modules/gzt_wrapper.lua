AddCSLuaFile()

GZT_WRAPPER = {
    gzt_categories = {},
    gzt_zones = {}    
}

function copyNoFunctions(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            if(type(orig_value)=="function") then 
                continue
            end
            copy[copyNoFunctions(orig_key)] = copyNoFunctions(orig_value)
        end
        setmetatable(copy, copyNoFunctions(debug.getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

if SERVER then 
    util.AddNetworkString("gzt_GetAllCategories")
    util.AddNetworkString("gzt_ClientMakeZone")
    util.AddNetworkString("gzt_ClientUpdateZone")
    util.AddNetworkString("gzt_returnclientzoneid")
    util.AddNetworkString("gzt_getcategoryuuid")
    
    net.Receive("gzt_GetAllCategories", function(len, ply)
        net.Start(net.ReadString())
            net.WriteTable(GZT_WRAPPER:GetClientCategories())
        net.Send(ply)
    end)

    net.Receive("gzt_ClientMakeZone", function(len, ply)
        local zoneObj = net.ReadTable()
        GZT_WRAPPER:MakeZone(zoneObj,ply)
    end)

    net.Receive("gzt_ClientUpdateZone", function(len, ply)
        local entId = net.ReadString()
        local zoneObj = net.ReadTable()
        GZT_WRAPPER:UpdateZone(entId, zoneObj)
    end)

    net.Receive("gzt_getcategoryuuid", function(len,ply)
        net.Start(net.ReadString())
            local uuid = net.ReadString()
            for k,v in pairs(GZT_WRAPPER:GetClientCategories()) do
                if(v.gzt_uuid==uuid) then
                    net.WriteTable(v)
                    break
                end
            end
        net.Send(ply)
    end)

    function GZT_WRAPPER:GetClientCategories()
        return copyNoFunctions(self.gzt_categories)
    end

    function GZT_WRAPPER:SetCategories(cats)
        self.gzt_categories = cats
    end

    function GZT_WRAPPER:SetZones(zones)
        self.gzt_zones=zones
    end

    function GZT_WRAPPER:InitZones()  
        for k,v in pairs(self.gzt_zones) do
            self.gzt_zones[k].gzt_entity = self:MakeZone(v)
        end
    end

    function GZT_WRAPPER:MakeZone(zoneObj, ply)
        local curZone = ents.Create("gzt_zone")
        local pos1 = Vector(zoneObj.gzt_pos1.x,zoneObj.gzt_pos1.y,zoneObj.gzt_pos1.z)
        local pos2 = Vector(zoneObj.gzt_pos2.x,zoneObj.gzt_pos2.y,zoneObj.gzt_pos2.z)

        curZone:Setup(pos1, pos2, zoneObj.gzt_angle)
        curZone:Spawn()
        local parentNames = zoneObj.gzt_parents
        print(parentNames)
        local parentNameList = string.Split(parentNames, ",")
        local parent = parentNameList[#parentNameList]
        -- self.gzt_zones[]
        zoneObj.gzt_ent = curZone
        local storeName = FindAvailableName(parent)
        self.gzt_zones[storeName] = zoneObj
        if(ply) then
            print(storeName)
            net.Start("gzt_returnclientzoneid")
                net.WriteString(storeName)
            net.Send(ply)
        end
        return curZone
    end

    function GZT_WRAPPER:UpdateZone(entId, zoneObj)
        local zoneObj = self.gzt_zones[entId]
        if zoneObj == nil then
            return
        end

        zoneObj.gzt_ent:Setup(zoneObj.gzt_pos1, zoneObj.gzt_pos2, zoneObj.gzt_angle)
    end

    function FindAvailableName(categoryName)
        if GZT_WRAPPER.gzt_zones[categoryName] then
            local extraNum = 1
            while GZT_WRAPPER.gzt_zones[categoryName.." "..extraNum] != nil do
                extraNum = extraNum+1
            end
            return categoryName .. " "..extraNum
        end
        return categoryName
    end
    
    function InitPostEntity()
        GZT_WRAPPER:InitZones()
    end
    hook.Add("InitPostEntity", "GZT_BeforeLoadEntities", InitPostEntity)
    
else --CLIENT
    function GZT_WRAPPER:GetAllZones()

    end

    function GZT_WRAPPER:GetZone(zoneName)

    end

    function GZT_WRAPPER:GetZoneUUID(id)

    end
    
    function GZT_WRAPPER:ClientMakeZone(obj)

    end

    function GZT_WRAPPER:ClientMakeZone(zoneObj)
        print("teling server to make zone")
        net.Start("gzt_ClientMakeZone")
            net.WriteTable(zoneObj)
        net.SendToServer()
    end

    
    function GZT_WRAPPER:ClientUpdateZone(zoneObj, entId)
        print("teling server to update zone")
        net.Start("gzt_ClientUpdateZone")
            net.WriteString(entId)
            net.WriteTable(zoneObj)
        net.SendToServer()
    end

    function GZT_WRAPPER:GetCategoryUUID(uuid, cb)
        net.Start("gzt_getcategoryuuid")
            net.WriteString(cb)
            net.WriteString(uuid)
        net.SendToServer()
    end

    function GZT_WRAPPER:GetAllCategories(callback)
        net.Start("gzt_GetAllCategories")
            net.WriteString(callback)
        net.SendToServer()
    end
end

