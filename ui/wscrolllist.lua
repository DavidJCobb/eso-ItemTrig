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
   widget:scrollBy(-widget.scrollStep)
end
local function onScrollDownButton(self)
   local widget = ItemTrig.UI.WScrollList:cast(self:GetParent():GetParent())
   widget:scrollBy(widget.scrollStep)
end

ItemTrig.UI.WScrollList = ItemTrig.UI.WidgetClass:makeSubclass("WScrollList", "scrollList")
function ItemTrig.UI.WScrollList:_construct(options)
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
   self.contents   = self:GetNamedChild("Contents")
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
function ItemTrig.UI.WScrollList:at(index)
   if (not index) or index < 1 or index > table.getn(self.listItems) then
      return nil
   end
   return self.listItems[index]
end
function ItemTrig.UI.WScrollList:clear(update)
   ZO_ClearNumericallyIndexedTable(self.listItems)
   if (update == true) or (update == nil) then
      self:redraw()
   end
end
function ItemTrig.UI.WScrollList:controlByIndex(index)
   if (not index) or index < 1 then
      return nil
   end
   local contents = self.contents
   if index > contents:GetNumChildren() then
      return nil
   end
   return contents:GetChild(index)
end
function ItemTrig.UI.WScrollList:count()
   return table.getn(self.listItems)
end
function ItemTrig.UI.WScrollList:fromItem(control) -- static method
   return self:cast(control:GetParent():GetParent())
end
function ItemTrig.UI.WScrollList:indexOf(control)
   local contents = self.contents
   local count    = contents:GetNumChildren()
   for i = 1, count do
      if contents:GetChild(i) == control then
         return i
      end
   end
   return 0
end
function ItemTrig.UI.WScrollList:indexOfData(data)
   for i = 1, table.getn(self.listItems) do
      if self.listItems[i] == data then
         return i
      end
   end
   return 0
end
function ItemTrig.UI.WScrollList:push(obj, update)
   table.insert(self.listItems, obj)
   if (update == true) or (update == nil) then
      self:redraw()
   end
end
function ItemTrig.UI.WScrollList:_onRemoved(index, data) -- for subclasses to override
end
function ItemTrig.UI.WScrollList:onRedrawOrReposition()
   --
   -- Can be overridden.
   --
end
function ItemTrig.UI.WScrollList:remove(x, update)
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
   self:_onRemoved(x, item)
   if (update == true) or (update == nil) then
      self:redraw()
   end
end
function ItemTrig.UI.WScrollList:resizeScrollbar(scrollMax)
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
function ItemTrig.UI.WScrollList:_getExtraConstructorParams(index)
   --
   -- Subclasses can override this in order to provide additional 
   -- state to elements when they are being constructed.
   --
   return nil
end
function ItemTrig.UI.WScrollList:redraw()
   assert(self.element.toConstruct ~= nil, "You must supply a constructor callback before WScrollList can render list items.")
   assert(self.element.template    ~= "",  "You must supply a template to use for list items before WScrollList can render list items.")
   local contents = self.contents
   local existing = contents:GetNumChildren()
   local count    = table.getn(self.listItems)
   local yOffset  = -self.scrollTop
   local total    = 0
   local index    = 0
   for i = 1, existing do
      local child = contents:GetChild(i)
      if i <= count then
         child:SetHidden(false)
         self.element.toConstruct(child, self.listItems[i], self:_getExtraConstructorParams(i))
         child:ClearAnchors()
         child:SetAnchor(TOPLEFT,  contents, TOPLEFT,  0, yOffset)
         child:SetAnchor(TOPRIGHT, contents, TOPRIGHT, 0, yOffset)
         --
         local height = child:GetHeight()
         yOffset = yOffset + height + self.paddingBetween
         total   = total   + height + self.paddingBetween
      else
         child:SetHidden(true)
      end
      index = i
   end
   index = index + 1
   if index <= count then
      for i = index, count do
         local control, key = self.element._pool:AcquireObject()
         control.key = key
         --
         self.element.toConstruct(control, self.listItems[i], self:_getExtraConstructorParams(i))
         control:ClearAnchors()
         control:SetAnchor(TOPLEFT,  contents, TOPLEFT,  0, yOffset)
         control:SetAnchor(TOPRIGHT, contents, TOPRIGHT, 0, yOffset)
         --
         local height = control:GetHeight()
         yOffset = yOffset + height + self.paddingBetween
         total   = total   + height + self.paddingBetween
      end
   end
   if count then
      total = total - self.paddingBetween
   end
   self.scrollMax = total
   self:resizeScrollbar(total)
   self:onRedrawOrReposition()
end
function ItemTrig.UI.WScrollList:repositionItems()
   local contents = self.contents
   local existing = contents:GetNumChildren()
   local count    = table.getn(self.listItems)
   if existing < count then
      count = existing
   end
   local yOffset  = -self.scrollTop
   for i = 1, count do
      local child = contents:GetChild(i)
      child:ClearAnchors()
      child:SetAnchor(TOPLEFT,  contents, TOPLEFT,  0, yOffset)
      child:SetAnchor(TOPRIGHT, contents, TOPRIGHT, 0, yOffset)
      yOffset = yOffset + child:GetHeight() + self.paddingBetween
   end
   self:resizeScrollbar()
   self:onRedrawOrReposition()
end
function ItemTrig.UI.WScrollList:measureItems()
   local contents = self.contents
   local existing = contents:GetNumChildren()
   local count    = table.getn(self.listItems)
   if existing < count then
      count = existing
   end
   if count < 1 then
      return 0
   end
   local child = contents:GetChild(count)
   return ItemTrig.offsetBottom(child) + self.paddingEnd + self.scrollTop
   --[[--
   local yOffset  = self.paddingStart
   for i = 1, count do
      local child = contents:GetChild(i)
      yOffset = yOffset + child:GetHeight() + self.paddingBetween
   end
   if count then
      yOffset = yOffset - self.paddingBetween + self.paddingEnd
   end
   self.scrollMax = yOffset
   return yOffset
   --]]--
end
function ItemTrig.UI.WScrollList:scrollBy(delta) -- analogous to ZO_ScrollList_ScrollRelative
   local position = delta + self.scrollTop
   self:scrollTo(position)
end
function ItemTrig.UI.WScrollList:scrollToItem(index, shouldBeCentered, lazy)
   if (not index) or index < 0 then
      return
   end
   local contents = self.contents
   if index > contents:GetNumChildren() then
      return
   end
   local child    = contents:GetChild(index)
   local position = child:GetTop()
   if shouldBeCentered then
      local listHeight  = contents:GetHeight()
      local childHeight = child:GetHeight()
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
function ItemTrig.UI.WScrollList:scrollTo(position) -- analogous to ZO_ScrollList_ScrollAbsolute
   local height = self.contents:GetHeight()
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
   if self.scrollTop == position then
      return
   end
   if self.scrollbar:IsHidden() then
      self.scrollTop = position
      return
   end
   self.scrollbar:SetValue(position) -- slider XML-side event handler will call repositionItems
end