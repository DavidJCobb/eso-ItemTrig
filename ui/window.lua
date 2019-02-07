if not (ItemTrig and ItemTrig.UI) then return end

--[[--
   WWINDOW: HELPER CLASS FOR WINDOWS
   
   This helper class offers the ability to show and hide windows both incidentally 
   and as modals to other WWindows. You can subclass it and override a number of 
   methods to control advanced behaviors.
--]]--

ItemTrig.UI.WWindow = ItemTrig.UI.WidgetClass:makeSubclass("WWindow", "window")
function ItemTrig.UI.WWindow:getDefaultOptions() -- override me, if you want
end
function ItemTrig.UI.WWindow:_construct(options)
   if not options then
      options = self:getDefaultOptions() or {}
   end
   local control = self:asControl()
   self.controls = {
      blocker   = self:GetNamedChild("ModalUnderlay"), -- the control used to block mouse focus
      titleBar  = self:GetNamedChild("TitleBar"),
      titleText = nil,
      titleExit = nil,
   }
   self.prefs = {
      centerIfModal = options.centerIfModal or false, -- if true, then the modal opens at the center of the screen; if false, it opens relative to its creator
      modalOnly     = options.modalOnly     or false, -- boolean OR the name of the only allowed opener
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
            window:onHide()
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
function ItemTrig.UI.WWindow:onBeforeShow(...)
   --
   -- Subclasses can override this. Returning false or nil cancels the show 
   -- operation.
   --
   -- The function is passed any extra args that were provided to show() or to 
   -- showModal().
   --
   return true
end
function ItemTrig.UI.WWindow:onShow()
   --
   -- Subclasses can override this.
   --
end
function ItemTrig.UI.WWindow:onBeforeOpenBy(opener)
   --
   -- Subclasses can override this. Returning false or nil cancels the open 
   -- operation. The argument is a WWindow instance.
   --
   return true
end
function ItemTrig.UI.WWindow:_onChildModalHidden()
   --
   -- This method handles cleanup after a window's child modal is closed. An 
   -- alternate, non-underscore-prefixed, version is provided for you to over-
   -- ride (two separate methods exist so you don't have to call super if you 
   -- do override the non-prefixed one).
   --
   self.modalState.child = nil
   self.controls.blocker:SetHidden(true)
end
function ItemTrig.UI.WWindow:onChildModalHidden()
   --
   -- This event fires on a window when a modal that it has opened is closed. 
   -- This should be used to perform cleanup in the opener; the default function 
   -- clears some modal state and hides a "blocker" element that prevents clicks 
   -- to the opener while the modal is open.
   --
   -- Subclasses can override this.
   --
end
function ItemTrig.UI.WWindow:handleModalDeferredOnHide(deferred)
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
   -- This method handles cleanup after a window's child modal is closed. An 
   -- alternate, non-underscore-prefixed, version is provided for you to over-
   -- ride (two separate methods exist so you don't have to call super if you 
   -- do override the non-prefixed one).
   --
   local deferred = self.modalState.deferred
   if deferred then
      self:handleModalDeferredOnHide(deferred)
      self.modalState.deferred = nil
   end
   self.modalState.opener = nil
end
function ItemTrig.UI.WWindow:onHide()
   --
   -- Subclasses can override this.
   --
end
function ItemTrig.UI.WWindow:getModalOpener()
   return self.modalState.opener
end
function ItemTrig.UI.WWindow:show(...)
   --
   -- The arguments are passed to the before-show handler.
   --
   local c = self:asControl()
   if not c:IsHidden() then
      return
   end
   if self.prefs.modalOnly then
      return
   end
   if not self:onBeforeShow(...) then
      return
   end
   SCENE_MANAGER:ShowTopLevel(c)
   c:BringWindowToTop()
   self:onShow()
end
function ItemTrig.UI.WWindow:hide()
   SCENE_MANAGER:HideTopLevel(self:asControl())
end
function ItemTrig.UI.WWindow:showModal(modal, ...)
   --
   -- Makes this window show a child modal. If the modal is successfully opened, 
   -- this function returns a Deferred; if the modal fails to open, this function 
   -- returns nil.
   --
   -- Extra arguments are passed to the before-show handler.
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
      local name = child:asControl():GetName()
      if name ~= self.prefs.modalOnly then
         return nil
      end
   end
   if not child:onBeforeOpenBy(self) then
      return nil
   end
   if not child:onBeforeShow(...) then
      return nil
   end
   self.controls.blocker:SetHidden(false)
   self.modalState.child = child
   local deferred = ItemTrig.Deferred:new()
   deferred:always(self._onChildModalHidden, self) -- internal event for handling the modal blocker properly
   deferred:always(self.onChildModalHidden, self)  -- event provided for subclasses to override
   do -- show the modal
      local control = child:asControl()
      local openerC = self:asControl()
      child.modalState.opener   = self
      child.modalState.deferred = deferred
      --
      -- Position the opened modal:
      --
      control:ClearAnchors()
      if child.prefs.centerIfModal then
         control:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
      else
         local offsetX = 50
         local offsetY = 50
         -- account for the opener being crammed into the lower corner
         local cw = openerC:GetWidth()
         local ch = openerC:GetHeight()
         local sw = GuiRoot:GetWidth()
         local sh = GuiRoot:GetHeight()
         if openerC:GetTop() + ch + offsetY > sh then
            offsetY = -offsetY
         end
         if openerC:GetLeft() + cw + offsetX > sw then
            offsetX = -offsetX
         end
         control:SetAnchor(CENTER, openerC, CENTER, offsetX, offsetY)
      end
      SCENE_MANAGER:ShowTopLevel(control)
      control:BringWindowToTop()
   end
   return deferred:promise()
end
function ItemTrig.UI.WWindow:getTitle()
   return self.controls.titleText:GetText()
end
function ItemTrig.UI.WWindow:setTitle(text)
   return self.controls.titleText:SetText(text)
end

--[[--
   WSINGLETONWINDOW
   
   If you want to define a unique window, you can subclass WSingletonWindow. Your 
   subclass will only allow one instance of itself to exist, and will provide an 
   accessor to that instance after the instance is created.
--]]--

local SINGLETON_WINDOW_KEY = " window"

ItemTrig.UI.WSingletonWindow = ItemTrig.UI.WWindow:makeSubclass("WSingletonWindow")
function ItemTrig.UI.WSingletonWindow:_construct()
   local class = self:getClass()
   assert(class ~= ItemTrig.UI.WSingletonWindow, "You're supposed to subclass this!")
   assert(class[SINGLETON_WINDOW_KEY] == nil, "An instance of this window class already exists.")
   class[SINGLETON_WINDOW_KEY] = self
end
function ItemTrig.UI.WSingletonWindow:getInstance() -- static method
   return self[SINGLETON_WINDOW_KEY]
end