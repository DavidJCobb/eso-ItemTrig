if not ItemTrig then return end
if not ItemTrig.UI then
   ItemTrig.UI = {}
end

ItemTrig.UI.WViewHolder = {}
ItemTrig.UI.WViewHolder.__index = ItemTrig.UI.WViewHolder
function ItemTrig.UI.WViewHolder:install(control)
   if control.widgets and control.widgets.viewHolder then
      return control.widgets.viewHolder
   end
   local result = {
      control     = control,
      views       = {},  -- view control list
      selected    = nil, -- view control
      postInstall = false,
   }
   setmetatable(result, self)
   do -- link the wrapper to the control via an expando property
      if not control.widgets then
         control.widgets = {}
      end
      control.widgets.viewHolder = result
   end
   return result
end
function ItemTrig.UI.WViewHolder:setView(control)
   if type(control) == "number" then
      control = self.control:GetChild(control)
   end
   if not control then
      return
   end
   if self.selected == control then
      return
   end
   if self.selected then
      self.selected:SetHidden(true)
   else
      for i = 1, table.getn(self.views) do
         self.views[i]:SetHidden(true)
      end
   end
   control:SetHidden(false)
   self.selected = control
end
function ItemTrig.UI.WViewHolder:cast(control)
   assert(control ~= nil, "Cannot cast a nil control to WViewHolder.")
   if control.widgets then
      return control.widgets.viewHolder
   end
   return nil
end
function ItemTrig.UI.WViewHolder:hasView(control)
   for i = 1, table.getn(self.views) do
      if self.views[i] == control then
         return true
      end
   end
   return false
end
function ItemTrig.UI.WViewHolder:addView(control)
   if self:hasView(control) then
      return
   end
   table.insert(self.views, control)
   if not self.selected then
      if not control:IsHidden() then
         self.selected = control
      end
   elseif not control:IsHidden() then
      control:SetHidden(true) -- only allow one visible view
   end
end

--

ItemTrig.UI.WViewHolderView = {}
ItemTrig.UI.WViewHolderView.__index = ItemTrig.UI.WViewHolderView
function ItemTrig.UI.WViewHolderView:install(control)
   if control.widgets and control.widgets.viewHolderView then
      return control.widgets.viewHolderView
   end
   local result = {
      control = control,
      holder  = nil
   }
   setmetatable(result, self)
   local parent  = control:GetParent()
   if parent then
      local widget = ItemTrig.UI.WViewHolder:cast(parent)
      if widget then
         result.holder = widget
         widget:addView(control)
      end
   end
   do -- link the wrapper to the control via an expando property
      if not control.widgets then
         control.widgets = {}
      end
      control.widgets.viewHolderView = result
   end
   return result
end
function ItemTrig.UI.WViewHolderView:cast(control)
   assert(control ~= nil, "Cannot cast a nil control to WViewHolderView.")
   if control.widgets then
      return control.widgets.viewHolderView
   end
   return nil
end
function ItemTrig.UI.WViewHolderView:postInstall()
   local parent = self.control:GetParent()
   if parent then
      local widget = ItemTrig.UI.WViewHolder:cast(parent)
      if widget then
         self.holder = widget
         widget:addView(self.control)
      end
   end
end
function ItemTrig.UI.WViewHolderView:getHolder()
   return self.holder
end
function ItemTrig.UI.WViewHolderView:show()
   if not self.holder then
      d("Warning: A WViewHolderView instance is trying to show itself when it has no WViewHolder.")
      return
   end
   self.holder:setView(self.control)
end