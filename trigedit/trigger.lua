if not ItemTrig then return end
if not ItemTrig.TrigEditWindow then return end

local TriggerEditor = {
   trigger = {
      target  = nil, -- the trigger we want to edit (reference to something elsewhere)
      working = nil, -- a copy of that trigger, which we edit
      dirty   = false,
   },
   ui = {
      view           = nil,
      paneConditions = nil,
      paneActions    = nil,
   },
}
ItemTrig.TrigEditWindow.TriggerEditor = TriggerEditor

function TriggerEditor:initialize(viewControl)
   self.ui.view = ItemTrig.UI.WViewHolderView:cast(viewControl)
   do
      local col = viewControl:GetNamedChild("Col1")
      local c = col:GetNamedChild("Conditions"):GetNamedChild("List")
      local a = col:GetNamedChild("Actions"):GetNamedChild("List")
      self.ui.paneConditions = ItemTrig.UI.WScrollSelectList:cast(c)
      self.ui.paneActions    = ItemTrig.UI.WScrollSelectList:cast(a)
   end
   do
      local function setupOpcodeList(pane)
         local function formatOpcodeArg(s)
            return string.format("|c70B0FF%s|r", s)
         end
         --
         pane.element.template = "ItemTrig_TrigEdit_Template_Opcode"
         pane.element.toConstruct =
            function(control, data)
               local height = 0
               do
                  local text = GetControl(control, "Text")
                  local _, _, _, _, paddingX, paddingY = text:GetAnchor(1)
                  text:SetText(data:format(formatOpcodeArg))
                  height = text:GetHeight() + paddingY * 2
               end
               control:SetHeight(height)
            end
         pane.element.onSelect =
            function(index, control)
               local text  = GetControl(control, "Text")
               local color = {GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED)}
               text:SetColor(unpack(color))
            end
         pane.element.onDeselect =
            function(index, control)
               local text  = GetControl(control, "Text")
               local color = {GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL)}
               text:SetColor(unpack(color))
            end
      end
      setupOpcodeList(self.ui.paneConditions)
      setupOpcodeList(self.ui.paneActions)
   end
end
function TriggerEditor:commit()
   if not self.trigger.dirty then
      return
   end
   self.trigger.target.copyAssign(self.trigger.working)
end
function TriggerEditor:requestEdit()
   if self.trigger.dirty then
      --
      -- TODO: prompt for confirmation; return true if the 
      -- user confirms leaving, or false otherwise
      --
      -- This would run if we've made unsaved changes to 
      -- an outer trigger and then attempt to edit a nested 
      -- trigger. We could redesign later to allow seamless 
      -- editing of nested triggers, but let's keep it basic 
      -- for now.
      --
   end
   return true
end
function TriggerEditor:requestExit()
   if self.trigger.dirty then
      --
      -- TODO: prompt for confirmation; return true if the 
      -- user confirms leaving, or false otherwise.
      --
   end
   return true
end
function TriggerEditor:edit(trigger)
   self.trigger.target  = trigger
   self.trigger.working = trigger:clone(false) -- see documentation for this function
   self.trigger.dirty   = false
   self:refresh()
   self.ui.view:show()
end
function TriggerEditor:refresh()
   local trigger = self.trigger.working
   do -- render conditions
      local pane = self.ui.paneConditions
      pane:clear(false)
      for i = 1, table.getn(trigger.conditions) do
         pane:push(trigger.conditions[i], false)
      end
      pane:redraw()
   end
   do -- render actions
      local pane = self.ui.paneActions
      pane:clear(false)
      for i = 1, table.getn(trigger.actions) do
         pane:push(trigger.actions[i], false)
      end
      pane:redraw()
   end
end