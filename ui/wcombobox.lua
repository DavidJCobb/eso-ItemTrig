if not (ItemTrig and ItemTrig.UI) then return end

--
-- A class for drop-down menus. Under the hood, this relies on 
-- WScrollSelectList both to store list items and for the bulk 
-- of its other functionality.
--

local _AUTOCOMPLETE_RESET_TIME = 1500 -- 1.5s

local function _comboboxFromPane(pane)
   if type(pane) == "table" then
      pane = pane:asControl()
   end
   return ItemTrig.UI.WCombobox:cast(pane:GetParent():GetParent())
end

ItemTrig.UI.WCombobox   = ItemTrig.UI.WidgetClass:makeSubclass("WCombobox", "combobox")
local WCombobox         = ItemTrig.UI.WCombobox
local WScrollSelectList = ItemTrig.UI.WScrollSelectList
local fadeToBottom      = ItemTrig.fadeToBottom

WCombobox.style = {
   --
   -- Default style options for a window. You can override this 
   -- per-subclass by assigning a table to the subclass.
   --
   font = "ZoFontGame",
   focusRing        = ItemTrig.TRANSPARENT,
   fontColorNormal  = ItemTrig.BLACK,
   backColorNormal  = ItemTrig.TRANSPARENT,
   fontColorFocus   = ItemTrig.BLACK,
   backColorFocus   = ItemTrig.TRANSPARENT,
   backBorderTop    = ItemTrig.TRANSPARENT,
   backBorderBottom = ItemTrig.TRANSPARENT,
}
do
   local registry = ItemTrig.ThemeManager.callbacks
   local function _refresh(theme)
      local colors = theme.colors
      ItemTrig.assign(WCombobox.style, {
         focusRing        = colors.COMBOBOX_FOCUS_RING,
         fontColorNormal  = colors.COMBOBOX_TEXT,
         backColorNormal  = colors.COMBOBOX_BACKGROUND,
         fontColorFocus   = colors.COMBOBOX_MOUSEOVER_TEXT,
         backColorFocus   = colors.COMBOBOX_MOUSEOVER_BACK,
         backBorderTop    = colors.COMBOBOX_BODY_BORDER_TOP,
         backBorderBottom = colors.COMBOBOX_BODY_BORDER_BOTTOM,
      })
   end
   registry:RegisterCallback("update", _refresh)
end

