AddCSLuaFile()
GZT_ZONES = {
        unmadeZones = {},
        commitedZones = {}
    } 
if SERVER then  
    GZT_ZONELIST = { zones = {} }
    GZT_UNMADEZONELIST = { zones = {} }
    GZT_CATEGORYLIST = {categories = {}}
    --[[category example = {
        parents = {"Root","Parent1","Parent2"... etc},
        color = Color(255,0,0,255),
        events = {
            onEnter<Side> = function(ent)
        }
    } 
    ]]
    --[[Inheritance system example::
        cat = {parents="Root","Parent1",..etc}
        load zone:
        local originalCatFuncs = cat.events
        for pIndex,parent in pairs(cat.parents) do
            for funcIndex,func in pairs(parent.events)
                zone.events[funcIndex][#zone.events[funcIndex]+1]=GZT_ZONES:GetCategory(parent)[funcIndex]
            end
        end
        
        Root.events = {onEnter = function()},
                        {onShoot = function()}
        Parent1.events = {onEnter = function()}

        first iter: zone.events.onEnter = {Root.events.onEnter},
                    zone.events.onShoot = {Root.events.onShoot}
        second iter: zone.events.onEnter = {Root.events.onEnter, Parent1.events.onEnter},
                    zone.events.onShoot = {Root.events.onShoot}
    ]]
    util.AddNetworkString("gzt_RequestZone")
    util.AddNetworkString("gzt_GetAllZones")
    util.AddNetworkString("gzt_ZoneCommitSuccessful")
    util.AddNetworkString("gzt_RequestZoneInfo")
    util.AddNetworkString("gzt_getAllCategories")
    
    net.Receive("gzt_getAllCategories", function(len, ply)
        local callbackString = net.ReadString()
        local multiCallback = function()
            net.WriteTable(GZT_CATEGORYLIST)
            net.Send(ply)
        end
        net.SendMultiple({callbackString}, multiCallback)
    end)
    
    net.Receive("gzt_RequestZone", function(len,ply)
        local id = net.ReadString()
        if(IsValid(GZT_ZONELIST.zones[id])) then
            net.WriteEntity(GZT_ZONELIST.zones[id])
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
            -- GZT_ZONELIST:Push(unmadezone)
            GZT_ZONELIST[#GZT_ZONELIST+1] = unmadezone
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

    function GZT_ZONES:Push(zone)
        GZT_ZONELIST[#GZT_ZONELIST+1] = zone
    end

    function GZT_ZONES:Commit(zone, ply)
        local catagory = ply:GetInfo("GZT_SelectedCatagory")
        catagory = catagory and catagory or "Root"
        if(self.unmadeZones[zone.id]) then
            local id = zone.id
            local unmadezone = self.unmadeZones[id]
            self.unmadeZones[id] = nil
            self.commitedZones[id]=unmadezone
            self.commitedZones[id].catagory = catagory
            -- print("sending 2 player success")
            net.Start("gzt_ZoneCommitSuccessful")
                net.WriteString(id) // network this to client
            net.Send(ply)
        end
    end

    function GZT_ZONES:EditZone(id)
    end

    function GZT_ZONES:

    local random = math.random
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    local function uuidv4()
        local uuid, count = string.gsub(template, '[xy]', function (c)
                local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
                return string.format('%x', v)
            end)
        return uuid
    end
    
    function GM:PostGamemodeLoaded()
        // ok load categories!

    end

elseif CLIENT then
    function GZT_ZONES:GetZone(id)
        net.Start("gzt_RequestZone")
        net.WriteString(id)
        net.SendToServer()
    end

    function GZT_ZONES:GetAllZones() 
        net.Start("gzt_GetAllZones")   
        net.SendToServer()
    end

    function GZT_ZONES:GetAllCategories(callback)
        net.Start("gzt_getAllCategories")
            net.WriteString(callback)
        net.SendToServer()
    end
end