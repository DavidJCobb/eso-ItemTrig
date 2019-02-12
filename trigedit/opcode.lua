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
   self:setTitle(GetString(ITEMTRIG_STRING_UI_OPCODEEDIT_TITLE))
   --
   local control = self:asControl()
   ItemTrig.assign(self, {
      ui = {
         fragment   = nil,
         opcodeType = nil,
         opcodeBody = nil,
      },
      settingUp = false,
      opcode = {
         target  = nil, -- the opcode we want to edit (i.e. Opcode* other)
         working = nil, -- a copy of that opcode; we make changes to it and then commit to (target) later
         dirty   = false,
      },
      pendingResults = {
         outcome = false, -- true to resolve; false to reject
         results = nil,   -- param to send back
      },
   })
   do -- scene setup
      self.ui.fragment = ZO_SimpleSceneFragment:New(control, "ITEMTRIG_ACTION_LAYER_OPCODEEDIT")
      ItemTrig.SCENE_TRIGEDIT:AddFragment(self.ui.fragment)
      SCENE_MANAGER:RegisterTopLevel(control, false)
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
      --self.ui.opcodeType:SetSortsItems(true) -- TODO
   end
   self.ui.opcodeBody = ItemTrig_OpcodeEdit_OpcodeBody
   --
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
function WinCls:requestEdit(opener, opcode, dirty)
   assert(opener        ~= nil, "The opcode editor must be aware of its opener.")
   assert(opcode        ~= nil, "No opcode.")
   assert(opcode.base   ~= nil, "Opcode is invalid.")
   assert(self:getModalOpener() == nil, "The opcode editor is already showing!")
   local deferred = opener:showModal(self)
   if not deferred then
      return
   end
   self.settingUp = true
   self.opcode.target  = opcode
   self.opcode.working = opcode:clone(true)
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
      for i = 1, table.getn(list) do
         local base = list[i]
         --
         -- ZO_ScrollableComboBox uses ZO_ScrollList under the hood. The data entries 
         -- we add to the list are shown by accessing their "name" field, so we'd want 
         -- to pass structs like { name = base.name, base = base }. (We wouldn't want 
         -- to pass the OpcodeBase instances directly, as ZO_ScrollList tracks state 
         -- by storing it directly on the data items we push into it.)
         --
         combobox:push({ name = base.name, base = base }, false)
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
   --
   -- It's impossible to combine formatting codes (i.e. color, underline) with 
   -- links, and custom links cannot have color. We "solve" this by using two 
   -- separate text elements: an invisible (zero-alpha) one on top, with click-
   -- able links; and a visible one beneath it, with the exact same text, but 
   -- colored and underlined as appropriate.
   --
   local rendered = self.opcode.working:format(
      function(s, i)
         --return ZO_LinkHandler_CreateLink(s, nil, "ItemTrigOpcodeEditArg", i)
         return ZO_LinkHandler_CreateLinkWithFormat(s, nil, "ItemTrigOpcodeEditArg", 0, "|H%d:%s|h%s|h", i) -- link without brackets
      end
   )
   self.ui.opcodeBody:SetText(rendered)
   --
   rendered = self.opcode.working:format(
      function(s, i)
         local color = "70B0FF"
         if i == options.highlightIndex then
            color = "EE3333"
         end
         local fmt = string.format("|c%s|l0:1:1:3:1:%s|l", color, color)
         return string.format(fmt .. "%s|l|r", s)
      end
   )
   ItemTrig_OpcodeEdit_OpcodeBodyUnderlay:SetText(rendered)
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
end

function WinCls:onLinkClicked(linkData, linkText, mouseButton, ctrl, alt, shift, command)
   if self.settingUp then
      return
   end
   local editor   = ItemTrig.windows.opcodeEdit
   local params   = ItemTrig.split(linkData, ":") -- includes the link style and type
   local argIndex = tonumber(params[3])
   local deferred = ItemTrig.windows.opcodeArgEdit:requestEdit(editor, editor.opcode.working, argIndex)
   self:redrawDescription({ highlightIndex = argIndex })
   deferred:done(
      function(context, deferred, result) -- user clicked OK
         local editor  = WinCls:getInstance()
         local working = editor.opcode.working
         local index   = result.argIndex
         if working.args[index] ~= result.value then
            working.args[index] = result.value
            editor.opcode.dirty = true
            editor:refresh()
         end
      end
   ):fail(
      function(context, deferred) -- user clicked Cancel
         WinCls:getInstance():redrawDescription()
      end
   )
end