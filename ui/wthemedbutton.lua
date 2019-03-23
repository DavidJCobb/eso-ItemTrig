ItemTrig.UI.WThemedButton = ItemTrig.UI.WidgetClass:makeSubclass("WThemedButton", "themed")
local WThemedButton = ItemTrig.UI.WThemedButton

local getThemeColor = ItemTrig.getCurrentThemeColor
local thiscall      = ItemTrig.thiscall

local function _dispatchMouseEnter(control)
   WThemedButton:cast(control):onMouseEnter()
end
local function _dispatchMouseExit(control)
   WThemedButton:cast(control):onMouseExit()
end
local function _dispatchMouseDown(control)
   WThemedButton:cast(control):onMouseDown()
end
local function _dispatchMouseUp(control)
   WThemedButton:cast(control):onMouseUp()
end

function WThemedButton:_construct()
   local control = self:asControl()
   self.back = self:GetNamedChild("Back")
   --
   ItemTrig.ThemeManager.callbacks:RegisterCallback("update", function() self:refreshStyle() end)
   ZO_PreHookHandler(control, "OnMouseEnter", _dispatchMouseEnter)
   ZO_PreHookHandler(control, "OnMouseExit",  _dispatchMouseExit)
   ZO_PreHookHandler(control, "OnMouseDown",  _dispatchMouseDown)
   ZO_PreHookHandler(control, "OnMouseUp",    _dispatchMouseUp)
end
function WThemedButton:refreshStyle()
   local control = self:asControl()
   local theme   = ItemTrig.ThemeManager.current
   local colors  = theme.colors
   --
   control:SetNormalFontColor(   unpack(colors.BUTTON_TEXT_NORMAL))
   control:SetMouseOverFontColor(unpack(colors.BUTTON_TEXT_MOUSEOVER))
   control:SetPressedFontColor(  unpack(colors.BUTTON_TEXT_MOUSEDOWN))
   --
   -- TODO: font and background color for disabled buttons
   --
   self.back:SetColor(unpack(colors.BUTTON_BACKGROUND_NORMAL))
end
function WThemedButton:onMouseEnter()
   self.back:SetColor(unpack(getThemeColor("BUTTON_BACKGROUND_MOUSEOVER")))
end
function WThemedButton:onMouseExit()
   self.back:SetColor(unpack(getThemeColor("BUTTON_BACKGROUND_NORMAL")))
end
function WThemedButton:onMouseDown()
   self.back:SetColor(unpack(getThemeColor("BUTTON_BACKGROUND_MOUSEDOWN")))
end
function WThemedButton:onMouseUp()
   if upInside then
      self.back:SetColor(unpack(getThemeColor("BUTTON_BACKGROUND_MOUSEOVER")))
   else
      self.back:SetColor(unpack(getThemeColor("BUTTON_BACKGROUND_NORMAL")))
   end
end