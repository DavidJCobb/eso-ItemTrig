if not ItemTrig then return end

local Window = {
   ui = {
      control    = nil,
      viewholder = nil,
      viewEnum   = nil,
      valueEnum  = nil,
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
      local viewholder  = GetControl(control, "Body")
      --
      self.ui.viewEnum  = ItemTrig.UI.WViewHolderView:cast(GetControl(viewholder, "Enum"))
      self.ui.valueEnum = ZO_ComboBox_ObjectFromContainer(GetControl(self.ui.viewEnum.control, "Value"))
      --
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
            val = (val and 2) or 1
         end
         self.ui.viewEnum:show()
         local combobox = self.ui.valueEnum
         combobox:ClearItems()
         for i = 1, table.getn(arg.placeholder) do
            combobox:AddItem({ name = arg.placeholder[i], index = i }, ZO_COMBOBOX_SUPRESS_UPDATE)
         end
         combobox:UpdateItems()
         combobox:SetSelectedItemByEval(function(item) return item.index == tonumber(val) end)
      elseif archetype == "number" then
         --
         -- TODO
         --
      elseif archetype == "quantity" then
         --
         -- TODO
         --
      elseif archetype == "string" then
         --
         -- TODO
         --
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