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

ITEMTRIG_TRIGGER_EDIT_HAS_OPENED_NESTED_TRIGGER = 0x4E535444 -- "NSTD"

local WinCls = ItemTrig.UI.WSingletonWindow:makeSubclass("TriggerEditWindow")
ItemTrig:registerWindow("triggerEdit", WinCls)

local OpcodeListCls = ItemTrig.UI.WidgetClass:makeSubclass("OpcodeListCls", "opcodeList")
do -- helper class for opcode lists
   do -- helper class for list items
      ItemTrig.UI.OpcodeListEntry = ItemTrig.UI.WidgetClass:makeSubclass("OpcodeListEntry", "opcodeListEntry")
      local Cls = ItemTrig.UI.OpcodeListEntry
      function Cls:_construct()
         local control = self:asControl()
         self.back = self:GetNamedChild("Bg")
         self.text = self:GetNamedChild("Text")
         do -- theming
            self.back:SetColor(unpack(ItemTrig.theme.LIST_ITEM_BACKGROUND))
            self.text:SetColor(unpack(ItemTrig.theme.LIST_ITEM_TEXT_NORMAL))
         end
      end
      function Cls:getBaseBackgroundColor()
         if self:indexInParent() % 2 == 0 then
            return ItemTrig.theme.LIST_ITEM_BACKGROUND_ALT
         end
         return ItemTrig.theme.LIST_ITEM_BACKGROUND
      end
      function Cls:setSelected(state)
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
            self.text:SetColor(unpack(color))
         end
      end
      function Cls:setText(t)
         self.text:SetText(t)
         local height = ItemTrig.offsetBottom(self.text) + ItemTrig.offsetTop(self.text)
         self:asControl():SetHeight(ItemTrig.round(height))
      end
   end
   --
   function OpcodeListCls:_construct(type)
      self.type = type
      self.pane = ItemTrig.UI.WScrollSelectList:cast(self:GetNamedChild("List"))
      do -- pane
         local pane = self.pane
         pane.element.template = "ItemTrig_TrigEdit_Template_Opcode"
         pane.element.toConstruct =
            function(control, data, extra, pane)
               local baseArgs = data.base.args
               local function _formatOpcodeArg(s, i)
                  local function _validateEntryPoints(i)
                     local triggerEP = WinCls:getInstance().stack:getEnabledEntryPoints()
                     local opcodeEP  = baseArgs[i].allowedEntryPoints
                     if not opcodeEP then
                        return true
                     end
                     if not triggerEP then
                        return false
                     end
                     return ItemTrig.valuesOverlap(triggerEP, opcodeEP)
                  end
                  if not _validateEntryPoints(i) then
                     return s
                  end
                  --
                  s = ItemTrig.splitByCount(s, 200)
                  local out = ""
                  for j = 1, table.getn(s) do
                     out = out .. string.format("|c70B0FF%s|r", s[j])
                  end
                  return out
               end
               --
               local widget = ItemTrig.UI.OpcodeListEntry:cast(control)
               widget:setText(data:format(_formatOpcodeArg))
               widget:setSelected(extra and extra.selected)
            end
         pane.element.onSelect =
            function(index, control, pane)
               ItemTrig.UI.OpcodeListEntry:cast(control):setSelected(true)
               WinCls:getInstance():onPaneSelection(pane)
            end
         pane.element.onDeselect =
            function(index, control, pane)
               ItemTrig.UI.OpcodeListEntry:cast(control):setSelected(false)
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
            button:SetHandler("OnClicked",
               function(control, button)
                  local ol = OpcodeListCls:cast(control:GetParent():GetParent())
                  assert(ol ~= nil)
                  ol["handler" .. control.operation](ol)
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

local TriggerStack = {}
do -- editor state
   --
   -- We need to be able to handle the editing of nested triggers; therefore, 
   -- instead of simply storing editor state for one trigger at a time, we 
   -- need to store a stack of editor states.
   --
   TriggerStack.__index = TriggerStack
   function TriggerStack:new()
      local result = setmetatable({}, self)
      result.frames = {}
      return result
   end
   function TriggerStack:clear()
      self.frames = {}
   end
   function TriggerStack:count()
      return #self.frames
   end
   function TriggerStack:dirty(x)
      local last = self:last()
      if x ~= nil then
         if last then
            last.dirty = x
         end
         return
      end
      return last and last.dirty or false
   end
   function TriggerStack:first()
      if self:count() > 0 then
         return self.frames[1]
      end
   end
   function TriggerStack:getEnabledEntryPoints()
      local first = self:first()
      if not first then
         return {}
      end
      return first.working.entryPoints
   end
   function TriggerStack:last()
      local count = self:count()
      if count > 0 then
         return self.frames[count]
      end
   end
   function TriggerStack:push(trigger, dirty)
      local frame = {
         target   = trigger, --------------- the trigger we want to edit
         working  = trigger:clone(false), -- a copy, which we make changes to before committing them later
         dirty    = dirty or false,
         isNew    = dirty or false,
         deferred = self:count() > 0 and ItemTrig.Deferred:new() or nil
      }
      table.insert(self.frames, frame)
      return frame.deferred
   end
   function TriggerStack:pop(commit)
      local count = self:count()
      assert(count > 0, "No stack frame to pop.")
      local last = self.frames[count]
      assert(last ~= nil, "No stack frame to pop.")
      self.frames[count] = nil
      if commit then
         last.target:copyAssign(last.working)
         if last.deferred then
            last.deferred:resolve()
         end
      elseif last.deferred then
         last.deferred:reject()
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
   self.stack      = TriggerStack:new() -- state of the trigger(s) we're editing; nested; "last" frame is the innermost edited trigger
   self.refreshing = true
   self.pendingResults = {
      outcome = false,
      results = nil,
   }
   do
      local bar      = self:GetNamedChild("EntryPointBar")
      local combobox = ItemTrig.UI.WCombobox:cast(GetControl(bar, "Value"))
      self.ui.entryPointsBar      = bar
      self.ui.entryPointsCombobox = combobox
      --
      combobox.onChange = function() WinCls:getInstance():onEntryPointsChanged() end
      combobox:clear()
      combobox:multiSelect(true)
      combobox:setShouldSort(true, false)
      combobox.emptyText = GetString(ITEMTRIG_STRING_ENTRYPOINT_NONE_SELECTED)
      for k, v in pairs(ItemTrig.ENTRY_POINT_NAMES) do
         combobox:push({ name  = v, value = k }, false)
      end
      combobox:redraw()
   end
   do
      local col = self:GetNamedChild("Col1")
      local c = OpcodeListCls:install(GetControl(col, "Conditions"), "condition")
      local a = OpcodeListCls:install(GetControl(col, "Actions"),    "action")
      self.ui.paneConditions = c.pane
      self.ui.paneActions    = a.pane
      local namebar = self:GetNamedChild("NameBar")
      self.ui.triggerNameField = GetControl(namebar, "Value")
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
      created = ItemTrig.Condition:new(ItemTrig.TRIGGER_CONDITION_COMMENT)
   elseif type == "action" then
      created = ItemTrig.Action:new(ItemTrig.TRIGGER_ACTION_COMMENT)
   end
   local deferred = ItemTrig.windows.opcodeEdit:requestEdit(self, created, true, {
      entryPoints = self.stack:getEnabledEntryPoints(),
   })
   deferred:done(
      function(dirty) -- user clicked OK
         local editor = WinCls:getInstance()
         local trig   = editor.stack:last()
         assert(trig ~= nil)
         local pane
         if created.type == "condition" then
            trig.working:insertConditionAfter(created, insertAfterIndex)
            pane = editor.ui.paneConditions
         elseif created.type == "action" then
            trig.working:insertActionAfter(created, insertAfterIndex)
            pane = editor.ui.paneActions
         end
         trig.dirty = true
         editor:refresh()
         pane:select(created)
         pane:scrollToItem(pane:indexOf(created), true, true)
      end
   ):fail(
      function() -- user clicked Cancel
      end
   )
end
function WinCls:editOpcode(opcode)
   local deferred = ItemTrig.windows.opcodeEdit:requestEdit(self, opcode, false, {
      entryPoints = self.stack:getEnabledEntryPoints(),
   })
   deferred:done(
      function(dirty) -- user clicked OK
         if dirty then
            local editor = WinCls:getInstance()
            local trig   = editor.stack:last()
            assert(trig ~= nil)
            trig.dirty = true
            editor:refresh()
         end
      end
   ):fail(
      function() -- user clicked Cancel
      end
   )
end
function WinCls:moveOpcode(opcode, direction)
   local list
   local pane
   local trig = self.stack:last()
   assert(trig ~= nil)
   if opcode.type == "condition" then
      list = trig.working.conditions
      pane = self.ui.paneConditions
   else
      list = trig.working.actions
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
   trig.dirty = true
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
         local trig = w.stack:last()
         assert(trig ~= nil)
         if opcode.type == "condition" then
            pane = w.ui.paneConditions
            list = trig.working.conditions
         else
            pane = w.ui.paneActions
            list = trig.working.actions
         end
         local index = pane:indexOf(opcode)
         trig.dirty = true
         table.remove(list, index)
         pane:remove(index)
      end,
      self
   )
