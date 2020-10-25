AddCSLuaFile()

if SERVER then return end

CreateClientConVar("gzt_toolmode",1, false, true, "Current mode of the tool",1)
CreateClientConVar("gzt_selected_category_uuid","",false,true,"The UUID of the currently selected category for making zones")
CreateClientConVar("gzt_currently_editing_ent","", false, true, "UUID of the entity that is currently being edited")
