if not ItemTrig then return end

ItemTrig.TestMenu = {}
function ItemTrig.TestMenu.OnInitialized(control)
   local fragment = ZO_SimpleSceneFragment:New(ItemTrig_TestMenu)
   local scene    = ZO_Scene:New("ItemTrig_TestMenu_Scene", SCENE_MANAGER)
   scene:AddFragment(fragment)
   SCENE_MANAGER:RegisterTopLevel(ItemTrig_TestMenu, false)
   --
   local pane = ItemTrig_TestMenu:GetNamedChild("vScrollListTest")
   pane.tlData.template  = "ItemTrig_TestMenu_Template_ScrollListItem"
   pane.tlData.construct =
      function(control, data)
         local text = GetControl(control, "Name")
         text:SetText(data.name)
         control:SetHeight(text:GetHeight())
      end
   --
   ItemTrig.UI.vScrollList.clear(pane, false)
   for i = 1, 20 do
      local data = { name = "Test element " .. i }
      ItemTrig.UI.vScrollList.push(pane, data, false)
   end
   ItemTrig.UI.vScrollList.redraw(pane)
end