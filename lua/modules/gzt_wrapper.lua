AddCSLuaFile()

GZT_WRAPPER = {
    gzt_categories = {},
    gzt_zones = {} 
}

FACE_ENUM_NAME = {
	"F",
	"L",
	"U",
	"B",
	"R",
	"D",
	"Z"
}

if SERVER then  
    util.AddNetworkString("gzt_ClientMakeZone") --Used by the Client to signal to the Server that a zone needs to be made
    util.AddNetworkString("gzt_ClientUpdateZone") --Used by the Client to signal to the Server that a zone needs to be updated
    util.AddNetworkString("gzt_ReturnClientZoneUUID")--Used by the Server to return the UUID of the zone that was made back to the Client
    util.AddNetworkString("gzt_DeleteZone") --Used by the Client to signal to the Server that a zone needs to be deleted
    util.AddNetworkString("gzt_DeleteFinished") --Used by the Server to signal to the client that a delete was finished

    net.RateReceive("gzt_ClientMakeZone", function(len, ply)
        local zoneObj = net.ReadTable()
        local myUuid = GZT_WRAPPER:MakeZone(zoneObj,ply)
        net.Start("gzt_ReturnClientZoneUUID")
            net.WriteString(myUuid)
        net.Send(ply)
    end)

    net.RateReceive("gzt_ClientUpdateZone", function(len, ply)
        local zoneObj = net.ReadTable()
        GZT_WRAPPER:UpdateZone(zoneObj.gzt_uuid, zoneObj, ply)
    end)
    
    -- delete zone via uuid with some 'locking' mechanism with the isDeleting table
    -- protection against deleting a zone that is already deleted
    local isDeleting = {}
    net.RateReceive("gzt_DeleteZone", function(len, ply)
        local uuid = net.ReadString()
        if(uuid && !isDeleting[uuid]) then
            local zone = GZT_WRAPPER.gzt_zones[uuid]
            if(zone and IsValid(zone.gzt_entity) and !isDeleting[uuid]) then
                isDeleting[uuid] = true
                zone.gzt_entity:Remove()
            else
                return
            end
            GZT_WRAPPER.gzt_zones[uuid] = nil
            isDeleting[uuid] = nil
            net.Start("gzt_DeleteFinished")
            net.Send(ply)
        else
            return
        end
    end)

    -- Set zones from loaded file (used in loader)
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

    -- run on InitPostEntity to create the zones after load
    function GZT_WRAPPER:InitZones() 
        for uuid,zone in pairs(self.gzt_zones) do
            self:MakeZone(zone)
        end
    end
    hook.Add("InitPostEntity", "GZT_BeforeLoadEntities", GZT_WRAPPER.InitZones)

    -- Set Rotation logic for zones, handles face rotation as well
    function GZT_WRAPPER:SetRotation(uuid, angles)
        local zone = GZT_WRAPPER.gzt_zones[uuid]
        local angle = angles
        if zone && IsValid(zone.gzt_entity) then
            zone.gzt_entity:SetAngles(angle)
            zone.gzt_entity:SetupFaces()
            if IsValid(zone.gzt_entity:GetPhysicsObject()) then
                local min = zone.gzt_entity:OBBMins()-zone.gzt_entity:OBBCenter()
                local max = zone.gzt_entity:OBBMaxs()-zone.gzt_entity:OBBCenter()
                zone.gzt_pos1 = min
                zone.gzt_pos2 = max
                OrderVectors(zone.gzt_pos1, zone.gzt_pos2)
                zone.gzt_entity:SetMinBound(zone.gzt_pos1)
                zone.gzt_entity:SetMaxBound(zone.gzt_pos2)
            end
        end
    end

    -- make zone given zoneobject containing pos1, pos2, angle, center
    function GZT_WRAPPER:MakeZone(zoneObj, ply)
        if zoneObj.gzt_pos1 == zoneObj.gzt_pos2 then
            return "nil"
        end
        local curZone = ents.Create("gzt_zone")
        local tempuuid = zoneObj.gzt_uuid
        if(!zoneObj.gzt_uuid) then
            tempuuid = MakeUuid()
        end
        local center = Vector(zoneObj.gzt_center.x,zoneObj.gzt_center.y,zoneObj.gzt_center.z)
        local pos1,pos2 = Vector(zoneObj.gzt_pos1.x, zoneObj.gzt_pos1.y, zoneObj.gzt_pos1.z),Vector(zoneObj.gzt_pos2.x, zoneObj.gzt_pos2.y, zoneObj.gzt_pos2.z)
        local angle = Angle(zoneObj.gzt_angle.p,zoneObj.gzt_angle.y,zoneObj.gzt_angle.r)
        curZone:SetPos(center)
        curZone:SetMinBound(pos1)
        curZone:SetMaxBound(pos2)
        curZone:SetAngles(angle)
        curZone:SetUuid(tempuuid)
        curZone:Spawn()
        curZone:SetupFaces()
        self.gzt_zones[tempuuid] = zoneObj
        self.gzt_zones[tempuuid].gzt_uuid = tempuuid
        self.gzt_zones[tempuuid].gzt_entity = curZone
        return self.gzt_zones[tempuuid].gzt_uuid
    end

    --Updates a zone
    function GZT_WRAPPER:UpdateZone(uuid, zoneObj, ply)
        if self.gzt_zones[uuid]==nil then
            net.Start("gzt_ReturnClientZoneUUID") --If the client trys to update a zone that doesnt exist on the server, we just remove the uuid the client has
                net.WriteString("nil")
            net.Send(ply)
            return
        end
        if zoneObj.gzt_pos1 == zoneObj.gzt_pos2 then
            return
        end
        if zoneObj.angle then
            self:SetRotation(uuid, zoneObj.angle)
        end
        local zone = self.gzt_zones[uuid].gzt_entity
        if IsValid(zone) && zoneObj.gzt_pos1 && zoneObj.gzt_pos2 && zoneObj.gzt_center then
            local min, max = Vector(zoneObj.gzt_pos1),Vector(zoneObj.gzt_pos2)
            OrderVectors(min,max)
            zone:SetPos(zoneObj.gzt_center)
            zone:SetMinBound(min)
            zone:SetMaxBound(max)
            zone:SetupFaces()
            self:ServerNotifyCollision(zone)
        end
    end

    -- run arbitrary function specified by client on serverside entity object 
    function RemoteFunction(remoteFuncData)
        local uuid = remoteFuncData.uuid
        local funcName = remoteFuncData.funcName
        local data = remoteFuncData.data
        data = data and data or {}
        if (GZT_WRAPPER.gzt_zones && GZT_WRAPPER.gzt_zones[uuid] && IsValid(GZT_WRAPPER.gzt_zones[uuid].gzt_entity)) then
            GZT_WRAPPER.gzt_zones[uuid].gzt_entity[funcName](GZT_WRAPPER.gzt_zones[uuid].gzt_entity,unpack(data))
        end
    end
    hook.Add("gzt_remotefunction", "gzt_remotefunctionhandler", RemoteFunction)

    -- Used by the Server to notify to the Clients that a zone had a collision change 
    function GZT_WRAPPER:ServerNotifyCollision(zone, ply)
        local out = {uuid=zone:GetUuid(),faces={}}
        for k,v in pairs(FACE_ENUM_NAME) do
            local face = zone["Get"..v](zone)
            face:CollisionRulesChanged()
            out.faces[v] = face.CollisionInfo
        end
        net.SendChunks("gzt_servernotifycollision", out, ply)
    end   
