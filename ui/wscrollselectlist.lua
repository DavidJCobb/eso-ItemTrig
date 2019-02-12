if not (ItemTrig and ItemTrig.UI) then return end

local Set = ItemTrig.Set

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
   if self.selection.multi then
      self.selection.index = Set:new()
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
      local s = self.selection
      if s.multi then
         if IsShiftKeyDown() then
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
      if self.element.onDeselect then
         local control = self:controlByIndex(index)
         if control then
            self.element.onDeselect(index, control, self)
         end
      end
      self:_onSelectionChanged(false)
   end
   function WScrollSelectList:_onSelectionChanged(fireDeselection)
      if fireDeselection == nil then
         fireDeselection = true
      end
      local s   = self.selection
      local old = s._oldIndex
      local new = s.index
      if s.multi then
         local function _exec(a, b, call)
            if not call then
               return
            end
            a:complement(b):forEach(function(index)
               local control = self:controlByIndex(index)
               if control then
                  call(i[j], control, self)
               end
            end)
         end
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
         --
         if fireDeselection then
            _exec(old, self.element.onDeselect)
         end
         _exec(new, self.element.onSelect)
         --
         s._oldIndex = new
      end
      self:onChange()
   end
end
function WScrollSelectList:addToSelection(index)
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
         for i = 1, table.getn(s.index) do
            local control = self:controlByIndex(s.index[i])
            if control then
               callback(s.index[i], control, self)
            end
         end
      end
      s.index = {}
   elseif s.index then
      if callback then
         local control = self:controlByIndex(s.index)
         if control then
            callback(s.index, self:controlByIndex(s.index), self)
         end
      end
      s.index = nil
   end
   self:onChange()
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
function WScrollSelectList:getFirstSelectedIndex()
   if not self:hasSelection() then
      return nil
   end
   if self.selection.multi then
      return self.selection.index:first()
   end
   return self.selection.index
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
   return self:at(self.selection.index)
end
function WScrollSelectList:_modifySelection(x, op)
   assert((op == "select") or (op == "deselect"), "Invalid operation.")
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
      end
      if type(x) ~= "number" and not Set:is(x) then
         x = self:indexOf(x)
      end
      if not x then
         return
      end
      if type(x) == "number" then
         x = Set:new({ x })
      end
      local compareOp
      local modifyOp
      if op == "select" then
         compareOp = "complement"
         modifyOp  = "insert"
      else
         compareOp = "intersection"
         modifyOp  = "remove"
      end
      if x:empty() or s.index[empty](s.index, x):empty() then
         --
         -- This call won't actually change the selection.
         --
         return
      end
      s.index[modifyOp](s.index, x)
   else
      if op == "select" then
         if not s.index then
            self:select(x)
         end
      else
         if s.index == x then
            self:select(nil)
         end
      end
      return
   end
   self:_onSelectionChanged()
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
      end
      if type(x) ~= "number" and not Set:is(x) then
         x = self:indexOf(x)
      end
      if type(x) == "number" or x == nil then
         x = Set:new(x and { x } or nil)
      end
      if s.index:equal(x) then
         return
      end
      s.index:assign(x)
   else
      if type(x) == "function" then
         for i, data in ipairs(self.listItems) do
            if x(data) then
               self:select(i)
               return true
            end
         end
         return false
      end
      if type(x) ~= "number" then
         x = self:indexOf(x)
      end
      if s.index == x then
         return
      end
      s.index = x
   end
   self:_onSelectionChanged()
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