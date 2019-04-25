if not (ItemTrig and ItemTrig.UI) then return end

ItemTrig.UI.WTooltip = ItemTrig.UI.WidgetClass:makeSubclass("WTooltip", "tooltip")
local WTooltip = ItemTrig.UI.WTooltip

--[[--

   WTOOLTIP

   A simple widget for showing a text-only tooltip adjacent to some 
   element. You can specify the axis on which you'd like to position 
   the tooltip, and what side of that axis to prefer.
   
   An example call:
   
      tooltip:show(myControl, "Hi!", tooltip.AXIS_H, tooltip.PREFER_FORWARD, 7)
   
   In that example, the tooltip will try to position itself to the 
   right of the target control (horizontal axis, forward direction). 
   If there isn't enough room on the screen to do that, then it will 
   instead position itself on the left. "Forward" refers to down and 
   to the right, while "backward" is up and to the left.
   
   If you set the (adoptCrossAxisSize) option on the tooltip to true, 
   then it will resize itself to match the element it is being placed 
   near: it will copy whatever axis it is NOT being positioned by 
   (e.g. if it's to the left or right of the target, then it will copy 
   the target's height).
   
   "Cross axis" is a term borrowed from CSS flex; it exists in contrast 
   to the "main axis."

--]]--

local borderWidth    = 3 * ItemTrig.PIXEL
local borderDistance = 7

WTooltip.AXIS_H = 0
WTooltip.AXIS_V = 1
WTooltip.PREFER_FORWARD  = 0
WTooltip.PREFER_BACKWARD = 1

local getCurrentThemeColor = ItemTrig.getCurrentThemeColor

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
      local color   = getCurrentThemeColor("TOOLTIP_BORDER")
      local offsetX = borderDistance + borderWidth
      local offsetY = borderWidth
      local parent = self:asControl()
      edge:ClearAnchors()
      edge:SetAnchor(TOPLEFT,     parent, TOPLEFT,     -offsetX, -offsetY)
      edge:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT,  offsetX,  offsetY)
      edge:SetColor(unpack(color))
   end
   do -- fill
      local color  = getCurrentThemeColor("TOOLTIP_BACKGROUND")
      local offsetX = borderWidth
      local offsetY = borderWidth
      fill:ClearAnchors()
      fill:SetAnchor(TOPLEFT,     edge, TOPLEFT,      offsetX,  offsetY)
      fill:SetAnchor(BOTTOMRIGHT, edge, BOTTOMRIGHT, -offsetX, -offsetY)
      fill:SetColor(unpack(color))
   end
   do -- text
      local color  = getCurrentThemeColor("TOOLTIP_TEXT")
      text:SetColor(unpack(color))
   end
end
function WTooltip:setText(text)
   self.controls.text:SetText(text)
   if text == "" then
      self:hide()
   end
end
function WTooltip:show(target, text, axis, prefer, distance, crossOffset)
   --
   -- (axis) is the axis on which the tooltip should be positioned -- whether 
   -- it should be horizontally aligned with the (target) i.e. to the left or 
   -- to the right, or vertically aligned with the (target).
   --
   -- (prefer) indicates which direction on that axis you would prefer the 
   -- tooltip to be positioned: forward (down/right) or backward (up/left). 
   -- If there isn't room on the desired side (i.e. the tooltip would go off-
   -- screen), then it will use the other side instead.
   --
   -- (distance) is the distance along the main axis (i.e. (axis)), while 
   -- (crossOffset) is an offset along the cross axis (the opposite of the 
   -- main axis). The (crossOffset) is always in the forward direction for 
   -- the cross axis.
   --
   axis        = axis     or self.AXIS_H
   prefer      = prefer   or self.PREFER_FORWARD
   distance    = distance or 0
   crossOffset = crossOffset or 0
   --
   self:refreshStyle()
   --
   if target and text ~= "" then
      local control = self:asControl()
      self:setText(text)
      if self.options.adoptCrossAxisSize then
         if axis == self.AXIS_H then
            control:SetHeight(target:GetHeight())
         else
            control:SetWidth(target:GetWidth())
         end
      end
      if axis == self.AXIS_H then
         --
         -- gotta fix the width manually because resize-to-fit-descendents sucks
         --
         control:SetWidth(400) -- we need the text to not be wrapped
         control:SetWidth(self.controls.text:GetTextWidth())
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
         do -- Assign vars based on the main and cross axes.
            if axis == self.AXIS_H then
               cross    = TOP
               backward = LEFT
               forward  = RIGHT
               mainSize = cw
               before   = target:GetLeft() - distance
               after    = sw - target:GetLeft() - target:GetWidth() - distance
               --
               offsetX = distance + (borderWidth * 2 + borderDistance * 2)
            else
               cross    = LEFT
               backward = TOP
               forward  = BOTTOM
               mainSize = ch
               before   = target:GetTop() - distance
               after    = sh - target:GetTop() - target:GetHeight() - distance
               --
               offsetY = distance + (borderWidth * 2 + borderDistance * 2)
            end
         end
         do -- Main positioning.
            local canFitBefore = before >= mainSize
            local canFitAfter  = after  >= mainSize
            if prefer == self.PREFER_FORWARD then
               if (not canFitAfter) and canFitBefore then
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
               if (not canFitBefore) and canFitAfter then
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
         do -- crossOffset
            if axis == self.AXIS_H then
               offsetY = crossOffset
            else
               offsetX = crossOffset
            end
         end
      end
      InitializeTooltip(control, target, anchorThis, offsetX, offsetY, anchorTarget)
   else
      self:hide()
   end
end

--[[--

   WTOOLTIPINPLACE
   
   This is what Windows calls an "in-place tooltip." If you hover over 
   a list item somewhere that has been truncated, an in-place tooltip 
   will fully cover the list item and extend beyond it, allowing you 
   to see the full, untruncated text. You can click through the tooltip 
   to activate the list item. Typical Windows behavior is not to show 
   these on selected list items, since tooltips must have a uniform 
   background color i.e. they cannot show "selected" state.
   
   This really just overrides the (show) method.

--]]--

ItemTrig.UI.WTooltipInPlace = ItemTrig.UI.WTooltip:makeSubclass("WTooltipInPlace")
local WTooltipInPlace = ItemTrig.UI.WTooltipInPlace
function WTooltipInPlace:_construct(options)
end
function WTooltipInPlace:show(target, text, axis, baseLength)
   --
   -- The (axis) is the axis on which the (target) control is truncated. 
   -- The (baseLength) should be a maximum width for the tooltip. Note 
   -- that you can no longer express a preference for aligning forward 
   -- or backward; we always extend forward.
   --
   self:refreshStyle()
   if target and text ~= "" then
      local control = self:asControl()
      self:setText(text)
      if axis == self.AXIS_H then
         control:SetHeight(target:GetHeight())
         control:SetWidth(baseLength or 400)
         --
         local length = self.controls.text:GetTextWidth()
         local other  = target:GetWidth()
         control:SetWidth(math.max(length, other))
      else
         control:SetWidth(target:GetWidth())
         control:SetHeight(baseLength or 400)
         --
         local length = self.controls.text:GetTextHeight()
         local other  = target:GetHeight()
         control:SetHeight(math.max(length, other))
      end
      InitializeTooltip(control, target, TOPLEFT, 0, 0, TOPLEFT)
   else
      self:hide()
   end
end