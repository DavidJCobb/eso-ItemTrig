if not (ItemTrig and ItemTrig.UI) then return end

local function _comboboxFromPane(pane)
   if type(pane) == "table" then
      pane = pane:asControl()
   end
   return ItemTrig.UI.WCombobox:cast(pane:GetParent():GetParent())
end

ItemTrig.UI.WCombobox   = ItemTrig.UI.WidgetClass:makeSubclass("WCombobox", "combobox")
local WCombobox         = ItemTrig.UI.WCombobox
local WScrollSelectList = ItemTrig.UI.WScrollSelectList
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
   }
   self.element = {
      onSelect      = options.element.onSelect      or nil, -- callback
      onDeselect    = options.element.onDeselect    or nil, -- callback
      onDoubleClick = options.element.onDoubleClick or nil, -- callback
   }
   self.state = {
      disabled = false,
      isOpen   = false,
      lastMouseoverIndex = nil,
      _lastSelectedIndex = nil,
   }
   self.emptyText = options.emptyText or "" -- for multi-select, if there is no selection
   self.style = {
      focusRing = options.style.focusRing or ItemTrig.theme.COMBOBOX_FOCUS_RING,
      font      = options.style.font      or "ZoFontGame",
      fontColorNormal  = options.style.fontColorNormal  or ItemTrig.theme.COMBOBOX_TEXT,
      backColorNormal  = options.style.backColorNormal  or ItemTrig.theme.COMBOBOX_BACKGROUND,
      fontColorFocus   = options.style.fontColorFocus   or ItemTrig.theme.COMBOBOX_MOUSEOVER_TEXT,
      backColorFocus   = options.style.backColorFocus   or ItemTrig.theme.COMBOBOX_MOUSEOVER_BACK,
      backBorderTop    = options.style.backBorderTop    or ItemTrig.theme.COMBOBOX_BODY_BORDER_TOP,
      backBorderBottom = options.style.backBorderBottom or ItemTrig.theme.COMBOBOX_BODY_BORDER_BOTTOM,
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
            text:SetText(tostring(data.name))
            if combobox then
               if extra.index == combobox.state.lastMouseoverIndex then
                  GetControl(control, "Text"):SetColor(unpack(combobox.style.fontColorFocus))
                  GetControl(control, "Back"):SetColor(unpack(combobox.style.backColorFocus))
               else
                  GetControl(control, "Text"):SetColor(unpack(combobox.style.fontColorNormal))
                  GetControl(control, "Back"):SetColor(unpack(combobox.style.backColorNormal))
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
            local index = combobox:getSelectedIndex()
            if index ~= combobox.state._lastSelectedIndex then
               combobox.state._lastSelectedIndex = index
               combobox:onChange()
            end
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
end

function WCombobox:fromItem(control) -- static method
   local pane = WScrollSelectList:fromItem(control)
   if not pane then
      return nil
   end
   return _comboboxFromPane(pane)
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
         local count = table.getn(items)
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
         local old = self.controls.pane:controlByIndex(self.state.lastMouseoverIndex)
         self.state.lastMouseoverIndex = index
         GetControl(control, "Text"):SetColor(unpack(self.style.fontColorFocus))
         GetControl(control, "Back"):SetColor(unpack(self.style.backColorFocus))
         if old and old ~= control then
            GetControl(old, "Text"):SetColor(unpack(self.style.fontColorNormal))
            GetControl(old, "Back"):SetColor(unpack(self.style.backColorNormal))
         end
      end
      self:onItemMouseEnter(index, control)
   end
   function WCombobox:_onItemMouseExit(control)
      self:onItemMouseExit(self.controls.pane:indexOf(control), control)
   end
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
   if self.state.isOpen then
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
end
function WCombobox:count()
   assert(self ~= WCombobox, "This method must be called on an instance.")
   return self.controls.pane:count()
end
function WCombobox:forEach(functor)
   return self.controls.pane:forEach(functor)
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
      local count = self.controls.pane:count()
      if count > 5 then
         count = 5
      elseif count < 1 then
         count = 1
      end
      contents:SetHeight(self:asControl():GetHeight() * count + 2)
      self:refreshStyle() -- also redraws the pane
      self.controls.pane:scrollToItem(self:getSelectedIndex(), true)
   end
end
function WCombobox:push(...)
   assert(self ~= WCombobox, "This method must be called on an instance.")
   local pane  = self.controls.pane
   local empty = pane:count() == 0
   pane:push(...)
   if empty and pane:count() > 0 then
      pane:select(1)
   end
end
function WCombobox:refreshStyle()
   assert(self ~= WCombobox, "This method must be called on an instance.")
   local c = self.controls
   c.label:SetColor(unpack(self.style.fontColorNormal))
   c.back:SetColor(unpack(self.style.backColorNormal))
   c.dropBack:SetColor(unpack(self.style.backColorNormal))
   ItemTrig.fadeToBottom(c.dropEdge, self.style.backBorderTop, self.style.backBorderBottom)
   do -- focus ring
      local color = self.style.backColorNormal
      if self:isOpen() then
         color = self.style.focusRing
      end
      c.edge:SetColor(unpack(color))
   end
   c.pane.paddingSides = 2 -- TODO: make configurable
   c.pane.paddingEnd   = 2 -- TODO: make configurable
   if self:isOpen() then
      c.pane:redraw()
   end
end
function WCombobox:select(x)
   assert(self ~= WCombobox, "This method must be called on an instance.")
   if type(x) == "function" --
   or type(x) == "number" then
      return self.controls.pane:select(x)
   end
   assert(false, "Invalid argument type passed to WCombobox:select(...).")
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
