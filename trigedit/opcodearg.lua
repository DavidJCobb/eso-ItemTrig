if not ItemTrig then return end

local WinCls = ItemTrig.UI.WSingletonWindow:makeSubclass("OpcodeArgEditWindow")
ItemTrig:registerWindow("opcodeArgEdit", WinCls)

local ViewCls = {}
do -- helper classes for views
   do -- enum
      ViewCls.Enum = ItemTrig.UI.WViewHolderView:makeSubclass("OpcodeArgEnumView")
      function ViewCls.Enum:_construct()
         self.value = ItemTrig.UI.WCombobox:cast(self:GetNamedChild("Value"))
         self.value.onChange =
            function()
               local win = ItemTrig.windows.opcodeArgEdit
               if win then -- the view initializes before the window, so this can run early
                  win:onArgumentEdited()
               end
            end
         self.value:setShouldSort(true, false)
      end
      function ViewCls.Enum:GetValue()
         local x = self.value:getSelectedData()
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
   do -- number
      ViewCls.Number = ItemTrig.UI.WViewHolderView:makeSubclass("OpcodeArgNumberView")
      function ViewCls.Number:_construct()
         self.value = self:GetNamedChild("Value")
      end
      function ViewCls.Number:GetValue()
         return tonumber(self.value:GetText())
      end
   end
   do -- quantity
      ViewCls.Quantity = ItemTrig.UI.WViewHolderView:makeSubclass("OpcodeArgQuantityView")
      function ViewCls.Quantity:_construct()
         self.number    = self:GetNamedChild("Number")
         self.qualifier = ItemTrig.UI.WCombobox:cast(self:GetNamedChild("Qualifier"))
         --
         local qualifier = self.qualifier
         qualifier.onChange =
            function()
               local win = ItemTrig.windows.opcodeArgEdit
               if win then -- the view initializes before the window, so this can run early
                  win:onArgumentEdited()
               end
            end
         qualifier:clear()
         qualifier:push({ name = GetString(ITEMTRIG_STRING_QUALIFIERPREFIX_ATLEAST), value = "GTE" }, false)
         qualifier:push({ name = GetString(ITEMTRIG_STRING_QUALIFIERPREFIX_ATMOST),  value = "LTE" }, false)
         qualifier:push({ name = GetString(ITEMTRIG_STRING_QUALIFIERPREFIX_EXACTLY), value = "E"   }, false)
         qualifier:push({ name = GetString(ITEMTRIG_STRING_QUALIFIERPREFIX_NOTEQ),   value = "NE"  }, false)
         qualifier:redraw()
      end
      function ViewCls.Quantity:GetValue()
         local q = {
            qualifier = self.qualifier:getSelectedData(),
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
   do -- quantity-enum
      ViewCls.QuantityEnum = ItemTrig.UI.WViewHolderView:makeSubclass("OpcodeArgQuantityEnumView")
      function ViewCls.QuantityEnum:_construct()
         self.enum      = ItemTrig.UI.WCombobox:cast(self:GetNamedChild("Number"))
         self.qualifier = ItemTrig.UI.WCombobox:cast(self:GetNamedChild("Qualifier"))
         --
         local qualifier = self.qualifier
         qualifier.onChange =
            function()
               local win = ItemTrig.windows.opcodeArgEdit
               if win then -- the view initializes before the window, so this can run early
                  win:onArgumentEdited()
               end
            end
         self.enum.onChange = qualifier.onChange
         qualifier:clear()
         qualifier:push({ name = GetString(ITEMTRIG_STRING_QUALIFIERPREFIX_ATLEAST), value = "GTE" }, false)
         qualifier:push({ name = GetString(ITEMTRIG_STRING_QUALIFIERPREFIX_ATMOST),  value = "LTE" }, false)
         qualifier:push({ name = GetString(ITEMTRIG_STRING_QUALIFIERPREFIX_EXACTLY), value = "E"   }, false)
         qualifier:push({ name = GetString(ITEMTRIG_STRING_QUALIFIERPREFIX_NOTEQ),   value = "NE"  }, false)
         qualifier:redraw()
      end
      function ViewCls.QuantityEnum:GetValue()
         local q = { qualifier = self.qualifier:getSelectedData() }
         local s = self.enum:getSelectedData()
         if s then
            q.number = s.value
         end
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
         viewholder = nil, -- WViewHolder
         views = {
            checkbox  = nil, -- TODO
            enum      = nil,
            multiline = nil,
            number    = nil, -- TODO
            quantity  = nil,
            quantEnum = nil,
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
      local viewholder   = ItemTrig.UI.WViewHolder:cast(self:GetNamedChild("Body"))
      self.ui.viewholder = viewholder
      self.ui.views.enum      = ViewCls.Enum:install(viewholder:GetNamedChild("Enum"))
      self.ui.views.multiline = ViewCls.String:install(viewholder:GetNamedChild("Multiline"))
      self.ui.views.number    = ViewCls.Number:install(viewholder:GetNamedChild("Number"))
      self.ui.views.quantity  = ViewCls.Quantity:install(viewholder:GetNamedChild("Quantity"))
      self.ui.views.quantEnum = ViewCls.QuantityEnum:install(viewholder:GetNamedChild("QuantityEnum"))
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
      local enum = arg.enum
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
         combobox:clear()
         for k, v in pairs(enum) do
            combobox:push({ name = v, index = k }, false)
         end
         combobox:redraw()
         combobox:select(1) -- default selection in case qualifier is invalid; boolean arg suppresses "change" callback
         combobox:select(function(item) return item.index == tonumber(val) end)
      elseif archetype == "multiline" then
         self.view = self.ui.views.multiline
         self.view:show()
         self.view.value:SetText(val or "")
      elseif archetype == "number" then
         self.view = self.ui.views.number
         self.view:show()
         self.view.value:SetText(tostring(val))
      elseif archetype == "quantity" then
         self.view = self.ui.views.quantity
         self.view:show()
         self.view.qualifier:select(1) -- default selection in case qualifier is invalid; boolean arg suppresses "change" callback
         self.view.qualifier:select(function(item) return item.value == val.qualifier end)
         self.view.number:SetText(val.number or "0")
      elseif archetype == "quantity-enum" then
         self.view = self.ui.views.quantEnum
         self.view:show()
         self.view.qualifier:select(1) -- default selection in case qualifier is invalid; boolean arg suppresses "change" callback
         self.view.qualifier:select(function(item) return item.value == val.qualifier end)
         self.view.enum:clear()
         for k, v in pairs(enum) do
            self.view.enum:push({ name = v, value = k })
         end
         self.view.enum:redraw()
         self.view.enum:select(1) -- default
         self.view.enum:select(function(item) return item.index == tonumber(val) end)
      elseif archetype == "string" then
         self.view = self.ui.views.string
         self.view:show()
         self.view.value:SetText(val or "")
      end
      assert(self.view ~= nil, "No view for this archetype: " .. tostring(archetype) .. "! Did you forget to make one?")
   end
   self:autoSize()
   self.dirty = false -- writing to UI controls may trigger "change" handlers, so set this here
   return deferred
end
function WinCls:autoSize()
   if not self.view then
      return
   end
   local window   = self:asControl()
   local viewhold = self.ui.viewholder:asControl()
   local view     = self.view:asControl()
   window:SetWidth (window:GetWidth()  - viewhold:GetWidth()  + view:GetWidth())
   window:SetHeight(window:GetHeight() - viewhold:GetHeight() + view:GetHeight())
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