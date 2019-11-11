if CLIENT then return end

GZT_ZONES = {unmadeZones = {},
            commitedZones = {}}

GZT_ZONELIST = { zones = {}}
GZT_UNMADEZONELIST = { zones = {}}

util.AddNetworkString("gzt_RequestZone")
util.AddNetworkString("gzt_GetAllZones")
util.AddNetworkString("gzt_ZoneCommitSuccessful")
util.AddNetworkString("gzt_RequestZoneInfo")

net.Receive("gzt_RequestZone", function(len,ply)
    local id = net.ReadString()
    if(GZT_ZONELIST.zones[id]) then
        net.WriteTable(GZT_ZONELIST.zones[id])
        net.Send(ply)
    end
end)

net.Receive("gzt_GetAllZones", function(len, ply)
    net.WriteTable(GZT_ZONES.commitedZones)
    net.Send(ply)
end)

net.Receive("gzt_AddZone", function(len, ply)
    local id = net.ReadString()
    if(GZT_UNMADEZONELIST.zones[id]) then
        local unmadezone = GZT_UNMADEZONELIST.zones[id]
        GZT_UNMADEZONELIST.zones[id] = nil
        GZT_ZONELIST:Push(unmadezone)
    end
end)

net.Receive("gzt_EditZone", function(len, ply)
    local id = net.ReadString()
    ply:GetActiveWeapon():SetMode(ply:GetActiveWeapon().Modes.Edit)
    ply:GetActiveWeapon().CurrentBox.Ent = nil
    ply:GetActiveWeapon().CurrentBox.Ent = GZT_ZONES.commitedZones[id]
end)

net.Receive("gzt_RequestZoneInfo", function(len, ply)
    local id = net.ReadString()
    local reqTag = net.ReadString()
    local callback_string = net.ReadString()
    local data = nil
    if(!GZT_ZONELIST[id] || !GZT_ZONELIST[id][reqTag] ) then
        data = "NULL"
    else
        data = GZT_ZONELIST[id][reqTag]
    end
    net.Start(callback_string)
    if(type(data) == "table") then
        net.WriteTable(data)
    else
        net.WriteString(tostring(data))
    end
    net.Send(ply)
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
        print("sending 2 player success")
        net.Start("gzt_ZoneCommitSuccessful")
            net.WriteString(id)
        net.Send(ply)
        // network this to client
    else
        print("not in unmade zones ==========")
        print(zone.id)
        PrintTable(self.unmadeZones)
    end
end

function GZT_ZONES:EditZone(id)
   
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