if not (ItemTrig and ItemTrig.UI) then return end

local Set = ItemTrig.Set

--
-- A variation on WScrollList that allows you to select and 
-- deselect the list items. An option is provided for multi-
-- selection.
--

ItemTrig.UI.WScrollSelectList = ItemTrig.UI.WScrollList:makeSubclass("WScrollSelectList")
local WScrollSelectList = ItemTrig.UI.WScrollSelectList
function WScrollSelectList:_construct(options)
   if not options then
      options = {}
   end
   if not options.element then
      options.element = {}
   end
   self.selection = {
      index = nil, -- number, or an array if multiselection is enabled
      multi = options.multiSelection or false,
      _oldIndex = nil, -- used to fire events properly
   }
   if options.shiftToAdd == nil then
      self.selection.shiftToAdd = true
   else
      self.selection.shiftToAdd = options.shiftToAdd
   end
   if self.selection.multi then
      self.selection.index     = Set:new()
      self.selection._oldIndex = Set:new()
   end
   self.element.onSelect      = options.element.onSelect      or nil -- callback
   self.element.onDeselect    = options.element.onDeselect    or nil -- callback
   self.element.onDoubleClick = options.element.onDoubleClick or nil
end
do -- event handlers provided for subclasses and instances to override
   function WScrollSelectList:onChange()
      --
      -- Runs after element (de)select callbacks.
      --
   end
   function WScrollSelectList:onItemClicked(index)
      --
      -- Runs before element (de)select callbacks.
      --
   end
end
do -- internal event handlers, not to be overridden
   function WScrollSelectList:_onDoubleClick(control)
      local callback = self.element.onDoubleClick
      if not callback then
         return
      end
      local i = self:indexOfControl(control)
      if not i then
         return
      end
      callback(i, control, self)
   end
   function WScrollSelectList:_onItemClicked(control)
      local i = self:indexOfControl(control)
      if not i then
         return
      end
      self:onItemClicked(i)
      local s = self.selection
      if s.multi then
         if (not s.shiftToAdd) or IsShiftKeyDown() then
            self:toggle(i)
            return
         end
         self:select(i)
         return
      end
      self:select(i)
   end
   function WScrollSelectList:_onRemoved(index, data) -- overrides WScrollList
      if self.selection.multi then
         self.selection.multi:remove(index)
      else
         if self.selection.index == index then
            self.selection.index = nil
         end
      end
      --self:_onSelectionChanged(false)
   end
   function WScrollSelectList:_onSelectionChanged(fireDeselection)
      if fireDeselection == nil then
         fireDeselection = true
      end
      local s   = self.selection
      local old = s._oldIndex
      local new = s.index
      local anyChanges = false
      if s.multi then
         local function _exec(a, b, call)
            if not call then
               return
            end
            a:complement(b):forEach(function(index)
               local control = self:controlByIndex(index)
               if control then
                  call(index, control, self)
               end
            end)
         end
         anyChanges = not new:equal(old)
         --
         if fireDeselection then
            _exec(old, new, self.element.onDeselect)
         end
         _exec(new, old, self.element.onSelect)
         --
         s._oldIndex = new:clone()
      else
         local function _exec(index, call)
            if index and call then
               local control = self:controlByIndex(index)
               if control then
                  call(index, control, self)
               end
            end
         end
         anyChanges = old ~= new
         --
         if fireDeselection then
            _exec(old, self.element.onDeselect)
         end
         _exec(new, self.element.onSelect)
         --
         s._oldIndex = new
      end
      if anyChanges then
         self:onChange()
      end
   end
end
function WScrollSelectList:addToSelection(x)
   --
   -- You can pass a function to iterate over all list 
   -- items; return truthy to select.
   --
   self:_modifySelection(x, "select")
end
function WScrollSelectList:deselectAll()
   local s        = self.selection
   local callback = self.element.onDeselect
   if s.multi then
      if callback then
         s.index:forEach(function(i)
            local control = self:controlByIndex(i)
            if control then
               callback(i, control, self)
            end
         end)
      end
      s._oldIndex = Set:new()
      s.index     = Set:new()
   elseif s.index then
      if callback then
         local control = self:controlByIndex(s.index)
         if control then
            callback(s.index, self:controlByIndex(s.index), self)
         end
      end
      s._oldIndex = nil
      s.index     = nil
   end
   self:onChange()
end
function WScrollSelectList:forEachSelected(functor)
   local s = self.selection
   if s.multi then
      s.index:forEach(function(i)
         local data = self.listItems[i]
         if functor(i, data) then
            return true
         end
      end)
   else
      local i = s.index
      if not i then
         return
      end
      functor(i, self.listItems[i])
   end
