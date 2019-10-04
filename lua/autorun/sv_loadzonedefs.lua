if CLIENT then return end

//local GZT_ZONEDEF_FILELIST = {}
GZT_ZONEDEFS = {}
GZT_CATAGORYDEF = {}

-- function SearchForGZTZonedef(dir, depth)
--     //print("checking recursively ", dir)
--     -- if(string.find(dir, "dummy")) then
--     --     print(dir)
--     -- end
--     if(depth>10) then
--         return false
--     end
--     local rfiles, rdirs = file.Find(dir.."/*", "THIRDPARTY")
--     for k,v in pairs(rfiles) do
--         //print(v)
--         if(v == "gzt_zonedef.lua") then
--             GZT_ZONEDEF_FILELIST[#GZT_ZONEDEF_FILELIST+1] = {path=dir.."/"..v, gm = ""}
--         end 
--     end
--     //print("searching directories within "..dir)
--     for k,v in pairs(rdirs) do
--         SearchForGZTZonedef(dir.."/"..v, depth+1)
--     end
-- end


-- local files, dirs = file.Find("*", "THIRDPARTY")
-- if(files) then
--     for k,v in pairs(dirs) do
--         SearchForGZTZonedef(v, 0)
--     end
-- end 

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

    GZT_CATAGORYDEF[gm] = def
    //print("CATAGORY DEF WHEN LOADING.. ")
    //PrintTable(GZT_CATAGORYDEF)
end

function GZT_LOADER.LoadZoneDef(map, def)
    if(map==nil) then
        //TODO: return an error
        return 
    end
    GZT_ZONEDEFS[map] = def
end