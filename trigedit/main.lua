if not ItemTrig then return end

ItemTrig.SCENE_TRIGEDIT = ZO_Scene:New("ItemTrig_TrigEdit_Scene", SCENE_MANAGER)

ItemTrig.UIMain = {}

local Window = {
   control    = nil,
   viewholder = nil,
   views = {
      triggerlist = {
         control = nil,
         pane    = nil,
      },
      trigger = {
         control          = nil,
         currentTrigIndex = -1,
         targetTrig       = nil,
         workingTrig      = nil, -- copy of the trigger, usable for editing
         paneConditions   = nil,
         paneActions      = nil,
      },
   },
   keybinds = {
      alignment = KEYBIND_STRIP_ALIGN_CENTER,
      {
         name     = "Close Menu (Debugging)",
         keybind  = "UI_SHORTCUT_PRIMARY",
         callback = function() ItemTrig.UIMain.Toggle() end,
         visible  = function() return true end,
         enabled  = true,  -- set to "false" to make the keybind grey out -- can also be a function
         ethereal = false, -- if true, then the keybind isn't actually shown in the menus; vanilla gamepad menus use this for LT/RT flipping pages or fast-scrolling menus
      }
   }
}
ItemTrig.TrigEditWindow = Window
function Window:onOpen()
   KEYBIND_STRIP:AddKeybindButtonGroup(self.keybinds)
end
function Window:onClose()
   KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybinds)
end
function Window:showView(name)
   if name == "triggerlist" then
      self.views.triggerlist.control:SetHidden(false)
      self.views.trigger.control:SetHidden(true)
   elseif name == "trigger" then
      self.views.triggerlist.control:SetHidden(true)
      self.views.trigger.control:SetHidden(false)
   end
end
function Window.views.triggerlist:newTrigger()
   local editor  = ItemTrig.TrigEditWindow.TriggerEditor
   local pane    = self.pane
   local trigger = ItemTrig.Trigger:new()
   trigger.name = "Unnamed trigger"
   if not editor:requestEdit() then
      return
   end
   ItemTrig.TrigEditWindow.TriggerEditor:edit(trigger, true)
end
function Window.views.triggerlist:editTrigger(t)
   local editor  = ItemTrig.TrigEditWindow.TriggerEditor
   local pane    = self.pane
   local trigger = t
   if not trigger then
      trigger = pane:at(pane:getFirstSelectedIndex())
      if not trigger then
         return
      end
   end
   if not editor:requestEdit() then
      return
   end
   ItemTrig.TrigEditWindow.TriggerEditor:edit(trigger)
end

function ItemTrig.UIMain.Setup()
   SCENE_MANAGER:RegisterTopLevel(ItemTrig_TrigEdit, false)
end
function ItemTrig.UIMain.Toggle()
   SCENE_MANAGER:ToggleTopLevel(ItemTrig_TrigEdit)
end

function ItemTrig.UIMain.DispatchEvent(e)
   if e == "OnHide" then
      Window:onClose()
   elseif e == "OnShow" then
      Window:onOpen()
   end
end
function ItemTrig.UIMain.OnInitialized(control)
   Window.control = control
   local fragment = ZO_SimpleSceneFragment:New(ItemTrig_TrigEdit, "ITEMTRIG_ACTION_LAYER_TRIGEDIT_BASE")
   ItemTrig.SCENE_TRIGEDIT:AddFragment(fragment)
   --
   Window.viewholder = ItemTrig.UI.WViewHolder:cast(control:GetNamedChild("ViewHolder"))
   --
   do -- Set up views
      Window.views.triggerlist.control = Window.viewholder.control:GetNamedChild("ViewTriggerList")
      Window.views.trigger.control     = Window.viewholder.control:GetNamedChild("ViewTriggerSingle")
   end
   do -- Set up trigger list view
      local scrollPane = Window.viewholder.control:GetNamedChild("ViewTriggerList"):GetNamedChild("Col2")
      scrollPane = ItemTrig.UI.WScrollSelectList:cast(scrollPane)
      Window.views.triggerlist.pane = scrollPane
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
               ItemTrig.TrigEditWindow.views.triggerlist:editTrigger(trigger)
            end
         end
   end
   Window.TriggerEditor:initialize(Window.viewholder.control:GetNamedChild("ViewTriggerSingle")) -- trigger.lua
end

function ItemTrig.UIMain.RenderTriggers(tList)
   local scrollPane = Window.views.triggerlist.pane
   scrollPane:clear(false)
   for i = 1, table.getn(tList) do
      scrollPane:push(tList[i], false)
   end
   scrollPane:redraw()
end