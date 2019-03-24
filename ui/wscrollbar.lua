assert(ItemTrig and ItemTrig.UI and ItemTrig.UI.WidgetClass, "Incorrect load order for this file.")

ItemTrig.UI.WScrollbar = ItemTrig.UI.WidgetClass:makeSubclass("WScrollbar", "scrollbar")
local WScrollbar = ItemTrig.UI.WScrollbar

--[[
   WSCROLLBAR
   
   A WidgetClass-based scrollbar; this alternative to the Zenimax 
   scrollbar is slightly more configurable and more self-contained.
   
   WScrollbar has a callbacks object and will send a "request-scroll" 
   callback whenever the user interacts with it in a way that should 
   cause a change in scroll position. The callback will pass a single 
   argument: an event object with the following fields:
   
    - direction
      Either nil or one of the DIRECTION_* constants on WScrollbar.
   
    - delta
      If this is not nil, then you should multiply this by your desired 
      scroll step, multiply it by -1 if scrolling backward, and then 
      scroll your control by that amount.
   
    - source
      The type of interaction that caused a scroll.
   
    - position
      If this is not nil, then this is the exact position you should 
      scroll to. This is mutually exclusive with the (delta) field.
   
   WScrollbar instances change their alpha transparency depending on 
   whether they have mouseover focus. If you set an "area" for your 
   scrollbar -- that is, a control; generally the scrollable pane that 
   the scrollbar controls -- then mousing over the area will also alter 
   the scrollbar alpha. Zenimax typically makes their scrollbars fully 
   opaque if they're moused over, mostly opaque if their area is moused 
   over, and half opaque otherwise.
   
   For a usage example, look at WScrollList's constructor, which sets 
   up a WScrollbar.
   
]]--

WScrollbar.DIRECTION_BACKWARD = -1
WScrollbar.DIRECTION_FORWARD  =  1

WScrollbar.style = {
   alphaInitial   = 0.5, -- alpha when the mouse isn't near the scrollbar
   alphaHoverArea = 0.8, -- alpha when the mouse is over the scroll area
   alphaHoverSelf = 1.0, -- alpha when the mouse is over the scrollbar itself
}
do
   local registry = ItemTrig.ThemeManager.callbacks
   local function _refresh(theme)
      ItemTrig.assign(WScrollbar.style, {
         alphaInitial   = theme.numbers.SCROLLBAR_ALPHA_INITIAL,
         alphaHoverArea = theme.numbers.SCROLLBAR_ALPHA_HOVER_AREA,
         alphaHoverSelf = theme.numbers.SCROLLBAR_ALPHA_HOVER_SELF,
      })
   end
   registry:RegisterCallback("update", _refresh)
end

function WScrollbar:_construct(options)
   if not options then
      options = {}
   end
   local control = self:asControl()
   self.callbacks = ZO_CallbackObject:New()
   self.controls = {
      buttonUp   = self:GetNamedChild("Up"),
      buttonDown = self:GetNamedChild("Down"),
   }
   self.prefs = {
      alphaTransitionTime = options.alphaTransitionTime or 250, -- animation time in milliseconds
      area                = options.area                or nil, -- scrollable pane to which this bar is linked; control, not widget
      hideOnDisabled      = options.hideOnDisabled      or false,
   }
   self.state = {
      changingValue = false,
      hover         = false,
      hoverArea     = false,
      targetAlpha   = self.prefs.alphaBase,
      thumbIsHeld   = false,
   }
   do -- style
      self.style = {}
      if options.style then
         --
         -- TODO: This doesn't allow subclasses to add their own style properties.
         --
         ItemTrig.assign(self.style, ItemTrig.filterKeys(options.style, WScrollbar.style))
      end
   end
   control:SetMinMax(0, 100)
   control:SetValue(0)
   control:SetAlpha(self:getComputedStyle().alphaInitial)
   do -- animation
      self.alphaAnimation, self.timeline = CreateSimpleAnimation(ANIMATION_ALPHA, control)
      self.alphaAnimation:SetDuration(self.prefs.alphaTransitionTime)
   end
   control:SetHandler("OnUpdate", function() self:_onUpdate() end)
