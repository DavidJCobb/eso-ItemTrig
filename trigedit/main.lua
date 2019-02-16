if not ItemTrig then return end

ItemTrig.SCENE_TRIGEDIT = ZO_Scene:New("ItemTrig_TrigEdit_Scene", SCENE_MANAGER)

local WinCls = ItemTrig.UI.WSingletonWindow:makeSubclass("TriggerListWindow")
ItemTrig:registerWindow("triggerList", WinCls)

do -- helper class for trigger list entries
   ItemTrig.UI.TriggerListEntry = ItemTrig.UI.WidgetClass:makeSubclass("TriggerListEntry", "triggerListEntry")
   local TriggerListEntry = ItemTrig.UI.TriggerListEntry
   function TriggerListEntry:_construct()
      local control = self:asControl()
      self.back     = self:GetNamedChild("Bg")
      self.enabled  = self:GetNamedChild("Enabled")
      self.name     = self:GetNamedChild("Name")
      self.desc     = self:GetNamedChild("Description")
      self.contents = ItemTrig.UI.WBulletedList:cast(self:GetNamedChild("Contents"))
      self.contents.depthLimit = true
      self.contents.depthSpace = 200
      self.contents.style.tooDeepText       = "..."
      self.contents.style.topLevelHasBullet = false
      do -- theming
         self.back:SetColor(unpack(ItemTrig.theme.LIST_ITEM_BACKGROUND))
         self.name:SetColor(unpack(ItemTrig.theme.LIST_ITEM_TEXT_NORMAL))
         self.desc:SetColor(unpack(ItemTrig.theme.LIST_ITEM_TEXT_NORMAL))
      end
      self.enabled.toggleFunction =
         function(self, checked)
            local control = self:GetParent()
            local pane    = WinCls:getInstance().ui.pane
            local index   = pane:indexOfControl(control)
            if not index then
               return
            end
            local trigger = pane:at(index)
            trigger.enabled = checked
         end
   end
   function TriggerListEntry:getBaseBackgroundColor()
      if self:indexInParent() % 2 == 0 then
         return ItemTrig.theme.LIST_ITEM_BACKGROUND_ALT
      end
      return ItemTrig.theme.LIST_ITEM_BACKGROUND
   end
   function TriggerListEntry:setSelected(state)
      do -- background color
         local color = self:getBaseBackgroundColor()
         if state then
            color = ItemTrig.theme.LIST_ITEM_BACKGROUND_SELECT
         end
         self.back:SetColor(unpack(color))
      end
      do -- text color
         local color = ItemTrig.theme.LIST_ITEM_TEXT_NORMAL
         if state then
            color = ItemTrig.theme.LIST_ITEM_TEXT_SELECTED
         end
         self.name:SetColor(unpack(color))
         self.desc:SetColor(unpack(color))
         self.contents.style.fontColor   = color
         self.contents.style.bulletColor = color
         self.contents:refreshStyle()
      end
   end
   function TriggerListEntry:setEnabled(state)
      if state then
         ZO_CheckButton_SetChecked(self.enabled)
      else
         ZO_CheckButton_SetUnchecked(self.enabled)
      end
   end
   function TriggerListEntry:setText(name, description)
      local cName  = self.name
      local cDesc  = self.desc
      local paddingTop = ItemTrig.offsetTop(cName)
      local height     = 0
      --
      if name then
         cName:SetText(name)
      end
      height = ItemTrig.offsetBottom(cName)
      --[[if description then
         cDesc:SetText(description)
         if description == "" then
            cDesc:SetHidden(true)
         else
            cDesc:SetHidden(false)
            height = ItemTrig.offsetBottom(cDesc)
         end
      elseif not cDesc:GetHidden() then
         height = ItemTrig.offsetBottom(cDesc)
      end]]--
      if name or description then
         self:asControl():SetHeight(ItemTrig.round(height + paddingTop))
      end
   end
   function TriggerListEntry:renderContents(trigger)
      local function _triggerToList(trigger)
         local list = {
            [1] = { text = "Conditions:" },
            [2] = { text = "Actions:" },
         }
         if table.getn(trigger.conditions) == 0 then
            list[1].children = { [1] = { text = "[None]" } }
         else
            local c = {}
            for i = 1, table.getn(trigger.conditions) do
               table.insert(c, { text = trigger.conditions[i]:format() })
            end
            list[1].children = c
         end
         if table.getn(trigger.actions) == 0 then
            list[2].children = { [1] = { text = "[None]" } }
         else
            local c = {}
            for i = 1, table.getn(trigger.actions) do
               local action = trigger.actions[i]
               if action.base == ItemTrig.TRIGGER_ACTION_RUN_NESTED then
                  local item    = { text = trigger.actions[i]:format() }
                  item.children = _triggerToList(action.args[1])
                  table.insert(c, item)
               else
                  table.insert(c, { text = trigger.actions[i]:format() })
               end
            end
            list[2].children = c
         end
         return list
      end
      self.contents.listItems = _triggerToList(trigger)
      self.contents:redraw()
      do -- size
         local listControl = self.contents:asControl()
         self:asControl():SetHeight(ItemTrig.offsetTop(listControl) + listControl:GetHeight())
      end
   end
end

