if not ItemTrig then return end

local Window = {
   ui = {
      control    = nil,
      viewholder = nil, -- WViewHolder
      --
      views = {
         checkbox = {
            widget = nil,
            --
            -- TODO
            --
         },
         enum = {
            widget = nil, -- WViewHolderView
            value  = nil, -- ZO_ComboBox_Base
         },
         multiline = {
            widget = nil, -- WViewHolderView
            value  = nil,
         },
         number = {
            widget = nil,
            --
            -- TODO
            --
         },
         quantity = {
            widget    = nil, -- WViewHolderView
            number    = nil,
            qualifier = nil, -- ZO_ComboBox_Base
         },
         string = {
            widget = nil, -- WViewHolderView
            value  = nil,
         },
      },
   },
   view     = nil, -- one of the "views" objects above
   type     = nil, -- raw argument type, not ui type; i.e. boolean, number, string, quantity
   opcode   = nil, -- Opcode
   argIndex = nil, -- number
   deferred = nil, -- Deferred
}
ItemTrig.OpcodeArgEditWindow = Window

function Window.ui.views.checkbox:GetValue()
   --
   -- TODO
   --
end
function Window.ui.views.enum:GetValue()
   local x = self.value:GetSelectedItemData()
   if x then
      x = x.index
      if Window.type == "boolean" then
         --
         -- Convert from enum index to boolean.
         --
         x = (x == 2)
      end
      return x
   end
end
function Window.ui.views.multiline:GetValue()
   return self.value:GetText()
end
function Window.ui.views.number:GetValue()
   --
   -- TODO
   --
end
function Window.ui.views.quantity:GetValue()
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
function Window.ui.views.string:GetValue()
   return self.value:GetText()
end

function Window:OnInitialized(control)
   self.ui.fragment = ZO_SimpleSceneFragment:New(control, "ITEMTRIG_ACTION_LAYER_OPCODEARGEDIT")
   ItemTrig.SCENE_TRIGEDIT:AddFragment(self.ui.fragment)
   SCENE_MANAGER:RegisterTopLevel(control, false)
   --
   self.ui.window = control
   do
      local viewholder = GetControl(control, "Body")
      local view
      --
      do -- enum
         view = ItemTrig.UI.WViewHolderView:cast(GetControl(viewholder, "Enum"))
         self.ui.views.enum.widget = view
         self.ui.views.enum.value  = ZO_ComboBox_ObjectFromContainer(GetControl(view.control, "Value"))
      end
      do -- multiline
         view = ItemTrig.UI.WViewHolderView:cast(GetControl(viewholder, "Multiline"))
         self.ui.views.multiline.widget = view
         self.ui.views.multiline.value  = GetControl(view.control, "Value")
      end
      do -- quantity
         view = ItemTrig.UI.WViewHolderView:cast(GetControl(viewholder, "Quantity"))
         local qualifier = ZO_ComboBox_ObjectFromContainer(GetControl(view.control, "Qualifier"))
         self.ui.views.quantity.widget    = view
         self.ui.views.quantity.number    = GetControl(view.control, "Number")
         self.ui.views.quantity.qualifier = qualifier
         --
         qualifier:ClearItems()
         qualifier:AddItem({ name = GetString(ITEMTRIG_STRING_QUALIFIERPREFIX_ATLEAST), value = "GTE" }, ZO_COMBOBOX_SUPRESS_UPDATE)
         qualifier:AddItem({ name = GetString(ITEMTRIG_STRING_QUALIFIERPREFIX_ATMOST),  value = "LTE" }, ZO_COMBOBOX_SUPRESS_UPDATE)
         qualifier:AddItem({ name = GetString(ITEMTRIG_STRING_QUALIFIERPREFIX_EXACTLY), value = "E"   }, ZO_COMBOBOX_SUPRESS_UPDATE)
         qualifier:UpdateItems()
      end
      do -- string
         view = ItemTrig.UI.WViewHolderView:cast(GetControl(viewholder, "String"))
         self.ui.views.string.widget = view
         self.ui.views.string.value  = GetControl(view.control, "Value")
      end
   end
end
function Window:requestEdit(opener, opcode, argIndex)
   assert(opener ~= nil, "The argument editor must be aware of its opener.")
   assert(self.deferred == nil, "The argument editor is already showing!")
   assert(opcode ~= nil,      "No opcode.")
   assert(argIndex ~= nil,    "No argument index.")
   assert(opcode.base ~= nil, "Opcode is invalid.")
   self.deferred = ItemTrig.Deferred:new()
   do
      local host  = ItemTrig.UI.WModalHost:cast(opener)
      local modal = ItemTrig.UI.WModal:install(self.ui.window)
      if not modal:prepToShow(host) then
         return
      end
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
         self.view.widget:show()
         local combobox = self.view.value
         combobox:ClearItems()
         for i = 1, table.getn(arg.enum) do
            combobox:AddItem({ name = arg.enum[i], index = i }, ZO_COMBOBOX_SUPRESS_UPDATE)
         end
         combobox:UpdateItems()
         combobox:SetSelectedItemByEval(function(item) return item.index == tonumber(val) end)
         --
         -- TODO: If no value is selected, select the first list item.
         --
      elseif archetype == "multiline" then
         self.view = self.ui.views.multiline
         self.view.widget:show()
         self.view.value:SetText(val or "")
      elseif archetype == "number" then
         self.view = self.ui.views.number
         --
         -- TODO
         --
      elseif archetype == "quantity" then
         self.view = self.ui.views.quantity
         self.view.widget:show()
         self.view.qualifier:SetSelectedItemByEval(function(item) return item.value == val.qualifier end)
         --
         -- TODO: If no qualifier is selected, select the first list item.
         --
         self.view.number:SetText(val.number or "0")
      elseif archetype == "string" then
         self.view = self.ui.views.string
         self.view.widget:show()
         self.view.value:SetText(val or "")
      end
      --
      -- TODO: compress window size
      --
   end
   --
   SCENE_MANAGER:ShowTopLevel(self.ui.window)
   self.ui.window:BringWindowToTop()
   --
   return self.deferred
end
function Window:cancel()
   assert(self.deferred ~= nil, "Can't stop editing an argument if we aren't editing one yet.")
   self.view     = nil
   self.argIndex = nil
   self.deferred:reject()
   self.deferred = nil
   SCENE_MANAGER:HideTopLevel(self.ui.window)
end
function Window:commit()
   assert(self.argIndex ~= nil, "Don't know what argument index to commit.")
   assert(self.view     ~= nil, "Don't know what kind of value to commit.")
   d("Returning value: " .. tostring(self.view:GetValue()))
   local result = {
      argIndex = self.argIndex,
      value    = self.view:GetValue()
   }
   self.view     = nil
   self.argIndex = nil
   self.deferred:resolve(result)
   self.deferred = nil
   SCENE_MANAGER:HideTopLevel(self.ui.window)
end