end
function WScrollSelectList:getFirstSelectedIndex()
   if not self:hasSelection() then
      return nil
   end
   if self.selection.multi then
      return self.selection.index:first()
   end
   return self.selection.index
end
function WScrollSelectList:getFirstSelectedItem()
   return self:at(self:getFirstSelectedIndex())
end
function WScrollSelectList:getSelectedItems()
   local multi = self.selection.multi
   if not self:hasSelection() then
      if multi then
         return {}
      end
      return nil
   end
   if multi then
      return self.selection.index:map(self.listItems)
   end
   return { self:at(self.selection.index) }
end
function WScrollSelectList:hasSelection()
   local i = self.selection.index
   if not i then
      return false
   end
   if self.selection.multi then
      return not i:empty()
   end
   return true
end
function WScrollSelectList:isControlSelected(control)
   local index = self:indexOfControl(control)
   if index then
      return self:isIndexSelected(index)
   end
   return false
end
function WScrollSelectList:isIndexSelected(index)
   local sel = self.selection.index
   if not sel then
      return false
   end
   if self.selection.multi then
      return sel:has(index)
   end
   return sel == index
end
function WScrollSelectList:_modifySelection(x, op)
   assert((op == "select") or (op == "deselect") or (op == "replace"), "Invalid operation.")
   if not x then
      return
   end
   local s = self.selection
   if s.multi then
      if type(x) == "function" then
         local r = Set:new()
         for i, data in ipairs(self.listItems) do
            if x(data) then
               r:insert(i)
            end
         end
         x = r
      else
         if type(x) ~= "number" and not Set:is(x) then
            x = self:indexOf(x)
         end
         if not x then
            return
         end
         x = Set:new({ x })
      end
      if x:empty() then
         return -- This call won't actually change the selection.
      end
      if op == "select" then
         if x:complement(s.index):empty() then
            return -- This call won't actually change the selection.
         end
         s.index:insert(x)
      elseif op == "deselect" then
         if x:intersection(s.index):empty() then
            return -- This call won't actually change the selection.
         end
         s.index:remove(x)
      elseif op == "replace" then
         if s.index:equal(x) then
            return
         end
         s.index = x
      end
   else
      if type(x) == "function" then
         for i, data in ipairs(self.listItems) do
            if x(data) then
               s.index = i
               self:_onSelectionChanged()
               return true
            end
         end
         return false
      end
      if type(x) ~= "number" then
         x = self:indexOf(x)
      end
      if op == "select" then
         if s.index then
            return
         end
         s.index = x
      elseif op == "deselect" then
         if s.index ~= x then
            return
         end
         s.index = nil
      elseif op == "replace" then
         if s.index == x then
            return
         end
         s.index = x
      end
   end
   self:_onSelectionChanged()
end
function WScrollSelectList:multiSelect(flag) -- getter/setter
   local s = self.selection
   if flag == nil then
      return s.multi
   end
   if flag == s.multi then
      return flag
   end
   if flag then
      s.multi     = true
      s.index     = Set:new(s.index     and { s.index     } or nil)
      s._oldIndex = Set:new(s._oldIndex and { s._oldIndex } or nil)
   else
      local first = self:getFirstSelectedIndex()
      local call  = self.element.onDeselect
      if call then
         s.index:forEach(function(i)
            if i == first then
               return
            end
            local control = self:controlByIndex(i)
            if control then
               call(i, control, self)
            end
         end)
      end
      s.multi = false
      s.index = first
   end
   return flag
end
function WScrollSelectList:removeFromSelection(x)
   --
   -- You can pass a function to iterate over all list 
   -- items; return truthy to deselect.
   --
   self:_modifySelection(x, "deselect")
end
function WScrollSelectList:select(x)
   --
   -- You can pass a function to iterate over all list 
   -- items; return truthy to select.
   --
   if x == nil then
      self:deselectAll()
      return
   end
   return self:_modifySelection(x, "replace")
end
function WScrollSelectList:toggle(i)
   assert(type(i) == "number", "This function must be passed an index.")
   if self:isIndexSelected(i) then
      if self.selection.multi then
         self.selection.index:remove(i)
      else
         self.selection.index = nil
      end
   else
      if self.selection.multi then
         self.selection.index:insert(i)
      else
         if self.selection.index then
            return
         end
         self.selection.index = i
      end
   end
   self:_onSelectionChanged()
end
function WScrollSelectList:_getExtraConstructorParams(index)
   return {
      index    = index,
      selected = self:isIndexSelected(index)
   }
end