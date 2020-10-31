if CLIENT then return end

local hookList = {--currently just ideas of what to implement at a later date
    onEnter = "onEnter",
    onExit = "onExit",
    onDie = "onDie",
    // TODO: Actually enumerate the list of functions when we have them
}

local reservedCat = {
    gzt_visible = {type="boolean", optional=true, reserved=false},
    gzt_color = {type="table",optional=true, reserved=false},
    gzt_displayName = {type="string",optional=true, reserved=false},
    gzt_parents = {type="table", optional=false, reserved=false},
    gzt_functions = {type="table", optional=true, reserved=true},
    gzt_maxZones = {type="number", optional=true, reserved=false},
    gzt_properties = {type="table",optional=true, reserved=true},
    gzt_editable = {type="boolean",optional=true, reserved=true},
    gzt_loadedBy = {type="string",optional=true, reserved=true},
    gzt_uuid = {type="string",optional=true, reserved=true}
}

local reservedZone = {
    gzt_visible = {type="boolean", optional=true, reserved=false},
    gzt_color = {type="table",optional=true, reserved=false},
    gzt_parent = {type="string", optional=false, reserved=false},
    gzt_functions = {type="table", optional=true, reserved=true},
    gzt_properties = {type="table",optional=true, reserved=true},
    gzt_editable = {type="boolean",optional=true, reserved=true},
    gzt_loadedBy = {type="string",optional=true, reserved=true},
    gzt_cornerdist = {type="table",optional=false,reserved=false},
    gzt_center = {type="table",optional=false,reserved=false},
    gzt_angle = {type="table",optional=false,reserved=false},
    gzt_uuid = {type="string",optional=true, reserved=true}
}

function errorHandler(error)
    print(error)
end

local random = math.random
local function MakeUuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

