if not ItemTrig then return end

local WinCls = ItemTrig.UI.WSingletonWindow:makeSubclass("OpcodeArgEditWindow")
ItemTrig:registerWindow("opcodeArgEdit", WinCls)

local ViewCls = {}
do -- helper classes for views
   local WCombobox       = ItemTrig.UI.WCombobox
   local WNumberEditbox  = ItemTrig.UI.WNumberEditbox
   local WViewHolderView = ItemTrig.UI.WViewHolderView
   do -- enum
      ViewCls.Enum = WViewHolderView:makeSubclass("OpcodeArgEnumView")
      function ViewCls.Enum:_construct()
         self.value = WCombobox:cast(self:GetNamedChild("Value"))
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
      function ViewCls.Enum:SetupArgument(argValue, argBase, argIndex, opcodeBase)
         self:show()
         if argBase.type == "boolean" then
            argValue = argValue and 2 or 1
         end
         local combobox = self.value
         combobox:clear()
         opcodeBase:forEachInArgumentEnum(argIndex, function(k, v)
            combobox:push({ name = v, index = k }, false)
         end)
         combobox:redraw()
         combobox:select(1) -- default selection
         combobox:select(function(item) return item.index == tonumber(argValue) end)
      end
   end
   do -- number
      ViewCls.Number = WViewHolderView:makeSubclass("OpcodeArgNumberView")
      function ViewCls.Number:_construct()
         self.value = WNumberEditbox:install(self:GetNamedChild("Value"))
         self.value.onValidationStateChanged =
            function(widget, value, isNowValid)
               local color = ItemTrig.theme.TEXTEDIT_TEXT
               if not isNowValid then
                  color = ItemTrig.theme.TEXTEDIT_TEXT_WRONG
               end
               widget:asControl():SetColor(unpack(color))
            end
      end
      function ViewCls.Number:GetValue()
         return self.value:value()
      end
      function ViewCls.Number:SetupArgument(argValue, argBase, argIndex, opcodeBase)
         self:show()
         self.value:resetValidationConstraints()
         self.value:setValidationConstraints({
            min = argBase.min,
            max = argBase.max,
            requireInteger = argBase.requireInteger,
         })
         self.value:text(tostring(argValue))
      end
   end
   do -- quantity
      ViewCls.Quantity = WViewHolderView:makeSubclass("OpcodeArgQuantityView")
      function ViewCls.Quantity:_construct()
         self.number = WNumberEditbox:install(self:GetNamedChild("Number"))
         self.number.onValidationStateChanged =
            function(widget, value, isNowValid)
               local color = ItemTrig.theme.TEXTEDIT_TEXT
               if not isNowValid then
                  color = ItemTrig.theme.TEXTEDIT_TEXT_WRONG
               end
               widget:asControl():SetColor(unpack(color))
            end
         self.qualifier = WCombobox:cast(self:GetNamedChild("Qualifier"))
         self.argBase   = nil
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
         local qualifier = self.qualifier:getSelectedData()
         qualifier = qualifier and qualifier.value or "E"
         --
         local q = ItemTrig.OpcodeQuantityArg:new(
            qualifier,
            tonumber(self.number:GetText() or 0),
            nil,
            self.argBase
         )
         return q
      end
      function ViewCls.Quantity:SetupArgument(argValue, argBase, argIndex, opcodeBase)
         self.argBase = argBase
         self:show()
         self.qualifier:select(1) -- default selection in case qualifier is invalid
         self.qualifier:select(function(item) return item.value == argValue.qualifier end)
         self.number:resetValidationConstraints()
         self.number:setValidationConstraints({
            min = argBase.min,
            max = argBase.max,
            requireInteger = argBase.requireInteger,
         })
         self.number:SetText(argValue.number or "0")
      end
   end
   do -- quantity-enum
      ViewCls.QuantityEnum = WViewHolderView:makeSubclass("OpcodeArgQuantityEnumView")
      function ViewCls.QuantityEnum:_construct()
         self.enum      = WCombobox:cast(self:GetNamedChild("Number"))
         self.qualifier = WCombobox:cast(self:GetNamedChild("Qualifier"))
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
      function ViewCls.QuantityEnum:SetupArgument(argValue, argBase, argIndex, opcodeBase)
         self:show()
         self.qualifier:select(1) -- default selection in case qualifier is invalid
         self.qualifier:select(function(item) return item.value == argValue.qualifier end)
         self.enum:clear()
         opcodeBase:forEachInArgumentEnum(argIndex, function(k, v)
            self.enum:push({ name = v, value = k }, false)
         end)
         self.enum:redraw()
         self.enum:select(1) -- default
         self.enum:select(function(item) return item.value == tonumber(argValue.number) end)
      end
   end
   do -- string
      local _autoCompleteData = { entries = {} }
      local _AUTOCOMPLETE_FLAG =
         ZO_AutoComplete.AddFlag(
            function(results, input, onlineOnly, include)
               if ItemTrig.windows.opcodeArgEdit:asControl():IsHidden() then
                  --
                  -- This function affects textboxes that use the AUTO_COMPLETE_FLAG_ALL 
                  -- autocomplete type, so we need to be responsible and avoid tampering 
                  -- with the autocomplete results when our specific textbox isn't open.
                  --
                  return
               end
               for _, v in pairs(_autoCompleteData.entries) do
                  ZO_AutoComplete.IncludeOrExcludeResult(results, v, include)
               end
            end
         )
      --
      ViewCls.String = WViewHolderView:makeSubclass("OpcodeArgStringView")
      function ViewCls.String:_construct()
         self.value        = self:GetNamedChild("Value")
         self.autoComplete = ZO_AutoComplete:New(self.value, { _AUTOCOMPLETE_FLAG }, {}, AUTO_COMPLETION_ONLINE_ONLY, MAX_AUTO_COMPLETION_RESULTS, AUTO_COMPLETION_AUTOMATIC_MODE)
         --
         ZO_PreHookHandler(self:asControl(), "OnEffectivelyHidden",
            function(self)
               _autoCompleteData.entries = {}
            end
         )
      end
      function ViewCls.String:GetValue()
         return self.value:GetText()
      end
      function ViewCls.String:SetupArgument(argValue, argBase, argIndex, opcodeBase)
         self:show()
         self.value:SetText(argValue or "")
         --
         if argBase.autocompleteSet and ItemTrig.prefs:get("opcodeArgAutocomplete") then
            local s = argBase.autocompleteSet
            if type(s) == "function" then
               s = s()
            end
            _autoCompleteData.entries = s
         else
            _autoCompleteData.entries = {}
         end
      end
   end