function WCombobox:_construct(options)
   if not options then
      options = {}
   end
   if not options.element then
      options.element = {}
   end
   if not options.style then
      options.style = {}
   end
   self.controls = {
      edge     = self:GetNamedChild("Edge"),
      back     = self:controlByPath("Edge", "Back"),
      dropEdge = self:controlByPath("Contents", "Edge"),
      dropBack = self:controlByPath("Contents", "Edge", "Back"),
      label    = self:GetNamedChild("SelectedItemText"),
      button   = self:GetNamedChild("OpenButton"),
      contents = self:GetNamedChild("Contents"),
      pane     = WScrollSelectList:cast(self:controlByPath("Contents", "ScrollPane")),
      autoComplete = self:GetNamedChild("AutoComplete"),
   }
   do -- set up autocomplete box
      local editbox = self.controls.autoComplete
      editbox:SetCopyEnabled(false)
      editbox:SetNewLineEnabled(false)
      editbox:SetPasteEnabled(false)
   end
   self.element = {
      onSelect      = options.element.onSelect      or nil, -- callback
      onDeselect    = options.element.onDeselect    or nil, -- callback
      onDoubleClick = options.element.onDoubleClick or nil, -- callback
   }
   self.prefs = {
      maxCountVisible  = options.maxCountVisible  or nil, -- Drop-down can be no larger than is needed to display this many elements
      maxHeight        = options.maxHeight        or nil, -- Drop-down can be no larger than this many pixels
      maxHeightPercent = options.maxHeightPercent or 1 / 3, -- Drop-down can be no larger than this percent of the screen height. The default for Windows (or at least .NET) is 1/3 the screen.
      maxHeightIsMult  = options.maxHeightIsMult, -- When max height comes into play, constrain drop-down height to a multiple of the base widget height
   }
   if self.prefs.maxHeightIsMult == nil then
      self.prefs.maxHeightIsMult = true
   end
   self.state = {
      autocomplete = {
         lastEntry = "",
         lastIndex = nil,
         suppressEvents = false,
      },
      disabled = false,
      isOpen   = false,
      lastMouseoverIndex = nil,
   }
   self.emptyText = options.emptyText or "" -- for multi-select, if there is no selection
   self._useAutocomplete = options.useAutocomplete
   if self._useAutocomplete == nil then
      self._useAutocomplete = true
   end
   self.style = {
      focusRing        = options.style.focusRing,
      font             = options.style.font,
      fontColorNormal  = options.style.fontColorNormal,
      backColorNormal  = options.style.backColorNormal,
      fontColorFocus   = options.style.fontColorFocus,
      backColorFocus   = options.style.backColorFocus,
      backBorderTop    = options.style.backBorderTop,
      backBorderBottom = options.style.backBorderBottom,
   }
   do -- configure pane
      local pane = self.controls.pane
      if options.shouldSort then
         pane:setShouldSort(true)
      end
      pane.element.template      = options.element.template      or "ItemTrig_UITemplate_WComboboxItem"
      pane.element.onSelect      = options.element.onSelect      or nil -- callback
      pane.element.onDeselect    = options.element.onDeselect    or nil -- callback
      pane.element.onDoubleClick = options.element.onDoubleClick or nil -- callback
      pane.element.toConstruct =
         function(control, data, extra, pane)
            assert(data.name ~= nil, "The list item doesn't have a name.")
            local text     = GetControl(control, "Text")
            local combobox = WCombobox:fromItem(control)
            local style    = combobox:getComputedStyle()
            text:SetText(tostring(data.name))
            if combobox then
               if extra.index == combobox.state.lastMouseoverIndex then
                  GetControl(control, "Text"):SetColor(unpack(style.fontColorFocus))
                  GetControl(control, "Back"):SetColor(unpack(style.backColorFocus))
               else
                  GetControl(control, "Text"):SetColor(unpack(style.fontColorNormal))
                  GetControl(control, "Back"):SetColor(unpack(style.backColorNormal))
               end
            end
            local checkbox = GetControl(control, "Enabled")
            if combobox:multiSelect() then
               checkbox:SetHidden(false)
               if extra.selected then
                  ZO_CheckButton_SetChecked(checkbox)
               else
                  ZO_CheckButton_SetUnchecked(checkbox)
               end
               -- positioning
               text:ClearAnchors()
               text:SetAnchor(LEFT,  checkbox, RIGHT,  7, 0)
               text:SetAnchor(RIGHT, control,  RIGHT, -7, 0)
            else
               checkbox:SetHidden(true)
               ZO_CheckButton_SetUnchecked(checkbox)
               --
               text:ClearAnchors()
               text:SetAnchor(LEFT,  control, LEFT,   7, 0)
               text:SetAnchor(RIGHT, control, RIGHT, -7, 0)
            end
         end
      pane.element.onSelect =
         function(index, control, pane)
            if pane:multiSelect() then
               ZO_CheckButton_SetChecked(GetControl(control, "Enabled"))
            end
         end
      pane.element.onDeselect =
         function(index, control, pane)
            if pane:multiSelect() then
               ZO_CheckButton_SetUnchecked(GetControl(control, "Enabled"))
            end
         end
      pane.onChange =
         function(self)
            local combobox = _comboboxFromPane(self)
            combobox:_onChange()
            combobox:onChange()
         end
      pane.onItemClicked =
         function(self, index)
            local combobox = _comboboxFromPane(self)
            if combobox:multiSelect() then
               PlaySound(SOUNDS.DEFAULT_CLICK) -- checkbox sound
            end
            combobox:_onItemClicked(index)
         end
      pane.selection.shiftToAdd = false
      pane:multiSelect(options.multiSelect or false)
   end
   self:refreshStyle()
   ItemTrig.ThemeManager.callbacks:RegisterCallback("update", function() self:refreshStyle() end)
end

function WCombobox:fromItem(control) -- static method
   local pane = WScrollSelectList:fromItem(control)
   if not pane then
      return nil
   end
   return _comboboxFromPane(pane)
end

