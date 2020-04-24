if CLIENT then return end

concommand.Add("gzt_setpos", function(ply, cmd, args, str)
    ply:SetPos(Vector(args[1],args[2],args[3]))
end)