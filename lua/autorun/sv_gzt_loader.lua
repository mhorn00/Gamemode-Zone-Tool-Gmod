if CLIENT then return end

local hookList = {--currently just ideas of what to implement at a later date
    onEnter = "onEnter",
    onExit = "onExit",
    onDie = "onDie",
    // TODO: Actually enumerate the list of functions when we have them
}

local reserved = {
    gzt_visible = {type="boolean", optional=true},
    gzt_color = {type="table",optional=true},
    gzt_displayName = {type="string",optional=true},
    gzt_parents = {type="table", optional=false},
    gzt_functions = {type="table", optional=true},
    gzt_maxZones = {type="number", optional=true},
    gzt_properties = {type="table",optional=true}, //TODO: makes sure these names arent used (specificaly: functions, properites, editable, and loadedBy)
    gzt_editable = {type="boolean",optional=true},
    gzt_loadedBy = {type="string",optional=true}
}

function errorHandler(error)
    print(error)
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

print(listJoin({"onEnter","main"},"_",2))

function categoryFunctionProcessor(category)
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

function categoryPropertyProcessor(cat)
    if cat.properties == nil then
        cat.gzt_properties = {}
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

function errorCheck(catName,cat) -- basic error check making sure that all reserved props are the right datatypes
    //TODO: makes sure our reserved words arent used already
    for k,v in pairs(reserved) do 
        if ((!cat[k] or type(cat[k])!=v.type) and !v.optional) then
            print(cat[k])
            error("Invalid definition of category '"..catName.."': Invalid definition of '"..k.."', expected '"..v.type.."' got '"..type(cat[k]).."'")
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

function collisonDetectorAndHandler(gzt_cats, catName, cat)
    if(gzt_cats[catName]) then
        local deepCheck,propName,prop1,prop2 = deepTypeCheck(gzt_cats[catName].gzt_properties, cat.gzt_properties)
        if deepCheck then
            deepMerge(gzt_cats[catName], cat, catName)
        else
            error("Mismatched type on property '"..propName.."' of category '"..catName.."' on merge ("..type(prop1).." expected, got "..type(prop2)..")")
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
            cat.gzt_loadedBy="GM"
            cat.gzt_editable = false
            categoryFunctionProcessor(cat)
            categoryPropertyProcessor(cat)
            checkIfList(cat)
            collisonDetectorAndHandler(GZT_CATS, catName, cat)
        end
    end
    if file.Exists("gzt_defs/gzt_maps/"..engine.ActiveGamemode().."_"..game.GetMap().."_c.lua", "LUA") then
        local USERMAP_CATS = include("gzt_defs/gzt_maps/"..engine.ActiveGamemode().."_"..game.GetMap().."_c.lua")
        for catName, cat in pairs(USERMAP_CATS) do
            errorCheck(catName, cat)
            cat.gzt_loadedBy="USERMAP"
            categoryFunctionProcessor(cat)
            categoryPropertyProcessor(cat)
            checkIfList(cat)
            collisonDetectorAndHandler(GZT_CATS, catName, cat)
        end
    end
    
    if file.Exists("gzt_maps/"..game.GetMap().."/"..engine.ActiveGamemode()..".txt", "DATA") then
        local SUCCESS, USER_CATS_FUNC, err = xpcall(CompileString, errorHandler, file.Read("gzt_maps/"..game.GetMap().."/"..engine.ActiveGamemode()..".txt"), "gzt_user_cat_loader", false)
        local USER_CATS = {}
        if(SUCCESS && USER_CATS_FUNC!=nil) then
            USER_CATS = USER_CATS_FUNC()
        else
            print(err)
        end
        for catName, cat in pairs(USER_CATS) do
            errorCheck(catName, cat)
            cat.gzt_loadedBy="USER"
            categoryFunctionProcessor(cat)
            categoryPropertyProcessor(cat)
            checkIfList(cat)
            collisonDetectorAndHandler(GZT_CATS, catName, cat)
        end
    end
    PrintTable(GZT_CATS)
    GZT_CATS.gmC1C1.gzt_functions.onExit:main()
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