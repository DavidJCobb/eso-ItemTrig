if not ItemTrig then return end

local WinCls = ItemTrig.UI.WSingletonWindow:makeSubclass("OpcodeArgEditWindow")
ItemTrig:registerWindow("opcodeArgEdit", WinCls)

local ViewCls = {}
do -- helper classes for views
   do -- enum
      ViewCls.Enum = ItemTrig.UI.WViewHolderView:makeSubclass("OpcodeArgEnumView")
      function ViewCls.Enum:_construct()
         self.value = ZO_ComboBox_ObjectFromContainer(self:GetNamedChild("Value"))
      end
      function ViewCls.Enum:GetValue()
         local x = self.value:GetSelectedItemData()
         if x then
            x = x.index
            if WinCls:getInstance().type == "boolean" then
               --
               -- Convert from enum index to boolean.
               --
               x = (x == 2)
            end
            return x
         end
      end
   end
   do -- quantity
      ViewCls.Quantity = ItemTrig.UI.WViewHolderView:makeSubclass("OpcodeArgQuantityView")
      function ViewCls.Quantity:_construct()
         self.number    = self:GetNamedChild("Number")
         self.qualifier = ZO_ComboBox_ObjectFromContainer(self:GetNamedChild("Qualifier"))
         --
         local qualifier = self.qualifier
         qualifier:ClearItems()
         qualifier:AddItem({ name = GetString(ITEMTRIG_STRING_QUALIFIERPREFIX_ATLEAST), value = "GTE", callback = function() ItemTrig.windows.opcodeArgEdit:onArgumentEdited() end }, ZO_COMBOBOX_SUPRESS_UPDATE)
         qualifier:AddItem({ name = GetString(ITEMTRIG_STRING_QUALIFIERPREFIX_ATMOST),  value = "LTE", callback = function() ItemTrig.windows.opcodeArgEdit:onArgumentEdited() end }, ZO_COMBOBOX_SUPRESS_UPDATE)
         qualifier:AddItem({ name = GetString(ITEMTRIG_STRING_QUALIFIERPREFIX_EXACTLY), value = "E",   callback = function() ItemTrig.windows.opcodeArgEdit:onArgumentEdited() end }, ZO_COMBOBOX_SUPRESS_UPDATE)
         qualifier:UpdateItems()
      end
      function ViewCls.Quantity:GetValue()
         local q = {
            qualifier = self.qualifier:GetSelectedItemData(),
            number    = tonumber(self.number:GetText() or 0)
         }
         if q.qualifier then
            q.qualifier = q.qualifier.value
         else
            q.qualifier = "E"
         end
         return q
      end
   end
   do -- string
      ViewCls.String = ItemTrig.UI.WViewHolderView:makeSubclass("OpcodeArgStringView")
      function ViewCls.String:_construct()
         self.value = self:GetNamedChild("Value")
      end
      function ViewCls.String:GetValue()
         return self.value:GetText()
      end
   end
end

