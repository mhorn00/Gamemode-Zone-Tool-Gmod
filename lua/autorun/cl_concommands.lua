AddCSLuaFile()

if SERVER then return end

concommand.Add("gzt_toggle_gui", function()
    if !GZT_GUI then
        GZT_GUI = vgui.Create("gzt_gui")
    end
    if GZT_GUI:IsVisible() then
        GZT_GUI:SetVisible(false)
    else
        GZT_GUI:SetVisible(true)
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