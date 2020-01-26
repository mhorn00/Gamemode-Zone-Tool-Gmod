AddCSLuaFile()

if SERVER then return end

concommand.Add("gzt_toggle_gui", function()
    print(GZT_PANEL)
    if(!GZT_PANEL) then
        GZT_PANEL = vgui.Create("gzt_gui")
    end
    GZT_PANEL:SetVisible(true)
    GZT_PANEL:SetToolRef(LocalPlayer():GetActiveWeapon())
    GZT_PANEL:PopulateUI()
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