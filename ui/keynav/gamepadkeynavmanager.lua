ItemTrig.GamepadKeynavManager = {}
local GamepadKeynavManager = ItemTrig.GamepadKeynavManager

local WKeyNavigable       = ItemTrig.WKeyNavigable
local WKeyNavigableWindow = ItemTrig.WKeyNavigableWindow
local assign   = ItemTrig.assign
local thiscall = ItemTrig.thiscall

--[[
   THINGS TO TAKE CARE OF:
   
    - The focus ring should be a dotted line, akin to Windows Classic. 
      Alternatively, it can be a solid line that gently animates, 
      pulsing color/brightness.
   
    - The focus ring color should be controllable by both the currently-
      focused WKeyNavigable and (if that opts not to do anything) the 
      containing window.
    
    - We need to test how this system interacts with the WWindow widget's 
      modal feature. Do we properly handle windows as a modal is opened 
      and closed? (Probably not... Is there an event to detect when a 
      top-level control rises to the top, or changes depth generally?)
   
    - Use of the right stick to scroll, akin to the scroll wheel.
    
       - Fire onScrollFrame(delta) on the currently-focused control, and 
         bubble that to the top.
      
       - If nothing (including the containing window) handles the event, 
         then check whether the current window returns a WKeyNavigable 
         when we call getDefaultScroll() on it; if so, fire the scroll 
         event again on that control.
      
       - The goal is to make it possible to scroll non-focusable controls 
         (i.e. controls that you can't keynav to) using the right stick.
   
    - We'll probably want to provide WKeyNavigable subclasses for some 
      of our widgets, e.g. one for WScrollSelectList that uses the "direc-
      tion override" functions to allow for navigating within the list. 
      (The keynav manager would think that the list is focused, while 
      the list would intercept up/down to handle selection, scrolling, 
      etc., as appropriate; the list would maintain its "last focused 
      data" so that if you navigate away from it and then back to it, 
      we don't reset to the top of the list.)
]]--

EVENT_MANAGER:RegisterForUpdate(
   "ItemTrigGamepadKeynav",
   33,
   function(millisecondsRunning) GamepadKeynavManager:_onFrame() end
)

do -- enforce load order
   local err = "The GamepadKeynavManager file was loaded in the wrong order."
   assert(WKeyNavigable       ~= nil, err)
   assert(WKeyNavigableWindow ~= nil, err)
   assert(assign   ~= nil, err)
   assert(thiscall ~= nil, err)
end

do -- directions
   GamepadKeynavManager.LEFT  = { -1, 0 }
   GamepadKeynavManager.UP    = { 0, -1 }
   GamepadKeynavManager.DOWN  = { 0, 1 }
   GamepadKeynavManager.RIGHT = { 1, 0 }
end
local MAP_BINDINGS_TO_DIRECTIONS
local MAP_BINDINGS_TO_METHODS
do -- locals
   MAP_BINDINGS_TO_DIRECTIONS = {
      ITEMTRIG_KEYNAV_INPUT_LEFT  = GamepadKeynavManager.LEFT,
      ITEMTRIG_KEYNAV_INPUT_RIGHT = GamepadKeynavManager.RIGHT,
      ITEMTRIG_KEYNAV_INPUT_UP    = GamepadKeynavManager.UP,
      ITEMTRIG_KEYNAV_INPUT_DOWN  = GamepadKeynavManager.DOWN,
   }
   MAP_BINDINGS_TO_METHODS = {
      ITEMTRIG_KEYNAV_PRIMARY        = "onButtonPrimary",
      ITEMTRIG_KEYNAV_SECONDARY      = "onButtonSecondary",
      ITEMTRIG_KEYNAV_TERTIARY       = "onButtonTertiary",
      ITEMTRIG_KEYNAV_QUATERNARY     = "onButtonQuaternary",
      ITEMTRIG_KEYNAV_NEGATIVE       = "onButtonNegative",
      ITEMTRIG_KEYNAV_LEFT_SHOULDER  = "onShoulderLeft",
      ITEMTRIG_KEYNAV_RIGHT_SHOULDER = "onShoulderRight",
      ITEMTRIG_KEYNAV_LEFT_STICK     = "onStickClickLeft",
      ITEMTRIG_KEYNAV_RIGHT_STICK    = "onStickClickRight",
      ITEMTRIG_KEYNAV_LEFT_TRIGGER   = "onTriggerLeft",
      ITEMTRIG_KEYNAV_RIGHT_TRIGGER  = "onTriggerRight",
   }
end

assign(GamepadKeynavManager, {
   currentFocus  = nil,
   currentWindow = nil,
   lastLeftStickDirection = nil,
})
function GamepadKeynavManager:dispatchKey(binding)
   local method = MAP_BINDINGS_TO_METHODS[binding]
   if method then
      local direction = MAP_BINDINGS_TO_DIRECTIONS[binding]
      local focus     = self.currentFocus
      if not self.currentFocus then
         focus = self.currentWindow
         if focus then
            focus = WKeyNavigable:cast(focus)
         end
         if not focus then
            return
         end
      end
      local result = thiscall(focus, method, direction)
      while not result do
         focus = focus:getNearestFocusableAncestor()
         if not focus then
            break
         end
         result = thiscall(focus, method, direction)
      end
      return
   end
   local direction = MAP_BINDINGS_TO_DIRECTIONS[binding]
   if direction then
      self:_navigate(direction)
   end
end
function GamepadKeynavManager:isValidDirection(direction)
   if direction == self.LEFT
   or direction == self.RIGHT
   or direction == self.UP
   or direction == self.DOWN
   then
      return true
   end
   return false
end
function GamepadKeynavManager:_navigate(direction)
   local focus = self.currentFocus or self.currentWindow
   if not focus then
      return
   end
   focus = WKeyNavigable:cast(focus)
   if not focus then
      return
   end
   --
   local target = focus:tryNavigate(direction)
   if target then
      self:setCurrentFocus(target)
   end
end
function GamepadKeynavManager:_onFrame()
   do -- left stick
      local stickX = GetGamepadLeftStickX(false)
      local stickY = GetGamepadLeftStickY(false)
      local magX   = math.abs(stickX)
      local magY   = math.abs(stickY)
      --
      if math.abs(magX) > 0.2 or math.abs(magY) > 0.2 then -- stick is moved
         if math.abs(magX - magY) > 0.2 then -- we're not diagonal
            local direction
            if magX > magY then
               if stickX > 0 then
                  direction = self.RIGHT
               else
                  direction = self.LEFT
               end
            else
               if stickY < 0 then -- TODO: Is this affected by inverted Y sensitivity?
                  direction = self.DOWN
               else
                  direction = self.UP
               end
            end
            if direction ~= self.lastLeftStickDirection then
               self.lastLeftStickDirection = direction
               self:_navigate(direction)
            end
         end
      else
         self.lastLeftStickDirection = nil
      end
   end
   --
   -- TODO: Allow scrolling with the right stick (akin to the scroll wheel).
   --
end
function GamepadKeynavManager:setCurrentFocus(control)
   local target
   if control then
      target = WKeyNavigable:cast(control)
      if not (target and target:canHaveFocus()) then
         return
      end
   end
   if self.currentFocus then
      self.currentFocus:onNavigatedAway()
   end
   self.currentFocus = target
   local shouldHideFocusFing = true
   if target then
      target:onNavigatedTo()
      local t = target:shouldShowFocusRing()
      if t == nil then
         t = self.currentWindow:shouldShowFocusRing()
      end
      shouldHideFocusFing = not t
   end
   if shouldHideFocusRing then
      ItemTrig_GamepadKeynav_FocusRing:SetHidden(true)
   else
      local c = target:asControl()
      ItemTrig_GamepadKeynav_FocusRing:ClearAnchors()
      ItemTrig_GamepadKeynav_FocusRing:SetAnchor(TOPLEFT,     c, TOPLEFT,     3, 3)
      ItemTrig_GamepadKeynav_FocusRing:SetAnchor(BOTTOMRIGHT, c, BOTTOMRIGHT, -3, -3)
      ItemTrig_GamepadKeynav_FocusRing:SetHidden(false)
      ItemTrig_GamepadKeynav_FocusRing:SetParent(c:GetOwningWindow() or GuiRoot)
      --
      -- TODO: focus ring color
      --
   end
end
function GamepadKeynavManager:setCurrentWindow(control)
   local window
   if control then
      window = WKeyNavigableWindow:cast(control)
   end
   if not window then
      return
   end
   if self.currentWindow then
      self.currentWindow.lastFocusedControl = self.currentFocus
   end
   self.currentWindow = window
   if window.lastFocusedControl then
      self:setCurrentFocus(window.lastFocusedControl)
   else
      self:setCurrentFocus(window:getDefaultControl())
   end
end