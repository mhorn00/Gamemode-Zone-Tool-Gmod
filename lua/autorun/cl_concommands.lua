AddCSLuaFile()



if SERVER then 
    util.AddNetworkString("gzt_PlayerGivenZoneToolGun")
    return 
end

net.Receive("gzt_PlayerGivenZoneToolGun", function(ply, len)
    if(LocalPlayer():GetActiveWeapon():GetClass()=="gzt_zonetool") then
        LocalPlayer():ConCommand("gzt_toggle_gui")
    else
        LocalPlayer():ChatPrint("Could not give you the zone tool weapon. Missing permissions?")
        LocalPlayer():ChatPrint(LocalPlayer():GetActiveWeapon():GetClass())
    end
end)

concommand.Add("gzt_toggle_gui", function()
    print("gzt toggle gui")
    if(LocalPlayer():GetActiveWeapon():GetClass()=="gzt_zonetool") then
        print(GZT_PANEL)
        if(!GZT_PANEL) then
            GZT_PANEL = vgui.Create("gzt_gui")
        end
        GZT_PANEL:SetVisible(true)
        GZT_PANEL:SetToolRef(LocalPlayer():GetActiveWeapon())
        GZT_PANEL:PopulateUI()
    else
        net.Start("gzt_RequestZoneToolGun")
        net.SendToServer()
    end
end)

concommand.Add("gzt_hide_gui", function()
    GZT_PANEL:Hide()
end)

concommand.Add("gzt_kill_gui", function()
    local worldpanel = vgui.GetWorldPanel()
    for k,v in pairs(worldpanel:GetChildren()) do
        if(v:GetName()=="gzt_gui") then
            v:Remove()
            GZT_PANEL = nil
        end
    end
end)