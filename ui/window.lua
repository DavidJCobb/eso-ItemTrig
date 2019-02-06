if not (ItemTrig and ItemTrig.UI) then return end

ItemTrig.UI.WWindow = ItemTrig.UI.WidgetClass:makeSubclass("WWindow", "window")
function ItemTrig.UI.WWindow:_construct(options)
   if not options then
      options = {}
   end
   local control = self:asControl()
   self.controls = {
      blocker   = self:GetNamedChild("ModalUnderlay"), -- the control used to block mouse focus
      titleBar  = self:GetNamedChild("TitleBar"),
      titleText = nil,
      titleExit = nil,
   }
   self.prefs = {
      modalOnly = options.modalOnly or false, -- boolean OR the name of the only allowed opener
   }
   self.modalState = {
      child    = nil, -- WWindow: a modal that we've opened
      opener   = nil, -- WWindow: the window that has us open as a modal
      deferred = nil, -- Deferred to resolve when we're closed; allows opener to respond to our closing
   }
   assert(self.controls.blocker ~= nil, "A WWindow control must have a child named \"$(parent)ModalUnderlay\".")
   if self.controls.titleBar then
      self.controls.titleText = GetControl(self.controls.titleBar, "Title")
      self.controls.titleExit = GetControl(self.controls.titleBar, "Close")
      if (options.closeButton == false) and self.controls.titleExit then
         self.controls.titleExit:SetHidden(true)
      end
   end
   ZO_PreHookHandler(control, "OnEffectivelyHidden",
      function(self)
         local window = ItemTrig.UI.WWindow:cast(self)
         if window then
            window:_onHide()
         end
      end
   )
end
function ItemTrig.UI.WWindow:shouldShowCloseButton(v)
   local button = self.controls.titleExit
   if v == nil then
      if not button then
         return false
      end
      return not button:IsHidden()
   end
   assert(button ~= nil, "Cannot modify visibility of this window's close button: it has no close button.")
   button:SetHidden(v)
end
function ItemTrig.UI.WWindow:onCloseClicked()
   --
   -- Subclasses can override this.
   --
   self:hide()
end
function ItemTrig.UI.WWindow:_onBeforeShow()
   --
   -- Subclasses can override this. Returning false cancels the show operation.
   --
   return true
end
function ItemTrig.UI.WWindow:onShow()
   --
   -- Subclasses can override this.
   --
end
function ItemTrig.UI.WWindow:_onBeforeOpenBy(opener)
   --
   -- Subclasses can override this. Returning false cancels the open operation. 
   -- The argument is a WWindow instance.
   --
   return true
end
function ItemTrig.UI.WWindow:_onModalHidden()
   --
   -- This event fires on a window when a modal that it has opened is closed. 
   -- This should be used to perform cleanup in the opener; the default function 
   -- clears some modal state and hides a "blocker" element that prevents clicks 
   -- to the opener while the modal is open.
   --
   -- Subclasses can override this, but should always call super.
   --
   self.modalState.child = nil
   self.controls.blocker:SetHidden(true)
end
function ItemTrig.UI.WWindow:_handleModalDeferredOnHide(deferred)
   --
   -- If the window is opened as a modal, then it will have a Deferred that it can 
   -- use to:
   --
   -- a) Tell its opener when it closes.
   --
   -- b) Send a result back to its opener.
   --
   -- This function handles that deferred. Subclasses can override the function in 
   -- order to alter what is sent back; the code that originally opened the modal 
   -- can react to that (i.e. it receives the deferred and can add callbacks).
   --
   deferred:resolve()
end
function ItemTrig.UI.WWindow:_onHide()
   --
   -- Subclasses can override this, but should always call super.
   --
   local deferred = self.modalState.deferred
   if deferred then
      self:_handleModalDeferredOnHide(deferred)
      self.modalState.deferred = nil
   end
   self.modalState.opener = nil
end
function ItemTrig.UI.WWindow:getModalOpener()
   return self.modalState.opener
end
function ItemTrig.UI.WWindow:show()
   local c = self:asControl()
   if not c:IsHidden() then
      return
   end
   if self.prefs.modalOnly then
      return
   end
   if not self:_onBeforeShow() then
      return
   end
   SCENE_MANAGER:ShowTopLevel(c)
   c:BringWindowToTop()
   self:onShow()
end
function ItemTrig.UI.WWindow:hide()
   SCENE_MANAGER:HideTopLevel(self:asControl())
end
function ItemTrig.UI.WWindow:showModal(modal)
   --
   -- Makes this window show a child modal. If the modal is successfully opened, 
   -- this function returns a Deferred; if the modal fails to open, this function 
   -- returns nil.
   --
   assert(modal ~= nil, "Cannot show a nil modal.")
   local child = ItemTrig.UI.WWindow:cast(modal)
   assert(child ~= nil, "The specified modal isn't a valid WWindow.")
   do
      local other = child:getModalOpener()
      assert(child:getModalOpener() ~= self,   "This window is already showing the specified modal. Did you accidentally call this function twice?")
      assert(child:getModalOpener() == nil,    "The specified modal is already being shown.")
      assert(child.modalState.deferred == nil, "The specified modal's state has been mismanaged. The modal cannot be shown.")
   end
   assert(self.modalState.child == nil, "This window is already showing a modal.")
   if type(self.prefs.modalOnly) == "string" then
      local name = child.controls.window:GetName()
      if name ~= self.prefs.modalOnly then
         return nil
      end
   end
   if not child:_onBeforeOpenBy(self) then
      return nil
   end
   if not child:_onBeforeShow() then
      return nil
   end
   self.controls.blocker:SetHidden(false)
   self.modalState.child = child
   local deferred = ItemTrig.Deferred:new()
   deferred:always(self._onModalHidden, self)
   child.modalState.opener   = self
   child.modalState.deferred = deferred
   SCENE_MANAGER:ShowTopLevel(child:asControl())
   child:asControl():BringWindowToTop()
   return deferred
end
function ItemTrig.UI.WWindow:getTitle()
   return self.controls.titleText:GetText()
end
function ItemTrig.UI.WWindow:setTitle(text)
   return self.controls.titleText:SetText(text)
end