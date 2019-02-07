if not ItemTrig then return end

local Cls = ItemTrig.UI.WSingletonWindow:makeSubclass("Confirm")
ItemTrig:registerWindow("genericConfirm", Cls)

function Cls:_construct()
   self.result = nil
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
   self:GetNamedChild("Body"):GetChild(1):SetText(options.text)
   self:GetNamedChild("Buttons"):GetNamedChild("Y"):SetText(options.yesText or GetString(ITEMTRIG_STRING_UI_GENERIC_CONFIRM_YES))
   self:GetNamedChild("Buttons"):GetNamedChild("N"):SetText(options.noText or GetString(ITEMTRIG_STRING_UI_GENERIC_CONFIRM_NO))
   if options.showCloseButton == nil then
      options.showCloseButton = true
   end
   self:shouldShowCloseButton(options.showCloseButton)
   self.result = nil
   return true
end
function Cls:yes()
   self.result = true
   self:hide()
end
function Cls:no()
   self.result = false
   self:hide()
end