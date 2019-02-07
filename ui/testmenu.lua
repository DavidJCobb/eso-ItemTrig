if not ItemTrig then return end

local scene = ZO_Scene:New("ItemTrig_TestMenu_Scene", SCENE_MANAGER)

do
   local Cls = ItemTrig.UI.WSingletonWindow:makeSubclass("AnchorTestMenu")
   ItemTrig:registerWindow("testMenuAnchors", Cls)
   --
   SLASH_COMMANDS["/cobbshowanchortestmenu"] =
      function()
         Cls:getInstance():show()
      end
   --
   function Cls:_construct()
      local fragment = ZO_SimpleSceneFragment:New(self:asControl())
      scene:AddFragment(fragment)
      SCENE_MANAGER:RegisterTopLevel(self:asControl(), false)
      self.canvas   = self:GetNamedChild("Body")
      self.tests    = {}
      self.tests[1] = ItemTrig_AnchorTest_Control01
      self.tests[2] = ItemTrig_AnchorTest_Control02
      self.config   = {}
      do
         local wrap = self:GetNamedChild("Topbar")
         local rows = {
            [1] = GetControl(wrap, "Row1"),
            [2] = GetControl(wrap, "Row2"),
         }
         for i = 1, table.getn(rows) do
            local row = rows[i]
            local c = {
               pointSelf = ZO_ComboBox_ObjectFromContainer(GetControl(row, "PointSelf")),
               pointRel  = ZO_ComboBox_ObjectFromContainer(GetControl(row, "PointRel")),
            }
            do -- display
               local label  = GetControl(row, "Label")
               local target = GetControl(row, "TargetName")
               label:SetText("Control " .. i .. ":")
               if i == 1 then
                  target:SetText("canvas")
               elseif i == 2 then
                  target:SetText("control 1")
               end
            end
            table.insert(self.config, c)
         end
      end
   end
   function Cls:onShow()
      self:refresh()
   end
   function Cls:refresh()
      for i = 1, table.getn(self.config) do
         local row   = self.config[i]
         local pSelf = row.pointSelf:GetSelectedItemData().value
         local pRel  = row.pointRel:GetSelectedItemData().value
         --
         local cSelf = self.tests[i]
         local cRel
         if i <= 1 then
            cRel = self.canvas
         else
            cRel = self.tests[i - 1]
         end
         --
         cSelf:ClearAnchors()
         cSelf:SetAnchor(pSelf, cRel, pRel, 0, 0)
         --
         -- TODO: add support for a second anchor for each control
         --
      end
   end
end

ItemTrig.WClassTestMenu = ItemTrig.UI.WSingletonWindow:makeSubclass("WClassTestMenu")
SLASH_COMMANDS["/cobbshowtestmenu"] =
   function()
      ItemTrig.WClassTestMenu:getInstance():show()
   end
function ItemTrig.WClassTestMenu:_construct()
   self:callSuper("_construct")
   local control  = self:asControl()
   self:setTitle("Test menu for WClass and WWindow")
   local fragment = ZO_SimpleSceneFragment:New(control)
   scene:AddFragment(fragment)
   SCENE_MANAGER:RegisterTopLevel(control, false)
   --
   local pane = control:GetNamedChild("vScrollListTest")
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
      local data = { name = "Test element " .. i }
      list:push(data, false)
   end
   list:redraw()
end
function ItemTrig.WClassTestMenu:popTestModal()
   local kid = ItemTrig.WClassTestConfirm:cast(ItemTrig_WClassTestConfirm)
   local deferred = self:showModal(kid)
   if deferred then
      deferred:done(
         function()
            d("Modal was closed with: YES")
         end
      ):fail(
         function()
            d("Modal was closed with: NO")
         end
      )
   end
end

ItemTrig.WClassTestConfirm = ItemTrig.UI.WWindow:makeSubclass("WClassTestMenu")
function ItemTrig.WClassTestConfirm:_construct()
   self:callSuper("_construct")
   self:setTitle("Confirmation dialog example")
   self.result = nil
   local control  = self:asControl()
   local fragment = ZO_SimpleSceneFragment:New(control)
   scene:AddFragment(fragment)
   SCENE_MANAGER:RegisterTopLevel(control, false)
end
function ItemTrig.WClassTestConfirm:handleModalDeferredOnHide(deferred)
   if self.result then
      deferred:resolve()
   else
      deferred:reject()
   end
end
function ItemTrig.WClassTestConfirm:onCloseClicked()
   self.result = false
   self:hide()
end
function ItemTrig.WClassTestConfirm:yes()
   self.result = true
   self:hide()
end
function ItemTrig.WClassTestConfirm:no()
   self.result = false
   self:hide()
end