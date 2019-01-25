if not ItemTrig then return end
if not ItemTrig.UI then
   ItemTrig.UI = {}
end

ItemTrig.UI.WModalHost = {}
ItemTrig.UI.WModalHost.__index = ItemTrig.UI.WModalHost
function ItemTrig.UI.WModalHost:install(control, blocker)
   if control.widgets and control.widgets.modalHost then
      return control.widgets.modalHost
   end
   local result = {
      control = control,
      blocker = blocker,
      showing = nil,
   }
   setmetatable(result, self)
   do -- link the wrapper to the control via an expando property
      if not control.widgets then
         control.widgets = {}
      end
      control.widgets.modalHost = result
   end
   return result
end
function ItemTrig.UI.WModalHost:cast(control)
   assert(control ~= nil, "Cannot cast a nil control to WModalHost.")
   if getmetatable(control) == self then
      return control
   end
   if control.widgets then
      return control.widgets.modalHost
   end
   return nil
end
function ItemTrig.UI.WModalHost:prepToShowModal(modalControl)
   if self.showing then
      return nil
   end
   local deferred = ItemTrig.Deferred:new()
   self.blocker:SetHidden(false)
   deferred:done(self.onModalHidden, self)
   self.showing = modalControl
   return deferred
end
function ItemTrig.UI.WModalHost:onModalHidden()
   self.showing = nil
   self.blocker:SetHidden(true)
end

--

ItemTrig.UI.WModal = {}
ItemTrig.UI.WModal.__index = ItemTrig.UI.WModal
function ItemTrig.UI.WModal:install(control)
   if control.widgets and control.widgets.modal then
      return control.widgets.modal
   end
   local result = {
      control  = control,
      opener   = nil,
      deferred = nil,
   }
   setmetatable(result, self)
   ZO_PreHookHandler(control, "OnEffectivelyHidden",
      function(self)
         if result.deferred then
            result.deferred:resolve()
            result.deferred = nil
            result.opener   = nil
         end
      end
   )
   do -- link the wrapper to the control via an expando property
      if not control.widgets then
         control.widgets = {}
      end
      control.widgets.modal = result
   end
   return result
end
function ItemTrig.UI.WModal:cast(control)
   assert(control ~= nil, "Cannot cast a nil control to WModal.")
   if getmetatable(control) == self then
      return control
   end
   if control.widgets then
      return control.widgets.modal
   end
   return nil
end
function ItemTrig.UI.WModal:prepToShow(opener)
   assert(not self.opener,   "This modal is already being shown.")
   assert(not self.deferred, "This modal is already being shown.")
   assert(opener ~= nil, "Cannot show this modal; no opener.")
   local o = ItemTrig.UI.WModalHost:cast(opener)
   assert(o ~= nil, "Cannot show this modal; invalid opener.")
   local deferred = o:prepToShowModal(self.control)
   if not deferred then
      return false
   end
   self.deferred = deferred
   self.opener   = o
   return true
end