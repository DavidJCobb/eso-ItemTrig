ItemTrig.WKeyNavigableWindow = ItemTrig.WKeyNavigable:makeSubclass("WKeyNavigableWindow")
local WKeyNavigableWindow    = ItemTrig.WKeyNavigableWindow

local WKeyNavigable = ItemTrig.WKeyNavigable
local assign = ItemTrig.assign

function WKeyNavigableWindow:_construct()
   assign(self, {
      defaultFocus       = nil,
      lastFocusedControl = nil,
   })
   --
   -- TODO: Consider pre-hooking OnEffectivelyHidden, and using the hook to 
   -- clear self.lastFocusedControl.
   --
end
function WKeyNavigableWindow:canHaveFocus()
   --
   -- Something IN the window can have focus, but the window itself 
   -- cannot be keynavved to:
   --
   return false
end
function WKeyNavigableWindow:getDefaultControl()
   --
   -- TODO: What do we do if the default control is currently 
   -- rejecting focus (i.e. canHaveFocus returns false)?
   --
   return WKeyNavigable:cast(self.defaultFocus)
end
function WKeyNavigableWindow:setDefaultControl(control)
   self.defaultFocus = control
end

function WKeyNavigableWindow:getFocusRingColor()
   return { 0, 0, 0, 1 }
end
function WKeyNavigableWindow:shouldShowFocusRing()
   return true
end
function WKeyNavigableWindow:onHide()
   self.lastFocusedControl = nil
end