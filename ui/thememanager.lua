local filterKeys = ItemTrig.filterKeys
local thiscall   = ItemTrig.thiscall

local ThemeManager = {
   themes  = {},
   current = nil,
   --
   callbacks = ZO_CallbackObject:New(),
}
ItemTrig.ThemeManager = ThemeManager

function ItemTrig.getCurrentThemeColor(name, noFallback)
   if ThemeManager.current then
      return ThemeManager.current.colors[name]
   end
   if noFallback then
      return
   end
   return {0, 0, 0, 0}
end
function ItemTrig.getCurrentThemeNumber(name)
   if ThemeManager.current then
      return ThemeManager.current.numbers[name]
   end
   return 0
end
function ItemTrig.getCurrentThemeString(name)
   if ThemeManager.current then
      return ThemeManager.current.strings[name]
   end
   return ""
end

do
   local function _add(k, t)
      ThemeManager.themes[k] = t
   end
   _add("OldDesktop", {
      name        = GetString(ITEMTRIG_STRING_UI_THEMENAME_OLDDESKTOP),
      description = GetString(ITEMTRIG_STRING_UI_THEMEDESC_OLDDESKTOP),
      colors      = {
         WINDOW_BORDER_COLOR         = { 0, 0, 0, 1 },
         --WINDOW_BACKGROUND_TOP       = { 207/255, 201/255, 188/255, 1 },
         --WINDOW_BACKGROUND_BOTTOM    = { 212/255, 208/255, 199/255, 1 },
         WINDOW_BACKGROUND_TOP       = { 212/255, 208/255, 199/255, 1 },
         WINDOW_BACKGROUND_BOTTOM    = { 222/255, 218/255, 209/255, 1 },
         WINDOW_BARE_TEXT_COLOR      = { 0, 0, 0, 1 }, -- text that's right on a window bg
         TITLE_BAR_COLOR_FOCUS_START = { 0.55, 0.07, 0.00, 1 },
         TITLE_BAR_COLOR_FOCUS_END   = { 0.70, 0.35, 0.15, 1 },
         TITLE_BAR_COLOR_BLUR_START  = { 0.30, 0.30, 0.30, 1 },
         TITLE_BAR_COLOR_BLUR_END    = { 0.32, 0.32, 0.32, 1 },
         LIST_BORDER                 = { 131/255, 128/255, 121/255, 1 },
         --LIST_BACKGROUND_TOP         = { 209/255, 204/255, 194/255, 1 },
         --LIST_BACKGROUND_BOTTOM      = { 209/255, 204/255, 194/255, 1 },
         LIST_BACKGROUND_TOP         = { 205/255, 200/255, 190/255, 1 },
         LIST_BACKGROUND_BOTTOM      = { 205/255, 200/255, 190/255, 1 },
         LIST_ITEM_BACKGROUND        = { 1.00, 1.00, 1.00, 1 },
         --LIST_ITEM_BACKGROUND_ALT    = { 0.90, 0.90, 0.90, 1 },
         LIST_ITEM_BACKGROUND_ALT    = { 1.00, 1.00, 1.00, 1 },
         LIST_ITEM_BACKGROUND_SELECT = { 0.70, 0.25, 0.00, 1 },
         LIST_ITEM_TEXT_NORMAL       = { 0, 0, 0, 1 },
         LIST_ITEM_TEXT_SELECTED     = { 1, 1, 1, 1 },
         BUTTON_BACKGROUND_NORMAL    = { 242/255, 238/255, 229/255, 1 },
         BUTTON_BACKGROUND_MOUSEOVER = { 252/255, 248/255, 239/255, 1 },
         BUTTON_BACKGROUND_MOUSEDOWN = { 0.70, 0.25, 0.00, 1 },
         BUTTON_TEXT_NORMAL          = { 0, 0, 0, 1 },
         BUTTON_TEXT_MOUSEOVER       = { 0, 0, 0, 1 },
         BUTTON_TEXT_MOUSEDOWN       = { 1, 1, 1, 1 },
         TEXTEDIT_BACKGROUND         = { 1, 1, 1, 1 },
         TEXTEDIT_TEXT               = { 0.0, 0.0, 0.0, 1 },
         TEXTEDIT_TEXT_WRONG         = { 1.0, 0.1, 0.1, 1 },
         TEXTEDIT_SELECTION          = { 0.70, 0.25, 0.00, 1 },
         COMBOBOX_BACKGROUND         = { 1, 1, 1, 1 },
         COMBOBOX_TEXT               = { 0, 0, 0, 1 },
         COMBOBOX_FOCUS_RING         = { 0.70, 0.25, 0.00, 1 },
         COMBOBOX_MOUSEOVER_TEXT     = { 1.00, 1.00, 1.00, 1 },
         COMBOBOX_MOUSEOVER_BACK     = { 0.70, 0.25, 0.00, 1 },
         COMBOBOX_BODY_BORDER_TOP    = { 0.70, 0.25, 0.00, 1 },
         COMBOBOX_BODY_BORDER_BOTTOM = { 0.00, 0.00, 0.00, 1 },
         TOOLTIP_BACKGROUND          = { 1, 1, 0.5, 1 },
         TOOLTIP_TEXT                = { 0, 0, 0, 1 },
         TOOLTIP_BORDER              = { 0, 0, 0, 1 },
         --
         OPCODE_ARGUMENT_LINK_NORMAL = "70B0FF",
         OPCODE_ARGUMENT_LINK_SELECT = "70B0FF", -- container is selected
         OPCODE_ARGUMENT_LINK_FOCUS  = "EE3333", -- link is selected
      },
      numbers = {
         SCROLLBAR_THICKNESS = 16, -- not implemented
         SCROLLBAR_THUMB_SIZE_MAIN  = 32,
         SCROLLBAR_THUMB_SIZE_CROSS = 16,
         SCROLLBAR_BUTTON_SIZE_MAIN  = 16,
         SCROLLBAR_BUTTON_SIZE_CROSS = 16,
      },
      strings = {
         SCROLLBAR_TRACK_FILE = "EsoUI/Art/Miscellaneous/scrollbox_track.dds",
         SCROLLBAR_THUMB_FILE          = "EsoUI/Art/Miscellaneous/scrollbox_elevator.dds",
         SCROLLBAR_THUMB_FILE_DISABLED = "EsoUI/Art/Miscellaneous/scrollbox_elevator_disabled.dds",
         SCROLLBAR_THUMB_FILE_OVERLAY  = "EsoUI/Art/Tooltips/munge_overlay.dds",
         SCROLLBAR_UP_ARROW_FILE_NORMAL   = "ItemTrig/textures/scrollbutton_up_normal.dds",
         SCROLLBAR_UP_ARROW_FILE_PRESSED  = "ItemTrig/textures/scrollbutton_up_pressed.dds",
         SCROLLBAR_UP_ARROW_FILE_HOVER    = "ItemTrig/textures/scrollbutton_up_hover.dds",
         SCROLLBAR_UP_ARROW_FILE_DISABLED = "ItemTrig/textures/scrollbutton_up_disabled.dds",
         SCROLLBAR_DOWN_ARROW_FILE_NORMAL   = "ItemTrig/textures/scrollbutton_down_normal.dds",
         SCROLLBAR_DOWN_ARROW_FILE_PRESSED  = "ItemTrig/textures/scrollbutton_down_pressed.dds",
         SCROLLBAR_DOWN_ARROW_FILE_HOVER    = "ItemTrig/textures/scrollbutton_down_hover.dds",
         SCROLLBAR_DOWN_ARROW_FILE_DISABLED = "ItemTrig/textures/scrollbutton_down_disabled.dds",
      },
   })
   _add("Dark", {
      name        = GetString(ITEMTRIG_STRING_UI_THEMENAME_DARK),
      description = GetString(ITEMTRIG_STRING_UI_THEMEDESC_DARK),
      colors      = {
         WINDOW_BORDER_COLOR         = { 0, 0, 0, 1 },
         WINDOW_BACKGROUND_TOP       = { 40/255, 40/255, 40/255, 1 },
         WINDOW_BACKGROUND_BOTTOM    = { 48/255, 48/255, 48/255, 1 },
         WINDOW_BARE_TEXT_COLOR      = { 1, 1, 1, 1 }, -- text that's right on a window bg
         TITLE_BAR_COLOR_FOCUS_START = {  74/255, 130/255, 131/255, 1 },
         TITLE_BAR_COLOR_FOCUS_END   = {  27/255, 101/255, 107/255, 1 },
         TITLE_BAR_COLOR_BLUR_START  = { 0.30, 0.30, 0.30, 1 },
         TITLE_BAR_COLOR_BLUR_END    = { 0.32, 0.32, 0.32, 1 },
         LIST_BORDER                 = { 114/255, 114/255, 109/255, 1 },
         LIST_BACKGROUND_TOP         = { 0, 0, 0, 1 },
         LIST_BACKGROUND_BOTTOM      = { 0, 0, 0, 1 },
         LIST_ITEM_BACKGROUND        = {  67/255,  67/255,  59/255, 0.9 },
         LIST_ITEM_BACKGROUND_ALT    = {  67/255,  67/255,  59/255, 0.9 },
         LIST_ITEM_BACKGROUND_SELECT = {  74/255, 130/255, 131/255, 1 },
         LIST_ITEM_TEXT_NORMAL       = { 1, 1, 1, 1 },
         LIST_ITEM_TEXT_SELECTED     = { 1, 1, 1, 1 },
         BUTTON_BACKGROUND_NORMAL    = {   0/255,   0/255,   0/255, 1 },
         BUTTON_BACKGROUND_MOUSEOVER = { 114/255, 114/255, 109/255, 1 },
         BUTTON_BACKGROUND_MOUSEDOWN = {  74/255, 130/255, 131/255, 1 },
         BUTTON_TEXT_NORMAL          = { 1, 1, 1, 1 },
         BUTTON_TEXT_MOUSEOVER       = { 1, 1, 1, 1 },
         BUTTON_TEXT_MOUSEDOWN       = { 1, 1, 1, 1 },
         TEXTEDIT_BACKGROUND         = { 0, 0, 0, 1 },
         TEXTEDIT_TEXT               = { 1.0, 1.0, 1.0, 1 },
         TEXTEDIT_TEXT_WRONG         = { 1.0, 0.1, 0.1, 1 },
         TEXTEDIT_SELECTION          = {  67/255,  67/255,  59/255, 1 },
         COMBOBOX_BACKGROUND         = {   0/255,   0/255,   0/255, 1 },
         COMBOBOX_TEXT               = { 1.0, 1.0, 1.0, 1 },
         COMBOBOX_FOCUS_RING         = {  74/255, 130/255, 131/255, 1 },
         COMBOBOX_MOUSEOVER_TEXT     = { 1.00, 1.00, 1.00, 1 },
         COMBOBOX_MOUSEOVER_BACK     = {  74/255, 130/255, 131/255, 1 },
         COMBOBOX_BODY_BORDER_TOP    = {  74/255, 130/255, 131/255, 1 },
         COMBOBOX_BODY_BORDER_BOTTOM = {  27/255, 101/255, 107/255, 1 },
         TOOLTIP_BACKGROUND          = {   0/255,   0/255,   0/255, 1 },
         TOOLTIP_TEXT                = { 1, 1, 1, 1 },
         TOOLTIP_BORDER              = {  67/255,  67/255,  59/255, 1 },
         --
         OPCODE_ARGUMENT_LINK_NORMAL = "70B0FF",
         OPCODE_ARGUMENT_LINK_SELECT = "001080", -- container is selected
         OPCODE_ARGUMENT_LINK_FOCUS  = "EE3333", -- link is selected
      },
      numbers = {
         SCROLLBAR_THICKNESS = 16, -- not implemented
         SCROLLBAR_THUMB_SIZE_MAIN  = 32,
         SCROLLBAR_THUMB_SIZE_CROSS = 16,
         SCROLLBAR_BUTTON_SIZE_MAIN  = 16,
         SCROLLBAR_BUTTON_SIZE_CROSS = 16,
      },
      strings = {
         SCROLLBAR_TRACK_FILE = "EsoUI/Art/Miscellaneous/scrollbox_track.dds",
         SCROLLBAR_THUMB_FILE          = "EsoUI/Art/Miscellaneous/scrollbox_elevator.dds",
         SCROLLBAR_THUMB_FILE_DISABLED = "EsoUI/Art/Miscellaneous/scrollbox_elevator_disabled.dds",
         SCROLLBAR_THUMB_FILE_OVERLAY  = "EsoUI/Art/Tooltips/munge_overlay.dds",
         SCROLLBAR_UP_ARROW_FILE_NORMAL   = "EsoUI/Art/Buttons/scrollbox_upArrow_up.dds",
         SCROLLBAR_UP_ARROW_FILE_PRESSED  = "EsoUI/Art/Buttons/scrollbox_upArrow_down.dds",
         SCROLLBAR_UP_ARROW_FILE_HOVER    = "EsoUI/Art/Buttons/scrollbox_upArrow_over.dds",
         SCROLLBAR_UP_ARROW_FILE_DISABLED = "EsoUI/Art/Buttons/scrollbox_upArrow_up_disabled.dds",
         SCROLLBAR_DOWN_ARROW_FILE_NORMAL   = "EsoUI/Art/Buttons/scrollbox_downArrow_up.dds",
         SCROLLBAR_DOWN_ARROW_FILE_PRESSED  = "EsoUI/Art/Buttons/scrollbox_downArrow_down.dds",
         SCROLLBAR_DOWN_ARROW_FILE_HOVER    = "EsoUI/Art/Buttons/scrollbox_downArrow_over.dds",
         SCROLLBAR_DOWN_ARROW_FILE_DISABLED = "EsoUI/Art/Buttons/scrollbox_downArrow_up_disabled.dds",
      },
   })
end
ThemeManager.current = ThemeManager.themes["OldDesktop"] -- default theme

function ThemeManager:refresh()
   if not self.current then
      return
   end
   self.callbacks:FireCallbacks("update", self.current)
end
function ThemeManager:setupOptions()
   local result = {
      choices         = {},
      choicesValues   = {},
      choicesTooltips = {},
   }
   local i = 1
   for k, v in pairs(self.themes) do
      result.choices[i] = v.name
      result.choicesValues[i] = k
      result.choicesTooltips[i] = v.description
      i = i + 1
   end
   return result
end
function ThemeManager:switchTo(key)
   if self.themes[key] then
      self.current = self.themes[key]
      self:refresh()
   else
      self:refresh()
   end
end