end

function WinCls:onNameChanged()
   if self.refreshing then
      return
   end
   local edit = self.ui.triggerNameField
   local trig = self.stack:last()
   assert(trig ~= nil)
   trig.working.name = edit:GetText()
   trig.dirty = true
end
function WinCls:onEntryPointsChanged()
   if self.refreshing then
      return
   end
   local combobox = self.ui.entryPointsCombobox
   local trig     = self.stack:first()
   assert(trig ~= nil)
   local result = {}
   local points = combobox:getSelectedItems()
   for i = 1, #points do
      result[i] = points[i].value
   end
   trig.working.entryPoints = result
   trig.dirty = true
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
   self.stack:pop(false)
   if self.stack:count() == 0 then
      --
      -- We just finished editing the top-level trigger.
      --
      self.pendingResults.outcome = false
      self.pendingResults.results = nil
      self:hide()
   else
      self:refresh()
   end
end
function WinCls:commit()
   local alreadyDirty = self.stack:dirty()
   self.stack:pop(true)
   if self.stack:count() == 0 then
      --
      -- We just finished editing the top-level trigger.
      --
      self.pendingResults.outcome = true
      self.pendingResults.results = nil
      self:hide()
   else
      if alreadyDirty then
         --
         -- Committing changes to a nested trigger should count as changing 
         -- the parent trigger.
         --
         self.stack:dirty(true)
      end
      self:refresh()
   end
