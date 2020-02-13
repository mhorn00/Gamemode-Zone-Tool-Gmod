AddCSLuaFile()
GZT_INFO_WRAPPER = {}
local gzt_categories = {}
local gzt_zones = {}

if SERVER then 
    function GZT_INFO_WRAPPER:SetCategories(cats)
        gzt_categories = cats
    end

    function GZT_INFO_WRAPPER:SetZones(zones)
        gzt_zones=zones
    end

    function GZT_INFO_WRAPPER:InitZones()  
        print("Making Zones")
        PrintTable(gzt_zones)
        for k,v in pairs(gzt_zones) do
            local curZone = ents.Create("gzt_zone")
            curZone:Setup(Vector(gzt_zones[k].gzt_pos1.x,gzt_zones[k].gzt_pos1.y,gzt_zones[k].gzt_pos1.z), Vector(gzt_zones[k].gzt_pos2.x,gzt_zones[k].gzt_pos2.y,gzt_zones[k].gzt_pos2.z), gzt_zones[k].gzt_angle)
            curZone:Spawn()
            gzt_zones[k].entity = curZone

        end
    end

    function InitPostEntity()
        GZT_INFO_WRAPPER:InitZones()
    end
    hook.Add("InitPostEntity", "GZT_BeforeLoadEntities", InitPostEntity)

else
    function GZT_INFO_WRAPPER:GetAllZones()

    end

    function GZT_INFO_WRAPPER:GetZone(zoneName)

    end

    function GZT_INFO_WRAPPER:GetZoneUUID(id)

    end
    
end