function WinCls:_construct()
   self:setTitle(GetString(ITEMTRIG_STRING_UI_OPCODEARGEDIT_TITLE))
   --
   local control = self:asControl()
   ItemTrig.assign(self, {
      ui = {
         views = {
            checkbox  = nil, -- TODO
            enum      = nil,
            multiline = nil,
            number    = nil, -- TODO
            quantity  = nil,
            string    = nil,
         },
      },
      view     = nil, -- one of the "views" objects above
      type     = nil, -- raw argument type, not ui type; i.e. boolean, number, string, quantity
      opcode   = nil, -- Opcode
      argIndex = nil, -- number
      dirty    = false,
      pendingResults = {
         outcome = false, -- true to resolve; false to reject
         results = nil,   -- param to send back
      },
   })
   do -- scene setup
      self.ui.fragment = ZO_SimpleSceneFragment:New(control, "ITEMTRIG_ACTION_LAYER_OPCODEARGEDIT")
      ItemTrig.SCENE_TRIGEDIT:AddFragment(self.ui.fragment)
      SCENE_MANAGER:RegisterTopLevel(control, false)
   end
   do
      local viewholder = ItemTrig.UI.WViewHolder:cast(self:GetNamedChild("Body"))
      self.ui.views.enum      = ViewCls.Enum:install(viewholder:GetNamedChild("Enum"))
      self.ui.views.multiline = ViewCls.String:install(viewholder:GetNamedChild("Multiline"))
      self.ui.views.quantity  = ViewCls.Quantity:install(viewholder:GetNamedChild("Quantity"))
      self.ui.views.string    = ViewCls.String:install(viewholder:GetNamedChild("String"))
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
function WinCls:requestEdit(opener, opcode, argIndex)
   assert(opener ~= nil,      "The argument editor must be aware of its opener.")
   assert(opcode ~= nil,      "No opcode.")
   assert(argIndex ~= nil,    "No argument index.")
   assert(opcode.base ~= nil, "Opcode is invalid.")
   assert(self:getModalOpener() == nil, "The argument editor is already showing!")
   local deferred = opener:showModal(self)
   if not deferred then
      return
   end
   self.opcode   = opcode
   self.argIndex = argIndex
   self.view     = nil
   do
      local base = opcode.base
      local val  = opcode.args[argIndex]
      local arg  = base.args[argIndex]
      local archetype = base:getArgumentArchetype(argIndex)
      self.type = arg.type
      if archetype == "checkbox" then
         self.view = self.ui.views.checkbox
         --
         -- TODO
         --
      elseif archetype == "enum" then
         self.view = self.ui.views.enum
         if arg.type == "boolean" then
            val = val and 2 or 1
         end
         self.view:show()
         local combobox = self.view.value
         combobox:ClearItems()
         for i = 1, table.getn(arg.enum) do
            combobox:AddItem(
               {
                  name     = arg.enum[i],
                  index    = i,
                  callback = function() ItemTrig.windows.opcodeArgEdit:onArgumentEdited() end
               },
               ZO_COMBOBOX_SUPRESS_UPDATE
            )
         end
         combobox:UpdateItems()
         combobox:SelectItemByIndex(1, true) -- default selection in case qualifier is invalid; boolean arg suppresses "change" callback
         combobox:SetSelectedItemByEval(function(item) return item.index == tonumber(val) end)
      elseif archetype == "multiline" then
         self.view = self.ui.views.multiline
         self.view:show()
         self.view.value:SetText(val or "")
      elseif archetype == "number" then
         self.view = self.ui.views.number
         --
         -- TODO
         --
      elseif archetype == "quantity" then
         self.view = self.ui.views.quantity
         self.view:show()
         self.view.qualifier:SelectItemByIndex(1, true) -- default selection in case qualifier is invalid; boolean arg suppresses "change" callback
         self.view.qualifier:SetSelectedItemByEval(function(item) return item.value == val.qualifier end)
         self.view.number:SetText(val.number or "0")
      elseif archetype == "string" then
         self.view = self.ui.views.string
         self.view:show()
         self.view.value:SetText(val or "")
      end
      --
      -- TODO: compress window size
      --
   end
   self.dirty = false -- writing to UI controls may trigger "change" handlers, so set this here
   return deferred
end
function WinCls:onArgumentEdited()
   self.dirty = true
end
function WinCls:unsavedChangesMatter()
   --
   -- OpcodeArgEdit only warns if you're about to discard an unsaved change 
   -- that's actually effortful. Flipping a boolean isn't effortful; chang-
   -- ing text more often is.
   --
   if not self.dirty or not self.view then
      return false
   end
   return self.opcode:isArgumentEffortful(self.argIndex, self.view:GetValue())
end
function WinCls:cancel()
   assert(self.opcode ~= nil, "Can't stop editing an argument if we aren't editing one yet.")
   local deferred
   if self:unsavedChangesMatter() then
      deferred = self:showModal(ItemTrig.windows.genericConfirm, {
         text = GetString(ITEMTRIG_STRING_UI_OPCODEARGEDIT_ABANDON_UNSAVED_CHANGES),
         showCloseButton = false
      })
   else
      deferred = ItemTrig.Deferred:resolve()
   end
   deferred:done(
      function(w)
         w.pendingResults.outcome = false
         w.pendingResults.results = nil
         w:hide() -- onHide does cleanup
      end,
      self
   )
end
function WinCls:commit()
   assert(self.argIndex ~= nil, "Don't know what argument index to commit.")
   assert(self.view     ~= nil, "Don't know what kind of value to commit.")
   self.pendingResults.outcome = true
   self.pendingResults.results = {
      argIndex = self.argIndex,
      value    = self.view:GetValue()
   }
   self:hide() -- onHide does cleanup
end
function WinCls:onHide()
   self.view     = nil
   self.type     = nil
   self.argIndex = nil
   self.opcode   = nil
   self.dirty    = false
end