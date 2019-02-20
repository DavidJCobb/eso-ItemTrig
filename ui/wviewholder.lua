if not (ItemTrig and ItemTrig.UI) then return end

--[[--
   WVIEWHOLDER and WVIEWHOLDERVIEW
   
   These are convenience classes for managing the visibility of multiple mutually-
   exclusive "views" within a single context (the "view holder").
--]]--

ItemTrig.UI.WViewHolder = ItemTrig.UI.WidgetClass:makeSubclass("WViewHolder", "viewHolder")
function ItemTrig.UI.WViewHolder:_construct()
   local control = self:asControl()
   self.views    = {}  -- view control list
   self.selected = nil -- view control
   for i = 1, control:GetNumChildren() do
      --
      -- controls run OnInitialized in order of inner first, outer last, so 
      -- the only way to link views to their holder is via the holder's init 
      -- routine; consequently, a view must be the direct child of its holder
      --
      self:addView(control:GetChild(i)) -- addView returns silently if the control is not a WViewHolderView
   end
end
function ItemTrig.UI.WViewHolder:setView(control)
   if type(control) == "number" then
      control = self:asControl():GetChild(control)
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
      for i = 1, #self.views do
         self.views[i]:SetHidden(true)
      end
   end
   control:SetHidden(false)
   self.selected = control
end
function ItemTrig.UI.WViewHolder:viewByName(name)
   local c = GetControl(self:asControl(), name)
   if not c then
      return nil
   end
   return ItemTrig.UI.WViewHolderView:cast(c)
end
function ItemTrig.UI.WViewHolder:hasView(control)
   for i = 1, #self.views do
      if self.views[i] == control then
         return true
      end
   end
   return false
end
function ItemTrig.UI.WViewHolder:addView(control)
   local view = ItemTrig.UI.WViewHolderView:cast(control)
   if not view then
      return
   end
   if self:hasView(control) then
      return
   end
   assert(view.holder == nil, "Cannot re-parent a WViewHolderView.")
   table.insert(self.views, control)
   view.holder = self
   if not self.selected then
      if not control:IsHidden() then
         self.selected = control
      end
   elseif not control:IsHidden() then
      control:SetHidden(true) -- only allow one visible view
   end
end

--

ItemTrig.UI.WViewHolderView = ItemTrig.UI.WidgetClass:makeSubclass("WViewHolderView", "viewHolderView")
function ItemTrig.UI.WViewHolderView:_construct()
   local control = self:asControl()
   self.holder = nil -- WViewHolder
   local parent = control:GetParent()
   if parent then
      local widget = ItemTrig.UI.WViewHolder:cast(parent)
      if widget then
         widget:addView(control)
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
   self.holder:setView(self:asControl())
end