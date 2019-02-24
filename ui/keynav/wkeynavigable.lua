ItemTrig.WKeyNavigable = ItemTrig.UI.WidgetClass:makeSubclass("WKeyNavigable", "keynav")
local WKeyNavigable = ItemTrig.WKeyNavigable

local assign        = ItemTrig.assign
local dispatchEvent = ItemTrig.dispatchEvent

function WKeyNavigable:_construct()
   assign(self, {
      cache = {
         nearest = nil,
      },
      directionTargets   = {},
      directionOverrides = {},
   })
end
function WKeyNavigable:canHaveFocus()
   local c  = self:asControl()
   if c:IsHidden() then
      return false
   end
   local ct = c:GetType()
   if ct == CT_BUTTON then
      local state = c:GetState()
      if state == BSTATE_DISABLED or state == BSTATE_DISABLED_PRESSED then
         return false
      end
   elseif ct == CT_EDITBOX then
      if not c:GetEditEnabled() then
         return false
      end
   elseif ct == CT_SLIDER then
      if not c:GetEnabled() or c:IsThumbFlushWithExtents() then
         return false
      end
   elseif ct == CT_TOPLEVELCONTROL then
      return false
   end
   return true
end
function WKeyNavigable:getFocusRingColor()
   --
   -- Subclasses or instances should override this. Return nil to 
   -- use the default color, or return four numbers for RGBA.
   --
   return nil
end
function WKeyNavigable:getNearestFocusableAncestor()
   if self.cache.nearest then
      return self.cache.nearest
   end
   local target = self:asControl():GetParent()
   while target do
      local casted = WKeyNavigable:cast(target)
      if casted then
         self.cache.nearest = casted
         return casted
      end
      target = target:GetParent()
   end
   return nil
end
do -- Event handlers that can bubble
   --
   -- Subclasses and events can override these. Return true to flag 
   -- an event as "handled." An event that isn't handled will "bubble" 
   -- up to the nearest ancestor that is itself a WKeyNavigable.
   --
   function WKeyNavigable:onButtonPrimary() -- Default: A
      dispatchEvent(self:asControl(), "OnMouseDown")
      dispatchEvent(self:asControl(), "OnMouseUp")
      dispatchEvent(self:asControl(), "OnClicked")
      return true
   end
   function WKeyNavigable:onButtonNegative() -- Default: B
   end
   function WKeyNavigable:onButtonSecondary() -- Default: X
   end
   function WKeyNavigable:onButtonTertiary() -- Default: Y
   end
   function WKeyNavigable:onButtonQuaternary() -- no default binding on Xbox
   end
   function WKeyNavigable:onDPad(direction)
   end
   function WKeyNavigable:onScrollFrame(delta) -- right-stick scroll
   end
   function WKeyNavigable:onStickClickLeft()
   end
   function WKeyNavigable:onStickClickRight()
   end
   function WKeyNavigable:onShoulderLeft()
   end
   function WKeyNavigable:onShoulderRight()
   end
   function WKeyNavigable:onTriggerLeft()
   end
   function WKeyNavigable:onTriggerRight()
   end
end
do -- Event handlers that don't bubble
   function WKeyNavigable:onNavigatedAway()
      dispatchEvent(self:asControl(), "OnMouseExit")
   end
   function WKeyNavigable:onNavigatedTo()
      dispatchEvent(self:asControl(), "OnMouseEnter")
   end
end
function WKeyNavigable:setDirectionOverride(direction, func)
   assert(ItemTrig.GamepadKeynavManager:isValidDirection(direction), "Invalid direction.")
   assert(type(func) == "function", "You must specify a function.")
   self.directionOverrides[direction] = func
end
function WKeyNavigable:setDirectionTarget(direction, control)
   assert(ItemTrig.GamepadKeynavManager:isValidDirection(direction), "Invalid direction.")
   self.directionTargets[direction] = control
end
function WKeyNavigable:shouldShowFocusRing()
   --
   -- Subclasses or instances should override this. Return nil to 
   -- use the default for the window.
   --
end
function WKeyNavigable:tryNavigate(direction) -- TODO: consider renaming to getNavigationTarget(direction)
   local override = self.directionOverrides[direction]
   local default  = self.directionTargets[direction]
   local target
   if override then
      target = override(self, direction)
   end
   target = target or default
   if not target then
      return nil
   end
   while target do
      target = WKeyNavigable:cast(target)
      if not target then
         return nil
      end
      if target:canHaveFocus() then
         return target
      end
      --
      -- If the target isn't focusable, then navigate past it.
      --
      target = target:tryNavigate(direction)
   end
   return nil
end