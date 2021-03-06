if not ItemTrig then return end

--[[--
   The workflow for the opcode editor is as follows:
   
    * Store a reference to the opcode we wish to edit, akin to 
      C++ {Opcode* original;}.
   
    * Create and store a copy of that opcode, and make our edits 
      to the copy.
   
    * If the user cancels their changes, then we just destroy 
      the copy.
   
    * If the user commits their changes, then we overwrite each 
      field on the original opcode with the values in the copy; 
      think of C++ {*original = copy;}. We've created a method 
      for this purpose: Opcode:copyAssign.
--]]--

local WinCls = ItemTrig.UI.WSingletonWindow:makeSubclass("OpcodeEditWindow")
ItemTrig:registerWindow("opcodeEdit", WinCls)

function WinCls:_construct()
   self:pushActionLayer("ItemTrigBlockMostKeys")
   self:setTitle(GetString(ITEMTRIG_STRING_UI_OPCODEEDIT_TITLE))
   --
   local control = self:asControl()
   ItemTrig.assign(self, {
      ui = {
         fragment   = nil,
         opcodeType = nil,
         opcodeBody = nil,
         nestedTriggerEnable = nil,
      },
      settingUp   = false,
      entryPoints = {},
      opcode = {
         target  = nil, -- the opcode we want to edit (i.e. Opcode* other)
         working = nil, -- a copy of that opcode; we make changes to it and then commit to (target) later
         dirty   = false,
         isNew   = false,
      },
      pendingResults = {
         outcome = false, -- true to resolve; false to reject
         results = nil,   -- param to send back
      },
   })
   do -- scene setup
      --[[self.ui.fragment = ZO_SimpleSceneFragment:New(control)
      ItemTrig.SCENE_TRIGEDIT:AddFragment(self.ui.fragment)
      SCENE_MANAGER:RegisterTopLevel(control, false)]]--
      self.ui.fragment = ItemTrig.registerTrigeditWindowFragment(control)
   end
   do -- combobox setup
      self.ui.opcodeType = ItemTrig.UI.WCombobox:cast(ItemTrig_OpcodeEdit_Opcode)
      local combobox = self.ui.opcodeType
      combobox.onChange =
         function(combobox)
            local item = combobox:getSelectedData()
            if item then -- this handler can fire when the combobox is cleared
               WinCls:getInstance():_onTypeChanged(item.base)
            end
         end
      self.ui.opcodeType:setShouldSort(true, false)
      combobox:autocompleteEnabled(true)
   end
   self.ui.opcodeBody  = ItemTrig_OpcodeEdit_OpcodeBody
   self.ui.explanation = self:GetNamedChild("Explanation")
   --
   self.ui.nestedTriggerEnable = GetControl(ItemTrig_OpcodeEdit_NestedTriggerHack, "Enabled")
   self.ui.nestedTriggerEnable.toggleFunction =
      function(self, checked)
         local editor = WinCls:getInstance()
         local opcode = editor.opcode.working
         if opcode.base ~= ItemTrig.TRIGGER_ACTION_RUN_NESTED then
            return
         end
         opcode.args[1].enabled = checked
         editor.opcode.dirty = true
      end
end
function WinCls:handleModalDeferredOnHide(deferred)
   if self.pendingResults.outcome then
      deferred:resolve(self.pendingResults.results)
   else
      deferred:reject(self.pendingResults.results)
   end
end
function WinCls:onCloseClicked()
   self:cancel()
end
function WinCls:close()
   self.opcode.target  = nil
   self.opcode.working = nil
   self.opcode.dirty   = nil
   --
   -- TODO: reset UI state
   --
   self:hide()
end
function WinCls:abandon()
   self.pendingResults.outcome = false
   self.pendingResults.results = nil
   self:close()
end
function WinCls:cancel()
   self:requestExit():done(self.abandon, self)
end
function WinCls:commit()
   if self.opcode.dirty then
      self.opcode.target:copyAssign(self.opcode.working)
   end
   self.pendingResults.outcome = true
   self.pendingResults.results = self.opcode.dirty
   self:close()
end
function WinCls:requestExit()
   if self.opcode.dirty then
      return self:showModal(ItemTrig.windows.genericConfirm, {
         text = GetString(ITEMTRIG_STRING_UI_OPCODEEDIT_ABANDON_UNSAVED_CHANGES),
         showCloseButton = false
      })
   end
   return ItemTrig.Deferred:resolve()
