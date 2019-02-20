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
      local function _triggerToList(trigger, isNested, color)
         local list = {
            [1] = { color = color, text = "Conditions:" },
            [2] = { color = color, text = "Actions:" },
         }
         if #trigger.conditions == 0 then
            list[1].children = { [1] = { color = color, text = "[None]" } }
         else
            local c = {}
            for i = 1, #trigger.conditions do
               c[i] = { color = color, text = trigger.conditions[i]:format() }
            end
            list[1].children = c
         end
         if #trigger.actions == 0 then
            list[2].children = { [1] = { color = color, text = "[None]" } }
         else
            local c = {}
            for i = 1, #trigger.actions do
               local action = trigger.actions[i]
               if action.base == ItemTrig.TRIGGER_ACTION_RUN_NESTED then
                  local item    = { color = color, text = trigger.actions[i]:format() }
                  local inColor = color
                  if not action.args[1].enabled then
                     inColor = { nil, nil, nil, 0.8 } -- override alpha
                  end
                  item.children = _triggerToList(action.args[1], true, inColor)
                  c[i] = item
               else
                  c[i] = { color = color, text = trigger.actions[i]:format() }
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
      filters = {
         entryPoints = {},
      },
      currentTriggerList = nil,
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
   do -- entry point filter list
      local pane = ItemTrig.UI.WScrollSelectList:cast(self:controlByPath("Body", "Col1"))
      self.ui.entryPointFilterPane = pane
      --
      do -- config
         pane.onChange =
            function(pane)
               WinCls:getInstance():onEntryPointFilterChange()
            end
         --
         pane:setShouldSort(true, false)
         pane:setSortFunction(function(a, b)
            if not a.entryPoint then
               return true
            end
            if not b.entryPoint then
               return false
            end
            return tostring(a.name or a):lower() < tostring(b.name or b):lower()
         end, false)
         --
         pane.element.template = "ItemTrig_TrigEdit_Template_EntryPointFilterItem"
         pane.element.toConstruct =
            function(control, data, extra)
               local text = GetControl(control, "Text")
               local back = GetControl(control, "Bg")
               text:SetText(data.name)
               if extra and extra.selected then
                  back:SetColor(unpack(ItemTrig.theme.LIST_ITEM_BACKGROUND_SELECT))
                  text:SetColor(unpack(ItemTrig.theme.LIST_ITEM_TEXT_SELECTED))
               else
                  back:SetColor(unpack(ItemTrig.theme.LIST_ITEM_BACKGROUND))
                  text:SetColor(unpack(ItemTrig.theme.LIST_ITEM_TEXT_NORMAL))
               end
            end
         pane.element.onSelect =
            function(index, control, pane)
               local text = GetControl(control, "Text")
               local back = GetControl(control, "Bg")
               back:SetColor(unpack(ItemTrig.theme.LIST_ITEM_BACKGROUND_SELECT))
               text:SetColor(unpack(ItemTrig.theme.LIST_ITEM_TEXT_SELECTED))
            end
         pane.element.onDeselect =
            function(index, control, pane)
               local text = GetControl(control, "Text")
               local back = GetControl(control, "Bg")
               back:SetColor(unpack(ItemTrig.theme.LIST_ITEM_BACKGROUND))
               text:SetColor(unpack(ItemTrig.theme.LIST_ITEM_TEXT_NORMAL))
            end
      end
      do -- items
         for k, v in pairs(ItemTrig.ENTRY_POINT_NAMES) do
            pane:push({ name = v, entryPoint = k }, false)
         end
         pane:push({ name = GetString(ITEMTRIG_STRING_UI_TRIGGERLIST_FILTER_SHOW_ALL), entryPoint = nil }, false)
         pane:sort()
         pane:redraw()
      end
   end
   do -- Set up trigger list view
      local scrollPane = self:controlByPath("Body", "Col2")
      scrollPane = ItemTrig.UI.WScrollSelectList:cast(scrollPane)
      self.ui.pane = scrollPane
      scrollPane.element.template    = "ItemTrig_TrigEdit_Template_TriggerOuter"
      scrollPane.element.toConstruct =
         function(control, data, extra)
            local widget =  ItemTrig.UI.TriggerListEntry:cast(control)
            local trigger = data.trigger
            widget:setSelected(extra and extra.selected)
            widget:setText(trigger.name, trigger:getDescription())
            widget:setEnabled(trigger.enabled)
            widget:renderContents(trigger)
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
            local editor  = WinCls:getInstance()
            local trigger = editor:getTriggerByPaneIndex(index)
            if trigger then
               editor:editTrigger(trigger)
            end
         end
   end
end

function WinCls:onShow()
   KEYBIND_STRIP:AddKeybindButtonGroup(self.keybinds)
   self.ui.entryPointFilterPane:select(1)
   self:renderTriggers(ItemTrig.Savedata.triggers)
end
function WinCls:onHide()
   KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybinds)
   ItemTrig.Savedata:save()
end
function WinCls:onResizeFrame()
   self.ui.pane:redraw()
end

