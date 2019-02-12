if not ItemTrig then return end
if not ItemTrig.UI then
   ItemTrig.UI = {}
end

--
-- A  helper class for creating a scrollable  list of variably-
-- sized list items, scrolling by pixels rather than whole list 
-- items. Unlike Zenimax's element classes,  which decorate the 
-- control with expando properties and essentially offer static 
-- methods (with the control  passed manually as the first arg-
-- ument),  this class  creates a separate  wrapper object  and 
-- links  it to the control. This  means  that once  you have a 
-- reference  to the wrapper, you can quickly  and easily  call 
-- its methods.
--
-- Call this to set up a control:
--
--    local widget = ItemTrig.UI.WScrollList:install(control)
--
-- Call this to get the class from a control:
--
--    local widget = ItemTrig.UI.WScrollList:cast(control)
--
-- Once you have the instance, you can do things like
--
--    widget:scrollBy(-30)
--    widget:push(someData1, false)
--    widget:push(someData2, false)
--    widget:redraw()
--

local function onScrollUpButton(self)
   local widget = ItemTrig.UI.WScrollList:cast(self:GetParent():GetParent())
   assert(not widget.dirty, "The drawn list items are out-of-date! When modifying list items, you should endeavor to redraw the list during the same frame.")
   widget:scrollBy(-widget.scrollStep)
end
local function onScrollDownButton(self)
   local widget = ItemTrig.UI.WScrollList:cast(self:GetParent():GetParent())
   assert(not widget.dirty, "The drawn list items are out-of-date! When modifying list items, you should endeavor to redraw the list during the same frame.")
   widget:scrollBy(widget.scrollStep)
end

ItemTrig.UI.WScrollList = ItemTrig.UI.WidgetClass:makeSubclass("WScrollList", "scrollList")
local WScrollList = ItemTrig.UI.WScrollList
function WScrollList:_construct(options)
   if not options then
      options = {}
   end
   if not options.element then
      options.element = {}
   end
   local scrollbar = self:GetNamedChild("ScrollBar")
   self.element = {
      template    = options.element.template    or "",
      toConstruct = options.element.toConstruct or nil,
      toReset     = options.element.toReset     or nil,
      _pool       = nil,
   }
   self.aggressiveRecycling = true
   if options.aggressiveRecycling ~= nil then
      self.aggressiveRecycling = options.aggressiveRecycling
   end
   self.contents   = self:GetNamedChild("Contents")
   self.dirty      = false -- list items have been added/removed and we haven't redrawn yet
   self.scrollbar  = scrollbar
   self.scrollBtnU = GetControl(scrollbar, "Up")
   self.scrollBtnD = GetControl(scrollbar, "Down")
   self.scrollStep = options.scrollStep or 40
   self.scrollTop      = 0
   self.scrollMax      = -1 -- height of all generated elements
   self.paddingSides   = options.paddingSides   or 0 -- padding (except paddingBetween) is applied as a side-effect of self:resizeScrollbar
   self.paddingStart   = options.paddingStart   or 0
   self.paddingBetween = options.paddingBetween or 0
   self.paddingEnd     = options.paddingEnd     or 0
   self.listItems      = {} -- data items
   self.listItemStates = {} -- states for list items, i.e. cached top/bottom edge offsets
   self.visibleItems   = {} -- array of indices
   do
      local factoryFunction =
         function(objectPool)
            return ZO_ObjectPool_CreateNamedControl(string.format("%sRow", self:asControl():GetName()), self.element.template, objectPool, self.contents)
         end
      self.element._pool = ZO_ObjectPool:New(factoryFunction, self.element.toReset or ZO_ObjectPool_DefaultResetControl)
   end
   self.scrollBtnU:SetHandler("OnMouseDown", onScrollUpButton)
   self.scrollBtnD:SetHandler("OnMouseDown", onScrollDownButton)
   self.scrollbar:SetEnabled(false)
