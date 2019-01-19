if not ItemTrig then return end

ItemTrig.UIMain = {}

local GAMEPAD_KEY_DUP    = 123 -- D-Pad direction
local GAMEPAD_KEY_DDOWN  = 124 -- D-Pad direction
local GAMEPAD_KEY_DLEFT  = 125 -- D-Pad direction
local GAMEPAD_KEY_DRIGHT = 126 -- D-Pad direction
local GAMEPAD_KEY_START  = 127
local GAMEPAD_KEY_BACK   = 128
local GAMEPAD_KEY_LS     = 129 -- stick click
local GAMEPAD_KEY_RS     = 130 -- stick click
local GAMEPAD_KEY_LB     = 131
local GAMEPAD_KEY_RB     = 132
local GAMEPAD_KEY_A      = 133
local GAMEPAD_KEY_B      = 134
local GAMEPAD_KEY_X      = 135
local GAMEPAD_KEY_Y      = 136
local GAMEPAD_KEY_LUP    = 139 -- left stick movement direction
local GAMEPAD_KEY_LDOWN  = 140 -- left stick movement direction
local GAMEPAD_KEY_LLEFT  = 141 -- left stick movement direction
local GAMEPAD_KEY_LRIGHT = 142 -- left stick movement direction
local GAMEPAD_KEY_RUP    = 143 -- right stick movement direction
local GAMEPAD_KEY_RDOWN  = 144 -- right stick movement direction
local GAMEPAD_KEY_RLEFT  = 145 -- right stick movement direction
local GAMEPAD_KEY_RRIGHT = 146 -- right stick movement direction

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
         enabled  = true -- set to "false" to make the keybind grey out -- can also be a function
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
      Window.views.triggerlist.pane = scrollPane
      scrollPane.tlData.paddingBetween = 8
      scrollPane.tlData.template  = "ItemTrig_TrigEdit_Template_TriggerOuter"
      scrollPane.tlData.construct =
         function(control, data)
            local text = GetControl(control, "Name")
            local _, _, _, _, paddingX, paddingY = text:GetAnchor(1)
            text:SetText(data.name)
            control:SetHeight(text:GetHeight() + paddingY * 2)
         end
   end
   
end
function ItemTrig.UIMain.OnKeyDown(key, ctrl, alt, shift, command)
   --d("Detected keydown " .. key)
end
function ItemTrig.UIMain.OnKeyUp(key, ctrl, alt, shift, command)
   if key == GAMEPAD_KEY_START then -- safety, while we tinker
      ItemTrig.UIMain.Toggle()
   else
      return false -- don't block the game from receiving other keys (doesn't work? ZOS said they may implement it; did they?)
   end
end

function ItemTrig.UIMain.RenderTriggers(tList)
   local scrollPane = Window.views.triggerlist.pane
   ItemTrig.UI.vScrollList.clear(scrollPane, false)
   for i = 1, table.getn(tList) do
      ItemTrig.UI.vScrollList.push(scrollPane, tList[i], false)
   end
   ItemTrig.UI.vScrollList.redraw(scrollPane)
end