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