else
    -- ============================================================================================================================
    -- ============================================================================================================================
    -- ========================================================== CLIENT ==========================================================
    -- ============================================================================================================================
    -- ============================================================================================================================

    --Tell the server to make a new zone
    function GZT_WRAPPER:ClientMakeZone(zoneObj)
        net.Start("gzt_ClientMakeZone")
            net.WriteTable(zoneObj)
        net.SendToServer()
    end
    
    --Tell the server to update a zone 
    function GZT_WRAPPER:ClientUpdateZone(zoneObj)
        net.Start("gzt_ClientUpdateZone")
            net.WriteTable(zoneObj)
        net.SendToServer()
    end
    
    -- tell server to run specific function on the server's zone
    function GZT_WRAPPER:RemoteFunction(uuid, funcname, data)
        net.SendChunks("gzt_remotefunction", {uuid=uuid, funcName=funcname, data=data})
    end

    -- send uuid to server to delete a zone
    function GZT_WRAPPER:DeleteZone(uuid)
        net.Start("gzt_DeleteZone")
            net.WriteString(uuid)
        net.SendToServer()
    end

    -- Look up the zone entity with uuid on the Client
    function GZT_WRAPPER:ZoneEntityLookup(uuid)
        local zones = ents.FindByClass("gzt_zone")
        for k,v in pairs(zones) do
            if v:GetUuid() == uuid then
                return v
            end
        end
    end

    -- from net.SendChunks for ServerNotifyCollision
    -- tbl in form of {uuid, faces = {<ALL FACE ENUMS> = {CollisionClassList, CollisionClassListShouldCollide... etc}}}
    GZT_WRAPPER.gzt_zone_collision_storage = {}
    hook.Add("gzt_servernotifycollision", "_", function(tbl)
        -- put into (client) global storage for zone collision info so that it can apply when ready
        GZT_WRAPPER.gzt_zone_collision_storage[tbl.uuid] = tbl.faces 
        local zone = GZT_WRAPPER:ZoneEntityLookup(tbl.uuid)
        if(IsValid(zone)) then
            zone.NeedsCollisionUpdate = true
        end
    end)


end

function GZT_WRAPPER:toLocalSpace(pos1, pos2)
    pos1v, pos2v = Vector(pos1.x,pos1.y,pos1.z),Vector(pos2.x,pos2.y,pos2.z)
    local center = LerpVector(.5,pos1v, pos2v)
    return center, pos1v-center, pos2v-center
end