do -- autocomplete
   function WCombobox:autocompleteEnabled(flag)
      if flag == nil then
         return self._useAutocomplete
      end
      self._useAutocomplete = flag
      if self:isOpen() then
         self:setAutocompleteState(flag)
      end
   end
   function WCombobox:_autocompleteFocusIndex(index)
      local pane = self.controls.pane
      pane:scrollToItem(index, false, true)
      local control = pane:controlByIndex(index)
      if control then
         local oldIndex = self.state.lastMouseoverIndex
         if oldIndex then
            self:onItemMouseExit(oldIndex, pane:controlByIndex(oldIndex))
         end
         self:_onItemMouseEnter(control)
      end
   end
   function WCombobox:_onAutocompleteChange()
      local editbox = self.controls.autoComplete
      local state   = self.state.autocomplete
      if state.suppressEvents then
         return
      end
      if not (self._useAutocomplete and self:isOpen() and editbox:HasFocus()) then
         return
      end
      local text = editbox:GetText():lower()
      if text == state.lastEntry then
         return
      end
      state.lastIndex = nil
      local pane = self.controls.pane
      pane:forEach(function(i, data)
         local name = data.name:lower()
         if type(name) == "string" then
            if ItemTrig.stringStartsWith(name, text) then
               state.lastIndex = i
               return true
            end
         end
      end)
      state.lastEntry = text
      --
      if state.lastIndex then
         self:_autocompleteFocusIndex(state.lastIndex)
      end
      self:rescheduleAutocompleteReset()
   end
   function WCombobox:_onAutocompleteDirection(offset)
      local index = self.state.lastMouseoverIndex or 1
      index = math.min(self:count(), math.max(1, index + offset))
      if index ~= self.state.lastMouseoverIndex then
         self:_autocompleteFocusIndex(index)
      end
   end
   function WCombobox:_onAutocompleteEnter()
      local pane = self.controls.pane
      if pane:multiSelect() then
         pane:toggle(self.state.lastMouseoverIndex)
      else
         pane:select(self.state.lastMouseoverIndex)
      end
      self:_onItemClicked(self.state.lastMouseoverIndex)
   end
   function WCombobox:rescheduleAutocompleteReset()
      local uniqueName = "AutocompleteFor" .. self:asControl():GetName()
      EVENT_MANAGER:UnregisterForUpdate(uniqueName)
      EVENT_MANAGER:RegisterForUpdate(uniqueName, _AUTOCOMPLETE_RESET_TIME,
         function()
            EVENT_MANAGER:UnregisterForUpdate(uniqueName)
            self:resetAutocomplete(true)
         end
      )
   end
   function WCombobox:resetAutocomplete(suppressEvent)
      self.state.autocomplete.lastEntry = ""
      self.state.autocomplete.lastIndex = nil
      self.state.autocomplete.suppressEvents = suppressEvent
      self.controls.autoComplete:SetText("")
      self.state.autocomplete.suppressEvents = false
   end
   function WCombobox:setAutocompleteState(enabled)
      if enabled then
         if not self._useAutocomplete then
            return
         end
         self.controls.autoComplete:TakeFocus()
      else
         self.controls.autoComplete:LoseFocus()
         self:resetAutocomplete()
      end
   end
end
do -- events, to be overridden by subclasses or instances
   function WCombobox:onBeforeShow()
      --
      -- Returning false or nil cancels the dropdown opening.
      --
      return true
   end
   function WCombobox:onChange()
   end
   function WCombobox:onItemMouseEnter(i, control)
   end
   function WCombobox:onItemMouseExit(i, control)
   end
