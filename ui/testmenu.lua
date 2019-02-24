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
         for i = 1, #rows do
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
      for i = 1, #self.config do
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
   local control  = self:asControl()
   self:setTitle("Test menu for WClass and WWindow")
   local fragment = ZO_SimpleSceneFragment:New(control)
   scene:AddFragment(fragment)
   SCENE_MANAGER:RegisterTopLevel(control, false)
   --
   do -- WScrollList
      local pane = self:GetNamedChild("vScrollListTest")
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
      --list:redraw() -- moved to onShow
   end
   do -- WCombobox
      local combobox = self:GetNamedChild("vComboboxTest")
      combobox = ItemTrig.UI.WCombobox:cast(combobox)
      combobox:clear(false)
      combobox:multiSelect(true)
      for i = 1, 20 do
         local data = { name = "Test element " .. i }
         combobox:push(data, false)
      end
      combobox:redraw()
   end
end
function ItemTrig.WClassTestMenu:onShow()
   local pane = self:GetNamedChild("vScrollListTest")
   local list = ItemTrig.UI.WScrollList:cast(pane)
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

ItemTrig.BulletedListTestMenu = ItemTrig.UI.WSingletonWindow:makeSubclass("BulletedListTestMenu")
SLASH_COMMANDS["/cobbshowbullettestmenu"] =
   function()
      ItemTrig.BulletedListTestMenu:getInstance():show()
   end
function ItemTrig.BulletedListTestMenu:_construct()
   do -- scene
      local control  = self:asControl()
      local fragment = ZO_SimpleSceneFragment:New(control)
      scene:AddFragment(fragment)
      SCENE_MANAGER:RegisterTopLevel(control, false)
   end
   self.list = ItemTrig.UI.WBulletedList:cast(self:GetNamedChild("List"))
   assert(self.list ~= nil, "Can't find the list to test with.")
   self.list.style.topLevelHasBullet = false
   self.list.listItems = {
      [1] = { text = "List item 1" },
      [2] = {
         text = "List item 2",
         children = {
            [1] = { text = "List item 2.1" },
            [2] = { text = "List item 2.2" },
            [3] = { text = "List item 2.3" },
         }
      },
      [3] = { text = "List item 3" },
      [4] = {
         text = "List item 4",
         children = {
            [1] = { text = "List item 4.1" },
            [2] = { text = "List item 4.2" },
            [3] = {
               text = "List item 4.3",
               children = {
                  [1] = { text = "List item 4.3.1" },
                  [2] = { text = "List item 4.3.2" },
                  [3] = { text = "List item 4.3.3" },
               }
            },
         }
      },
      [5] = { text = "List item 5" },
      [6] = { text = "List item 6" },
      [7] = { text = "EVERY MORNING I WAKE UP AND OPEN PALM SLAM A VHS INTO THE SLOT. IT'S CHRONICLES OF RIDDICK AND RIGHT THEN AND THERE I START DOING THE MOVES ALONGSIDE WITH THE MAIN CHARACTER, RIDDICK. I DO EVERY MOVE AND I DO EVERY MOVE HARD." },
      [8] = { text = "List item 8" },
   }
end
function ItemTrig.BulletedListTestMenu:onShow()
   local control = self:asControl()
   local listCon = self.list:asControl()
   --local cHeight = control:GetHeight() - listCon:GetHeight()
   local cHeight = ItemTrig.offsetTop(listCon)
   self.list:redraw()
   control:SetHeight(cHeight + listCon:GetHeight())
end

do
   ItemTrig.KeynavTestMenu = ItemTrig.UI.WSingletonWindow:makeSubclass("KeynavTestMenu")
   local Cls = ItemTrig.KeynavTestMenu
   local GamepadKeynavManager = ItemTrig.GamepadKeynavManager
   local WKeyNavigable        = ItemTrig.WKeyNavigable
   local WKeyNavigableWindow  = ItemTrig.WKeyNavigableWindow
   
   SLASH_COMMANDS["/cobbshowkeynavtestmenu"] =
      function()
         Cls:getInstance():show()
      end
   
   function Cls:_construct()
      SCENE_MANAGER:RegisterTopLevel(self:asControl(), true)
      self:pushActionLayer("ItemTrigGamepadKeynav")
      self:setTitle("Gamepad keynav test window")
      local keynavWin = WKeyNavigableWindow:install(self:asControl())
      --
      local b01 = WKeyNavigable:install(self:GetNamedChild("01"))
      local b02 = WKeyNavigable:install(self:GetNamedChild("02"))
      local b03 = WKeyNavigable:install(self:GetNamedChild("03"))
      local b04 = WKeyNavigable:install(self:GetNamedChild("04"))
      local b05 = WKeyNavigable:install(self:GetNamedChild("05"))
      local b06 = WKeyNavigable:install(self:GetNamedChild("06"))
      --
      --     [5]
      -- [1] [2] [3] [4]
      --     [6]
      --
      b01:setDirectionTarget(GamepadKeynavManager.RIGHT, b02)
      b02:setDirectionTarget(GamepadKeynavManager.RIGHT, b03)
      b03:setDirectionTarget(GamepadKeynavManager.RIGHT, b04)
      b04:setDirectionTarget(GamepadKeynavManager.LEFT, b03)
      b03:setDirectionTarget(GamepadKeynavManager.LEFT, b02)
      b02:setDirectionTarget(GamepadKeynavManager.LEFT, b01)
      b02:setDirectionTarget(GamepadKeynavManager.UP, b05)
      b06:setDirectionTarget(GamepadKeynavManager.UP, b02)
      b05:setDirectionTarget(GamepadKeynavManager.DOWN, b02)
      b02:setDirectionTarget(GamepadKeynavManager.DOWN, b06)
      --
      keynavWin:setDefaultControl(b01)
      --
      keynavWin.onButtonSecondary =
         function()
            d("Window caught the secondary button!")
            return true
         end
      keynavWin.onButtonTertiary =
         function()
            d("Window caught the tertiary button!")
            return true
         end
      keynavWin.onButtonNegative =
         function()
            d("Window caught the negative button!")
            return true
         end
   end
   function Cls:onShow()
      GamepadKeynavManager:setCurrentWindow(self:asControl())
   end
   function Cls:onHide()
      WKeyNavigableWindow:cast(self:asControl()):onHide() -- for now
   end
end