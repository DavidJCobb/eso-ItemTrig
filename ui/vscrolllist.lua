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
   self:scrollBy(delta)
   --
   -- TODO: can/should we animate scrolling?
   --
   if onScrollCompleteCallback then
      onScrollCompleteCallback() -- TODO: what args is this meant to take?
   end
end
local function onScrollUpButton(self)
    scrollRelative(self:GetParent():GetParent(), -self.tlData.scrollStep)
end
local function onScrollDownButton(self)
    scrollRelative(self:GetParent():GetParent(), self.tlData.scrollStep)
end

ItemTrig.UI.vScrollList = {}
ItemTrig.UI.vScrollList.__index = ItemTrig.UI.vScrollList
function ItemTrig.UI.vScrollList:initialize(control, template, construct, options)
   assert(template  ~= nil) -- string
   assert(construct ~= nil) -- callback
   if not options then
      options = {
         scrollStep = 1,
         reset      = nil, -- callback
      }
   end
   self.tlData = {
      listItems  = {},
      contents   = GetControl(self, "Contents"),
      scrollbar  = GetControl(self, "ScrollBar"),
      scrollBtnU = GetControl(self, "Up"),
      scrollBtnD = GetControl(self, "Down"),
      scrollStep = options.scrollStep,
      template   = template,
      construct  = construct,
      scrollTop  = 0,
      scrollMax  = -1,
   }
   do
      local factoryFunction =
         function(objectPool)
            return ZO_ObjectPool_CreateNamedControl(string.format("%s%dRow", self:GetName(), typeId), template, objectPool, self.tlData.contents)
         end
      tlData.pool = ZO_ObjectPool:New(factoryFunction, options.reset or ZO_ObjectPool_DefaultResetControl)
   end
   self.tlData.scrollBtnU:SetHandler("OnMouseDown", onScrollUpButton)
   self.tlData.scrollBtnD:SetHandler("OnMouseDown", onScrollDownButton)
   self.tlData.scrollbar:SetEnabled(false)
end
function ItemTrig.UI.vScrollList:push(obj, update)
   table.insert(self.tlData.listItems)
   if (update == true) or (update == nil) then
      self:redraw()
   end
end
function ItemTrig.UI.vScrollList:redraw()
   local contents = self.tlData.contents
   local existing = contents:GetNumChildren()
   local count    = table.getn(self.tlData.listItems)
   local yOffset  = -self.tlData.scrollTop
   local total    = 0
   for i = 1, existing do
      local child = self:GetChild(i)
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
   end
   if existing < count then
      for i = count - existing, count do
         local control, key = self.tlData.pool:AcquireObject()
         control.key = key
         --
         self.tlData.construct(control, self.tlData.listItems[i])
         control:ClearAnchors()
         control:SetAnchor(TOPLEFT,  contents, TOPLEFT,  0, yOffset)
         control:SetAnchor(TOPRIGHT, contents, TOPRIGHT, 0, yOffset)
         --
         local height = child:GetHeight()
         yOffset = yOffset + child:GetHeight()
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
      local child = self:GetChild(i)
      control:ClearAnchors()
      control:SetAnchor(TOPLEFT,  contents, TOPLEFT,  0, yOffset)
      control:SetAnchor(TOPRIGHT, contents, TOPRIGHT, 0, yOffset)
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
      local child = self:GetChild(i)
      yOffset = yOffset + child:GetHeight()
   end
   return yOffset
end
function ItemTrig.UI.vScrollList:scrollBy(delta) -- analogous to ZO_ScrollList_ScrollRelative
   local position = delta + self.tlData.scrollTop
   self:scrollTo(position)
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
   self:repositionItems()
end

local function render(control)
   
end