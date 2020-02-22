AddCSLuaFile()

if SERVER then return end

CreateClientConVar("gzt_is_paused", 0, false, true, "Is player currently paused, used for input proccesing (Dont Touch)",0,1)
CreateClientConVar("gzt_in_menu", 0, false, true, "Is player currently in the gzt GUI, used for input proccesing (Dont Touch)",0,1)
CreateClientConVar("gzt_toolmode",1, false, true, "Current mode of the tool",1)
CreateClientConVar("gzt_selected_category_uuid","",false,true,"The UUID of the currently selected category for making zones")
CreateClientConVar("gzt_currently_editing_ent","", false, true, "UUID of the entity that is currently being edited")

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
        GZT_GUI.BasePanel.TabPane:SwitchToName(GZT_ZONETOOL.ModeList[GetConVar("gzt_toolmode"):GetInt()])
        if !GZT_GUI.BasePanel.TabPane.CreateTab.populated then 
            GZT_GUI.BasePanel.TabPane.CreateTab:GetCategories()
        end
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