end
function WinCls:onHide()
   self.stack:clear()
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
   if self.stack:dirty() then
      return self:showModal(ItemTrig.windows.genericConfirm, {
         text = GetString(ITEMTRIG_STRING_UI_TRIGGEREDIT_ABANDON_UNSAVED_CHANGES),
         showCloseButton = false
      })
   end
   return ItemTrig.Deferred:resolve()
end
function WinCls:requestEdit(opener, trigger, dirty, mustBeTopLevel)
   assert(opener  ~= nil, "The trigger editor must be aware of its opener.")
   assert(trigger ~= nil, "No trigger.")
   --assert(self:getModalOpener() == nil, "The trigger editor is already showing!")
   local deferred
   local sentinel
   if self.stack:count() == 0 then
      deferred = opener:showModal(self)
      if not deferred then
         return
      end
      self.stack:push(trigger, dirty)
   else
      assert(not mustBeTopLevel, "A trigger is already being edited.")
      deferred = self.stack:push(trigger, dirty)
      sentinel = ITEMTRIG_TRIGGER_EDIT_HAS_OPENED_NESTED_TRIGGER
   end
   self.ui.paneConditions:select(nil)
   self.ui.paneActions:select(nil)
   --self.stack:dirty(dirty or false) -- needed here since SetText fires a change handler
   self:refresh()
   return deferred, sentinel
end
function WinCls:refresh()
   self.refreshing = true
   local trig    = self.stack:last()
   assert(trig ~= nil)
   local trigger    = trig.working
   local isTopLevel = self.stack:count() == 1
   do -- window title
      local baseTitle = GetString(ITEMTRIG_STRING_UI_TRIGGEREDIT_TITLE_EDIT)
      local rootName  = ""
      if isTopLevel then
         if trig.isNew then
            baseTitle = GetString(ITEMTRIG_STRING_UI_TRIGGEREDIT_TITLE_NEW)
         end
      else
         rootName = self.stack:first().working.name
         if trig.isNew then
            baseTitle = GetString(ITEMTRIG_STRING_UI_TRIGGEREDIT_TITLE_NEW_NESTED)
         else
            baseTitle = GetString(ITEMTRIG_STRING_UI_TRIGGEREDIT_TITLE_EDIT_NESTED)
         end
      end
      self:setTitle(LocalizeString(baseTitle, rootName))
   end
   self.ui.triggerNameField:SetText(trigger.name)
   do -- render entry points
      local nameBar  = self:GetNamedChild("NameBar")
      local bar      = self.ui.entryPointsBar
      local combobox = self.ui.entryPointsCombobox
      local body     = self:GetNamedChild("Col1")
      local bottom   = self:GetNamedChild("Bottom")
      if isTopLevel then
         bar:SetHidden(false)
         body:ClearAnchors()
         body:SetAnchor(TOPLEFT,     bar,    BOTTOMLEFT, 0, 7)
         body:SetAnchor(BOTTOMRIGHT, bottom, TOPRIGHT,   0, -7)
         --
         combobox:close()
         combobox:deselectAll()
         for i = 1, #trigger.entryPoints do
            combobox:addToSelection(function(data) return data.value == trigger.entryPoints[i] end)
         end
         combobox:redraw()
      else
         combobox:close()
         combobox:deselectAll()
         --
         bar:SetHidden(true)
         body:SetAnchor(TOPLEFT,     nameBar, BOTTOMLEFT, 0, 7)
         body:SetAnchor(BOTTOMRIGHT, bottom,  TOPRIGHT,   0, -7)
      end
   end
   do -- render conditions
      local pane = self.ui.paneConditions
      pane:clear(false)
      for i = 1, #trigger.conditions do
         pane:push(trigger.conditions[i], false)
      end
      pane:redraw()
   end
   do -- render actions
      local pane = self.ui.paneActions
      pane:clear(false)
      for i = 1, #trigger.actions do
         pane:push(trigger.actions[i], false)
      end
      pane:redraw()
   end
   self.refreshing = false
end