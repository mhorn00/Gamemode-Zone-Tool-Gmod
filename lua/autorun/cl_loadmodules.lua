--AddCSLuaFile()

if SERVER then return end

include("modules/util/multicallback.lua")
include("modules/gzt_info_wrapper.lua")
include("modules/cl_gui/gzt_gui.lua")

-- function BuildTree(gzt_cats)
--     local categoriesObj = {}
--     for k,v in pairs(gzt_cats) do
--         local curCat = v
--         local curParentRef = categoriesObj
--         for j=1,#curCat.gzt_parents do
--             local curParent = curCat.gzt_parents[j]
--             print(curParent)
--             if(!curParentRef[curParent]) then
--                 curParentRef[curParent] = {}
--                 curParentRef = curParentRef[curParent]
--             end
--         end
--         PrintTable(categoriesObj)
--         local parentRef = categoriesObj
--         print("starting to set parentref")
--         for j=1,#curCat.gzt_parents do
--             print("====PARENT REF BEFORE SETTING====")
--             PrintTable(parentRef)
--             print(" SWITCHING TO "..curCat.gzt_parents[j].." !!!!!!!!!!!")
--             parentRef = parentRef[curCat.gzt_parents[j]]
--             print("parentref after",j,"iter")
--             print(parentRef)
--             PrintTable(parentRef)
--         end
--         print("final parentref")
--         print(parentRef)
--         PrintTable(parentRef)
        
--         parentRef[k] = v
--     end
--     return categoriesObj
-- end

-- PrintTable(BuildTree({
--     cat1 = {gzt_parents={}},
--     cat2 = {gzt_parents={"cat1"}},
--     cat3 = {gzt_parents={"cat1","cat2"}},
--     cat4 = {gzt_parents={"cat1"}}
-- }))