function WinCls:_construct()
   self:setTitle(GetString(ITEMTRIG_STRING_UI_TRIGGERLIST_TITLE))
   self:setResizeThrottle(5) -- throttle resize frame handler to every five frames
   --
   local control = self:asControl()
   ItemTrig.assign(self, {
      ui = {
         fragment = nil,
         pane     = nil,
      },
      lastTriggerList = nil,
      keybinds = {
         alignment = KEYBIND_STRIP_ALIGN_CENTER,
         {
            name     = "Close Menu (Debugging)",
            keybind  = "UI_SHORTCUT_PRIMARY",
            callback = function() WinCls:getInstance():close() end,
            visible  = function() return true end,
            enabled  = true,  -- set to "false" to make the keybind grey out -- can also be a function
            ethereal = false, -- if true, then the keybind isn't actually shown in the menus; vanilla gamepad menus use this for LT/RT flipping pages or fast-scrolling menus
         },
      },
   })
   do -- scene setup
      self.ui.fragment = ZO_SimpleSceneFragment:New(control, "ITEMTRIG_ACTION_LAYER_TRIGGERLIST")
      ItemTrig.SCENE_TRIGEDIT:AddFragment(self.ui.fragment)
      SCENE_MANAGER:RegisterTopLevel(control, false)
   end
   do -- Set up trigger list view
      local scrollPane = self:GetNamedChild("Body"):GetNamedChild("Col2")
      scrollPane = ItemTrig.UI.WScrollSelectList:cast(scrollPane)
      self.ui.pane = scrollPane
      --[[--
      scrollPane.paddingSides        = 7
      scrollPane.paddingStart        = 7
      scrollPane.paddingBetween      = 7
      scrollPane.paddingEnd          = 7
      --]]--
      scrollPane.element.template    = "ItemTrig_TrigEdit_Template_TriggerOuter"
      scrollPane.element.toConstruct =
         function(control, data, extra)
            local widget = ItemTrig.UI.TriggerListEntry:cast(control)
            widget:setSelected(extra and extra.selected)
            widget:setText(data.name, data:getDescription())
            widget:setEnabled(data.enabled)
            widget:renderContents(data)
         end
      scrollPane.element.onSelect =
         function(index, control, pane)
            ItemTrig.UI.TriggerListEntry:cast(control):setSelected(true)
         end
      scrollPane.element.onDeselect =
         function(index, control, pane)
            ItemTrig.UI.TriggerListEntry:cast(control):setSelected(false)
         end
      scrollPane.element.onDoubleClick =
         function(index, control, pane)
            local trigger = pane.listItems[index]
            if trigger then
               WinCls:getInstance():editTrigger(trigger)
            end
         end
   end
end

function WinCls:onShow()
   KEYBIND_STRIP:AddKeybindButtonGroup(self.keybinds)
   self:renderTriggers(ItemTrig.Savedata.triggers)
end
function WinCls:onHide()
   KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybinds)
   ItemTrig.Savedata:save()
end
function WinCls:onResizeFrame()
   self.ui.pane:redraw()
end

function WinCls:newTrigger()
   local editor  = ItemTrig.windows.triggerEdit
   local trigger = ItemTrig.Trigger:new()
   trigger.name = GetString(ITEMTRIG_STRING_DEFAULT_TRIGGER_NAME)
   editor:requestEdit(self, trigger, true, true):done(
      function()
         local win  = WinCls:getInstance()
         local pane = win.ui.pane
         local i    = pane:getFirstSelectedIndex()
         if i == nil then
            table.insert(self.lastTriggerList, trigger)
         else
            table.insert(self.lastTriggerList, i + 1, trigger)
         end
         self:refresh()
         pane:select(trigger)
         pane:scrollToItem(pane:indexOf(trigger), true, true)
      end
   )
end
function WinCls:editTrigger(trigger)
   local editor = ItemTrig.windows.triggerEdit
   if not trigger then
      local pane = self.ui.pane
      trigger = pane:at(pane:getFirstSelectedIndex())
      if not trigger then
         return
      end
   end
   editor:requestEdit(self, trigger, false, true):done(self.refresh, self)
end
function WinCls:moveSelectedTrigger(direction)
   local list = self.lastTriggerList
   local pane = self.ui.pane
   local i    = pane:getFirstSelectedIndex()
   if (not i) or direction == 0 then
      return
   end
   if direction > 0 then
      if not ItemTrig.swapForward(list, i) then
         return -- trigger was already at the end of the list, and was not moved
      end
   elseif direction < 0 then
      if not ItemTrig.swapBackward(list, i) then
         return -- trigger was already at the start of the list, and was not moved
      end
   end
   self:refresh()
   pane:select(i + direction)
   pane:scrollToItem(i + direction, false, true) -- when triggers are big, reordering them can move the selection out of view
end
function WinCls:deleteSelectedTrigger()
   local index = self.ui.pane:getFirstSelectedIndex()
   deferred = self:showModal(ItemTrig.windows.genericConfirm, {
      text = GetString(ITEMTRIG_STRING_UI_TRIGGERLIST_CONFIRM_DELETE),
      showCloseButton = false
   }):done(
      function(w)
         table.remove(w.lastTriggerList, index)
         w.ui.pane:remove(index)
      end,
      self
   )
end

function WinCls:renderTriggers(tList)
   self.lastTriggerList = tList
   self:refresh()
end
function WinCls:refresh()
   local tList = self.lastTriggerList or {}
   local scrollPane = self.ui.pane
   scrollPane:clear(false)
   for i = 1, table.getn(tList) do
      scrollPane:push(tList[i], false)
   end
   scrollPane:redraw()
end