end
function WinCls:requestEdit(opener, opcode, dirty, extra)
   assert(opener        ~= nil, "The opcode editor must be aware of its opener.")
   assert(opcode        ~= nil, "No opcode.")
   assert(opcode.base   ~= nil, "Opcode is invalid.")
   assert(self:getModalOpener() == nil, "The opcode editor is already showing!")
   local deferred = opener:showModal(self)
   if not deferred then
      return
   end
   if not extra then
      extra = {}
   end
   self.settingUp = true
   self.opcode.target  = opcode
   self.opcode.working = opcode:clone(true)
   self.opcode.isNew   = dirty or false
   self.entryPoints    = extra.entryPoints or {}
   do
      local list
      if opcode.type == "condition" then
         list = ItemTrig.tableConditions
         if dirty then
            self:setTitle(GetString(ITEMTRIG_STRING_UI_OPCODEEDIT_TITLE_C_NEW))
         else
            self:setTitle(GetString(ITEMTRIG_STRING_UI_OPCODEEDIT_TITLE_C))
         end
      else
         list = ItemTrig.tableActions
         if dirty then
            self:setTitle(GetString(ITEMTRIG_STRING_UI_OPCODEEDIT_TITLE_A_NEW))
         else
            self:setTitle(GetString(ITEMTRIG_STRING_UI_OPCODEEDIT_TITLE_A))
         end
      end
      local combobox = self.ui.opcodeType
      combobox:clear()
      for i = 1, #list do
         local base = list[i]
         if not base.deprecated or base == opcode.base then
            combobox:push({ name = base.name, base = base }, false)
         end
      end
      combobox:redraw()
   end
   self:refresh()
   self.opcode.dirty = dirty or false -- writing to UI controls during the above may trigger "change" handlers, so set this here
   self.settingUp = false
   --
   return deferred
end
function WinCls:_onTypeChanged(opcodeBase)
   if self.settingUp then
      return
   end
   local list
   if self.opcode.type == "condition" then
      list = ItemTrig.tableConditions
   else
      list = ItemTrig.tableActions
   end
   --
   -- TODO: If switching away from the Run Nested Trigger opcode-base, 
   -- warn the user that their data is going to be lost. (This would 
   -- mean making a confirmation dialogue modal that uses a Deferred, 
   -- similar to our existing modals, and then setting the following 
   -- lines up to run when that Deferred is resolved.)
   --
   self.opcode.dirty = true
   self.opcode.working.base = opcodeBase
   self.opcode.working:resetArgs()
   self:refresh()