function WinCls:onEntryPointFilterChange()
   local selectedTrigger = self:getTriggerByPaneIndex()
   --
   local pane = self.ui.entryPointFilterPane
   self.filters.entryPoints = {}
   local data = pane:getFirstSelectedItem()
   if data.entryPoint then
      self.filters.entryPoints = { data.entryPoint }
   end
   self:refresh()
   --
   if selectedTrigger then
      local triggerIndex = self:getPaneIndexForTrigger(selectedTrigger)
      if triggerIndex then
         local pane = self.ui.pane
         pane:select(triggerIndex)
         pane:scrollToItem(triggerIndex, false, true)
      end
   end
end

--
-- The trigger list can be filtered, which means that not all triggers 
-- in the current trigger list will be visible, and the indices of data 
-- items in the list pane will not match the indices of triggers in the 
-- current trigger list.
--
-- To work around this, the list pane no longer stores the triggers dir-
-- ectly; instead, it stores data objects that look like this:
--
--    { trigger = ..., triggerIndex = ... }
--
-- This means that in order to retrieve a trigger from the list pane, or 
-- find a trigger's index in the list pane, we need helper functions.
--
function WinCls:getTriggerByPaneIndex(index)
   local pane = self.ui.pane
   if not index then
      index = pane:getFirstSelectedIndex()
      if not index then
         return nil
      end
   end
   local data = pane:at(index)
   if not data then
      return nil
   end
   assert(data.triggerIndex ~= nil, "Bad trigger index!")
   return data.trigger, data.triggerIndex
end
function WinCls:getPaneIndexForTrigger(trigger)
   local pane  = self.ui.pane
   local index = nil
   pane:forEach(function(i, data)
      if data.trigger == trigger then
         index = i
         return true
      end
   end)
   return index
end

function WinCls:newTrigger()
   local editor  = ItemTrig.windows.triggerEdit
   local trigger = ItemTrig.Trigger:new()
   trigger.name = GetString(ITEMTRIG_STRING_DEFAULT_TRIGGER_NAME)
   editor:requestEdit(self, trigger, true, true):done(
      function()
         local win  = WinCls:getInstance()
         local pane = win.ui.pane
         local _, i = self:getTriggerByPaneIndex()
         if i == nil then
            table.insert(self.currentTriggerList, trigger)
         else
            table.insert(self.currentTriggerList, i + 1, trigger)
         end
         self:refresh()
         do
            local paneIndex = self:getPaneIndexForTrigger(trigger)
            --
            -- If the trigger's entry points don't match our filter, then 
            -- it may not be visible.
            --
            if paneIndex then
               pane:select(paneIndex)
               pane:scrollToItem(paneIndex, true, true)
            end
         end
      end
   )
end
function WinCls:editTrigger(trigger)
   local editor = ItemTrig.windows.triggerEdit
   if not trigger then
      trigger = self:getTriggerByPaneIndex()
      if not trigger then
         return
      end
   end
   editor:requestEdit(self, trigger, false, true):done(self.refresh, self)
end
function WinCls:moveSelectedTrigger(direction)
   if direction == 0 then
      return
   end
   local list      = self.currentTriggerList
   local pane      = self.ui.pane
   local paneIndex = pane:getFirstSelectedIndex()
   --
   local trigger, i = self:getTriggerByPaneIndex(paneIndex)
   if not i then
      return
   end
   local _, j = self:getTriggerByPaneIndex(paneIndex + direction)
   if not j then
      return
   end
   --
   if direction > 0 then
      if not ItemTrig.moveToAfter(list, i, j) then
         return
      end
   elseif direction < 0 then
      if not ItemTrig.moveToBefore(list, i, j) then
         return
      end
   end
   --
   self:refresh()
   local final = self:getPaneIndexForTrigger(trigger)
   if final then
      pane:select(final)
      pane:scrollToItem(final, false, true) -- when triggers are big, reordering them can move the selection out of view
   end
end
function WinCls:deleteSelectedTrigger()
   local paneIndex          = self.ui.pane:getFirstSelectedIndex()
   local trigger, listIndex = self:getTriggerByPaneIndex(paneIndex)
   deferred = self:showModal(ItemTrig.windows.genericConfirm, {
      text = GetString(ITEMTRIG_STRING_UI_TRIGGERLIST_CONFIRM_DELETE),
      showCloseButton = false
   }):done(
      function(w)
         table.remove(w.currentTriggerList, listIndex)
         w.ui.pane:remove(paneIndex)
      end,
      self
   )
end

function WinCls:shouldShowTrigger(trigger)
   local filters = self.filters.entryPoints
   local count   = #filters
   if count < 1 then
      return true
   end
   for i = 1, count do
      if trigger:allowsEntryPoint(filters[i]) then
         return true
      end
   end
   return false
end
function WinCls:renderTriggers(tList)
   self.currentTriggerList = tList
   self:refresh()
end
function WinCls:refresh()
   local tList = self.currentTriggerList or {}
   local scrollPane = self.ui.pane
   scrollPane:clear(false)
   for i = 1, #tList do
      local trigger = tList[i]
      if self:shouldShowTrigger(trigger) then
         scrollPane:push({ trigger = trigger, triggerIndex = i }, false)
      end
   end
   scrollPane:redraw()
end