end
function WScrollList:at(index)
   if (not index) or index < 1 or index > table.getn(self.listItems) then
      return nil
   end
   return self.listItems[index]
end
function WScrollList:clear(update)
   ZO_ClearNumericallyIndexedTable(self.listItems)
   if (update == true) or (update == nil) then
      self:redraw()
   else
      self.dirty = true
   end
end

do -- functions for working directly with controls
   function WScrollList:controlByIndex(index)
      if (not index) or index < 1 then
         return nil
      end
      index = self.listItemStates[index].controlIndex
      if not index then
         return nil
      end
      local contents = self.contents
      if index > contents:GetNumChildren() then
         return nil
      end
      return contents:GetChild(index)
   end
   function WScrollList:indexOfControl(control)
      local index    = nil
      local contents = self.contents
      for i = 1, contents:GetNumChildren() do
         if contents:GetChild(i) == control then
            index = i
            break
         end
      end
      if index then
         for i = 1, self:count() do
            if self.listItemStates[i].controlIndex == index then
               return i
            end
         end
      end
      return nil
   end
end

function WScrollList:count()
   return table.getn(self.listItems)
end
function WScrollList:fromItem(control) -- static method
   return self:cast(control:GetParent():GetParent())
end
function WScrollList:indexOf(data)
   for i = 1, table.getn(self.listItems) do
      if self.listItems[i] == data then
         return i
      end
   end
   return 0
end
function WScrollList:push(obj, update)
   table.insert(self.listItems, obj)
   table.insert(self.listItemStates, {
      top    = nil, -- offsets without scrolling applied
      bottom = nil,
      offsetTop    = nil, -- offsets with scrolling applied
      offsetBottom = nil,
      controlIndex = nil,
   })
   if (update == true) or (update == nil) then
      self:redraw()
   else
      self.dirty = true
   end
end
function WScrollList:_onRemoved(index, data) -- for subclasses to override
end
function WScrollList:onRedrawOrReposition()
   --
   -- Can be overridden.
   --
end
function WScrollList:remove(x, update)
   if not x then
      return
   end
   if type(x) == "userdata" then
      x = self:indexOf(x)
   elseif type(x) ~= "number" then
      x = self:indexOfData(x)
   end
   if x < 1 then
      return
   end
   local item = self.listItems[x]
   table.remove(self.listItems, x)
   table.remove(self.listItemStates, x)
   self:_onRemoved(x, item)
   if (update == true) or (update == nil) then
      self:redraw()
   else
      self.dirty = true
   end
end
function WScrollList:resizeScrollbar(scrollMax)
   --
   -- This function handles the following tasks:
   --
   -- a) Show or hide the scrollbar depending on whether scrolling is possible.
   --
   -- b) Update the content area's anchors, so that when the scrollbar is hidden, the 
   --    content area expands to fill the space that the scrollbar would've taken.
   --
   -- c) Since we're updating the content area's anchors anyway, also handle the outer 
   --    padding values (start, sides, end) by insetting the content area.
   --
   -- TODO: Expanding the content area to fill the scrollbar's space could cause a 
   -- reflow that changes the height of list items; this would cause our cached list 
   -- item states (top and bottom edges) to become out of date. How should we handle 
   -- this?
   --
   local scrollbar  = self.scrollbar
   local listHeight = self.contents:GetHeight()
   local barHeight  = scrollbar:GetHeight()
   if scrollMax == nil then
      scrollMax = self.scrollMax
   end
   if scrollMax < 0 then
      scrollMax = self:measureItems()
   end
   if scrollMax > 0 and scrollMax > listHeight then
      scrollbar:SetEnabled(true)
      scrollbar:SetHidden(false)
      scrollbar:SetThumbTextureHeight(barHeight * listHeight / (scrollMax + listHeight))
      scrollbar:SetMinMax(0, scrollMax - listHeight)
      --
      do
         local control  = self:asControl()
         local contents = self.contents
         contents:ClearAnchors()
         contents:SetAnchor(TOPLEFT,     control, TOPLEFT,     self.paddingSides, self.paddingStart)
         contents:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -(self.paddingSides + ZO_SCROLL_BAR_WIDTH), -self.paddingEnd)
      end
   else
      self.scrollTop = 0
      scrollbar:SetThumbTextureHeight(barHeight)
      scrollbar:SetMinMax(0, 0)
      scrollbar:SetEnabled(false)
      scrollbar:SetHidden(true)
      --
      do
         local control  = self:asControl()
         local contents = self.contents
         contents:ClearAnchors()
         contents:SetAnchor(TOPLEFT,     control, TOPLEFT,      self.paddingSides, self.paddingStart)
         contents:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -self.paddingSides, -self.paddingEnd)
      end
   end
