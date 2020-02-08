if CLIENT then return end

local hookList = {--currently jsut ideas of what to implement
    onEnter = "onEnter",
    onExit = "onExit",
    onDie = "onDie",
    // TODO: Actually enumerate the list of functions when we have them
}

local reserved = {
    visible = {type="boolean", optional=true},
    color = {type="table",optional=true},
    displayName = {type="string",optional=true},
    parents = {type="table", optional=false},
    functions = {type="table", optional=true},
    maxZones = {type="number", optional=true},
    properties = {type="table",optional=true}, //TODO: makes sure these names arent used (specifical functions, properites, editable and loadedBy)
    editable = {type="boolean",optional=true},
    loadedBy = {type="string",optional=true}
}

function errorHandler(error)
    print(error)
end

function categoryFunctionProcessor(category)
    if category.functions == nil then
        category.functions = {}
    end
    if category.properties == nil then
        category.properties = {}
    end
    for functionName, func in pairs(category) do
        if type(func)=="function" then
            local added = false
            for hookName, str in pairs(hookList) do
                if(string.StartWith(functionName, hookName)) then
                    if category.functions[hookName] == nil then
                        category.functions[hookName] = {}
                    end
                    category.functions[hookName][string.Split(functionName,"_")[2]] = func //insert it into function table indexed by original name (after underscore)
                    added=true
                    category[functionName] = nil
                end
            end
            if !added then
                category.properties[functionName] = func
                category[functionName] = nil
            end
        end
    end
end

function categoryPropertyProcessor(cat)
    if cat.properties == nil then
        cat.properties = {}
    end
    for propertyName,prop in pairs(cat) do
        if type(prop) != "function" then
            if reserved[propertyName] == nil then
                cat.properties[propertyName] = prop
                cat[propertyName] = nil 
            end
        end
    end
end

function errorCheck(catName,cat) -- basic error check making sure that all of the right datatypes
    for k,v in pairs(reserved) do 
        if ((!cat[k] or type(cat[k])!=v.type) and !v.optional) then
            error("Invalid definition of category '"..catName.."': Invalid definition of '"..k.."', expected '"..v.type.."' got '"..type(cat[k]).."'")
        end
    end
end

function deepTypeCheck(t1, t2)
    local deepCheckViolation = true
    for property, value in pairs(t1) do
        if(value==t1 || t2[property]==t2) then
            error("Recursive tables are not supported")
        end
        if(t2[property]) then
            if(type(value)!=type(t2[property])) then
                return false
            end
            if(type(value)=='table') then
                deepCheckViolation = deepTypeCheck(t1[property],t2[property])
            end
        else
            return false
        end
    end
    return deepCheckViolation
end

function checkIfList(myList)
    for index,value in pairs(myList) do
        if(type(index)!=number) then
            return false
        end
    end
    error("You must give your list/array an index i.e.\n properties = {\"value1\",\"value2\",\"value3\"} -> properties={myList={\"value1\",\"value2\",\"value3\"}}")
    return true
end

function collisonDetectorAndHandler(gzt_cats, catName, cat)
    if(gzt_cats[catName]) then
        if deepTypeCheck(cat.properties, gzt_cats[catName].properties) then
            
        end
    else
        gzt_cats[catName] = cat
    end
end

function PostGamemodeLoaded()
    local GZT_CATS = {}
    if file.Exists(engine.ActiveGamemode().."/lua/gzt_defs/gzt_catdef.lua", "LUA") then --Looking for "<current gamemode>/lua/gzt_defs/gzt_catdef.lua"
        local GM_CATS = include(engine.ActiveGamemode().."/lua/gzt_defs/gzt_catdef.lua")
        for catName, cat in pairs(GM_CATS) do
            errorCheck(catName,cat)
            cat.loadedBy="GM"
            cat.editable = false
            categoryFunctionProcessor(cat)
            categoryPropertyProcessor(cat)
            collisonDetectorAndHandler(GZT_CATS, catName, cat)
        end
    end
    if file.Exists("gzt_defs/gzt_maps/"..engine.ActiveGamemode().."_"..game.GetMap().."_c.lua", "LUA") then
        local USERMAP_CATS = include("gzt_defs/gzt_maps/"..engine.ActiveGamemode().."_"..game.GetMap().."_c.lua")
        for catName, cat in pairs(USERMAP_CATS) do
            errorCheck(catName, cat)
            cat.loadedBy="USERMAP"
            categoryFunctionProcessor(cat)
            categoryPropertyProcessor(cat)
            collisonDetectorAndHandler(GZT_CATS, catName, cat)
        end
    end
    
    if file.Exists("gzt_maps/"..game.GetMap().."/"..engine.ActiveGamemode()..".txt", "DATA") then
        local SUCCESS, USER_CATS_FUNC = xpcall(CompileString, errorHandler, file.Read("gzt_maps/"..game.GetMap().."/"..engine.ActiveGamemode()..".txt"), "gzt_user_cat_loader", false)
        local USER_CATS = {}
        if(SUCCESS) then
            USER_CATS = USER_CATS_FUNC()
        end
        for catName, cat in pairs(USER_CATS) do
            errorCheck(catName, cat)
            cat.loadedBy="USER"
            categoryFunctionProcessor(cat)
            categoryPropertyProcessor(cat)
            collisonDetectorAndHandler(GZT_CATS, catName, cat)
        end
    end
end
hook.Add("PostGamemodeLoaded", "GZT_Loader_PostGamemodeLoaded", PostGamemodeLoaded)

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