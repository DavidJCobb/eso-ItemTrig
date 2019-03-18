if not (ItemTrig and ItemTrig.UI) then return end

ItemTrig.UI.WTooltip = ItemTrig.UI.WidgetClass:makeSubclass("WTooltip", "tooltip")
local WTooltip = ItemTrig.UI.WTooltip

local borderWidth    = 3 * ItemTrig.PIXEL
local borderDistance = 7

WTooltip.AXIS_H = 0
WTooltip.AXIS_V = 1
WTooltip.PREFER_FORWARD  = 0
WTooltip.PREFER_BACKWARD = 1

function WTooltip:_construct(options)
   options = options or {}
   --
   self.controls = {
      edge = self:GetNamedChild("Edge"),
      fill = self:controlByPath("Edge", "Fill"),
      text = self:GetNamedChild("Text"),
   }
   self.options = {
      adoptCrossAxisSize = options.adoptCrossAxisSize or false,
   }
   self:refreshStyle()
end
function WTooltip:hide()
   ClearTooltip(self:asControl())
end
function WTooltip:refreshStyle()
   local edge = self.controls.edge
   local fill = self.controls.fill
   local text = self.controls.text
   do -- edge
      local color  = ItemTrig.theme.TOOLTIP_BORDER
      local offsetX = borderDistance + borderWidth
      local offsetY = borderWidth
      local parent = self:asControl()
      edge:ClearAnchors()
      edge:SetAnchor(TOPLEFT,     parent, TOPLEFT,     -offsetX, -offsetY)
      edge:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT,  offsetX,  offsetY)
      edge:SetColor(unpack(color))
   end
   do -- fill
      local color  = ItemTrig.theme.TOOLTIP_BACKGROUND
      local offsetX = borderWidth
      local offsetY = borderWidth
      fill:ClearAnchors()
      fill:SetAnchor(TOPLEFT,     edge, TOPLEFT,      offsetX,  offsetY)
      fill:SetAnchor(BOTTOMRIGHT, edge, BOTTOMRIGHT, -offsetX, -offsetY)
      fill:SetColor(unpack(color))
   end
   do -- text
      local color  = ItemTrig.theme.TOOLTIP_TEXT
      text:SetColor(unpack(color))
   end
end
function WTooltip:setText(text)
   self.controls.text:SetText(text)
   if text == "" then
      self:hide()
   end
end
function WTooltip:show(target, text, axis, prefer, distance)
   axis     = axis     or self.AXIS_H
   prefer   = prefer   or self.PREFER_FORWARD
   distance = distance or 0
   --
   if target and text ~= "" then
      local control = self:asControl()
      self:setText(text)
      if self.options.adoptCrossAxisSize then
         if axis == self.AXIS_W then
            control:SetHeight(target:GetHeight())
         else
            control:SetWidth(target:GetWidth())
         end
      end
      --
      local anchorThis
      local anchorTarget
      local offsetX = 0
      local offsetY = 0
      do
         local cw = control:GetWidth()
         local ch = control:GetHeight()
         local sw = GuiRoot:GetWidth()
         local sh = GuiRoot:GetHeight()
         --
         local cross
         local backward
         local forward
         local before
         local after
         local mainSize
         do
            if axis == self.AXIS_W then
               cross    = TOP
               backward = RIGHT
               forward  = LEFT
               mainSize = cw
               before   = target:GetLeft() - distance
               after    = sh - target:GetLeft() - target:GetWidth() - distance
               --
               offsetX = distance + (borderWidth * 2 + borderDistance)
            else
               cross    = LEFT
               backward = TOP
               forward  = BOTTOM
               mainSize = ch
               before   = target:GetTop() - distance
               after    = sh - target:GetTop() - target:GetHeight() - distance
               --
               offsetY = distance + (borderWidth * 2 + borderDistance)
            end
         end
         do
            local canFitBefore = before >= mainSize
            local canFitAfter  = after  >= mainSize
            if prefer == self.PREFER_FORWARD then
               if not canFitAfter and canFitBefore then
                  anchorTarget = backward or cross
                  anchorThis   = forward  or cross
                  --
                  offsetX = -offsetX
                  offsetY = -offsetY
               else
                  anchorTarget = forward  or cross
                  anchorThis   = backward or cross
               end
            else
               if not canFitBefore and canFitAfter then
                  anchorTarget = forward  or cross
                  anchorThis   = backward or cross
               else
                  anchorTarget = backward or cross
                  anchorThis   = forward  or cross
                  --
                  offsetX = -offsetX
                  offsetY = -offsetY
               end
            end
         end
      end
      InitializeTooltip(control, target, anchorThis, offsetX, offsetY, anchorTarget)
   else
      self:hide()
   end
end