if not ItemTrig then return end

ItemTrig.UIMain = {}

local GAMEPAD_ITEMTRIG_WINDOW_SCENE
local GAMEPAD_ITEMTRIG_WINDOW

local Window = {
   control = nil,
   views = {
      triggerlist = {
         pane = nil,
         paneDataType = 1,
      },
      trigger = {
      },
   },
   keybinds = {
      alignment = KEYBIND_STRIP_ALIGN_CENTER,
      {
         name     = "Close Menu (Debugging)",
         keybind  = "UI_SHORTCUT_PRIMARY",
         callback = function() ItemTrig.UIMain.Toggle() end,
         visible  = function() return true end,
         enabled  = true,  -- set to "false" to make the keybind grey out -- can also be a function
         ethereal = false, -- if true, then the keybind isn't actually shown in the menus; vanilla gamepad menus use this for LT/RT flipping pages or fast-scrolling menus
      }
   }
}
ItemTrig.TrigEditWindow = Window
function Window:onOpen()
   KEYBIND_STRIP:AddKeybindButtonGroup(self.keybinds)
end
function Window:onClose()
   KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybinds)
end
function Window:onTriggerListEntryClick(control)
   local list = Window.views.triggerlist.pane
   --
   -- TODO
   --
   d("trigger clicked")
   --
end

function ItemTrig.UIMain.Setup()
   SCENE_MANAGER:RegisterTopLevel(ItemTrig_TrigEdit, false)
end
function ItemTrig.UIMain.Toggle()
   SCENE_MANAGER:ToggleTopLevel(ItemTrig_TrigEdit)
end

function ItemTrig.UIMain.DispatchEvent(e)
   if e == "OnHide" then
      Window:onClose()
   elseif e == "OnShow" then
      Window:onOpen()
   end
end
function ItemTrig.UIMain.OnInitialized(control)
   Window.control = control
   local fragment = ZO_SimpleSceneFragment:New(ItemTrig_TrigEdit)
   local scene    = ZO_Scene:New("ItemTrig_TrigEdit_Scene", SCENE_MANAGER)
   scene:AddFragment(fragment)
   --
   do
      local scrollPane = ItemTrig_TrigEdit:GetNamedChild("ViewTriggerList"):GetNamedChild("Col2")
      scrollPane = ItemTrig.UI.WScrollSelectList:cast(scrollPane)
      Window.views.triggerlist.pane = scrollPane
      scrollPane.paddingBetween      = 8
      scrollPane.element.template    = "ItemTrig_TrigEdit_Template_TriggerOuter"
      scrollPane.element.toConstruct =
         function(control, data)
            local text = GetControl(control, "Name")
            local _, _, _, _, paddingX, paddingY = text:GetAnchor(1)
            text:SetText(data.name)
            control:SetHeight(text:GetHeight() + paddingY * 2)
         end
      scrollPane.element.onSelect =
         function(index, control)
            local text = GetControl(control, "Name")
            --text:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_HIGHLIGHT))
            text:SetColor(1.0, 0.25, 0.0)
         end
      scrollPane.element.onDeselect =
         function(index, control)
            local text = GetControl(control, "Name")
            text:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
         end
   end
end

function ItemTrig.UIMain.RenderTriggers(tList)
   local scrollPane = Window.views.triggerlist.pane
   scrollPane:clear(false)
   for i = 1, table.getn(tList) do
      scrollPane:push(tList[i], false)
   end
   scrollPane:redraw()
end