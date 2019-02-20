if not (ItemTrig and ItemTrig.UI) then return end

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
-- Moreover, this class differs from Zenimax's "scrolling list" 
-- control in that it lets list items have varying heights, and 
-- it scrolls by pixels instead of by whole list items.
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
-- There are some limitations: list items must have a consistent 
-- height, and should not change height unpredictably. Under the 
-- hood, this widget only  maintains  controls  for  the visible 
-- list items, and recycles those as the user scrolls; it caches 
-- the heights of list items that are scrolled out of view. This 
-- means that if list items change height unexpectedly, the list 
-- may break. When in doubt, call redraw() again.
--
-- Related to that fact: the "toConstruct" callback, used to set 
-- up a list item,  may be called multiple times for a list item 
-- that already  exists;  and  element  callbacks on  subclasses 
-- (e.g. onSelect/onDeselect for WScrollSelectList) may not fire 
-- if those list items are scrolled out of view.
--
-- The list control doesn't detect its own resize. If its height 
-- changes, you need to call redraw. I may add an OnUpdate event 
-- handler in the future to account for this.
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

local function _defaultSortFunction(itemA, itemB)
   return tostring(itemA.name or itemA):lower() < tostring(itemB.name or itemB):lower()
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
   scrollbar.hideScrollBarOnDisabled = false
   self.element = {
      template    = options.element.template    or "",
      toConstruct = options.element.toConstruct or nil,
      toFinalize  = options.element.toFinalize  or nil, -- called on visible elements after they're all drawn and the scrollbar is adjusted
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
   self.shouldSort     = options.shouldSort     or false
   self.sortFunction   = options.sortFunction   or _defaultSortFunction
   self.paddingSides   = options.paddingSides   or 0 -- padding (except paddingBetween) is applied as a side-effect of self:_updateScrollbar
   self.paddingStart   = options.paddingStart   or 0
   self.paddingBetween = options.paddingBetween or 0
   self.paddingEnd     = options.paddingEnd     or 0
   self.listItems      = {} -- data items
   self.listItemStates = {} -- states for list items, i.e. cached top/bottom edge offsets
   self.visibleItems   = {} -- array of indices
   self.listItemMoused = nil -- last list item index to receive mouseover
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

do -- functions for working directly with controls
   function WScrollList:controlByIndex(index)
      if (not index) or not self:boundsCheckIndex(index) then
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
do -- internal events
   function WScrollList:_onItemMouseEnter(control)
      self.listItemMoused = self:indexOfControl(control)
   end
   function WScrollList:_onItemMouseExit(control)
      self.listItemMoused = nil
   end
   function WScrollList:_updateMouseoverStateOnScroll()
      --
      -- OnMouseEnter and OnMouseExit only fire when the mouse actively 
      -- moves over or off of a control; if the control itself is moved 
      -- under or out from under the mouse, by a script, then the event 
      -- handlers will not fire. We want them to fire, so we'll do it 
      -- ourselves.
      --
      local function _getListItemFromDescendant(c)
         local p = c:GetParent()
         while p and p ~= self.contents do
            c = p
            p = p:GetParent()
         end
         return c
      end
      --
      local target   = WINDOW_MANAGER:GetMouseOverControl()
      local previous = self:controlByIndex(self.listItemMoused)
      if target ~= previous then
         if previous then
            ItemTrig.dispatchEvent(previous, "OnMouseExit")
         end
         if target and target:IsChildOf(self.contents) then
            target = _getListItemFromDescendant(target)
            assert(target ~= nil, "Unable to get the list item that contains " .. (WINDOW_MANAGER:GetMouseOverControl():GetName()) .. ".")
            ItemTrig.dispatchEvent(target, "OnMouseEnter")
         end
      end
   end
end

function WScrollList:at(index)
   if (not index) or not self:boundsCheckIndex(index) then
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
function WScrollList:boundsCheckIndex(index)
   if index < 1 then
      return false
   end
   return index <= #self.listItems
end
function WScrollList:count()
   return #self.listItems
end
function WScrollList:forEach(functor)
   for i, data in ipairs(self.listItems) do
      if functor(i, data) then
         break
      end
   end
end
function WScrollList:fromItem(control) -- static method
   return self:cast(control:GetParent():GetParent())
end
function WScrollList:indexOf(data)
   for i = 1, #self.listItems do
      if self.listItems[i] == data then
         return i
      end
   end
   return 0
end
function WScrollList:isScrollbarVisible()
   return not self.scrollbar:IsHidden()
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
   if self.shouldSort then
      self:sort()
   end
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
   if type(x) ~= "number" then
      x = self:indexOf(x)
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
function WScrollList:_getExtraConstructorParams(index)
   --
   -- Subclasses can override this in order to provide additional 
   -- state to elements when they are being constructed.
   --
   return nil
end
function WScrollList:redraw(options)
   assert(self.element.toConstruct ~= nil, "You must supply a constructor callback before WScrollList can render list items.")
   assert(self.element.template    ~= "",  "You must supply a template to use for list items before WScrollList can render list items.")
   if not options then
      options = {
         iterations       = 2,
         waitingForHeight = false,
      }
   end
   --
   -- We have to run this twice in order for list items to be able to properly 
   -- compute their heights in certain cases, such as when a list item's height 
   -- depends on the height of contained text that can word-wrap.
   --
   -- Yes, I know this is ugly, but as long as Zenimax refuses to document prec-
   -- isely when, how, and why the UI reflows, we have to do stupid crap like 
   -- this, because it's impossible to know what the better approaches even are.
   --
   local contents  = self.contents
   if contents:GetHeight() < 0 then
      --
      -- ESO's UI system is...
      --
      -- Okay, it's not *great*.
      --
      return
   end
   local count     = self:count()
   local viewStart = 0
   local viewEnd   = contents:GetHeight()
   for i = 1, options.iterations do
      self.visibleItems = {}
      local existing  = contents:GetNumChildren()
      local created   = 0
      local yOffset   = -self.scrollTop
      local j         = 1
      for i = 1, count do
         local child
         if j <= existing + created then
            child = contents:GetChild(j)
         else
            local control, key = self.element._pool:AcquireObject()
            child   = control
            created = created + 1
            --
            ZO_PreHookHandler(child, "OnMouseEnter", function(self) WScrollList:fromItem(self):_onItemMouseEnter(self) end)
            ZO_PreHookHandler(child, "OnMouseExit",  function(self) WScrollList:fromItem(self):_onItemMouseExit(self) end)
         end
         child:SetHidden(false)
         self.element.toConstruct(child, self.listItems[i], self:_getExtraConstructorParams(i), self)
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
      if j <= existing then
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
      if self.scrollTop + viewEnd > self.scrollMax then
         self.scrollTop = 0
      end
   end
   self.dirty     = false
   self:_updateScrollbar(total)
   if self.element.toFinalize then
      for i = 1, #self.visibleItems do
         local index   = self.visibleItems[i]
         local control = self:controlByIndex(index)
         if control then
            self.element.toFinalize(control, self.listItems[index], self)
         end
      end
   end
   self:onRedrawOrReposition()
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
   local listHeight  = self.contents:GetHeight()
   local childHeight = state.bottom - state.top
   if childHeight < listHeight then
      if lazy then
         if self.scrollTop < position and self.scrollTop + listHeight > position + childHeight then
            return
         end
      end
      if shouldBeCentered then
         local offset = (listHeight - childHeight) / 2
         position = position - offset
      end
   end
   self:scrollTo(position)
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
         if #self.visibleItems < 1 then
            return true
         end
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
      self:_updateMouseoverStateOnScroll()
   end
   if self.scrollbar:IsHidden() then
      self.scrollTop = position
      return
   end
   if not options.fromSlider then
      self.scrollbar:SetValue(position)
   end
end
function WScrollList:setShouldSort(to, update)
   self.shouldSort = to
   if to then
      self:sort()
      if (update == true) or (update == nil) then
         self:redraw()
      end
   end
end
function WScrollList:setSortFunction(f, update)
   self.sortFunction = f or _defaultSortFunction
   if self.shouldSort then
      self:sort()
      if (update == true) or (update == nil) then
         self:redraw()
      end
   end
end
function WScrollList:sort()
   local indices = {}
   local count   = 0
   for k, _ in ipairs(self.listItems) do
      count = count + 1
      indices[count] = k
   end
   table.sort(indices, function(a, b)
      local itemA = self.listItems[a]
      local itemB = self.listItems[b]
      return self.sortFunction(itemA, itemB)
   end)
   local replItems  = {}
   local replStates = {}
   for i = 1, count do
      replItems[i]  = self.listItems[indices[i]]
      replStates[i] = self.listItemStates[indices[i]]
   end
   self.listItems      = replItems
   self.listItemStates = replStates
   self.dirty = true
end
function WScrollList:_updateScrollbar(scrollMax)
   --
   -- This function handles the following tasks:
   --
   -- a) Show or hide the scrollbar depending on whether scrolling is possible.
   --
   -- b) Update anchors for the scrollbar and the content area, based on our 
   --    padding settings.
   --
   local scrollbar  = self.scrollbar
   if scrollMax == nil then
      scrollMax = self.scrollMax
   end
   if scrollMax < 0 then
      scrollMax = self:measureItems()
   end
   do -- Update anchors to account for padding
      local control  = self:asControl()
      do -- scrollbar
         local SCROLL_BUTTON_HEIGHT = 16 -- assumed; this is the constant ZOS uses to offset scrollbars downward
         scrollbar:ClearAnchors()
         scrollbar:SetAnchor(TOPRIGHT,    control, TOPRIGHT,    -self.paddingSides, SCROLL_BUTTON_HEIGHT + self.paddingStart)
         scrollbar:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -self.paddingSides, -(SCROLL_BUTTON_HEIGHT + self.paddingEnd))
      end
      do -- content
         local contents = self.contents
         contents:ClearAnchors()
         contents:SetAnchor(TOPLEFT,     control, TOPLEFT,     self.paddingSides, self.paddingStart)
         contents:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -(self.paddingSides * 2 + ZO_SCROLL_BAR_WIDTH), -self.paddingEnd)
      end
   end
   local listHeight = self.contents:GetHeight()
   local barHeight  = scrollbar:GetHeight()
   if scrollMax > 0 and scrollMax > listHeight then
      scrollbar:SetEnabled(true)
      scrollbar:SetHidden(false)
      scrollbar:SetThumbTextureHeight(barHeight * listHeight / (scrollMax + listHeight))
      scrollbar:SetMinMax(0, scrollMax - listHeight)
   else
      self.scrollTop = 0
      --scrollbar:SetThumbTextureHeight(barHeight)
      scrollbar:SetThumbTextureHeight(0)
      scrollbar:SetMinMax(0, 0)
      scrollbar:SetEnabled(false)
      scrollbar:SetHidden(scrollbar.hideScrollBarOnDisabled)
   end
end