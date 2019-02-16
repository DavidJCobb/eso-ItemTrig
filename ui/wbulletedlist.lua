if not (ItemTrig and ItemTrig.UI) then return end

--[[
   WBULLETEDLIST
   This class automates the process of showing a bulleted list, with nested 
   list items allowed. There are no accessors to the list that an instance 
   will display; for now, tamper with the (listItems) member directly. A 
   nested list looks like this:
   
   {
      [1] = { text = "List item 1" },
      [2] = { text = "List item 2" },
      [3] = {
         text = "List item 3",
         children = {
            [1] = { text = "List item 3.1" },
            [2] = { text = "List item 3.2" },
         },
      },
   }
   
   Lists can be nested to any depth.
   
   WBulletedList can limit the depth to which it displays list items, with 
   three options: don't show elements past a specified nesting level; stop 
   showing elements once we've indented past half of the container's width; 
   or stop showing elements once we have less than a specified amount of 
   space remaining due to indentation. List items that are disqualified by 
   these criteria are skipped when rendering, but there is also an option 
   to show a placeholder string (e.g. "...") in place of the first list 
   item to disqualify in a row.
]]--

ItemTrig.UI.WBulletedList = ItemTrig.UI.WidgetClass:makeSubclass("WBulletedList", "bulletedList")
local WBulletedList = ItemTrig.UI.WBulletedList
function WBulletedList:_construct(options)
   if not options then
      options = {}
   end
   if not options.style then
      options.style = {}
   end
   self.listItems  = {}
   self.depthLimit = options.depthLimit or nil -- if true, limit to 50% width; if a number, limit to that number
   self.depthSpace = options.depthSpace or nil -- if depthLimit == true and this value isn't nil, then instead of limiting to 50% width, we require that this much width be available
   do
      self.element = {
         template = "ItemTrig_UITemplate_WBulletedListItem",
         toReset  = nil,
      }
      local factoryFunction =
         function(objectPool)
            local parent = self:asControl()
            return ZO_ObjectPool_CreateNamedControl(string.format("%sRow", parent:GetName()), self.element.template, objectPool, parent)
         end
      self.pool = ZO_ObjectPool:New(factoryFunction, self.element.toReset or ZO_ObjectPool_DefaultResetControl)
   end
   do
      local s = options.style
      self.style = {
         tooDeepText = s.tooDeepText or nil, -- if this is a non-empty string, then the first too-deep list item will be rendered with this string
         font        = s.font        or "ITEMTRIG_FONT_BASIC",
         fontColor   = s.fontColor   or ItemTrig.theme.WINDOW_BARE_TEXT_COLOR,
         bulletColor = s.bulletColor or s.fontColor or ItemTrig.theme.WINDOW_BARE_TEXT_COLOR,
         indent      = s.indent      or 48, -- indentation for nested list items
         bulletSpaceBefore = s.bulletSpaceBefore or 16, -- space between bullet and margin
         bulletSpaceAfter  = s.bulletSpaceAfter  or 16, -- space between bullet and text
         topLevelHasBullet = s.topLevelHasBullet or true,
      }
   end
end
function WBulletedList:forEach(functor, _)
   local depth = (_ and _.depth) or 1
   local set   = (_ and _.set)   or self.listItems
   for i = 1, table.getn(set) do
      local item = set[i]
      if functor(item, depth) then
         return true
      end
      if item.children and table.getn(item.children) then
         if self:forEach(functor, { set = item.children, depth = depth + 1 }) then
            return true
         end
      end
   end
end
function WBulletedList:refreshStyle()
   --
   -- Use this when the list's style has changed in a way that won't 
   -- affect the size or positioning of any elements; this should be 
   -- cheaper than redrawing the list entirely.
   --
   local root     = self:asControl()
   local existing = root:GetNumChildren()
   local bulletY  = nil
   for i = 1, existing do
      local child = root:GetChild(i)
      if child and not child:IsHidden() then
         local bullet = GetControl(child, "Bullet")
         local text   = GetControl(child, "Text")
         do -- style
            text:SetColor(unpack(self.style.fontColor))
            bullet:SetColor(unpack(self.style.bulletColor))
         end
      end
   end
end
function WBulletedList:redraw()
   local root     = self:asControl()
   local existing = root:GetNumChildren()
   local created  = 0
   local count    = 1
   local offsetY  = 0
   local bulletY  = nil
   local width    = root:GetWidth()
   local badCount   = 0
   local badAllowed = 0
   if self.style.tooDeepText and self.style.tooDeepText ~= "" then
      badAllowed = 1
   end
   self:forEach(function(item, depth)
      local currentIsBad = false
      if type(self.depthLimit) == "number" and depth > self.depthLimit then
         currentIsBad = true
      end
      local offsetX
      if self.style.topLevelHasBullet then
         offsetX = (self.style.indent * (depth - 1))
      else
         offsetX = (self.style.indent * (depth - 2))
         if offsetX < 0 then
            offsetX = 0
         end
      end
      if self.depthLimit == true and depth > 1 then
         if self.depthSpace ~= nil then
            local space = self.depthSpace
            currentIsBad = (width - offsetX) < self.depthSpace
         elseif offsetX > (width / 2) then
            currentIsBad = true
         end
      end
      if currentIsBad then
         badCount = badCount + 1
         if badCount > badAllowed then
            return
         end
      else
         badCount = 0
      end
      --
      local child
      if count <= existing + created then
         child = root:GetChild(count)
      else
         local control, key = self.pool:AcquireObject()
         child   = control
         created = created + 1
      end
      count = count + 1
      --
      child:SetHidden(false)
      local bullet  = GetControl(child, "Bullet")
      local text    = GetControl(child, "Text")
      if depth > 1 or self.style.topLevelHasBullet then
         offsetX = offsetX + self.style.bulletSpaceBefore
         bullet:SetHidden(false)
      else
         bullet:SetHidden(true)
      end
      child:ClearAnchors()
      child:SetAnchor(TOPLEFT,  root, TOPLEFT,  0, offsetY)
      child:SetAnchor(TOPRIGHT, root, TOPRIGHT, 0, offsetY)
      --
      do -- style
         text:SetFont(self.style.font)
         text:SetColor(unpack(self.style.fontColor))
         bullet:SetColor(unpack(self.style.bulletColor))
         if bulletY == nil then
            local lineHeight = text:GetFontHeight()
            local bullHeight = bullet:GetHeight()
            bulletY = (lineHeight - bullHeight) / 2
         end
      end
      bullet:ClearAnchors()
      bullet:SetAnchor(TOPLEFT, child, TOPLEFT, offsetX, bulletY)
      if depth > 1 or self.style.topLevelHasBullet then
         offsetX = offsetX + bullet:GetWidth() + self.style.bulletSpaceAfter
      end
      text:ClearAnchors()
      text:SetAnchor(TOPLEFT,  child, TOPLEFT,  offsetX, 0)
      text:SetAnchor(TOPRIGHT, child, TOPRIGHT, 0, 0)
      if currentIsBad then
         text:SetText(self.style.tooDeepText)
      else
         text:SetText(item.text)
      end
      --
      child:SetHeight(text:GetHeight())
      offsetY = offsetY + child:GetHeight()
   end)
   if count <= existing then
      for i = count, existing do
         root:GetChild(i):SetHidden(true)
      end
   end
   root:SetHeight(offsetY)
end