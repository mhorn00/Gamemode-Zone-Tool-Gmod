if CLIENT then return end

GZT_ZONEDEFS = {}
GZT_CATAGORYDEF = {}

GZT_LOADER = {}

util.AddNetworkString("gzt_getcatagories")

net.Receive("gzt_getcatagories", function(len, ply)
        net.Start("gzt_receivecatagories")
        net.WriteTable(GZT_CATAGORYDEF)
        net.Send(ply)
end)

function GZT_LOADER.LoadCatagories(gm, def)
    if(gm == nil) then
        //TODO: return an error
        return
    end
    --TODO: error checking and stuff
    GZT_CATAGORYDEF[gm] = def
end

function GZT_LOADER.LoadZoneDef(map, def)
    if(map==nil) then
        //TODO: return an error
        return 
    end
    GZT_ZONEDEFS[map] = def
end