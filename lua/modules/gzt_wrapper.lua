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
    util.AddNetworkString("gzt_ReturnClientZoneUUID")
    util.AddNetworkString("gzt_GetCategoryByUUID")
    util.AddNetworkString("gzt_GetAllZones")
    util.AddNetworkString("gzt_GetZoneByUUID")
    util.AddNetworkString("gzt_UpdateClientZones")
    util.AddNetworkString("gzt_UpdateClientCategory")
    util.AddNetworkString("gzt_returnclientzoneid")
    
    net.Receive("gzt_GetAllCategories", function(len, ply)
        net.SendChunks(net.ReadString(), GZT_WRAPPER:GetClientCategories(), ply)
    end)

    net.Receive("gzt_GetAllZones", function(len, ply)
        net.SendChunks(net.ReadString(),GZT_WRAPPER:GetClientZones(),ply)
    end)

    net.Receive("gzt_GetZoneByUUID", function(len, ply)
        net.Start(net.ReadString())
            net.WriteTable(copyNoFunctions(GZT_WRAPPER.gzt_zones[net.ReadString()]))
        net.Send(ply)
    end)

    net.Receive("gzt_ClientMakeZone", function(len, ply)
        local zoneObj = net.ReadTable()
        local myUuid = GZT_WRAPPER:MakeZone(zoneObj,ply)
        net.Start("gzt_returnclientzoneid")
            net.WriteString(myUuid)
        net.Send(ply)
    end)

    net.Receive("gzt_ClientUpdateZone", function(len, ply)
        local uuid = net.ReadString()
        local zoneObj = net.ReadTable()
        GZT_WRAPPER:UpdateZone(uuid, zoneObj)
    end)

    net.Receive("gzt_GetCategoryByUUID", function(len,ply)
        net.Start(net.ReadString())
            net.WriteTable(copyNoFunctions(GZT_WRAPPER.gzt_categories[net.ReadString()]))
        net.Send(ply)
    end)

    function GZT_WRAPPER:GetClientCategories()
        return copyNoFunctions(self.gzt_categories)
    end

    function GZT_WRAPPER:GetClientZones()
        return copyNoFunctions(self.gzt_zones)
    end

    function GZT_WRAPPER:SetCategories(cats)
        local uuidIndexed = {}
        for k,v in pairs(cats) do
            v.gzt_internalname=k
            uuidIndexed[v.gzt_uuid] = v
        end
        for uuid,cat in pairs(uuidIndexed) do
            for i,parentName in pairs(cat.gzt_parents) do
                for search_uuid,search_cat in pairs(uuidIndexed) do
                    if search_cat.gzt_internalname == parentName then
                        uuidIndexed[uuid].gzt_parents[i] = search_uuid
                    end
                end 
            end
        end
        self.gzt_categories = uuidIndexed
    end

    function GZT_WRAPPER:SetZones(zones)
        local uuidIndexed = {}
        for k,v in pairs(zones) do
            v.gzt_internalname=k
            for uuid,cat in pairs(self.gzt_categories) do
                if cat.gzt_internalname == v.gzt_parent then
                    v.gzt_parent=uuid
                end
            end
            uuidIndexed[v.gzt_uuid] = v
        end
        self.gzt_zones=uuidIndexed
    end

    function GZT_WRAPPER:InitZones() 
        for uuid,zone in pairs(self.gzt_zones) do
            self:MakeZone(zone)
        end
    end

    local random = math.random
    local function uuid()
        local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
        return string.gsub(template, '[xy]', function (c)
            local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
            return string.format('%x', v)
        end)
    end

    function GZT_WRAPPER:MakeZone(zoneObj, ply)
        local curZone = ents.Create("gzt_zone")
        local pos1 = Vector(zoneObj.gzt_pos1.x,zoneObj.gzt_pos1.y,zoneObj.gzt_pos1.z)
        local pos2 = Vector(zoneObj.gzt_pos2.x,zoneObj.gzt_pos2.y,zoneObj.gzt_pos2.z)
        local angle = nil
        if(zoneObj.gzt_angle) then
            angle = Angle(zoneObj.gzt_angle.p,zoneObj.gzt_angle.y,zoneObj.gzt_angle.r)
        end
        curZone:Setup(pos1, pos2, angle)
        curZone:Spawn()
        local tempuuid = zoneObj.gzt_uuid
        if(!zoneObj.gzt_uuid) then
            tempuuid = uuid()
        end
        self.gzt_zones[tempuuid] = zoneObj
        self.gzt_zones[tempuuid].gzt_uuid = tempuuid
        self.gzt_zones[tempuuid].gzt_entity = curZone
        self:UpdateClientZone(self.gzt_zones[tempuuid])
        return self.gzt_zones[tempuuid].gzt_uuid
    end

    function GZT_WRAPPER:UpdateZone(uuid, zoneObj)
        if self.gzt_zones[uuid]==nil then
            self:MakeZone(zoneObj, ply)
            return
        end
        local serverZoneObj = self.gzt_zones[uuid]
        if serverZoneObj == nil then
            return
        end
        if IsValid(serverZoneObj.gzt_entity) then
            serverZoneObj.gzt_entity:Setup(zoneObj.gzt_pos1, zoneObj.gzt_pos2, zoneObj.gzt_angle)
        end
        self:UpdateClientZone(zoneObj)
    end

    function FindAvailableName(categoryName)--UPDATE ME
        if GZT_WRAPPER.gzt_zones[categoryName] then
            local extraNum = 1
            while GZT_WRAPPER.gzt_zones[categoryName.." "..extraNum] != nil do
                extraNum = extraNum+1
            end
            return categoryName .. " "..extraNum
        end
        return categoryName
    end

    function GZT_WRAPPER:UpdateClientZone(zoneObj)
        net.Start("gzt_UpdateClientZones")
            net.WriteTable(copyNoFunctions(zoneObj))
        net.Broadcast()
    end
    
    function GZT_WRAPPER:UpdateClientCategory(uuid,categoryObj)
        net.Start("gzt_UpdateClientCategory")
            net.WriteString(uuid)
            net.WriteTable(copyNoFunctions(categoryObj))
        net.Broadcast()
    end

    function InitPostEntity()
        GZT_WRAPPER:InitZones()
    end
    hook.Add("InitPostEntity", "GZT_BeforeLoadEntities", InitPostEntity)
    
    function RemoteFunction(remoteFuncData)
        local uuid = remoteFuncData.uuid
        local funcName = remoteFuncData.funcName
        local data = remoteFuncData.data
        data = data and data or {}
        GZT_WRAPPER.gzt_zones[uuid].gzt_entity[funcName](GZT_WRAPPER.gzt_zones[uuid].gzt_entity,unpack(data))
    end
    hook.Add("gzt_remotefunction", "gzt_remotefunctionhandler", RemoteFunction)