function listJoin(givenList,joiner, startIndex, endIndex )
    local ret = ""
    startIndex = startIndex and startIndex or 1
    endIndex = endIndex and endIndex or #givenList
    if(#givenList==1) then
        error("You must name your function i.e. function "..givenList[1].."_main()")
    end
    for k,v in pairs(givenList) do
        if(type(k)!="number") then
            error("List join requires that the given table is a list that is indexed by numbers")
        else
            if(k>=startIndex && k<=endIndex) then
                ret = ret..v..(k==endIndex and "" or joiner)
            end
        end
    end
    return ret
end

function FunctionProcessor(category)
    if category.gzt_functions == nil then
        category.gzt_functions = {}
    end
    if category.gzt_properties == nil then
        category.gzt_properties = {}
    end
    for functionName, func in pairs(category) do
        if type(func)=="function" then
            local added = false
            for hookName, str in pairs(hookList) do
                if(string.StartWith(functionName, hookName)) then
                    if category.gzt_functions[hookName] == nil then
                        category.gzt_functions[hookName] = {}
                    end
                    category.gzt_functions[hookName][listJoin(string.Split(functionName,"_"),"_",2)] = func //insert it into function table indexed by original name (after underscore)
                    added=true
                    category[functionName] = nil
                end
            end
            if !added then
                category.gzt_properties[functionName] = func
                category[functionName] = nil
            end
        end
    end
end

function PropertyProcessor(cat,isZone)
    if cat.properties == nil then
        cat.gzt_properties = {}
    end
    local reserved = {}
    if(isZone) then
        reserved = reservedZone
    else
        reserved = reservedCat
    end
    for propertyName,prop in pairs(cat) do
        if type(prop) != "function" then
            if reserved[propertyName] == nil then
                cat.gzt_properties[propertyName] = prop
                cat[propertyName] = nil 
            end
        end
    end
end

function errorCheck(catName,cat, isZone) -- basic error check making sure that all reserved props are the right datatypes
    isZone = isZone and isZone or false
    local reserved = {}
    local errStringTypeName= ""
    if(isZone) then
        reserved = reservedZone
        errStringTypeName="zone"
    else
        reserved = reservedCat
        errStringTypeName="category"
    end
    for k,v in pairs(reserved) do 
        if ((!cat[k] || type(cat[k])!=v.type) && !v.optional) then
            error("Invalid definition of "..errStringTypeName.." '"..catName.."': Invalid definition of '"..k.."', expected '"..v.type.."' got '"..type(cat[k]).."'")
        end
        if(cat[k] && v.reserved) then
            error("Invalid definition of "..errStringTypeName.." '"..catName.."': Reserved property '"..k.."' is defined when that is for Gamemode Zonetool internal use. Please rename it!")
        end
    end
end

function deepTypeCheck(t1, t2)
    local deepCheckSafe = true
    local propertyName = nil 
    local v1 = nil
    local v2 = nil
    for property, value in pairs(t1) do
        if(t2[property]) then
            if(type(value)!=type(t2[property])) then
                return false, property, value, t2[property]
            end
            if(type(value)=='table') then
                deepCheckSafe, propertyName, v1, v2 = deepTypeCheck(t1[property],t2[property])
            end
        end
    end
    return deepCheckSafe, propertyName, v1, v2
end

function deepMerge(t1, t2, catName)
    local deepMergeSuccess = true
    for property, value in pairs(t2) do
        if(!string.EndsWith(property,"_IMMUTABLE")&&type(value)!="table") then
            t1[property] = value
        elseif(type(value)=="table") then
            if(!t1[property]) then
                t1[property] = {}
            end
            deepMergeSuccess = deepMerge(t1[property], t2[property])
        elseif(string.EndsWith(property,"_IMMUTABLE")) then
            error("Attempted to mutate immutable property in category '"..catName.."' on property '".. property.."'")
            return false
        end
    end
    return deepMergeSuccess
end

function checkIfList(cat)
    for propName,prop in pairs(cat.gzt_properties) do
        if type(prop)=="table" then
            for index,value in pairs(prop) do
                if(type(index)==number) then
                    error("You must give your list/array an index i.e.\n properties = {\"value1\",\"value2\",\"value3\"} -> properties={myList={\"value1\",\"value2\",\"value3\"}}")
                end
            end
        end
    end
end

function collisonDetectorAndHandler(gzt_table, name, obj, isZone)
    if(gzt_table[name]) then
        if(obj.overwrite != true) then
            if(isZone) then
                print("[Gamemode Zone Tool] WARNING: Overwriting zone "..name.." that already existed. Did you mean to do this?\n")
            else
                print("[Gamemode Zone Tool] WARNING: Overwriting category "..name.." that already existed. Did you mean to do this?\n")
            end
        end
        local deepCheck,propName,prop1,prop2 = deepTypeCheck(gzt_table[name].gzt_properties, obj.gzt_properties)
        if deepCheck then
            deepMerge(gzt_table[name], obj, name)
        else
            error("Mismatched type on property '"..propName.."' of objegory '"..name.."' on merge ("..type(prop1).." expected, got "..type(prop2)..")")
        end
    else
        gzt_table[name] = obj
    end
end

function PostGamemodeLoaded()
    local GZT_CATS = {}
    local GZT_ZONES = {}
    local gm_zones_file = ""
    local gm_categories_file = ""
    local map_zones_file = ""
    local map_categories_file = ""
    if file.Exists(engine.ActiveGamemode().."/lua/gzt_defs/gzt_catdef.lua", "LUA") then --Looking for "<current gamemode>/lua/gzt_defs/gzt_catdef.lua"
        local GM_CATS = include(engine.ActiveGamemode().."/lua/gzt_defs/gzt_catdef.lua")
        local gm_categories_file = file.Read(engine.ActiveGamemode().."/lua/gzt_defs/gzt_catdef.lua")
        for catName, cat in pairs(GM_CATS) do
            errorCheck(catName,cat)
            cat.gzt_loadedBy="GM"
            cat.gzt_editable = false
            cat.gzt_uuid = MakeUuid()
            FunctionProcessor(cat)
            PropertyProcessor(cat,false)
            checkIfList(cat)
            collisonDetectorAndHandler(GZT_CATS, catName, cat, false)
        end
    end
    if file.Exists("gzt_defs/gzt_maps/"..game.GetMap().."/"..engine.ActiveGamemode().."/gzt_catdef.lua", "LUA") then
        local USERMAP_CATS = include("gzt_defs/gzt_maps/"..game.GetMap().."/"..engine.ActiveGamemode().."/gzt_catdef.lua")
        local map_categories_file = file.Read("gzt_defs/gzt_maps/"..game.GetMap().."/"..engine.ActiveGamemode().."/gzt_catdef.lua")
        for catName, cat in pairs(USERMAP_CATS) do
            errorCheck(catName, cat)
            cat.gzt_loadedBy="USERMAP"
            cat.gzt_uuid = MakeUuid()
            FunctionProcessor(cat)
            PropertyProcessor(cat,false)
            checkIfList(cat)
            collisonDetectorAndHandler(GZT_CATS, catName, cat, false)
        end
    end
    
    if file.Exists("gzt_maps/"..game.GetMap().."/"..engine.ActiveGamemode().."_c.txt", "DATA") then
        local SUCCESS, USER_CATS_FUNC, err = xpcall(CompileString, errorHandler, file.Read("gzt_maps/"..game.GetMap().."/"..engine.ActiveGamemode().."_c.txt"), "gzt_user_cat_loader", false)
        local USER_CATS = {}
        if(SUCCESS && USER_CATS_FUNC!=nil) then
            USER_CATS = USER_CATS_FUNC()
        else
            print(err)
        end
        for catName, cat in pairs(USER_CATS) do
            errorCheck(catName, cat)
            cat.gzt_loadedBy="USER"
            cat.gzt_uuid = MakeUuid()
            FunctionProcessor(cat)
            PropertyProcessor(cat,false)
            checkIfList(cat)
            collisonDetectorAndHandler(GZT_CATS, catName, cat, false)
        end
    end
    --[[
        LOAD ZONES!
    ]]

    if file.Exists(engine.ActiveGamemode().."/lua/gzt_defs/gzt_maps/"..game.GetMap()..".lua", "LUA") then --Looking for "<current gamemode>/lua/gzt_defs/gzt_maps/<current map>"
        local GM_ZONES = include(engine.ActiveGamemode().."/lua/gzt_defs/gzt_maps/"..game.GetMap()..".lua")
        gm_zones_file = file.Read(engine.ActiveGamemode().."/lua/gzt_defs/gzt_maps/"..game.GetMap()..".lua")
        for zoneId, zone in pairs(GM_ZONES) do
            errorCheck(zoneId,zone, true)
            zone.gzt_loadedBy="GM"
            zone.gzt_editable = false
            zone.gzt_uuid = MakeUuid()
            FunctionProcessor(zone)
            PropertyProcessor(zone,true)
            checkIfList(zone)
            collisonDetectorAndHandler(GZT_ZONES, zoneId, zone, true)
        end
    end
    if file.Exists("gzt_defs/gzt_maps/"..game.GetMap().."/"..engine.ActiveGamemode().."/gzt_zonedef.lua", "LUA") then
        local USERMAP_ZONES = include("gzt_defs/gzt_maps/"..game.GetMap().."/"..engine.ActiveGamemode().."/gzt_zonedef.lua")
        local map_zones_file = file.Read("gzt_defs/gzt_maps/"..game.GetMap().."/"..engine.ActiveGamemode().."/gzt_zonedef.lua")
        for zoneId, zone in pairs(USERMAP_ZONES) do
            errorCheck(zoneId, zone, true)
            zone.gzt_loadedBy="USERMAP"
            zone.gzt_uuid = MakeUuid()
            FunctionProcessor(zone)
            PropertyProcessor(zone,true)
            checkIfList(zone)
            collisonDetectorAndHandler(GZT_ZONES, zoneId, zone, true)
        end
    end
    
    if file.Exists("gzt_maps/"..game.GetMap().."/"..engine.ActiveGamemode().."_z.txt", "DATA") then
        local SUCCESS, USER_ZONE_FUNC, err = xpcall(CompileString, errorHandler, file.Read("gzt_maps/"..game.GetMap().."/"..engine.ActiveGamemode().."_z.txt"), "gzt_user_zone_loader", false)
        local USER_ZONES = {}
        if(SUCCESS && USER_ZONE_FUNC!=nil) then
            USER_ZONES = USER_ZONE_FUNC()
        else
            print(err)
        end
        for zoneId, zone in pairs(USER_ZONES) do
            errorCheck(zoneId, zone, true)
            zone.gzt_loadedBy="USER"
            zone.gzt_uuid = MakeUuid()
            FunctionProcessor(zone)
            PropertyProcessor(zone,true)
            checkIfList(zone)
            collisonDetectorAndHandler(GZT_ZONES, zoneId, zone, true)
        end
    end
    for k,v in pairs(GZT_ZONES) do
        transform_zone_corners(v)
    end
    

    GZT_WRAPPER:SetCategories(GZT_CATS)
    GZT_WRAPPER:SetZones(GZT_ZONES)
    GZT_WRAPPER.gzt_gm_zones_file = gm_zones_file
    GZT_WRAPPER.gzt_gm_categories_file = gm_categories_file
    GZT_WRAPPER.gzt_map_zones_file = map_zones_file
    GZT_WRAPPER.gzt_map_categories_file = map_categories_file
end
hook.Add("PostGamemodeLoaded", "GZT_Loader_PostGamemodeLoaded", PostGamemodeLoaded)

function transform_zone_corners(zone)
    local center = Vector(zone.gzt_center.x,zone.gzt_center.y,zone.gzt_center.z)
    local corner_dist = Vector(zone.gzt_cornerdist.x,zone.gzt_cornerdist.y,zone.gzt_cornerdist.z)
    local opposite = corner_dist * -1
    zone.gzt_pos1 = corner_dist
    zone.gzt_pos2 = opposite
    zone.gzt_cornerdist = nil
end
--[[
    Load order
    1. Gamemode cateories
    2. User Catagories 
    3. TODO: Gamemode Zones
    4. TODO: User Zones
]]

--[[
    Property collions between load hiarchy or categories:
    if 2 properties have same type and same name when loaded from different sources (ie property t from gamemode and property t from user)
        property with highest specificity takes precidence in order of USER > MAP > GAMEMODE
    if 2 properties have diffent type and same name when loaded from different sources 
        throw an error
]]