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
function WTooltip:show(target, text, axis, prefer, distance)
   axis     = axis     or self.AXIS_H
   prefer   = prefer   or self.PREFER_FORWARD
   distance = distance or 0
   --
   self:refreshStyle()
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