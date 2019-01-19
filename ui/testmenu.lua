if not ItemTrig then return end

ItemTrig.TestMenu = {}
function ItemTrig.TestMenu.OnInitialized(control)
   local fragment = ZO_SimpleSceneFragment:New(ItemTrig_TestMenu)
   local scene    = ZO_Scene:New("ItemTrig_TestMenu_Scene", SCENE_MANAGER)
   scene:AddFragment(fragment)
   SCENE_MANAGER:RegisterTopLevel(ItemTrig_TestMenu, false)
   --
   local pane = ItemTrig_TestMenu:GetNamedChild("vScrollListTest")
   local list = ItemTrig.UI.WScrollList:cast(pane)
   list.elementTemplateName = "ItemTrig_TestMenu_Template_ScrollListItem"
   list.callbackConstruct   =
      function(control, data)
         local text = GetControl(control, "Name")
         text:SetText(data.name)
         control:SetHeight(text:GetHeight())
      end
   --
   list:clear(false)
   for i = 1, 20 do
   --for i = 1, 3 do
      local data = { name = "Test element " .. i }
      list:push(data, false)
   end
   list:redraw()
end