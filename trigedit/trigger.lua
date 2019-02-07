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

local WinCls = ItemTrig.UI.WSingletonWindow:makeSubclass("TriggerEditWindow")
ItemTrig:registerWindow("triggerEdit", WinCls)

local OpcodeListCls = ItemTrig.UI.WidgetClass:makeSubclass("OpcodeListCls", "opcodeList")
do -- helper class for opcode lists
   function OpcodeListCls:_construct(type)
      self.type = type
      self.pane = ItemTrig.UI.WScrollSelectList:cast(self:GetNamedChild("List"))
      do -- pane
         local function formatOpcodeArg(s)
            return string.format("|c70B0FF%s|r", s)
         end
         --
         local pane = self.pane
         pane.element.template = "ItemTrig_TrigEdit_Template_Opcode"
         pane.paddingBetween   = 4
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
            function(index, control, pane)
               local text  = GetControl(control, "Text")
               local color = {GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED)}
               text:SetColor(unpack(color))
               WinCls:getInstance():onPaneSelection(pane)
            end
         pane.element.onDeselect =
            function(index, control, pane)
               local text  = GetControl(control, "Text")
               local color = {GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL)}
               text:SetColor(unpack(color))
            end
         pane.element.onDoubleClick =
            function(index, control, pane)
               local opcode = pane.listItems[index]
               if opcode then
                  WinCls:getInstance():editOpcode(opcode)
               end
            end
      end
      do -- buttons
         local buttons = self:GetNamedChild("Buttons")
         local names   = { "Add", "Edit", "MoveUp", "MoveDown", "Delete" }
         for _, v in pairs(names) do
            local button = GetControl(buttons, v)
            button.operation = v
            button:SetHandler("OnMouseUp",
               function(control, button, upInside, ctrl, alt, shift, command)
                  if upInside then
                     local ol = OpcodeListCls:cast(control:GetParent():GetParent())
                     assert(ol ~= nil)
                     ol["handler" .. control.operation](ol)
                  end
               end
            )
         end
      end
   end
   function OpcodeListCls:getSelected()
      return self.pane:at(self.pane:getFirstSelectedIndex())
   end
   function OpcodeListCls:handlerAdd()
      local i = self.pane:getFirstSelectedIndex()
      WinCls:getInstance():addOpcode(self.type, i)
   end
   function OpcodeListCls:handlerEdit()
      local opcode = self:getSelected()
      if opcode then
         WinCls:getInstance():editOpcode(opcode)
      end
   end
   function OpcodeListCls:handlerMoveUp()
      local opcode = self:getSelected()
      if opcode then
         WinCls:getInstance():moveOpcode(opcode, -1)
      end
   end
   function OpcodeListCls:handlerMoveDown()
      local opcode = self:getSelected()
      if opcode then
         WinCls:getInstance():moveOpcode(opcode, 1)
      end
   end
   function OpcodeListCls:handlerDelete()
      local opcode = self:getSelected()
      if opcode then
         WinCls:getInstance():deleteOpcode(opcode)
      end
   end
end

function WinCls:_construct()
   self:setTitle(GetString(ITEMTRIG_STRING_UI_TRIGGEREDIT_TITLE_EDIT))
   --
   local control = self:asControl()
   self.ui = {}
   do -- scene setup
      self.ui.fragment = ZO_SimpleSceneFragment:New(control, "ITEMTRIG_ACTION_LAYER_TRIGGEREDIT")
      ItemTrig.SCENE_TRIGEDIT:AddFragment(self.ui.fragment)
      SCENE_MANAGER:RegisterTopLevel(control, false)
   end
   self.trigger = {
      --
      -- TODO: In order to account for nested triggers, we'll probably want to 
      -- redesign this just *slightly*, in order to function as a stack rather 
      -- than just a single set of data.
      --
      target  = nil, -- the trigger we want to edit (reference to something elsewhere)
      working = nil, -- a copy of that trigger, which we edit
      dirty   = false,
   }
   self.pendingResults = {
      outcome = false,
      results = nil,
   }
   do
      local col = self:GetNamedChild("Col1")
      local c = OpcodeListCls:install(GetControl(col, "Conditions"), "condition")
      local a = OpcodeListCls:install(GetControl(col, "Actions"),    "action")
      self.ui.paneConditions = c.pane
      self.ui.paneActions    = a.pane
   end
end

function WinCls:onPaneSelection(pane)
   if pane == self.ui.paneConditions then
      self.ui.paneActions:deselectAll()
   else
      self.ui.paneConditions:deselectAll()
   end
end
function WinCls:addOpcode(type, insertAfterIndex)
   local created
   if type == "condition" then
      created = ItemTrig.Condition:new(1)
   elseif type == "action" then
      created = ItemTrig.Action:new(4)
   end
   local deferred = ItemTrig.windows.opcodeEdit:requestEdit(self, created, true)
   deferred:done(
      function(context, deferred, dirty) -- user clicked OK
         local editor = WinCls:getInstance()
         local pane
         if created.type == "condition" then
            editor.trigger.working:insertConditionAfter(created, insertAfterIndex)
            pane = editor.ui.paneConditions
         elseif created.type == "action" then
            editor.trigger.working:insertActionAfter(created, insertAfterIndex)
            pane = editor.ui.paneActions
         end
         editor.trigger.dirty = true
         editor:refresh()
         pane:select(created)
         pane:scrollToItem(pane:indexOfData(created), true, true)
      end
   ):fail(
      function(context, deferred) -- user clicked Cancel
      end
   )
