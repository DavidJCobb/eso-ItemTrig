if not (ItemTrig and ItemTrig.UI) then return end

ItemTrig.UI.WBulletedList = ItemTrig.UI.WidgetClass:makeSubclass("WBulletedList", "bulletedList")
local WBulletedList = ItemTrig.UI.WBulletedList
function WBulletedList:_construct(options)
   if not options then
      options = {}
   end
   if not options.style then
      options.style = {}
   end
   self.listItems = {}
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
   self:forEach(function(item, depth)
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
      local offsetX
      if self.style.topLevelHasBullet then
         offsetX = (self.style.indent * (depth - 1))
      else
         offsetX = (self.style.indent * (depth - 2))
         if offsetX < 0 then
            offsetX = 0
         end
      end
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
      text:SetText(item.text)
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