end
do -- internals
   local function OnMenuHidden(combobox)
      WCombobox:cast(combobox):close()
   end
   --
   function WCombobox:_onChange()
      if self:multiSelect() then
         local items = self:getSelectedItems()
         local count = #items
         if count < 1 then
            self.controls.label:SetText(self.emptyText or "")
         else
            local labels = {}
            for i = 1, count do
               table.insert(labels, tostring(items[i].name))
            end
            labels = table.concat(labels, ", ")
            self.controls.label:SetText(labels)
         end
      else
         local data = self:getSelectedData()
         if data then
            self.controls.label:SetText(tostring(data.name))
         else
            self.controls.label:SetText("")
         end
      end
   end
   function WCombobox:_onGlobalMouseUp(eventCode, button)
      if self:isOpen() then
         if button == MOUSE_BUTTON_INDEX_LEFT and not MouseIsOver(self.controls.contents) then
            self:close()
         end
      else
         local contents = self.controls.contents
         if contents:IsHidden() then
            self:close()
         else
            contents:SetHidden(false)
            self:open()
         end
      end
   end
   function WCombobox:_onItemClicked(index)
      if self:isOpen() then
         if not self.controls.pane.selection.multi then
            self:close()
         end
      end
   end
   function WCombobox:_onItemMouseEnter(control)
      local index = self.controls.pane:indexOfControl(control)
      do -- mouseover colors
         local style = self:getComputedStyle()
         local old   = self.controls.pane:controlByIndex(self.state.lastMouseoverIndex)
         self.state.lastMouseoverIndex = index
         GetControl(control, "Text"):SetColor(unpack(style.fontColorFocus))
         GetControl(control, "Back"):SetColor(unpack(style.backColorFocus))
         if old and old ~= control then
            GetControl(old, "Text"):SetColor(unpack(style.fontColorNormal))
            GetControl(old, "Back"):SetColor(unpack(style.backColorNormal))
         end
      end
      self:onItemMouseEnter(index, control)
   end
   function WCombobox:_onItemMouseExit(control)
      self:onItemMouseExit(self.controls.pane:indexOf(control), control)
   end
end

function WCombobox:addToSelection(...)
   self.controls.pane:addToSelection(...)
end
function WCombobox:at(...)
   return self.controls.pane:at(...)
end
function WCombobox:clear(...)
   assert(self ~= WCombobox, "This method must be called on an instance.")
   local hadItems = self.controls.pane:count() > 0
   self.controls.pane:clear(...)
   self.state.selectedIndex = nil
   if hadItems then
      self:_onChange()
      self:onChange()
   end
   if self:isOpen() then
      self:close()
   end
end
function WCombobox:close()
   assert(self ~= WCombobox, "This method must be called on an instance.")
   if not self:isOpen() then
      return
   end
   ClearMenu()
   self.controls.contents:UnregisterForEvent(EVENT_GLOBAL_MOUSE_UP)
   self.controls.contents:SetHidden(true)
   self.state.isOpen = false
   self:refreshStyle() -- clear focus ring
   self:setAutocompleteState(false) -- turn off type-to-autocomplete
end
function WCombobox:count()
   assert(self ~= WCombobox, "This method must be called on an instance.")
   return self.controls.pane:count()
end
function WCombobox:deselectAll(...)
   self.controls.pane:deselectAll(...)
end
function WCombobox:forEach(functor)
   return self.controls.pane:forEach(functor)
end
function WCombobox:getComputedStyle()
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
function WCombobox:getFirstSelectedIndex(...)
   return self.controls.pane:getFirstSelectedIndex(...)
end
function WCombobox:getSelectedData()
   assert(self ~= WCombobox, "This method must be called on an instance.")
   return self.controls.pane:at(self:getSelectedIndex())
end
function WCombobox:getSelectedIndex()
   assert(self ~= WCombobox, "This method must be called on an instance.")
   return self.controls.pane:getFirstSelectedIndex()
end
function WCombobox:getSelectedItems(...)
   return self.controls.pane:getSelectedItems(...)
end
function WCombobox:multiSelect(flag)
   local result = self.controls.pane:multiSelect(flag)
   if (flag ~= nil) and (self:count() > 0) then
      self:redraw()
   end
   return result
end
function WCombobox:isDisabled()
   assert(self ~= WCombobox, "This method must be called on an instance.")
   return self.state.disabled
end
function WCombobox:isOpen()
   assert(self ~= WCombobox, "This method must be called on an instance.")
   return self.state.isOpen
