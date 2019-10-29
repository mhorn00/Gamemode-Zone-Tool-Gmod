ZONETABLE = {}

util.AddNetworkString("RequestZone")
util.AddNetworkString("GetAllZones")

net.Receive("RequestZone", function(len,ply)
    local id = net.ReadString()
    if(ZONETABLE[id]) then
        net.WriteTable(ZONETABLE[id])
        net.Send(ply)
    end
end)

net.Receive("GetAllZones", function(len, ply)
    net.WriteTable(ZONETABLE)
    net.Send(ply)
end)