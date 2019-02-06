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

local Window = {}
local WinCls = ItemTrig.UI.WWindow:makeSubclass("OpcodeEditWindow")
function WinCls:_construct()
   ItemTrig.windows.opcodeEdit = self
   self:setTitle(GetString(ITEMTRIG_STRING_UI_OPCODEEDIT_TITLE))
   --
   local control = self:asControl()
   ItemTrig.assign(self, {
      ui = {
         fragment   = nil,
         opcodeType = nil,
         opcodeBody = nil,
      },
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
   self.ui.opcodeType = ZO_ComboBox_ObjectFromContainer(ItemTrig_OpcodeEdit_Opcode)
   self.ui.opcodeBody = ItemTrig_OpcodeEdit_OpcodeBody
   --
   self.ui.opcodeType:SetSortsItems(true)
end

ItemTrig.OpcodeEditWindow = {}
function ItemTrig.OpcodeEditWindow:OnInitialized(control)
   ItemTrig.OpcodeEditWindow = WinCls:install(control)
   Window = ItemTrig.OpcodeEditWindow
end

--

function WinCls:_handleModalDeferredOnHide(deferred)
   if self.pendingResults.outcome then
      deferred:resolve(self.pendingResults.results)
   else
      deferred:reject(self.pendingResults.results)
   end
end
function WinCls:onCloseClicked()
   if self:requestExit() then
      self:abandon()
   end
end
function WinCls:close()
   assert(self.deferred == nil, "Can't close the OpcodeEdit window -- we still have to notify its opener!")
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
      --
      -- TODO: prompt for confirmation; same as above
      --
      return false
   end
   return true
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
   self.opcode.target  = opcode
   self.opcode.working = opcode:clone(true)
   self.opcode.dirty   = dirty or false
   do
      local function _onSelect(combobox, name, item, selectionChanged, oldItem)
         if selectionChanged then
            Window:_onTypeChanged(item.base)
         end
      end
      local list
      if opcode.type == "condition" then
         list = ItemTrig.tableConditions
         self:setTitle(GetString(ITEMTRIG_STRING_UI_OPCODEEDIT_TITLE_C))
      else
         list = ItemTrig.tableActions
         self:setTitle(GetString(ITEMTRIG_STRING_UI_OPCODEEDIT_TITLE_A))
      end
      local combobox = self.ui.opcodeType
      combobox:ClearItems()
      for i = 1, table.getn(list) do
         local base = list[i]
         --
         -- ZO_ScrollableComboBox uses ZO_ScrollList under the hood. The data entries 
         -- we add to the list are shown by accessing their "name" field, so we'd want 
         -- to pass structs like { name = base.name, base = base }. (We wouldn't want 
         -- to pass the OpcodeBase instances directly, as ZO_ScrollList tracks state 
         -- by storing it directly on the data items we push into it.)
         --
         combobox:AddItem({ name = base.name, base = base, callback = _onSelect }, ZO_COMBOBOX_SUPRESS_UPDATE)
      end
      combobox:UpdateItems()
   end
   self:refresh()
   --
   return deferred
end
function WinCls:_onTypeChanged(opcodeBase)
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
   self.opcode.working.base = opcodeBase
   self.opcode.working:resetArgs()
   self:refresh()
end
function WinCls:refresh() -- Render the opcode being edited.
   do -- opcode type
      local opcodeBase = self.opcode.working.base
      local combobox   = self.ui.opcodeType
      combobox:SetSelectedItemByEval(function(item) return item.base == opcodeBase end)
   end
   do -- opcode body
      --
      -- It's impossible to combine formatting codes (i.e. color, underline) with 
      -- links, and custom links cannot have color. We "solve" this by using two 
      -- separate text elements: an invisible (zero-alpha) one on top, with click-
      -- able links; and a visible one beneath it, with the exact same text, but 
      -- colored and underlined as appropriate.
      --
      local rendered = self.opcode.working:format(
         function(s, i)
            return ZO_LinkHandler_CreateLink(s, nil, "ItemTrigOpcodeEditArg", i)
         end
      )
      self.ui.opcodeBody:SetText(rendered)
      --
      rendered = self.opcode.working:format(
         function(s, i)
            return string.format("|c70B0FF|l0:1:1:3:1:70B0FF|l%s|l|r", s)
         end
      )
      ItemTrig_OpcodeEdit_OpcodeBodyUnderlay:SetText(rendered)
   end
end

function WinCls:onLinkClicked(linkData, linkText, mouseButton, ctrl, alt, shift, command)
   local editor   = ItemTrig.windows.opcodeEdit
   local params   = ItemTrig.split(linkData, ":") -- includes the link style and type
   local argIndex = tonumber(params[3])
   local deferred = ItemTrig.windows.opcodeArgEdit:requestEdit(editor, editor.opcode.working, argIndex)
   deferred:done(
      function(context, deferred, result) -- user clicked OK
         local working = Window.opcode.working
         local index   = result.argIndex
         if working.args[index] ~= result.value then
            working.args[index] = result.value
            Window.opcode.dirty = true
            Window:refresh()
         end
      end
   ):fail(
      function(context, deferred) -- user clicked Cancel
      end
   )
end