end
function WCombobox:open()
   assert(self ~= WCombobox, "This method must be called on an instance.")
   if self:isDisabled() or self:isOpen() then
      return
   end
   do -- Zenimax's combobox does this; no clue what it means, tho
      --local control = self:asControl()
      local control = self.controls.contents
      ClearMenu()
      SetMenuMinimumWidth(control:GetWidth() - GetMenuPadding() * 2)
      SetMenuHiddenCallback(function() self:close() end)
      ShowMenu(control, nil, MENU_TYPE_COMBO_BOX)
      AnchorMenu(control, OFFSET_Y)
      control:SetHidden(false)
   end
   self.state.isOpen = true
   self.state.lastMouseoverIndex = self:getSelectedIndex()
   do
      local contents = self.controls.contents
      zo_callLater(
         --
         -- We need to register for the event after at least one frame has passed, 
         -- so that the same click that caused the dropdown to open doesn't count 
         -- as a "global click" and cause it to close.
         --
         function()
            --
            -- closures use locals from enclosing function: contents, self
            --
            contents:RegisterForEvent(EVENT_GLOBAL_MOUSE_UP, function(...) self:_onGlobalMouseUp(...) end)
         end,
         1 -- it looks like zo_callLater guarantees at least one frame's worth of delay
      ) 
      local height
      do -- Set and constrain drop-down height
         local prefs        = self.prefs
         local count        = self.controls.pane:count()
         local selfHeight   = self:asControl():GetHeight()
         local screenHeight = GuiRoot:GetHeight()
         local offsetTop    = contents:GetTop()
         local maxHeight    = nil
         if prefs.maxHeightVisible then
            maxHeight = selfHeight * prefs.maxHeightVisible
         elseif prefs.maxHeight then
            maxHeight = prefs.maxHeight
         elseif prefs.maxHeightPercent then
            maxHeight = screenHeight * prefs.maxHeightPercent
         end
         height = selfHeight * count
         if offsetTop + (maxHeight or height) > screenHeight then -- Ensure we're not cut off at the screen edge
            maxHeight = screenHeight - offsetTop
         end
         if maxHeight and height > maxHeight then
            height = maxHeight
            if prefs.maxHeightIsMult then
               height = ItemTrig.floor(height, count)
            end
         end
      end
      contents:SetHeight(height + 2) -- +2 to account for the drop-down bottom border
      self:refreshStyle() -- also redraws the pane
      self.controls.pane:scrollToItem(self:getSelectedIndex(), true)
   end
   self:setAutocompleteState(true) -- turn on type-to-autocomplete
end
function WCombobox:push(...)
   assert(self ~= WCombobox, "This method must be called on an instance.")
   local pane  = self.controls.pane
   local empty = pane:count() == 0
   pane:push(...)
   if empty and pane:count() > 0 then
      self:select(1)
   end
end
function WCombobox:refreshStyle()
   assert(self ~= WCombobox, "This method must be called on an instance.")
   local style = self:getComputedStyle()
   local c     = self.controls
   c.label:SetColor(   unpack(style.fontColorNormal))
   c.back:SetColor(    unpack(style.backColorNormal))
   c.dropBack:SetColor(unpack(style.backColorNormal))
   fadeToBottom(c.dropEdge, style.backBorderTop, style.backBorderBottom)
   do -- focus ring
      local color = style.backColorNormal
      if self:isOpen() then
         color = style.focusRing
      end
      c.edge:SetColor(unpack(color))
   end
   c.pane.paddingSides = 2 -- TODO: make configurable
   c.pane.paddingEnd   = 2 -- TODO: make configurable
   if self:isOpen() then
      c.pane:redraw()
   end
end
function WCombobox:removeFromSelection(...)
   self.controls.pane:removeFromSelection(...)
end
function WCombobox:select(x)
   assert(self ~= WCombobox, "This method must be called on an instance.")
   return self.controls.pane:select(x)
end
function WCombobox:setDisabled(setTo)
   assert(self ~= WCombobox, "This method must be called on an instance.")
   self.state.disabled = setTo
   if setTo and self:isOpen() then
      self:close()
   end
end
function WCombobox:setShouldSort(...)
   self.controls.pane:setShouldSort(...)
end
function WCombobox:setSortFunction(...)
   self.controls.pane:setSortFunction(...)
end
function WCombobox:toggle()
   assert(self ~= WCombobox, "This method must be called on an instance.")
   if self:isOpen() then
      self:close()
   else
      self:open()
   end
end
function WCombobox:redraw()
   assert(self ~= WCombobox, "This method must be called on an instance.")
   self.controls.pane:redraw()
   self:_onChange()
end
