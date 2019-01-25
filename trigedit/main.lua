if not ItemTrig then return end

ItemTrig.SCENE_TRIGEDIT = ZO_Scene:New("ItemTrig_TrigEdit_Scene", SCENE_MANAGER)

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
         function(control, data)
            local height = 0
            do
               local text = GetControl(control, "Name")
               local _, _, _, _, paddingX, paddingY = text:GetAnchor(1)
               text:SetText(data.name)
               height = text:GetHeight() + paddingY * 2
            end
            do
               local text = GetControl(control, "Description")
               local desc = data:getDescription()
               text:SetText(desc)
               if desc == "" then
                  text:SetHidden(true)
               else
                  text:SetHidden(false)
               local _, _, _, _, paddingX, paddingY = text:GetAnchor(1)
                  height = height + text:GetHeight()
               end
            end
            control:SetHeight(height)
            --
            do
               local enabled = GetControl(control, "Enabled") -- checkbox
               if data.enabled then
                  ZO_CheckButton_SetChecked(enabled)
               else
                  ZO_CheckButton_SetUnchecked(enabled)
               end
               enabled.toggleFunction =
                  function(self, checked)
                     local control = self:GetParent()
                     d("Clicked a trigger's 'enabled' toggle. Checked flag is: " .. tostring(checked))
                  end
            end
         end
      scrollPane.element.onSelect =
         function(index, control, pane)
            local text  = GetControl(control, "Name")
            local desc  = GetControl(control, "Description")
            local color = {GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED)}
            --color = {1.0, 0.25, 0.0}
            text:SetColor(unpack(color))
            desc:SetColor(unpack(color))
         end
      scrollPane.element.onDeselect =
         function(index, control, pane)
            local text  = GetControl(control, "Name")
            local desc  = GetControl(control, "Description")
            local color = {GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL)}
            text:SetColor(unpack(color))
            desc:SetColor(unpack(color))
         end
         --
         -- Should we also use INTERFACE_TEXT_COLOR_HIGHLIGHT on mouseover ?
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
   local pane   = self.ui.pane
   if not trigger then
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