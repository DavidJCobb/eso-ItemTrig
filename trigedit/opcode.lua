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

local Window = {
   ui = {
      fragment   = nil,
      window     = nil,
      opcodeType = nil,
      opcodeBody = nil,
   },
   opcode = {
      target  = nil, -- the opcode we want to edit (i.e. Opcode* other)
      working = nil, -- a copy of that opcode; we make changes to it and then commit to (target) later
      dirty   = false,
   },
}
ItemTrig.OpcodeEditWindow = Window

function Window:OnInitialized(control)
   self.ui.fragment = ZO_SimpleSceneFragment:New(control, "ITEMTRIG_ACTION_LAYER_OPCODEEDIT")
   ItemTrig.SCENE_TRIGEDIT:AddFragment(self.ui.fragment)
   SCENE_MANAGER:RegisterTopLevel(control, false)
   --
   self.ui.window     = control
   self.ui.opcodeType = ZO_ComboBox_ObjectFromContainer(ItemTrig_OpcodeEdit_Opcode)
   self.ui.opcodeBody = ItemTrig_OpcodeEdit_OpcodeBody
   --
   self.ui.opcodeType:SetSortsItems(true)
end
function Window:abandon()
   self.opcode.target  = nil
   self.opcode.working = nil
   self.opcode.dirty   = nil
   --
   -- TODO: reset UI state
   --
   SCENE_MANAGER:HideTopLevel(self.ui.window)
end
function Window:commit()
   if not self.opcode.dirty then
      return
   end
   self.opcode.target:copyAssign(self.opcode.working)
end
function Window:requestEdit()
   if self.opcode.dirty then
      --
      -- TODO: prompt for confirmation
      --
      -- TODO: probably requires implementing something 
      -- comparable to JavaScript promises/deferreds
      --
      return false
   end
   return true
end
function Window:requestExit()
   if self.opcode.dirty then
      --
      -- TODO: prompt for confirmation; same as above
      --
      return false
   end
   return true
end
function Window:edit(opcode, dirty)
   assert(ItemTrig.TriggerEditWindow ~= nil, "Cannot open the opcode editor window if the trigger editor window doesn't exist.")
   self.opcode.target  = opcode
   self.opcode.working = opcode:clone(true)
   self.opcode.dirty   = dirty or false
   do
      local host  = ItemTrig.UI.WModalHost:cast(ItemTrig.TriggerEditWindow.ui.window)
      local modal = ItemTrig.UI.WModal:install(self.ui.window)
      if not modal:prepToShow(host) then
         return
      end
   end
   --
   do
      local list
      if opcode.type == "condition" then
         list = ItemTrig.tableConditions
      else
         list = ItemTrig.tableActions
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
         combobox:AddItem({ name = base.name, base = base }, ZO_COMBOBOX_SUPRESS_UPDATE)
      end
      combobox:UpdateItems()
   end
   self:refresh()
   --
   SCENE_MANAGER:ShowTopLevel(self.ui.window)
   self.ui.window:BringWindowToTop()
end
function Window:refresh()
   --
   -- TODO: render the opcode being edited
   --
   -- * set the opcode type (combobox selection)
   --
   -- * render the opcode body
   --
   do -- opcode type
      local opcodeBase = self.opcode.working.base
      local combobox   = self.ui.opcodeType
      combobox:SetSelectedItemByEval(
         function(item)
            if item.base == opcodeBase then
               return true
            end
            return false
         end
      )
   end
end