end
function WinCls:redrawDescription(options)
   if not options then
      options = {}
   end
   local baseOp   = self.opcode.working.base
   local baseArgs = baseOp.args
   local function _formatTransform(fmt)
      if baseOp == ItemTrig.TRIGGER_ACTION_RUN_NESTED then
         return GetString(ITEMTRIG_STRING_ACTIONDESC_RUNNESTED_EDIT)
      end
      return fmt
   end
   local function _validateEntryPoints(i)
      local ep = baseArgs[i].allowedEntryPoints
      if not ep then
         return true
      end
      return ItemTrig.valuesOverlap(ep, self.entryPoints)
   end
   local triggerArgIndex = nil
   local triggerArgLink  = nil
   local triggerArgText  = nil
   --
   -- It's impossible to combine formatting codes (i.e. color, underline) with 
   -- links, and custom links cannot have color. We "solve" this by using two 
   -- separate text elements: an invisible (zero-alpha) one on top, with click-
   -- able links; and a visible one beneath it, with the exact same text, but 
   -- colored and underlined as appropriate.
   --
   -- Another dumb obstacle: When a format code has a start and an end, it will 
   -- also have an undocumented length limit; exceeding this length limit will 
   -- cause the displayed text to fail to display properly (e.g. the displayed 
   -- text will be truncated to just a couple characters, or similar problems).
   --
   local rendered = self.opcode.working:format(
      function(s, i)
         --return ZO_LinkHandler_CreateLink(s, nil, "ItemTrigOpcodeEditArg", i) -- can't use this; it inserts brackets
         if not _validateEntryPoints(i) then
            return s
         end
         s = ItemTrig.splitByCount(s, 200)
         local out = ""
         for j = 1, #s do
            out = out .. ZO_LinkHandler_CreateLinkWithFormat(s[j], nil, "ItemTrigOpcodeEditArg", 0, "|H%d:%s|h%s|h", i) -- link without brackets
         end
         if baseArgs[i].type == "trigger" then
            triggerArgIndex = i
            triggerArgLink  = out
            out = ""
         end
         return out
      end,
      _formatTransform
   )
   self.ui.opcodeBody:SetText(rendered)
   --
   rendered = self.opcode.working:format(
      function(s, i)
         if not _validateEntryPoints(i) then
            return s
         end
         s = ItemTrig.splitByCount(s, 200)
         local out   = ""
         local color = ItemTrig.getCurrentThemeString("OPCODE_ARGUMENT_LINK_NORMAL", true) or "70B0FF"
         if i == options.highlightIndex then
            color = ItemTrig.getCurrentThemeString("OPCODE_ARGUMENT_LINK_FOCUS", true) or "EE3333"
         end
         local fmt = LocalizeString("|c<<1>>|l0:1:1:5%:2.5:<<1>>|l", color) .. "<<1>>|l|r"
         for j = 1, #s do
            out = out .. LocalizeString(fmt, s[j])
         end
         if baseArgs[i].type == "trigger" then
            triggerArgText = out
            out = ""
         end
         return out
      end,
      _formatTransform
   )
   ItemTrig_OpcodeEdit_OpcodeBodyUnderlay:SetText(rendered)
   --
   do
      local node = ItemTrig_OpcodeEdit_NestedTriggerHack
      if triggerArgIndex then
         local show  = GetControl(node, "Underlay")
         local link  = GetControl(node, "Clickable")
         local check = GetControl(node, "Enabled")
         show:SetText(triggerArgText)
         link:SetText(triggerArgLink)
         do
            local state = self.opcode.working.args[triggerArgIndex].enabled
            if state then
               ZO_CheckButton_SetChecked(check)
            else
               ZO_CheckButton_SetUnchecked(check)
            end
         end
         node:SetHidden(false)
      else
         node:SetHidden(true)
      end
   end
   --
   -- If you have reason to believe that the opcode text may have changed, 
   -- make sure to call autoSize() at this point. You may also need to run 
   -- a zo_callLater(function() self:autoSize() end, 1) call, since text 
   -- doesn't always wrap/reflow/etc. properly on the same frame that it 
   -- has changed.
   --
end
function WinCls:refresh(options) -- Render the opcode being edited.
   if not options then
      options = {}
   end
   do -- opcode type
      local opcodeBase = self.opcode.working.base
      local combobox   = self.ui.opcodeType
      combobox:select(function(item) return item.base == opcodeBase end)
   end
   self:redrawDescription(options)
   do -- opcode explanation
      local node = self.ui.explanation
      local base = self.opcode.working.base or {}
      local text = base.explanation
      if not (text and text ~= "") then
         --
         -- If an opcode doesn't supply its own explanation, and if the opcode 
         -- can only be used from a specific entry point, then take this oppor-
         -- tunity to bring that to the user's attention.
         --
         -- NOTE: This doesn't handle the case of an opcode only allowing one 
         -- of a set of multiple entry points.
         --
         local list = base.allowedEntryPoints
         if list then
            local count  = #list
            if count == 1 then
               local format = GetString(ITEMTRIG_STRING_OPCODEEXPLANATION_GENERIC_EP)
               if self.opcode.working.type == "condition" then
                  format = GetString(ITEMTRIG_STRING_CONDITIONEXPLANATION_GENERIC_EP)
               elseif self.opcode.working.type == "action" then
                  format = GetString(ITEMTRIG_STRING_ACTIONEXPLANATION_GENERIC_EP)
               end
               local ep = ItemTrig.ENTRY_POINT_NAMES[list[1]]
               if ep then
                  text = LocalizeString(format, ep)
               end
            else
               local format = GetString(ITEMTRIG_STRING_OPCODEEXPLANATION_GENERIC_EP_MULTI)
               if self.opcode.working.type == "condition" then
                  format = GetString(ITEMTRIG_STRING_CONDITIONEXPLANATION_GENERIC_EP_MULTI)
               elseif self.opcode.working.type == "action" then
                  format = GetString(ITEMTRIG_STRING_ACTIONEXPLANATION_GENERIC_EP_MULTI)
               end
               local assembled = ""
               for i = 1, count do
                  local ep = ItemTrig.ENTRY_POINT_NAMES[list[i]]
                  if i > 1 then
                     assembled = assembled .. GetString(ITEMTRIG_STRING_OPCODEEXPLANATION_GENERIC_EP_MULTI_SEP)
                  end
                  assembled = assembled .. ep
               end
               text = LocalizeString(format, assembled)
            end
         end
      end
      if text and text ~= "" then
         node:SetText(text)
         node:SetHidden(false)
      else
         node:SetText("")
         node:SetHidden(true)
      end
   end
   self:autoSize()
   zo_callLater(function() self:autoSize() end, 1) -- in my experience, text doesn't always wrap/reflow/etc. on the same frame you edit it
