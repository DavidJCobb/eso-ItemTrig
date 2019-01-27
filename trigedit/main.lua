if not ItemTrig then return end

ItemTrig.SCENE_TRIGEDIT = ZO_Scene:New("ItemTrig_TrigEdit_Scene", SCENE_MANAGER)

do -- helper class for trigger list entries
   if not ItemTrig.UI then
      ItemTrig.UI = {}
   end
   ItemTrig.UI.TriggerListEntry = {}
   ItemTrig.UI.TriggerListEntry.__index = ItemTrig.UI.TriggerListEntry
   function ItemTrig.UI.TriggerListEntry:install(control)
      if control.widgets and control.widgets.triggerListEntry then
         return control.widgets.triggerListEntry
      end
      local result = {
         control = control,
         enabled = GetControl(control, "Enabled"),
         name    = GetControl(control, "Name"),
         desc    = GetControl(control, "Description"),
      }
      setmetatable(result, self)
      result.enabled.toggleFunction =
         function(self, checked)
            local control = self:GetParent()
            d("Clicked a trigger's 'enabled' toggle. Checked flag is: " .. tostring(checked))
         end
      do -- link the wrapper to the control via an expando property
         if not control.widgets then
            control.widgets = {}
         end
         control.widgets.triggerListEntry = result
      end
      return result
   end
   function ItemTrig.UI.TriggerListEntry:cast(control)
      assert(control ~= nil, "Cannot cast a nil control to TriggerListEntry.")
      if control.widgets then
         return control.widgets.triggerListEntry
      end
      return nil
   end
   function ItemTrig.UI.TriggerListEntry:setSelected(state)
      local color = {GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL)}
      if state then
         color = {GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED)}
      end
      self.name:SetColor(unpack(color))
      self.desc:SetColor(unpack(color))
   end
   function ItemTrig.UI.TriggerListEntry:setEnabled(state)
      if state then
         ZO_CheckButton_SetChecked(self.enabled)
      else
         ZO_CheckButton_SetUnchecked(self.enabled)
      end
   end
   function ItemTrig.UI.TriggerListEntry:setText(name, description)
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
         self.control:SetHeight(height)
      end
   end
end

local Window = {
   ui = {
      fragment = nil,
      window   = nil,
      pane     = nil,
   },
   keybinds = {
      alignment = KEYBIND_STRIP_ALIGN_CENTER,
      {
         name     = "Close Menu (Debugging)",
         keybind  = "UI_SHORTCUT_PRIMARY",
         callback = function() Window:close() end,
         visible  = function() return true end,
         enabled  = true,  -- set to "false" to make the keybind grey out -- can also be a function
         ethereal = false, -- if true, then the keybind isn't actually shown in the menus; vanilla gamepad menus use this for LT/RT flipping pages or fast-scrolling menus
      }
   }
}
ItemTrig.TriggerListWindow = Window

function Window:OnInitialized(control)
   Window.control = control
   self.ui.window   = control
   self.ui.fragment = ZO_SimpleSceneFragment:New(control, "ITEMTRIG_ACTION_LAYER_TRIGEDIT_BASE")
   ItemTrig.SCENE_TRIGEDIT:AddFragment(self.ui.fragment)
   SCENE_MANAGER:RegisterTopLevel(ItemTrig_TrigEdit, false)
   --
   do -- Set up trigger list view
      local scrollPane = control:GetNamedChild("Body"):GetNamedChild("Col2")
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
            local widget = ItemTrig.UI.TriggerListEntry:cast(control)
            widget:setSelected(true)
         end
      scrollPane.element.onDeselect =
         function(index, control, pane)
            local widget = ItemTrig.UI.TriggerListEntry:cast(control)
            widget:setSelected(false)
         end
         --
         -- Should we also use INTERFACE_TEXT_COLOR_HIGHLIGHT on mouseover ?
         --
      scrollPane.element.onDoubleClick =
         function(index, control, pane)
            local trigger = pane.listItems[index]
            if trigger then
               Window:editTrigger(trigger)
            end
         end
   end
end
function Window:OnClose()
   KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybinds)
end
function Window:OnOpen()
   KEYBIND_STRIP:AddKeybindButtonGroup(self.keybinds)
end

function Window:open()
   SCENE_MANAGER:ShowTopLevel(self.ui.window)
   self:renderTriggers(ItemTrig.Savedata.triggers)
end
function Window:close()
   SCENE_MANAGER:HideTopLevel(self.ui.window)
end

function Window:newTrigger()
   local editor  = ItemTrig.TriggerEditWindow
   local trigger = ItemTrig.Trigger:new()
   trigger.name = "Unnamed trigger"
   editor:tryEdit(trigger, true)
end
function Window:editTrigger(trigger)
   local editor = ItemTrig.TriggerEditWindow
   if not trigger then
      local pane = self.ui.pane
      trigger = pane:at(pane:getFirstSelectedIndex())
      if not trigger then
         return
      end
   end
   editor:tryEdit(trigger)
end
function Window:renderTriggers(tList)
   if not tList then
      tList = {}
   end
   local scrollPane = self.ui.pane
   scrollPane:clear(false)
   for i = 1, table.getn(tList) do
      scrollPane:push(tList[i], false)
   end
   scrollPane:redraw()
end