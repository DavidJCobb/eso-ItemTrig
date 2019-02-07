if not ItemTrig then return end

ItemTrig.SCENE_TRIGEDIT = ZO_Scene:New("ItemTrig_TrigEdit_Scene", SCENE_MANAGER)

local WinCls = ItemTrig.UI.WSingletonWindow:makeSubclass("TriggerListWindow")
ItemTrig:registerWindow("triggerList", WinCls)

do -- helper class for trigger list entries
   ItemTrig.UI.TriggerListEntry = ItemTrig.UI.WidgetClass:makeSubclass("TriggerListEntry", "triggerListEntry")
   local TriggerListEntry = ItemTrig.UI.TriggerListEntry
   function TriggerListEntry:_construct()
      local control = self:asControl()
      self.enabled = self:GetNamedChild("Enabled")
      self.name    = self:GetNamedChild("Name")
      self.desc    = self:GetNamedChild("Description")
      self.enabled.toggleFunction =
         function(self, checked)
            local control = self:GetParent()
            --
            -- TODO: TOGGLE TRIGGER ENABLE STATE
            --
            d("Clicked a trigger's 'enabled' toggle. Checked flag is: " .. tostring(checked))
         end
   end
   function TriggerListEntry:setSelected(state)
      local color = {GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL)}
      if state then
         color = {GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED)}
      end
      self.name:SetColor(unpack(color))
      self.desc:SetColor(unpack(color))
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
      local height = 0
      do
         local _, _, _, _, paddingX, paddingY = cName:GetAnchor(1)
         height = paddingY * 2
      end
      if name then
         cName:SetText(name)
      end
      height = height + cName:GetHeight()
      if description then
         cDesc:SetText(description)
         if description == "" then
            cDesc:SetHidden(true)
         else
            cDesc:SetHidden(false)
            height = height + cDesc:GetHeight()
         end
      elseif not cDesc:GetHidden() then
         height = height + cDesc:GetHeight()
      end
      if name or description then
         self:asControl():SetHeight(height)
      end
   end
end

function WinCls:_construct()
   self:setTitle(GetString(ITEMTRIG_STRING_UI_TRIGGERLIST_TITLE))
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
      scrollPane.paddingBetween      = 8
      scrollPane.element.template    = "ItemTrig_TrigEdit_Template_TriggerOuter"
      scrollPane.element.toConstruct =
         function(control, data, extra)
            local widget = ItemTrig.UI.TriggerListEntry:install(control)
            widget:setSelected(extra and extra.selected)
            widget:setText(data.name, data:getDescription())
            widget:setEnabled(data.enabled)
         end
      scrollPane.element.onSelect =
         function(index, control, pane)
            ItemTrig.UI.TriggerListEntry:cast(control):setSelected(true)
         end
      scrollPane.element.onDeselect =
         function(index, control, pane)
            ItemTrig.UI.TriggerListEntry:cast(control):setSelected(false)
         end
         --
         -- Should we also use INTERFACE_TEXT_COLOR_HIGHLIGHT on mouseover ?
         --
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
end

function WinCls:newTrigger()
   local editor  = ItemTrig.windows.triggerEdit
   local trigger = ItemTrig.Trigger:new()
   trigger.name = "Unnamed trigger"
   editor:requestEdit(self, trigger, true)
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
   editor:requestEdit(self, trigger):done(self.refresh, self)
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