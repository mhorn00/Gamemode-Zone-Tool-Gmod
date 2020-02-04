if CLIENT then return end

function PostGamemodeLoaded()
    local GM_CATS = include(engine.ActiveGamemode().."/lua/gzt_defs/gzt_catdef.lua")
    GM_CATS["Spawn"].func()
    GM_CATS["Spawn"].Test()
    -- local mapZones = include("gzt_maps/"..game.GetMap()..".lua")
end
hook.Add("PostGamemodeLoaded", "GZT_Loader_PostGamemodeLoaded", PostGamemodeLoaded)

--[[
    Load order
    1. Gamemode catagories
    2. TODO: User Catagories 
    3. TODO: Gamemode Zones
    4. TODO: User Zones
]]