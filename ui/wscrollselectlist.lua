if not (ItemTrig and ItemTrig.UI) then return end

ItemTrig.UI.WScrollSelectList = ItemTrig.UI.WScrollList:makeSubclass("WScrollSelectList")
function ItemTrig.UI.WScrollSelectList:_construct(options)
   if not options then
      options = {
         element = {},
      }
   end
   self:callSuper("_construct", options)
   self.selection = {
      index = nil, -- number, or an array if multiselection is enabled
      multi = options.multiSelection or false,
   }
   if self.selection.multi then
      self.selection.index = {}
   end
   self.element.onSelect      = options.element.onSelect      or nil -- callback
   self.element.onDeselect    = options.element.onDeselect    or nil -- callback
   self.element.onDoubleClick = options.element.onDoubleClick or nil
end
function ItemTrig.UI.WScrollList:_onRemoved(index, data)
   if self.selection.multi then
      ItemTrig.remove(self.selection.multi,
         function(i, e)
            return e == index
         end
      )
   else
      if self.selection.index == index then
         self.selection.index = nil
      end
   end
   if self.element.onDeselect then
      local old = self:controlByIndex(index)
      self.element.onDeselect(index, old, self)
   end
end
function ItemTrig.UI.WScrollSelectList:deselectAll()
   local s        = self.selection
   local callback = self.element.onDeselect
   if s.multi then
      if callback then
         for i = 1, table.getn(s.index) do
            callback(s.index[i], self:controlByIndex(s.index[i]), self)
         end
      end
      s.index = {}
   elseif s.index then
      if callback then
         callback(s.index, self:controlByIndex(s.index), self)
      end
      s.index = nil
   end
end
function ItemTrig.UI.WScrollSelectList:hasSelection()
   local i = self.selection.index
   if not i then
      return false
   end
   if (type(i) == "table") and table.getn(i) == 0 then
      return false
   end
   return true
end
function ItemTrig.UI.WScrollSelectList:isIndexSelected(index)
   local sel = self.selection.index
   if not sel then
      return false
   end
   if (type(sel) == "table") then
      for j = 1, table.getn(sel) do
         if sel[j] == index then
            return true
         end
      end
   end
   return sel == index
end
function ItemTrig.UI.WScrollSelectList:getFirstSelectedIndex()
   local multi = self.selection.multi
   if not self:hasSelection() then
      return nil
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
function ItemTrig.UI.WScrollSelectList:select(x)
   if type(x) == "userdata" then
      x = self:indexOf(x)
   elseif type(x) ~= "number" then
      x = self:indexOfData(x)
   end
   local c = self:controlByIndex(x)
   if not c then
      return
   end
   self:_onItemSelected(c)
end
function ItemTrig.UI.WScrollSelectList:_getExtraConstructorParams(index)
   return {
      selected = self:isIndexSelected(index)
   }
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
   callback(index, control, self)
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
                  local old = self:controlByIndex(s.index[i])
                  callback(s.index[i], old, self)
               end
            end
            s.index = {}
         end
      else
         s.index = {}
      end
      table.insert(self.selection.index, index)
      if self.element.onSelect then
         self.element.onSelect(index, control, self)
      end
   else
      if self:hasSelection() then
         if index == s.index then
            return
         end
         if self.element.onDeselect then
            local old = self:controlByIndex(s.index)
            self.element.onDeselect(s.index, old, self)
         end
      end
      s.index = index
      if self.element.onSelect then
         self.element.onSelect(index, control, self)
      end
   end
end