end
function WinCls:editOpcode(opcode)
   local deferred = ItemTrig.windows.opcodeEdit:requestEdit(self, opcode)
   deferred:done(
      function(context, deferred, dirty) -- user clicked OK
         if dirty then
            local editor = WinCls:getInstance()
            editor.trigger.dirty = true
            editor:refresh()
         end
      end
   ):fail(
      function(context, deferred) -- user clicked Cancel
      end
   )
end
function WinCls:moveOpcode(opcode, direction)
   local list
   local pane
   if opcode.type == "condition" then
      list = self.trigger.working.conditions
      pane = self.ui.paneConditions
   else
      list = self.trigger.working.actions
      pane = self.ui.paneActions
   end
   local i = ItemTrig.indexOf(list, opcode)
   if (not i) or direction == 0 then
      return
   end
   if direction > 0 then
      if not ItemTrig.swapForward(list, i) then
         return -- opcode was already at the end of the list, and was not moved
      end
   elseif direction < 0 then
      if not ItemTrig.swapBackward(list, i) then
         return -- opcode was already at the start of the list, and was not moved
      end
   end
   self.trigger.dirty = true
   self:refresh()
   pane:select(opcode)
end
function WinCls:deleteOpcode(opcode)
   assert(opcode ~= nil, "Cannot delete a nil opcode.")
   local deferred
   if opcode:isEffortful() then
      --
      -- Only pop a confirmation prompt if it's an opcode whose arguments 
      -- might take some effort to set up, e.g. strings that the user typed.
      --
      local s
      if opcode.type == "condition" then
         s = GetString(ITEMTRIG_STRING_UI_TRIGGEREDIT_CONFIRM_DELETE_C)
      else
         s = GetString(ITEMTRIG_STRING_UI_TRIGGEREDIT_CONFIRM_DELETE_A)
      end
      deferred = self:showModal(ItemTrig.windows.genericConfirm, {
         text = s,
         showCloseButton = false
      })
   else
      deferred = ItemTrig.Deferred:resolve()
   end
   deferred:done(
      function(w)
         local pane
         local list
         if opcode.type == "condition" then
            pane = w.ui.paneConditions
            list = w.trigger.working.conditions
         else
            pane = w.ui.paneActions
            list = w.trigger.working.actions
         end
         w.trigger.dirty = true
         table.remove(list, index)
         pane:remove(pane:indexOfData(opcode))
      end,
      self
   )
end

function WinCls:handleModalDeferredOnHide(deferred)
   if self.pendingResults.outcome then
      deferred:resolve(self.pendingResults.results)
   else
      deferred:reject(self.pendingResults.results)
   end
   self.pendingResults.outcome = false
   self.pendingResults.results = nil
end
function WinCls:abandon()
   self.pendingResults.outcome = false
   self.pendingResults.results = nil
   self:hide()
end
function WinCls:commit()
   self.trigger.target:copyAssign(self.trigger.working)
   --
   -- TODO: In order to account for nested triggers, when we stop 
   -- commit a nested trigger, we need to flag its parent as dirty.
   --
   self.pendingResults.outcome = true
   self.pendingResults.results = nil
   self:hide()
end
function WinCls:onHide()
   self.trigger.target  = nil
   self.trigger.working = nil
   self.trigger.dirty   = false
   self.ui.paneConditions:clear()
   self.ui.paneActions:clear()
end
function WinCls:cancel()
   self:requestExit():done(self.abandon, self)
end
function WinCls:onCloseClicked()
   self:cancel()
end
function WinCls:requestExit()
   if self.trigger.dirty then
      return self:showModal(ItemTrig.windows.genericConfirm, {
         text = GetString(ITEMTRIG_STRING_UI_TRIGGEREDIT_ABANDON_UNSAVED_CHANGES),
         showCloseButton = false
      })
   end
   local deferred = ItemTrig.Deferred:new()
   deferred:resolve()
   return deferred
end
function WinCls:requestEdit(opener, trigger, dirty)
   assert(opener  ~= nil, "The trigger editor must be aware of its opener.")
   assert(trigger ~= nil, "No trigger.")
   assert(self:getModalOpener() == nil, "The trigger editor is already showing!")
   local deferred = opener:showModal(self)
   if not deferred then
      return
   end
   self.trigger.target  = trigger
   self.trigger.working = trigger:clone(false) -- see documentation for this function
   self.trigger.dirty   = dirty or false
   if dirty then
      self:setTitle(GetString(ITEMTRIG_STRING_UI_TRIGGEREDIT_TITLE_NEW))
   else
      self:setTitle(GetString(ITEMTRIG_STRING_UI_TRIGGEREDIT_TITLE_EDIT))
   end
   self:refresh()
   return deferred
end
function WinCls:refresh()
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