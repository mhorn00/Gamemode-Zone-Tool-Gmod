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
    -- util.AddNetworkString("gzt_UpdateClientZones")
    util.AddNetworkString("gzt_UpdateClientCategory")
    util.AddNetworkString("gzt_returnclientzoneid")
    util.AddNetworkString("gzt_setrotation")
    util.AddNetworkString("gzt_deletezone")
    util.AddNetworkString("gzt_GivePlayersFaceTable")

    net.RateReceive("gzt_GetAllCategories", function(len, ply)
        net.SendChunks(net.ReadString(), GZT_WRAPPER:GetClientCategories(), ply)
    end)

    net.RateReceive("gzt_GetAllZones", function(len, ply)
        net.SendChunks(net.ReadString(),GZT_WRAPPER:GetClientZones(),ply)
    end)

    net.RateReceive("gzt_GetZoneByUUID", function(len, ply)
        net.Start(net.ReadString())
            net.WriteTable(copyNoFunctions(GZT_WRAPPER.gzt_zones[net.ReadString()]))
        net.Send(ply)
    end)

    net.RateReceive("gzt_ClientMakeZone", function(len, ply)
        local zoneObj = net.ReadTable()
        local myUuid = GZT_WRAPPER:MakeZone(zoneObj,ply)
        --GZT_WRAPPER:SendPlayerZoneCollision(myUuid)
        net.Start("gzt_returnclientzoneid")
            net.WriteString(myUuid)
        net.Send(ply)
    end)

    net.RateReceive("gzt_ClientUpdateZone", function(len, ply)
        local zoneObj = net.ReadTable()
        GZT_WRAPPER:UpdateZone(zoneObj.gzt_uuid, zoneObj, ply)
    end)

    net.RateReceive("gzt_GetCategoryByUUID", function(len,ply)
        net.Start(net.ReadString())
            net.WriteTable(copyNoFunctions(GZT_WRAPPER.gzt_categories[net.ReadString()]))
        net.Send(ply)
    end)
    
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
            net.Start("gzt_deleteFinished")
            net.Send(ply)
        else
            return
        end
    end)

    function GZT_WRAPPER:SendPlayerZoneCollision(uuid, ply)
        if uuid then
            local zone = self.gzt_zones[uuid].gzt_entity
            local combinedTable = {uuid=uuid, faces={}}
            for i,face_enum in pairs(FACE_ENUM_NAME) do
                local face = zone["Get"..face_enum](zone)--calls the get method for all the networked faces on the zone
                combinedTable.faces[face_enum] = {}
                combinedTable.faces[face_enum] = {CollisionClassListShouldCollide=face.CollisionClassListShouldCollide, CollisionClassList = face.CollisionClassList, CollisionTeamListShouldCollide = face.CollisionTeamListShouldCollide, CollisionTeamList = face.CollisionTeamList}
            end
            net.SendChunks("gzt_finishcollisionlookup", combinedTable, ply)--ply can be nil to send to everyone
        end
    end

    function GZT_WRAPPER:UpdateCollisions(uuid, face_enum, CCLSC, CCL, CTLSC, CTL)
        local zone = self.gzt_zones[uuid].gzt_entity
        -- check to see if parameters are nil, if they are, do not update corresponding value for the zone. if they are non-nil, update corresponding value :)
        local face = zone.Faces[face_enum] 
        face.CollisionClassListShouldCollide = CCLSC == nil and face.CollisionClassListShouldCollide or CCLSC
        face.CollisionClassList = CCL == nil and face.CollisionClassList or CCL
        face.CollisionTeamListShouldCollide = CTLSC == nil and face.CollisionTeamListShouldCollide or CTLSC 
        face.CollisionTeamList = CTL == nil and face.CollisionTeamList or CTL
        self:SendPlayerZoneCollision(uuid) -- update clients
    end

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


    function GZT_WRAPPER:UpdateZone(uuid, zoneObj, ply)
        if self.gzt_zones[uuid]==nil then
            net.Start("gzt_returnclientzoneid") --If the client trys to update a zone that doesnt exist on the server, we just remove the uuid the client has
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
        if zoneObj.gzt_pos1 && zoneObj.gzt_pos2 && zoneObj.gzt_center then
            local min, max = Vector(zoneObj.gzt_pos1),Vector(zoneObj.gzt_pos2)
            OrderVectors(min,max)
            zone:SetPos(zoneObj.gzt_center)
            zone:SetMinBound(min)
            zone:SetMaxBound(max)
            zone:SetupFaces()
        end
        self:SendPlayerZoneCollision(uuid)
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

    -- function GZT_WRAPPER:UpdateClientZone(zoneObj)
    --     net.Start("gzt_UpdateClientZones")
    --         net.WriteTable(copyNoFunctions(zoneObj))
    --     net.Broadcast()
    -- end
    
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
        if (GZT_WRAPPER.gzt_zones && GZT_WRAPPER.gzt_zones[uuid] && IsValid(GZT_WRAPPER.gzt_zones[uuid].gzt_entity)) then
            GZT_WRAPPER.gzt_zones[uuid].gzt_entity[funcName](GZT_WRAPPER.gzt_zones[uuid].gzt_entity,unpack(data))
        end
    end
    hook.Add("gzt_remotefunction", "gzt_remotefunctionhandler", RemoteFunction)
