if not ItemTrig then return end

local Cls = ItemTrig.UI.WSingletonWindow:makeSubclass("Confirm")
ItemTrig:registerWindow("genericConfirm", Cls)

local FRAMES_NEEDED_FOR_THE_RESIZE_TO_BLOODY_WORK = 2
--
-- If we're resizing down (i.e. we showed a long prompt and now we need to 
-- show a short one), then resizing on the first possible frame actually 
-- makes us slightly too small; seems the getters for text height are busted.

function Cls:_construct()
   self.result = nil
   self.text   = GetControl(self:GetNamedChild("Body"), "Text")
   self.buttonYes = GetControl(self:GetNamedChild("Buttons"), "Y")
   self.buttonNo  = GetControl(self:GetNamedChild("Buttons"), "N")
   do -- Set up onAfterShow
      --
      -- We need to be able to resize the confirmation dialog to fit all of 
      -- its text, but we can only do that on the frame after it is shown.
      --
      self._fireAfterShow = false
      ZO_PreHookHandler(self:asControl(), "OnUpdate",
         function(self)
            local window = Cls:getInstance()
            if window and window._fireAfterShow > 0 then
               if not window:asControl():IsHidden() then
                  window._fireAfterShow = window._fireAfterShow - 1
                  window:onAfterShow()
               end
            end
         end
      )
   end
   --
   local control  = self:asControl()
   local fragment = ZO_SimpleSceneFragment:New(control)
   ItemTrig.SCENE_TRIGEDIT:AddFragment(fragment)
   SCENE_MANAGER:RegisterTopLevel(control, false)
end
function Cls:getDefaultOptions()
   return {
      centerIfModal = true,
      modalOnly     = true,
   }
end
function Cls:handleModalDeferredOnHide(deferred)
   if self.result then
      deferred:resolve()
   else
      deferred:reject()
   end
end
function Cls:onBeforeShow(options)
   assert(options      ~= nil, "You must specify options for this modal in the form of a table, passed to showModal, containing at minimum a 'text' key.")
   assert(options.text ~= nil, "You must specify the text for this modal.")
   self:setTitle(options.title or GetString(ITEMTRIG_STRING_UI_GENERIC_CONFIRM_TITLE))
   self.text:SetText(options.text)
   self.buttonYes:SetText(options.yesText or GetString(ITEMTRIG_STRING_UI_GENERIC_CONFIRM_YES))
   self.buttonNo:SetText( options.noText  or GetString(ITEMTRIG_STRING_UI_GENERIC_CONFIRM_NO))
   if options.showCloseButton == nil then
      options.showCloseButton = true
   end
   self:shouldShowCloseButton(options.showCloseButton)
   self.result = nil
   self._fireAfterShow = FRAMES_NEEDED_FOR_THE_RESIZE_TO_BLOODY_WORK
   return true
end
function Cls:onAfterShow()
   local height  = self.text:GetTextHeight()
   local avail   = self.text:GetParent():GetHeight()
   local control = self:asControl()
   control:SetHeight(control:GetHeight() - avail + height + 30)
end
function Cls:yes()
   self.result = true
   self:hide()
end
function Cls:no()
   self.result = false
   self:hide()
end