end
function WScrollList:_getExtraConstructorParams(index)
   --
   -- Subclasses can override this in order to provide additional 
   -- state to elements when they are being constructed.
   --
   return nil
end
function WScrollList:redraw()
   assert(self.element.toConstruct ~= nil, "You must supply a constructor callback before WScrollList can render list items.")
   assert(self.element.template    ~= "",  "You must supply a template to use for list items before WScrollList can render list items.")
   self.visibleItems = {}
   local contents  = self.contents
   local existing  = contents:GetNumChildren()
   local created   = 0
   local count     = self:count()
   local yOffset   = -self.scrollTop
   local j         = 1
   local viewStart = 0
   local viewEnd   = contents:GetHeight()
   for i = 1, count do
      local child
      if j <= existing + created then
         child = contents:GetChild(j)
      else
         local control, key = self.element._pool:AcquireObject()
         child   = control
         created = created + 1
      end
      child:SetHidden(false)
      self.element.toConstruct(child, self.listItems[i], self:_getExtraConstructorParams(i))
      child:ClearAnchors()
      child:SetAnchor(TOPLEFT,  contents, TOPLEFT,  0, yOffset)
      child:SetAnchor(TOPRIGHT, contents, TOPRIGHT, 0, yOffset)
      local top    = ItemTrig.offsetTop(child)
      local bottom = ItemTrig.offsetBottom(child)
      self.listItemStates[i].top          = top    + self.scrollTop
      self.listItemStates[i].bottom       = bottom + self.scrollTop
      self.listItemStates[i].offsetTop    = top
      self.listItemStates[i].offsetBottom = bottom
      self.listItemStates[i].controlIndex = nil
      assert(bottom - top == child:GetHeight(), string.format("Child bounds don't match; [%d, %d] -> %d ~= %d", top, bottom, (bottom - top), child:GetHeight()))
      local isVisible = (bottom > viewStart and top < viewEnd)
      if isVisible or (not self.aggressiveRecycling) then
         if isVisible then
            table.insert(self.visibleItems, i)
         end
         --
         -- This control is in the visible area, so we shouldn't recycle it. 
         -- Alternatively, this list is configured not to recycle controls 
         -- (i.e. all list items should always be rendered).
         --
         self.listItemStates[i].controlIndex = j
         j = j + 1
      else
         child:SetHidden(true)
      end
      yOffset = yOffset + child:GetHeight() + self.paddingBetween
   end
   if j < existing then
      --
      -- If there were more controls than list items, then hide the excess 
      -- controls.
      --
      for i = j, existing do
         local child = contents:GetChild(i)
         if child then
            child:SetHidden(true)
         end
      end
   end
   local total = 0
   if count > 0 then
      total = self.listItemStates[count].bottom or 0
   end
   self.scrollMax = total
   self.dirty     = false
   self:resizeScrollbar(total)
   self:onRedrawOrReposition()
   return
