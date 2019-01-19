if not ItemTrig then return end
if not ItemTrig.UI then return end

ItemTrig.UI.WScrollSelectList = {}
ItemTrig.UI.WScrollSelectList.__index = ItemTrig.UI.WScrollSelectList
setmetatable(ItemTrig.UI.WScrollSelectList, { __index = ItemTrig.UI.WScrollList })
function ItemTrig.UI.WScrollSelectList:install(control, options)
   if control.widgets and control.widgets.scrollList then
      d("WARNING: Attempting to install WScrollSelectList on a control that already has it?")
   end
   if not options then
      options = {
         element = {},
      }
   end
   local result = ItemTrig.UI.WScrollList:install(control, options)
   setmetatable(result, self)
   result.selection = {
      index = 0, -- 0 if no selections; an array if multiselection is enabled
      multi = options.multiSelection or false,
   }
   result.element.onSelect      = options.element.onSelect      or nil -- callback
   result.element.onDeselect    = options.element.onDeselect    or nil -- callback
   result.element.onDoubleClick = options.element.onDoubleClick or nil
   return result
end
function ItemTrig.UI.WScrollSelectList:cast(control)
   if control.widgets then
      local widget = control.widgets.scrollList
      if getmetatable(widget) == self then
         return widget
      end
   end
   return nil
end
function ItemTrig.UI.WScrollSelectList:hasSelection()
   local i = self.selection.index
   if (not i) or tonumber(i) < 1 then
      return false
   end
   if (type(i) == "table") and table.getn(i) == 0 then
      return false
   end
   return true
end
function ItemTrig.UI.WScrollSelectList:getFirstSelectedIndex()
   local multi = self.selection.multi
   if not self:hasSelection() then
      return 0
   end
   if multi then
      return self.selection.index[1]
   end
   return self.selection.index
end
function ItemTrig.UI.WScrollSelectList:getSelectedControls()
   local multi = self.selection.multi
   if not self:hasSelection() then
      if multi then
         return {}
      end
      return nil
   end
   if multi then
      local results = {}
      local list    = self.selection.index
      for i = 1, table.getn(list) do
         results[i] = self:controlByIndex(list[i])
      end
      return results
   end
   return self:controlByIndex(self.selection.index)
end
function ItemTrig.UI.WScrollSelectList:getSelectedItems()
   local multi = self.selection.multi
   if not self:hasSelection() then
      if multi then
         return {}
      end
      return nil
   end
   if multi then
      local results = {}
      local list    = self.selection.index
      for i = 1, table.getn(list) do
         results[i] = self:at(list[i])
      end
      return results
   end
   return self:at(self.selection.index)
end
function ItemTrig.UI.WScrollSelectList:_onDoubleClick(control)
   local callback = self.element.onDoubleClick
   if not callback then
      return
   end
   local index = self:indexOf(control)
   if not index then
      return
   end
   callback(index, control)
end
function ItemTrig.UI.WScrollSelectList:_onItemSelected(control)
   local index = self:indexOf(control)
   if not index then
      return
   end
   local shift = IsShiftKeyDown()
   local s     = self.selection
   if s.multi then
      if self:hasSelection() then
         if not shift then
            local callback = self.element.onDeselect
            if callback then
               for i = 1, table.getn(s.index) do
                  local old = self:controlByIndex(s.index)
                  callback(s.index, old)
               end
            end
            s.index = {}
         end
      else
         s.index = {}
      end
      table.insert(self.selection.index, index)
      if self.element.onSelect then
         self.element.onSelect(index, control)
      end
   else
      if self:hasSelection() then
         if index == s.index then
            return
         end
         if self.element.onDeselect then
            local old = self:controlByIndex(s.index)
            self.element.onDeselect(s.index, old)
         end
      end
      s.index = index
      if self.element.onSelect then
         self.element.onSelect(index, control)
      end
   end
end