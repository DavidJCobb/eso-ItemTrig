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
      back     = self:GetNamedChild("Bg"),
      dropBack = GetControl(self:GetNamedChild("Contents"), "Bg"),
      label    = self:GetNamedChild("SelectedItemText"),
      button   = self:GetNamedChild("OpenButton"),
      contents = self:GetNamedChild("Contents"),
      pane     = WScrollSelectList:cast(GetControl(self:GetNamedChild("Contents"), "ScrollPane")),
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
      _lastSelectedIndex = nil,
      _preventBubble     = false, -- if we click the dropdown button, we need to stop the click handler on the dropdown itself from firing
   }
   self.style = {
      font      = options.style.font      or "ZoFontGame",
      fontColorNormal = options.style.fontColorSel or {0,0,0,1},
      backColorNormal = options.style.backColorSel or {1,1,1,1},
      fontColorSel    = options.style.fontColorSel or {1, 1, 1, 1},
      backColorSel    = options.style.backColorSel or {0.1, 0.1, 0.9, 1},
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
               GetControl(control, "Text"):SetColor(unpack(combobox.style.fontColorNormal))
               GetControl(control, "Back"):SetColor(unpack(combobox.style.backColorNormal))
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
         if self:asControl():IsHidden() then
            self:close()
         else
            self.controls.contents:SetHidden(false)
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
      self:onItemMouseEnter(self.controls.pane:indexOf(control), control)
   end
   function WCombobox:_onItemMouseExit(control)
      self:onItemMouseExit(self.controls.pane:indexOf(control), control)
   end
end

function WCombobox:clear(...)
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
   if not self:isOpen() then
      return
   end
   ClearMenu()
   self.controls.contents:UnregisterForEvent(EVENT_GLOBAL_MOUSE_UP)
   self.controls.contents:SetHidden(true)
end
function WCombobox:count()
   return self.controls.pane:count()
end
function WCombobox:forEach(functor)
   for i, data in ipairs(self.controls.pane.listItems) do
      if functor(i, data) then
         break
      end
   end
end
function WCombobox:getSelectedData()
   return self.controls.pane:at(self:getSelectedIndex())
end
function WCombobox:getSelectedIndex()
   return self.controls.pane:getFirstSelectedIndex()
end
function WCombobox:isDisabled()
   return self.state.disabled
end
function WCombobox:isOpen()
   return self.state.isOpen
end
function WCombobox:open()
   if self:isDisabled() or self:isOpen() then
      return
   end
   do -- Zenimax's combobox does this; no clue what it means, tho
      local control = self:asControl()
      ClearMenu()
      SetMenuMinimumWidth(control:GetWidth() - GetMenuPadding() * 2)
      SetMenuHiddenCallback(function() GlobalMenuClearCallback(self) end)
      ShowMenu(control, nil, MENU_TYPE_COMBO_BOX)
      AnchorMenu(control, OFFSET_Y)
      control:SetHidden(false)
   end
   do
      local contents = self.controls.contents
      contents:RegisterForEvent(EVENT_GLOBAL_MOUSE_UP, function(...) self:_onGlobalMouseUp(...) end)
      local count = self.controls.pane:count()
      if count > 5 then
         count = 5
      end
      contents:SetHeight(self:asControl():GetHeight() * count)
      self.controls.pane:redraw()
   end
   --
   -- TODO
   --
end
function WCombobox:push(...)
   local empty = self.controls.pane:count() == 0
   self.controls.pane:push(...)
   if empty and self.controls.pane:count() > 0 then
      self.controls.pane:select(1)
   end
end
function WCombobox:refreshStyle()
   local c = self.controls
   c.label:SetColor(unpack(self.style.fontColorNormal))
   c.back:SetColor(unpack(self.style.backColorNormal))
   c.dropBack:SetColor(unpack(self.style.backColorNormal))
   --
   -- TODO
   --
end
function WCombobox:select(x)
   if type(x) == "function" --
   or type(x) == "number" then
      return self.controls.pane:select(x)
   end
   assert(false, "Invalid argument type passed to WCombobox:select(...).")
end
function WCombobox:toggle()
   if self:isOpen() then
      self:close()
   else
      self:open()
   end
end
function WCombobox:redraw()
   self.controls.pane:redraw()
   self:_onChange()
end
