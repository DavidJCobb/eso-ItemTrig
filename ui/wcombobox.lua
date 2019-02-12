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
      dropBack = self:controlByPath("Contents", "Back"),
      label    = self:GetNamedChild("SelectedItemText"),
      button   = self:GetNamedChild("OpenButton"),
      contents = self:GetNamedChild("Contents"),
      pane     = WScrollSelectList:cast(self:controlByPath("Contents", "ScrollPane")),
   }
   self.shouldSort = options.shouldSort or false
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
   self.style = {
      focusRing = options.style.focusRing or ItemTrig.theme.COMBOBOX_FOCUS_RING,
      font      = options.style.font      or "ZoFontGame",
      fontColorNormal = options.style.fontColorNormal or ItemTrig.theme.COMBOBOX_TEXT,
      backColorNormal = options.style.backColorNormal or ItemTrig.theme.COMBOBOX_BACKGROUND,
      fontColorFocus  = options.style.fontColorFocus  or ItemTrig.theme.COMBOBOX_MOUSEOVER_TEXT,
      backColorFocus  = options.style.backColorFocus  or ItemTrig.theme.COMBOBOX_MOUSEOVER_BACK,
   }
   do -- configure pane
      local pane = self.controls.pane
      pane.element.template      = options.element.template      or "ItemTrig_UITemplate_WComboboxItem"
      pane.element.onSelect      = options.element.onSelect      or nil -- callback
      pane.element.onDeselect    = options.element.onDeselect    or nil -- callback
      pane.element.onDoubleClick = options.element.onDoubleClick or nil -- callback
      pane.element.toConstruct =
         function(control, data, extra)
            assert(data.name ~= nil, "The list item doesn't have a name.")
            GetControl(control, "Text"):SetText(tostring(data.name))
            local combobox = WCombobox:fromItem(control)
            if combobox then
               if extra.index == combobox.state.lastMouseoverIndex then
                  GetControl(control, "Text"):SetColor(unpack(combobox.style.fontColorFocus))
                  GetControl(control, "Back"):SetColor(unpack(combobox.style.backColorFocus))
               else
                  GetControl(control, "Text"):SetColor(unpack(combobox.style.fontColorNormal))
                  GetControl(control, "Back"):SetColor(unpack(combobox.style.backColorNormal))
               end
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
      local data = self:getSelectedData()
      if data then
         self.controls.label:SetText(tostring(data.name))
      else
         self.controls.label:SetText("")
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
   function WCombobox:_onItemClick(control)
      --
      -- TODO
      --
   end
   function WCombobox:_onItemMouseEnter(control)
      local index = self.controls.pane:indexOf(control)
      do -- mouseover colors
         local old = self.controls.pane:controlByIndex(self.state.lastMouseoverIndex)
         self.state.lastMouseoverIndex = index
         GetControl(control, "Text"):SetColor(unpack(self.style.fontColorFocus))
         GetControl(control, "Back"):SetColor(unpack(self.style.backColorFocus))
         if old then
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
end
function WCombobox:count()
   assert(self ~= WCombobox, "This method must be called on an instance.")
   return self.controls.pane:count()
end
function WCombobox:forEach(functor)
   assert(self ~= WCombobox, "This method must be called on an instance.")
   for i, data in ipairs(self.controls.pane.listItems) do
      if functor(i, data) then
         break
      end
   end
end
function WCombobox:getSelectedData()
   assert(self ~= WCombobox, "This method must be called on an instance.")
   return self.controls.pane:at(self:getSelectedIndex())
end
function WCombobox:getSelectedIndex()
   assert(self ~= WCombobox, "This method must be called on an instance.")
   return self.controls.pane:getFirstSelectedIndex()
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
      end
      contents:SetHeight(self:asControl():GetHeight() * count)
      self.controls.pane:redraw()
      self.controls.pane:scrollToItem(self:getSelectedIndex(), true)
   end
end
function WCombobox:push(...)
   assert(self ~= WCombobox, "This method must be called on an instance.")
   local empty = self.controls.pane:count() == 0
   self.controls.pane:push(...)
   if empty and self.controls.pane:count() > 0 then
      self.controls.pane:select(1)
   end
end
function WCombobox:refreshStyle()
   assert(self ~= WCombobox, "This method must be called on an instance.")
   local c = self.controls
   c.label:SetColor(unpack(self.style.fontColorNormal))
   c.back:SetColor(unpack(self.style.backColorNormal))
   c.dropBack:SetColor(unpack(self.style.backColorNormal))
   do -- focus ring
      local color = self.style.backColorNormal
      if self:isOpen() then
         color = self.style.focusRing
      end
      c.edge:SetColor(unpack(color))
   end
   c.pane:redraw()
end
function WCombobox:select(x)
   assert(self ~= WCombobox, "This method must be called on an instance.")
   if type(x) == "function" --
   or type(x) == "number" then
      return self.controls.pane:select(x)
   end
   assert(false, "Invalid argument type passed to WCombobox:select(...).")
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
