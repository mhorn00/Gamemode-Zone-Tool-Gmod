if CLIENT then return end

concommand.Add("gzt_setpos", function(ply, cmd, args, str)
    ply:SetPos(Vector(args[1],args[2],args[3]))
end)

concommand.Add("gzt_setang", function(ply, cmd, args, str)
    ply:SetEyeAngles(Angle(args[1],args[2],args[3]))
end)

concommand.Add("gzt_parentprop", function(ply, cmd, args, str)
    if CLIENT then return end
    local prop = ents.Create("prop_physics")
    prop:SetModel("models/props_c17/oildrum001.mdl")
    prop:SetPos(Vector(100,100,100))
    -- prop:SetAngles()
    prop:SetMoveParent(ply)
end)

concommand.Add("set_team", function( ply, cmd, args )
	local Team = args[1] or 1
	ply:SetTeam( Team )
	ply:Spawn()
end )