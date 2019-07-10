if not (ItemTrig and ItemTrig.UI) then return end

--
-- A subclass of WScrollSelectList, showing checkboxes on the items.
--

ItemTrig.UI.WCheckboxList = ItemTrig.UI.WScrollSelectList:makeSubclass("WCheckboxList")
local WCheckboxList       = ItemTrig.UI.WCheckboxList

WCheckboxList.style = {
   --
   -- Default style options for a window. You can override this 
   -- per-subclass by assigning a table to the subclass.
   --
   font = "ZoFontGame",
   itemBackColor = ItemTrig.TRANSPARENT,
   itemTextColor = ItemTrig.BLACK,
}
do
   local registry = ItemTrig.ThemeManager.callbacks
   local function _refresh(theme)
      local colors = theme.colors
      ItemTrig.assign(WCheckboxList.style, {
         itemBackColor  = colors.CHECKBOXLIST_ITEM_BACK,
         itemTextColor  = colors.CHECKBOXLIST_ITEM_TEXT,
      })
   end
   registry:RegisterCallback("update", _refresh)
end

function WCheckboxList:_construct()
   self:multiSelect(true)
   self.selection.shiftToAdd = false
   --
   self.element.template = "ItemTrig_UITemplate_WCheckboxListItem"
   self.element.toConstruct =
      function(control, data, extra, pane)
         assert(data.name ~= nil, "The list item doesn't have a name.")
         local text   = GetControl(control, "Text")
         local master = WCheckboxList:fromItem(control)
         local style  = master:getComputedStyle()
         text:SetText(tostring(data.name))
         do -- style
            GetControl(control, "Text"):SetColor(unpack(style.itemTextColor))
            GetControl(control, "Back"):SetColor(unpack(style.itemBackColor))
         end
         local checkbox = GetControl(control, "Enabled")
         if extra.selected then
            ZO_CheckButton_SetChecked(checkbox)
         else
            ZO_CheckButton_SetUnchecked(checkbox)
         end
      end
   local pane = self
   self.element.onSelect =
      function(index, control, pane)
         ZO_CheckButton_SetChecked(GetControl(control, "Enabled"))
      end
   self.element.onDeselect =
      function(index, control, pane)
         ZO_CheckButton_SetUnchecked(GetControl(control, "Enabled"))
      end
end
function WCheckboxList:getComputedStyle()
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
function WCheckboxList:multiSelect(flag) -- do not allow this to be disabled
   local raw = self:getClass():getSuperclass().multiSelect
   if flag ~= nil then
      raw(self, true)
   end
   return true
end