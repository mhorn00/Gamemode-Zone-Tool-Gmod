AddCSLuaFile()

GZT_INFO_WRAPPER = {
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

    net.Receive("gzt_GetAllCategories", function(len, ply)
        net.Start(net.ReadString())
            net.WriteTable(GZT_INFO_WRAPPER:GetClientCategories())
        net.Send(ply)
    end)

    function GZT_INFO_WRAPPER:GetClientCategories()
        return copyNoFunctions(self.gzt_categories)
    end

    function GZT_INFO_WRAPPER:SetCategories(cats)
        self.gzt_categories = cats
    end

    function GZT_INFO_WRAPPER:SetZones(zones)
        self.gzt_zones=zones
    end

    function GZT_INFO_WRAPPER:InitZones()  
        for k,v in pairs(self.gzt_zones) do
            self.gzt_zones[k].gzt_entity = self:MakeZone(v)
        end
    end

    function GZT_INFO_WRAPPER:MakeZone(zoneObj)
        local curZone = ents.Create("gzt_zone")
        local pos1 = Vector(zoneObj.gzt_pos1.x,zoneObj.gzt_pos1.y,zoneObj.gzt_pos1.z)
        local pos2 = Vector(zoneObj.gzt_pos2.x,zoneObj.gzt_pos2.y,zoneObj.gzt_pos2.z)

        curZone:Setup(pos1, pos2, zoneObj.gzt_angle)
        curZone:Spawn()
        return curZone
    end

    function InitPostEntity()
        GZT_INFO_WRAPPER:InitZones()
    end
    hook.Add("InitPostEntity", "GZT_BeforeLoadEntities", InitPostEntity)
    
else --CLIENT
    function GZT_INFO_WRAPPER:GetAllZones()

    end

    function GZT_INFO_WRAPPER:GetZone(zoneName)

    end

    function GZT_INFO_WRAPPER:GetZoneUUID(id)

    end
    
    function GZT_INFO_WRAPPER:GetAllCategories(callback)
        net.Start("gzt_GetAllCategories")
            net.WriteString(callback)
        net.SendToServer()
    end
end

