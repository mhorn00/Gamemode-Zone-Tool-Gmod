if CLIENT then return end

util.AddNetworkString("gzt_RequestZoneToolGun")

net.Receive("gzt_RequestZoneToolGun", function(len,ply)
    if(ply:IsAdmin()) then
        ply:Give("gzt_zonetool")
        ply:SelectWeapon("gzt_zonetool")
        -- coroutine.wait(.01)
    end
    net.Start("gzt_PlayerGivenZoneToolGun")
    net.Send(ply)
end)

concommand.Add("gzt_setpos", function(ply, cmd, args, str)
    ply:SetPos(Vector(args[1],args[2],args[3]))
end)