end
do
   function WScrollbar:_onAreaMouseOver()
      self.state.hoverArea = true
      self:refreshAlpha()
   end
   function WScrollbar:_onAreaMouseOut()
      self.state.hoverArea = false
      self:refreshAlpha()
   end
   function WScrollbar:_onButtonClick(button)
      local direction
      if button == self.controls.buttonUp then
         direction = self.DIRECTION_BACKWARD
      else
         direction = self.DIRECTION_FORWARD
      end
      self.callbacks:FireCallbacks("request-scroll", {
         source    = "button",
         direction = direction,
         delta     = 1,
      })
   end
   function WScrollbar:_onHidden()
      if self.timeline then
         self.timeline:Stop()
      end
      self:asControl():SetAlpha(self.state.targetAlpha)
   end
   function WScrollbar:_onMouseDown()
      if MouseIsOver(self:asControl():GetThumbTextureControl()) then
         self.state.thumbIsHeld = true
         self:refreshAlpha()
      end
   end
   function WScrollbar:_onMouseUp()
      self.state.thumbIsHeld = false
      self:refreshAlpha()
   end
   function WScrollbar:_onMouseOver()
      self.state.hover = true
      self:refreshAlpha()
   end
   function WScrollbar:_onMouseOut()
      if MouseIsOver(self.controls.buttonUp) or MouseIsOver(self.controls.buttonDown) then
         --
         -- The alpha animation glitches if we move the mouse directly 
         -- from the scrollbar to one of its buttons in the same frame: 
         -- only the first animation we try to queue in that frame (the 
         -- fade-out animation) will play, so the scrollbar ends up 
         -- faded when it shouldn't be.
         --
         return
      end
      self.state.hover = false
      self:refreshAlpha()
   end
   function WScrollbar:_onMouseWheel(delta)
      local direction
      if delta < 0 then
         direction = self.DIRECTION_BACKWARD
      elseif delta > 0 then
         direction = self.DIRECTION_FORWARD
      end
      self.callbacks:FireCallbacks("request-scroll", {
         source    = "wheel",
         direction = direction,
         delta     = math.abs(delta),
      })
   end
   function WScrollbar:_onUpdate()
      if self.prefs.area then
         local over = MouseIsOver(self.prefs.area)
         if over ~= self.state.hoverArea then
            if over then
               self:_onAreaMouseOver()
            else
               self:_onAreaMouseOut()
            end
            self.state.hoverArea = over
         end
      end
   end
   function WScrollbar:_onValueChanged(value)
      if self.state.changingValue then
         return
      end
      self.callbacks:FireCallbacks("request-scroll", {
         source    = "slider",
         direction = nil,
         delta     = nil,
         position  = value,
      })
   end
end
function WScrollbar:getComputedStyle()
   local lists = { rawget(self, "style") }
   local class = self:getClass()
   while class do
      local style = rawget(class, "style")
      if style then
         lists[#lists + 1] = style
      end
      class = class:getSuperclass()
   end
   local result = {}
   for i = #lists, 1, -1 do
      ItemTrig.assign(result, lists[i])
   end
   return result
end
function WScrollbar:getExtents()
   return self:asControl():GetMinMax()
end
function WScrollbar:refreshAlpha()
   local control  = self:asControl()
   local style    = self:getComputedStyle()
   local newAlpha = style.alphaInitial
   if control:GetEnabled() then
      if self.state.hoverArea then
         newAlpha = style.alphaHoverArea
      end
      if self.state.thumbIsHeld or self.state.hover then
         newAlpha = style.alphaHoverSelf
      end
   end
   if newAlpha ~= control:GetAlpha() then
      self.state.targetAlpha = newAlpha
      if control:IsHidden() then
         control:SetAlpha(newAlpha)
      else
         self.timeline:Stop()
         self.alphaAnimation:SetAlphaValues(control:GetAlpha(), newAlpha)
         self.timeline:PlayFromStart()
      end
   end
end
function WScrollbar:setAlphaTransitionTime(ms)
   assert(ms and tonumber(ms), "You must specify a number of milliseconds.")
   self.prefs.alphaTransitionTime = ms
   self.alphaAnimation:SetDuration(self.prefs.alphaTransitionTime)
end
function WScrollbar:setArea(control)
   self.prefs.area = control
end
function WScrollbar:setExtents(min, max)
   assert(min <= max, "Your extents are inverted.")
   local control = self:asControl()
   control:SetMinMax(min, max)
   local disable = min == max
   control:SetEnabled(not disable)
   control:SetHidden(disable and self.prefs.hideOnDisabled)
end
function WScrollbar:setPosition(position)
   self.state.changingValue = true
   self:asControl():SetValue(position)
   self.state.changingValue = false
end
function WScrollbar:setThumbHeight(height)
   self:asControl():SetThumbTextureHeight(height)
end