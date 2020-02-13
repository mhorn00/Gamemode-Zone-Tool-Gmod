AddCSLuaFile()

if SERVER then return end

CreateClientConVar("gzt_is_paused", 0, false, true, "Is player currently paused, used for input proccesing (Dont Touch)",0,1)
CreateClientConVar("gzt_in_menu", 0, false, true, "Is player currently in the gzt GUI, used for input proccesing (Dont Touch)",0,1)

concommand.Add("gzt_toggle_gui", function()
    local firstTime = false
    if !GZT_GUI then
        GZT_GUI = vgui.Create("gzt_gui")
        firstTime = true
    end
    if GZT_GUI:IsVisible() && !firstTime then
        if ConVarExists("gzt_in_menu") then
            GetConVar("gzt_in_menu"):SetInt(0)
        end
        GZT_GUI:AlphaTo(0, 0.2, 0, function() GZT_GUI:SetVisible(false) end)
    else
        if ConVarExists("gzt_in_menu") then
            GetConVar("gzt_in_menu"):SetInt(1)
        end
        GZT_GUI:SetVisible(true)
        GZT_GUI:AlphaTo(255, 0.2)
    end
end)

concommand.Add("gzt_hide_gui", function()
    GZT_GUI:Hide()
end)

concommand.Add("gzt_kill_gui", function()
    local worldpanel = vgui.GetWorldPanel()
    for k,v in pairs(worldpanel:GetChildren()) do
        if(v:GetName()=="gzt_gui") then
            v:Remove()
            GZT_GUI = nil
        end
    end
    print("Killed gzt_gui")
end)