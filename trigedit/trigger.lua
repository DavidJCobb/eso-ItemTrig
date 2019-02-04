if not ItemTrig then return end

--[[--
   The workflow for the trigger editor is as follows:
   
    * Store a reference to the trigger we wish to edit, akin to 
      C++ {Trigger* original;}.
   
    * Create and store a copy of that trigger, and make our edits 
      to the copy.
   
    * If the user cancels their changes, then we just destroy 
      the copy.
   
    * If the user commits their changes, then we overwrite each 
      field on the original trigger with the values in the copy; 
      think of C++ {*original = copy;}. We've created a method 
      for this purpose: Trigger:copyAssign.
--]]--

local Window = {
   trigger = {
      --
      -- TODO: In order to account for nested triggers, we'll probably want to 
      -- redesign this just *slightly*, in order to function as a stack rather 
      -- than just a single set of data.
      --
      target  = nil, -- the trigger we want to edit (reference to something elsewhere)
      working = nil, -- a copy of that trigger, which we edit
      dirty   = false,
   },
   ui = {
      fragment       = nil,
      window         = nil,
      paneConditions = nil,
      paneActions    = nil,
   },
}
ItemTrig.TriggerEditWindow = Window

function Window:OnInitialized(control)
   self.ui.fragment = ZO_SimpleSceneFragment:New(control, "ITEMTRIG_ACTION_LAYER_TRIGGEREDIT")
   ItemTrig.SCENE_TRIGEDIT:AddFragment(self.ui.fragment)
   SCENE_MANAGER:RegisterTopLevel(control, false)
   --
   self.ui.window = control
   do
      local col = control:GetNamedChild("Col1")
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
         pane.element.onDoubleClick =
            --
            -- TODO: make consistent with the trigger list
            --
            function(index, control, pane)
               local opcode = pane.listItems[index]
               if opcode then
                  local editor = ItemTrig.OpcodeEditWindow
                  if not editor:requestEdit() then
                     return
                  end
                  editor:edit(opcode)
               end
            end
         --
         local buttons = pane.control:GetParent():GetNamedChild("Buttons")
         do -- opcode list buttons
            local bNew    = buttons:GetNamedChild("New")
            local bEdit   = buttons:GetNamedChild("Edit")
            local bUp     = buttons:GetNamedChild("MoveUp")
            local bDown   = buttons:GetNamedChild("MoveDown")
            local bDelete = buttons:GetNamedChild("Delete")
            --
            -- TODO: other buttons
            --
            bEdit:SetHandler("OnMouseUp",
               --
               -- TODO: make consistent with the trigger list
               --
               function(control, button, upInside, ctrl, alt, shift, command)
                  if not upInside then
                     return
                  end
                  local editor = ItemTrig.OpcodeEditWindow
                  local pane   = ItemTrig.UI.WScrollSelectList:cast(control:GetParent():GetParent():GetNamedChild("List"))
                  local opcode = pane:at(pane:getFirstSelectedIndex())
                  if not opcode then
                     return
                  end
                  local deferred = editor:requestEdit(editor.ui.window, opcode)
                  deferred:done(
                     function(context, deferred, dirty) -- user clicked OK
                        if dirty then
                           ItemTrig.TriggerEditWindow:refresh()
                        end
                     end
                  ):fail(
                     function(context, deferred) -- user clicked Cancel
                     end
                  )
               end
            )
         end
      end
      setupOpcodeList(self.ui.paneConditions)
      setupOpcodeList(self.ui.paneActions)
   end
end

function Window:tryEdit(trigger, dirty)
   if not self:requestEdit() then
      return
   end
   self:edit(trigger, dirty)
end

function Window:abandon()
   self.trigger.target  = nil
   self.trigger.working = nil
   self.trigger.dirty   = false
   self.ui.paneConditions:clear()
   self.ui.paneActions:clear()
   SCENE_MANAGER:HideTopLevel(self.ui.window)
end
function Window:commit()
   if not self.trigger.dirty then
      return
   end
   self.trigger.target:copyAssign(self.trigger.working)
   --
   -- TODO: In order to account for nested triggers, when we stop 
   -- commit a nested trigger, we need to flag its parent as dirty.
   --
end
function Window:requestEdit()
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
      -- TODO: probably requires implementing something 
      -- comparable to JavaScript promises/deferreds
      --
   end
   return true
end
function Window:requestExit()
   if self.trigger.dirty then
      --
      -- TODO: prompt for confirmation; return true if the 
      -- user confirms leaving, or false otherwise.
      --
   end
   return true
end
function Window:edit(trigger, dirty)
   assert(ItemTrig.TriggerListWindow ~= nil, "Cannot open the trigger editor window if the trigger list window doesn't exist.")
   self.trigger.target  = trigger
   self.trigger.working = trigger:clone(false) -- see documentation for this function
   self.trigger.dirty   = dirty or false
   do
      local host  = ItemTrig.UI.WModalHost:cast(ItemTrig.TriggerListWindow.ui.window)
      local modal = ItemTrig.UI.WModal:install(self.ui.window)
      if not modal:prepToShow(host) then
         return
      end
   end
   self:refresh()
   SCENE_MANAGER:ShowTopLevel(self.ui.window)
   self.ui.window:BringWindowToTop()
end
function Window:refresh()
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