end
function WinCls:autoSize()
   local window        = self:asControl()
   local explanation   = self.ui.explanation
   local _, baseH      = window:GetDimensionConstraints()
   local explNewHeight = explanation:IsHidden() and 0 or explanation:GetHeight()
   --
   local nodeOpcodeBody   = self.ui.opcodeBody
   local nodeNestedTrig   = ItemTrig_OpcodeEdit_NestedTriggerHack -- An additional line of text, used when editing the Run Nested Trigger action.
   local heightOpcodeBody = nodeOpcodeBody:GetHeight()
   local heightNestedTrig = 0
   if not nodeNestedTrig:IsHidden() then
      heightNestedTrig = GetControl(nodeNestedTrig, "Underlay"):GetHeight()
   end
   --
   local heightAllOthers
   do
      window:SetHeight(baseH) -- should force reflow immediately
      heightAllOthers = baseH - nodeOpcodeBody:GetParent():GetHeight()
   end
   --
   local desired = heightAllOthers + heightOpcodeBody + heightNestedTrig + explNewHeight
   if desired < baseH then
      desired = baseH
   end
   window:SetHeight(desired)
end

function WinCls:editNestedTriggerArgument(trigger)
   local editor = ItemTrig.windows.triggerEdit
   assert(editor.stack:count() > 0, "This is supposed to be a nested trigger!")
   local state = {
      working  = self.opcode.working,
      target   = self.opcode.target,
   }
   self.pendingResults.outcome = nil
   self.pendingResults.results = nil
   self:hide()
   local deferred, sentinel = editor:requestEdit(self, arg)
   assert(sentinel == ITEMTRIG_TRIGGER_EDIT_HAS_OPENED_NESTED_TRIGGER, "Something went wrong.")
   deferred:done(function()
      target:copyAssign(working)
   end)
end
function WinCls:onLinkClicked(linkData, linkText, mouseButton, ctrl, alt, shift, command)
   if self.settingUp then
      return
   end
   local params   = ItemTrig.split(linkData, ":") -- includes the link style and type
   local argIndex = tonumber(params[3])
   do -- Special-case: nested trigger options.
      local arg = self.opcode.working.args[argIndex]
      if arg and ItemTrig.Trigger:is(arg) then
         local editor = ItemTrig.windows.triggerEdit
         assert(editor.stack:count() > 0, "This is supposed to be a nested trigger!")
         local target = self.opcode.target
         --
         -- Unfortunately, we have to commit the opcode; if the user clicked the 
         -- "New" button and is making a new opcode, then this is the only way 
         -- to signal to the trigger-edit window that the new opcode needs to be 
         -- retained.
         --
         self:commit()
         local deferred, sentinel = editor:requestEdit(self, target.args[argIndex])
         assert(sentinel == ITEMTRIG_TRIGGER_EDIT_HAS_OPENED_NESTED_TRIGGER, "Something went wrong.")
         return
      end
   end
   local deferred = ItemTrig.windows.opcodeArgEdit:requestEdit(self, self.opcode.working, argIndex)
   self:redrawDescription({ highlightIndex = argIndex }) -- highlight the arg we're editing
   deferred:done(
      function(result) -- user clicked OK
         local editor  = WinCls:getInstance()
         local working = editor.opcode.working
         local index   = result.argIndex
         if working.args[index] ~= result.value then
            working.args[index] = result.value
            editor.opcode.dirty = true
            editor:refresh()
         else
            self:redrawDescription() -- un-highlight the arg we just edited
         end
      end
   ):fail(
      function() -- user clicked Cancel
         WinCls:getInstance():redrawDescription()
      end
   )
end