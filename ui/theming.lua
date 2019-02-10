if not ItemTrig then return end

-- Dark theme
--
ItemTrig.theme = {
   WINDOW_BORDER_COLOR         = { 140/255, 140/255, 140/255, 1 },
   WINDOW_BACKGROUND_TOP       = { 0, 0, 0, 1 },
   WINDOW_BACKGROUND_BOTTOM    = { 0.1, 0.1, 0.1, 1 },
   WINDOW_BARE_TEXT_COLOR      = { 1, 1, 1, 1 }, -- text that's right on a window bg
   TITLE_BAR_COLOR_FOCUS_START = { 0.55, 0.07, 0.00, 1 },
   TITLE_BAR_COLOR_FOCUS_END   = { 0.70, 0.35, 0.15, 1 },
   TITLE_BAR_COLOR_BLUR_START  = { 0.30, 0.30, 0.30, 1 },
   TITLE_BAR_COLOR_BLUR_END    = { 0.32, 0.32, 0.32, 1 },
   LIST_BORDER                 = { 0, 0, 0, 1 },
   LIST_BACKGROUND_TOP         = { 0, 0, 0, 1 },
   LIST_BACKGROUND_BOTTOM      = { 0.01, 0.01, 0.01, 0.95 },
   LIST_ITEM_BACKGROUND        = { 40/255, 40/255, 40/255, 1 },
   LIST_ITEM_BACKGROUND_ALT    = { 40/255, 40/255, 40/255, 1 },
   LIST_ITEM_BACKGROUND_SELECT = { 40/255, 40/255, 40/255, 1 },
   LIST_ITEM_TEXT_NORMAL       = {GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL)},
   LIST_ITEM_TEXT_SELECTED     = {GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED)},
   BUTTON_BACKGROUND_NORMAL    = { 0.0, 0.0, 0.0, 1 },
   BUTTON_BACKGROUND_MOUSEOVER = { 0.2, 0.2, 0.2, 1 },
   BUTTON_BACKGROUND_MOUSEDOWN = { 0.2, 0.2, 0.8, 1 },
   BUTTON_TEXT_NORMAL          = { 1, 1, 1, 1 },
   BUTTON_TEXT_MOUSEOVER       = { 1, 1, 1, 1 },
   BUTTON_TEXT_MOUSEDOWN       = { 1, 1, 1, 1 },
}

-- Windows-inspired theme
--
ItemTrig.theme = {
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
   LIST_BACKGROUND_TOP         = { 209/255, 204/255, 194/255, 1 },
   LIST_BACKGROUND_BOTTOM      = { 209/255, 204/255, 194/255, 1 },
   LIST_ITEM_BACKGROUND        = { 1.00, 1.00, 1.00, 1 },
   --LIST_ITEM_BACKGROUND_ALT    = { 0.90, 0.90, 0.90, 1 },
   LIST_ITEM_BACKGROUND_ALT    = { 1.00, 1.00, 1.00, 1 },
   LIST_ITEM_BACKGROUND_SELECT = { 0.70, 0.25, 0.00, 1 },
   LIST_ITEM_TEXT_NORMAL       = { 0, 0, 0, 1 },
   LIST_ITEM_TEXT_SELECTED     = { 1, 1, 1, 1 },
   BUTTON_BACKGROUND_NORMAL    = { 232/255, 228/255, 219/255, 1 },
   BUTTON_BACKGROUND_MOUSEOVER = { 252/255, 248/255, 239/255, 1 },
   BUTTON_BACKGROUND_MOUSEDOWN = { 0.70, 0.25, 0.00, 1 },
   BUTTON_TEXT_NORMAL          = { 0, 0, 0, 1 },
   BUTTON_TEXT_MOUSEOVER       = { 0, 0, 0, 1 },
   BUTTON_TEXT_MOUSEDOWN       = { 1, 1, 1, 1 },
   TEXTEDIT_BACKGROUND         = { 1, 1, 1, 1 },
   TEXTEDIT_TEXT               = { 0, 0, 0, 1 },
   TEXTEDIT_SELECTION          = { 0.70, 0.25, 0.00, 1 },
}