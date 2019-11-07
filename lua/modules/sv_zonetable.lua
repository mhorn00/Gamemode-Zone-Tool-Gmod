if CLIENT then return end

GZT_ZONES = {unmadeZones = {},
            commitedZones = {}}

GZT_ZONELIST = { zones = {}}
GZT_UNMADEZONELIST = { zones = {}}

util.AddNetworkString("RequestZone")
util.AddNetworkString("GetAllZones")

net.Receive("RequestZone", function(len,ply)
    local id = net.ReadString()
    if(GZT_ZONELIST.zones[id]) then
        net.WriteTable(GZT_ZONELIST.zones[id])
        net.Send(ply)
    end
end)

net.Receive("GetAllZones", function(len, ply)
    net.WriteTable(GZT_ZONELIST.zones)
    net.Send(ply)
end)

net.Receive("AddZone", function(len, ply)
    local id = net.ReadString()
    if(GZT_UNMADEZONELIST.zones[id]) then
        local unmadezone = GZT_UNMADEZONELIST.zones[id]
        GZT_UNMADEZONELIST.zones[id] = nil
        GZT_ZONELIST:Push(unmadezone)
    end
end)

local random = math.random
local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
local function uuidv4()
    local uuid, count = string.gsub(template, '[xy]', function (c)
            local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
            return string.format('%x', v)
        end)
    return uuid
end

function GZT_ZONES:Commit(zone, ply)
    local catagory = ply:GetInfo("GZT_SelectedCatagory")
    print("CATAGORY", catagory)
    catagory = catagory and catagory or "Root"
    if(self.unmadeZones[zone.id]) then
        print("putting into commited =======")
        local id = zone.id
        local unmadezone = self.unmadeZones[id]
        self.unmadeZones[id] = nil
        self.commitedZones[id]=unmadezone

        self.commitedZones[id].catagory = catagory
    else
        print("not in unmade zones ==========")
        print(zone.id)
        PrintTable(self.unmadeZones)
    end
end

-- function self:Push(zone) 
--     local id = uuidv4()
--     GZT_ZONELIST[id] = zone
--     zone.id = id
-- end

function GZT_ZONES:Push(zone) 
    local id = uuidv4()
    self.unmadeZones[id] = zone
    zone.id = id
    -- print("===============")
    -- PrintTable(self.unmadeZones)
end