else 
    --CLIENT
    GZT_WRAPPER.gzt_client_table_info = {}

    function GZT_WRAPPER:SetFaceTableTemporarily(zoneUuid, facecollisiontable)
        print("Inserting ", zoneUuid)
        print(facecollisiontable)
        self.gzt_client_table_info[zoneUuid] = facecollisiontable
    end

    function GZT_WRAPPER:ApplyFaceCollisionToEntity(zone)
        local uuid = zone:GetUuid()
        print("Checking ", uuid)
        for i, face_name in pairs(FACE_ENUM_NAME) do
		    local face = zone["Get"..face_name](zone)
            local facetbl = self.gzt_client_table_info[uuid][face_name]
		    face.CollisionClassList = facetbl.CollisionClassList
		    face.CollisionClassListShouldCollide = facetbl.CollisionClassListShouldCollide
		    face.CollisionTeamList = facetbl.CollisionTeamList
		    face.CollisionTeamListShouldCollide = facetbl.CollisionTeamListShouldCollide
		    face:CollisionRulesChanged()
    	end
    end
    
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
            net.WriteTable(zoneObj)
        net.SendToServer()
    end
    
    function GZT_WRAPPER:ClientUpdateZone(zoneObj)
        net.Start("gzt_ClientUpdateZone")
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

    function GZT_WRAPPER:SetRotation(uuid,angle)
        net.Start("gzt_setrotation")
            net.WriteString(uuid)
            net.WriteAngle(angle)
        net.SendToServer()
    end

    function GZT_WRAPPER:RemoteFunction(uuid, funcname, data)
        net.SendChunks("gzt_remotefunction", {uuid=uuid, funcName=funcname, data=data})
    end

    function GZT_WRAPPER:DeleteZone(uuid)
        net.Start("gzt_deletezone")
            net.WriteString(uuid)
        net.SendToServer()
    end


    function GZT_WRAPPER:ZoneEntityLookup(uuid)
        local zones = ents.FindByClass("gzt_zone")
        for k,v in pairs(zones) do
            if v:GetUuid() == uuid then
                return v
            end
        end
        print("NO MATCH FOR ZONE WITH UUID",uuid)
    end
end

function GZT_WRAPPER:toLocalSpace(pos1, pos2)
    pos1v, pos2v = Vector(pos1.x,pos1.y,pos1.z),Vector(pos2.x,pos2.y,pos2.z)
    local center = LerpVector(.5,pos1v, pos2v)
    return center, pos1v-center, pos2v-center
end