else --CLIENT
    function GZT_WRAPPER:GetAllZones(cb)
        net.Start("gzt_GetAllZones")
            net.WriteString(cb)
        net.SendToServer()
    end

    function GZT_WRAPPER:GetZoneUUID(id,cb)
        net.Start("gzt_GetZoneByUUID")
            net.WriteString(cb)
            net.WriteString(id)
        net.SendToServer()
    end

    function GZT_WRAPPER:ClientMakeZone(zoneObj)
        net.Start("gzt_ClientMakeZone")
            -- net.WriteString(cb)
            print(zoneObj)
            PrintTable(zoneObj)
            net.WriteTable(zoneObj)
        net.SendToServer()
    end
    
    function GZT_WRAPPER:ClientUpdateZone(zoneObj, entId)
        net.Start("gzt_ClientUpdateZone")
            net.WriteString(entId)
            net.WriteTable(zoneObj)
        net.SendToServer()
    end

    function GZT_WRAPPER:GetCategoryUUID(uuid, cb)
        net.Start("gzt_GetCategoryByUUID")
            net.WriteString(cb)
            net.WriteString(uuid)
        net.SendToServer()
    end

    function GZT_WRAPPER:GetAllCategories(callback)
        net.Start("gzt_GetAllCategories")
            net.WriteString(callback)
        net.SendToServer()
    end

    function GZT_WRAPPER:RemoteFunction(uuid, funcname, data)
        net.SendChunks("gzt_remotefunction", {uuid=uuid, funcName=funcname, data=data})
    end
end