end
function WScrollList:reposition()
   assert(not self.dirty, "The drawn list items are out-of-date!")
   --
   -- Optimized function for repositioning all list items when none of them 
   -- have had their visibility changed (i.e. if we've scrolled a little bit, 
   -- but not enough to move a list item into or out of view).
   --
   for i = 1, self:count() do
      local state = self.listItemStates[i]
      state.offsetTop    = state.top    - self.scrollTop
      state.offsetBottom = state.bottom - self.scrollTop
      if ItemTrig.indexOf(self.visibleItems, i) ~= nil then
         local control = self:controlByIndex(i)
         if control then
            control:ClearAnchors()
            control:SetAnchor(TOPLEFT,  contents, TOPLEFT,  0, state.offsetTop)
            control:SetAnchor(TOPRIGHT, contents, TOPRIGHT, 0, state.offsetTop)
         end
      end
   end
end
function WScrollList:measureItems()
   assert(not self.dirty, "The drawn list items are out-of-date!")
   --
   -- TODO: Double-check whether this should include padding-start and padding-end
   --
   if self:count() then
      local last = self.listItemStates[self:count()]
      return last.bottom + self.paddingEnd
   else
      return 0
   end
end
function WScrollList:scrollBy(delta) -- analogous to ZO_ScrollList_ScrollRelative
   local position = delta + self.scrollTop
   self:scrollTo(position)
end
function WScrollList:scrollToItem(index, shouldBeCentered, lazy)
   if (not index) or index < 0 then
      return
   end
   local state    = self.listItemStates[index]
   local position = state.top
   if shouldBeCentered then
      local listHeight  = self.contents:GetHeight()
      local childHeight = state.bottom - state.top
      if childHeight >= listHeight then
         self:scrollTo(position)
      else
         if lazy then
            if self.scrollTop < position and self.scrollTop + listHeight > position + childHeight then
               return
            end
         end
         local offset = (listHeight - childHeight) / 2
         self:scrollTo(position - offset)
      end
   else
      self:scrollTo(position)
   end
end
function WScrollList:scrollTo(position, options) -- analogous to ZO_ScrollList_ScrollAbsolute
   assert(not self.dirty, "The drawn list items are out-of-date!")
   if not options then
      options = {
         fromSlider = false, -- used to avoid recursion from Slider:OnValueChanged
      }
   end
   local height = self.contents:GetHeight()
   do -- clamp scroll position to list pane extents
      if position < 0 then
         position = 0
      else
         if self.scrollMax < 0 then
            self:measureItems()
         end
         if position > self.scrollMax - height then
            position = self.scrollMax - height
            if position < 0 then
               position = 0
            end
         end
      end
   end
   if self.scrollTop == position then
      return
   end
   do -- Check whether any list items have been scrolled into or out of view
      local function _checkRedraw(self, oldPos, newPos)
         local viewStart = 0
         local viewEnd   = self.contents:GetHeight()
         local function _visible(state)
            local b = state.bottom - newPos
            local t = state.top    - newPos
            return (b > viewStart and t < viewEnd)
         end
         local ivFirst = self.visibleItems[1]
         local ivLast  = self.visibleItems[table.getn(self.visibleItems)]
         local ihFirst = nil
         local ihLast  = nil
         if ivFirst > 1 then
            ihFirst = ivFirst - 1
         end
         if ivLast < self:count() then
            ihLast = ivLast + 1
         end
         if ihFirst and _visible(self.listItemStates[ihFirst]) then -- list item scrolled into view
            return true
         end
         if not _visible(self.listItemStates[ivFirst]) then -- list item scrolled out of view
            return true
         end
         if ihLast and _visible(self.listItemStates[ihLast]) then -- list item scrolled into view
            return true
         end
         if not _visible(self.listItemStates[ivLast]) then -- list item scrolled out of view
            return true
         end
      end
      if _checkRedraw(self, self.scrollTop, position) then
         self.scrollTop = position
         self:redraw()
      else
         self.scrollTop = position
         self:reposition()
      end
   end
   if self.scrollbar:IsHidden() then
      self.scrollTop = position
      return
   end
   if not options.fromSlider then
      self.scrollbar:SetValue(position)
   end
end