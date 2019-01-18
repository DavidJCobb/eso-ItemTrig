if not ItemTrig then return end
if not ItemTrig.UI then
   ItemTrig.UI = {}
end

--
-- Class for scrolling a list of variably-sized items, with pixel 
-- scrolling rather than whole-item scrolling. All items are 
-- rendered at once.
--
-- TODO: How do we handle overflow?
--

local function scrollRelative(self, delta, onScrollCompleteCallback, animateInstantly)
   -- if in doubt, model after Zenimax's ZO_ScrollList_ScrollRelative
   ItemTrig.UI.vScrollList.scrollBy(self, delta)
   --
   -- TODO: can/should we animate scrolling?
   --
   if onScrollCompleteCallback then
      onScrollCompleteCallback() -- TODO: what args is this meant to take?
   end
end
local function onScrollUpButton(self)
   local list = self:GetParent():GetParent()
   scrollRelative(list, -list.tlData.scrollStep)
end
local function onScrollDownButton(self)
   local list = self:GetParent():GetParent()
   scrollRelative(list, list.tlData.scrollStep)
end

ItemTrig.UI.vScrollList = {}
ItemTrig.UI.vScrollList.__index = ItemTrig.UI.vScrollList
function ItemTrig.UI.vScrollList:initialize(control, template, construct, options)
   --assert(template  ~= nil) -- string
   --assert(construct ~= nil) -- callback
   if not options then
      options = {
         scrollStep = 1,
         reset      = nil, -- callback
      }
   end
   local scrollbar = GetControl(self, "ScrollBar")
   self.tlData = {
      listItems  = {},
      contents   = GetControl(self, "Contents"),
      scrollbar  = scrollbar,
      scrollBtnU = GetControl(scrollbar, "Up"),
      scrollBtnD = GetControl(scrollbar, "Down"),
      scrollStep = options.scrollStep,
      template   = template,
      construct  = construct,
      scrollTop  = 0,
      scrollMax  = -1,
   }
   do
      local factoryFunction =
         function(objectPool)
            return ZO_ObjectPool_CreateNamedControl(string.format("%sRow", self:GetName()), self.tlData.template, objectPool, self.tlData.contents)
         end
      self.tlData.pool = ZO_ObjectPool:New(factoryFunction, options.reset or ZO_ObjectPool_DefaultResetControl)
   end
   self.tlData.scrollBtnU:SetHandler("OnMouseDown", onScrollUpButton)
   self.tlData.scrollBtnD:SetHandler("OnMouseDown", onScrollDownButton)
   self.tlData.scrollbar:SetEnabled(false)
end
function ItemTrig.UI.vScrollList:clear(update)
   ZO_ClearNumericallyIndexedTable(self.tlData.listItems)
   if (update == true) or (update == nil) then
      ItemTrig.UI.vScrollList.redraw(self)
   end
end
function ItemTrig.UI.vScrollList:push(obj, update)
   table.insert(self.tlData.listItems, obj)
   if (update == true) or (update == nil) then
      ItemTrig.UI.vScrollList.redraw(self)
   end
end
function ItemTrig.UI.vScrollList:redraw()
   local contents = self.tlData.contents
   local existing = contents:GetNumChildren()
   local count    = table.getn(self.tlData.listItems)
   local yOffset  = -self.tlData.scrollTop
   local total    = 0
   local index    = 0
   for i = 1, existing do
      local child = contents:GetChild(i)
      if i <= count then
         child:SetHidden(false)
         self.tlData.construct(child, self.tlData.listItems[i])
         control:ClearAnchors()
         control:SetAnchor(TOPLEFT,  contents, TOPLEFT,  0, yOffset)
         control:SetAnchor(TOPRIGHT, contents, TOPRIGHT, 0, yOffset)
         --
         local height = child:GetHeight()
         yOffset = yOffset + child:GetHeight()
         total   = total   + height
      else
         child:SetHidden(true)
      end
      index = i
   end
   index = index + 1
   if index <= count then
      for i = index, count do
         local control, key = self.tlData.pool:AcquireObject()
         control.key = key
         --
         self.tlData.construct(control, self.tlData.listItems[i])
         control:ClearAnchors()
         control:SetAnchor(TOPLEFT,  contents, TOPLEFT,  0, yOffset)
         control:SetAnchor(TOPRIGHT, contents, TOPRIGHT, 0, yOffset)
         --
         local height = control:GetHeight()
         yOffset = yOffset + control:GetHeight()
         total   = total   + height
      end
   end
   self.tlData.scrollMax = total
end
function ItemTrig.UI.vScrollList:repositionItems()
   local contents = self.tlData.contents
   local existing = contents:GetNumChildren()
   local count    = table.getn(self.tlData.listItems)
   if existing < count then
      count = existing
   end
   local yOffset  = -self.tlData.scrollTop
   for i = 1, count do
      local child = contents:GetChild(i)
      child:ClearAnchors()
      child:SetAnchor(TOPLEFT,  contents, TOPLEFT,  0, yOffset)
      child:SetAnchor(TOPRIGHT, contents, TOPRIGHT, 0, yOffset)
      yOffset = yOffset + child:GetHeight()
   end
end
function ItemTrig.UI.vScrollList:measureItems()
   local contents = self.tlData.contents
   local existing = contents:GetNumChildren()
   local count    = table.getn(self.tlData.listItems)
   if existing < count then
      count = existing
   end
   local yOffset  = 0
   for i = 1, count do
      local child = contents:GetChild(i)
      yOffset = yOffset + child:GetHeight()
   end
   return yOffset
end
function ItemTrig.UI.vScrollList:scrollBy(delta) -- analogous to ZO_ScrollList_ScrollRelative
   local position = delta + self.tlData.scrollTop
   ItemTrig.UI.vScrollList.scrollTo(self, position)
end
function ItemTrig.UI.vScrollList:scrollTo(position) -- analogous to ZO_ScrollList_ScrollAbsolute
   local height = self:GetHeight()
   if position < 0 then
      position = 0
   else
      if self.tlData.scrollMax < 0 then
         self:measureItems()
      end
      if position > self.tlData.scrollMax - height then
         position = self.tlData.scrollMax - height
         if position < 0 then
            position = 0
         end
      end
   end
   self.tlData.scrollTop = position
   ItemTrig.UI.vScrollList.repositionItems(self)
end