end

function WinCls:_construct()
   self:pushActionLayer("ItemTrigBlockMostKeys")
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
         explanation = nil,
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
      --[[self.ui.fragment = ZO_SimpleSceneFragment:New(control)
      ItemTrig.SCENE_TRIGEDIT:AddFragment(self.ui.fragment)
      SCENE_MANAGER:RegisterTopLevel(control, false)]]--
      self.ui.fragment = ItemTrig.registerTrigeditWindowFragment(control)
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
      self.ui.explanation = self:GetNamedChild("Explanation")
      self.ui.explanation:SetColor(unpack(ItemTrig.theme.WINDOW_BARE_TEXT_COLOR))
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
      do -- Set up the view.
         local archetype = base:getArgumentArchetype(argIndex)
         self.type = arg.type
         if archetype == "checkbox" then
            self.view = self.ui.views.checkbox
            --
            -- TODO
            --
         elseif archetype == "enum" then
            self.view = self.ui.views.enum
         elseif archetype == "multiline" then
            self.view = self.ui.views.multiline
         elseif archetype == "number" then
            self.view = self.ui.views.number
         elseif archetype == "quantity" then
            self.view = self.ui.views.quantity
         elseif archetype == "quantity-enum" then
            self.view = self.ui.views.quantEnum
         elseif archetype == "string" then
            self.view = self.ui.views.string
         end
         self.view:SetupArgument(val, arg, argIndex, base)
         assert(self.view ~= nil, "No view for this archetype: " .. tostring(archetype) .. "! Did you forget to make one?")
      end
      do -- Set up the explanation
         local node = self.ui.explanation
         node:SetText(arg.explanation or "")
      end
   end
   self:autoSize()
   self.dirty = false -- writing to UI controls may trigger "change" handlers, so set this here
   return deferred
end
function WinCls:autoSize(recursing)
   if not self.view then
      return
   end
   local window        = self:asControl()
   local viewhold      = self.ui.viewholder:asControl()
   local view          = self.view:asControl()
   local explanation   = self.ui.explanation
   local explOldHeight = explanation:GetHeight()
   window:SetWidth (window:GetWidth()  - viewhold:GetWidth()  + view:GetWidth())
   window:SetHeight(window:GetHeight() - viewhold:GetHeight() - explOldHeight + view:GetHeight() + explanation:GetHeight())
   --
   if not recursing then
      --
      -- The game's UI engine doesn't compute word-wrapping correctly 
      -- until the next frame. It'll compute it, but just not correctly.
      --
      zo_callLater(function()
         self:autoSize(true)
      end, 1)
   end
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