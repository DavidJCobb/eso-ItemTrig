if not ItemTrig then return end

local scene = ZO_Scene:New("ItemTrig_TestMenu_Scene", SCENE_MANAGER)

ItemTrig.TestMenu = {}
function ItemTrig.TestMenu.OnInitialized(control)
   local fragment = ZO_SimpleSceneFragment:New(ItemTrig_TestMenu)
   scene:AddFragment(fragment)
   SCENE_MANAGER:RegisterTopLevel(ItemTrig_TestMenu, false)
   --
   local pane = ItemTrig_TestMenu:GetNamedChild("vScrollListTest")
   local list = ItemTrig.UI.WScrollList:cast(pane)
   list.element.template    = "ItemTrig_TestMenu_Template_ScrollListItem"
   list.element.toConstruct =
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

ItemTrig.AnchorTestMenu = {
   controls = {
      window = nil,
      canvas = nil,
      tests  = {},
      config = {},
   },
}
function ItemTrig.AnchorTestMenu:OnInitialized(control)
   local fragment = ZO_SimpleSceneFragment:New(control)
   scene:AddFragment(fragment)
   SCENE_MANAGER:RegisterTopLevel(control, false)
   --
   self.controls.window   = control
   self.controls.canvas   = control:GetNamedChild("Body")
   self.controls.tests[1] = ItemTrig_AnchorTest_Control01
   self.controls.tests[2] = ItemTrig_AnchorTest_Control02
   do
      local wrap = control:GetNamedChild("Topbar")
      local rows = {
         [1] = wrap:GetNamedChild("Row1"),
         [2] = wrap:GetNamedChild("Row2"),
      }
      for i = 1, table.getn(rows) do
         local row = rows[i]
         local c = {
            pointSelf = ZO_ComboBox_ObjectFromContainer(row:GetNamedChild("PointSelf")),
            pointRel  = ZO_ComboBox_ObjectFromContainer(row:GetNamedChild("PointRel")),
         }
         do -- display
            local label  = row:GetNamedChild("Label")
            local target = row:GetNamedChild("TargetName")
            label:SetText("Control " .. i .. ":")
            if i == 1 then
               target:SetText("canvas")
            elseif i == 2 then
               target:SetText("control 1")
            end
         end
         table.insert(self.controls.config, c)
      end
   end
end
function ItemTrig.AnchorTestMenu:refresh()
   for i = 1, table.getn(self.controls.config) do
      local row   = self.controls.config[i]
      local pSelf = row.pointSelf:GetSelectedItemData().value
      local pRel  = row.pointRel:GetSelectedItemData().value
      --
      local cSelf = self.controls.tests[i]
      local cRel
      if i <= 1 then
         cRel = self.controls.canvas
      else
         cRel = self.controls.tests[i - 1]
      end
      --
      cSelf:ClearAnchors()
      cSelf:SetAnchor(pSelf, cRel, pRel, 0, 0)
      --
      -- TODO: add support for a second anchor for each control
      --
   end
end