if CLIENT then return end

GZT_ZONEDEFS = {}
GZT_CATEGORYDEF = {}

GZT_LOADER = {}

function GZT_LOADER.LoadCategories(gm, def)
    if(gm == nil) then
        //TODO: return an error
        return
    end
    --TODO: error checking and stuff
    -- GZT_CATEGORYDEFS[gm] = def
    GZT_CATEGORYLIST.categories = def
end

function GZT_LOADER.LoadZoneDef(map, def)
    if(map==nil) then
        //TODO: return an error
        return 
    end
    GZT_ZONEDEFS[map] = def
end

function ReloadZonesAfterCleanup()
    // TODO
end

hook.Add("PostCleanupMap", "GZT_ReloadZonesAfterCleanup", ReloadZonesAfterCleanup)

-- function GM:PreGamemodeLoaded()

-- end

-- {
--     {name="Zone 1",
--     type="Catagory",
--     OnEnter="OnEnter"},
-- }
-- GZT_FUNCTIONS[type][OnEnter]

-- GZT_FUNCTIONS = {
--     Catagory = {
--         OnEnter = function(zone, ply, pos)

--         end
--     }
-- }