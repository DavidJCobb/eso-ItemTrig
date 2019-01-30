if not ItemTrig then return end

local Window = {
   ui = {
      control    = nil,
      viewholder = nil, -- WViewHolder
      --
      views = {
         enum = {
            widget = nil, -- WViewHolderView
            value  = nil,
         },
         multiline = {
            widget = nil, -- WViewHolderView
            value  = nil,
         },
         quantity = {
            widget    = nil, -- WViewHolderView
            number    = nil,
            qualifier = nil,
         },
         string = {
            widget = nil, -- WViewHolderView
            value  = nil,
         },
      },
   },
   type     = nil,
   deferred = nil,
}
ItemTrig.OpcodeArgEditWindow = Window

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
      view = ItemTrig.UI.WViewHolderView:cast(GetControl(viewholder, "Enum"))
      self.ui.views.enum.widget = view
      self.ui.views.enum.value  = ZO_ComboBox_ObjectFromContainer(GetControl(view.control, "Value"))
      --
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
         qualifier:AddItem({ name = GetString(ITEMTRIG_STRING_QUALIFIERPREFIX_ATLEAST), value = ">=" }, ZO_COMBOBOX_SUPRESS_UPDATE)
         qualifier:AddItem({ name = GetString(ITEMTRIG_STRING_QUALIFIERPREFIX_ATMOST),  value = "<=" }, ZO_COMBOBOX_SUPRESS_UPDATE)
         qualifier:AddItem({ name = GetString(ITEMTRIG_STRING_QUALIFIERPREFIX_EXACTLY), value = "==" }, ZO_COMBOBOX_SUPRESS_UPDATE)
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
   do
      local base = opcode.base
      local val  = opcode.args[argIndex]
      local arg  = base.args[argIndex]
      local archetype = base:getArgumentArchetype(argIndex)
      if archetype == "checkbox" then
         --
         -- TODO
         --
      elseif archetype == "enum" then
         if arg.type == "boolean" then
            val = val and 2 or 1
         end
         self.ui.views.enum.widget:show()
         local combobox = self.ui.views.enum.value
         combobox:ClearItems()
         for i = 1, table.getn(arg.enum) do
            combobox:AddItem({ name = arg.enum[i], index = i }, ZO_COMBOBOX_SUPRESS_UPDATE)
         end
         combobox:UpdateItems()
         combobox:SetSelectedItemByEval(function(item) return item.index == tonumber(val) end)
      elseif archetype == "multiline" then
         local view = self.ui.views.multiline
         view.widget:show()
         view.value:SetText(val)
      elseif archetype == "number" then
         --
         -- TODO
         --
      elseif archetype == "quantity" then
         local view = self.ui.views.quantity
         view.widget:show()
         view.qualifier:SetSelectedItemByEval(function(item) return item.value == val.qualifier end)
         view.number:SetText(val.number)
      elseif archetype == "string" then
         local view = self.ui.views.string
         view.widget:show()
         view.value:SetText(val)
      end
      --
      -- TODO: compress window size
      --
   end
   d("Arg " .. argIndex .. " current value: " .. tostring(opcode.args[argIndex]))
   --
   SCENE_MANAGER:ShowTopLevel(self.ui.window)
   self.ui.window:BringWindowToTop()
   --
   return self.deferred
end
function Window:cancel()
   assert(self.deferred ~= nil, "Can't stop editing an argument if we aren't editing one yet.")
   self.type = nil
   self.deferred:reject()
   self.deferred = nil
   SCENE_MANAGER:HideTopLevel(self.ui.window)
end