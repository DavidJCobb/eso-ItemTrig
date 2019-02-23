if not ItemTrig then return end

ItemTrig.PIXEL = GuiRoot:GetWidth() / tonumber(GetCVar("WindowedWidth"))

function ItemTrig.dispatchEvent(control, eventName, ...)
   assert(control ~= nil, "Cannot dispatch an event to a nil control.")
   local f = control:GetHandler(eventName)
   if f then
      f(control, ...)
   end
end
function ItemTrig.fitHeightToChildren(control, zeroIfNone)
   local count = control:GetNumChildren()
   if count < 1 then
      if zeroIfNone == true or zeroIfNone == nil then
         control:SetHeight(0)
      end
      return
   end
   local height = 0
   for i = 1, count do
      local child = control:GetChild(i)
      if child then
         local h = child:GetHeight()
         if h > height then
            height = h
         end
      end
   end
   control:SetHeight(height)
end
function ItemTrig.fadeToBottom(control, color1, color2)
   assert(control.SetVertexColors ~= nil, "This function can only be called on controls that provide the SetVertexColors method.")
   local edge1 = VERTEX_POINTS_TOPLEFT    + VERTEX_POINTS_TOPRIGHT
   local edge2 = VERTEX_POINTS_BOTTOMLEFT + VERTEX_POINTS_BOTTOMRIGHT
   control:SetVertexColors(edge1, unpack(color1))
   control:SetVertexColors(edge2, unpack(color2))
end
function ItemTrig.offsetLeft(control, basis)
   if not basis then
      basis = control:GetParent()
   end
   if basis then
      return control:GetLeft() - basis:GetLeft()
   else
      return control:GetLeft()
   end
end
function ItemTrig.offsetRight(control, basis)
   if not basis then
      basis = control:GetParent()
   end
   if basis then
      return control:GetRight() - basis:GetLeft()
   else
      return control:GetRight()
   end
end
function ItemTrig.offsetTop(control, basis)
   if not basis then
      basis = control:GetParent()
   end
   if basis then
      return control:GetTop() - basis:GetTop()
   else
      return control:GetTop()
   end
end
function ItemTrig.offsetBottom(control, basis)
   if not basis then
      basis = control:GetParent()
   end
   if basis then
      return control:GetBottom() - basis:GetTop()
   else
      return control:GetBottom()
   end
end
function ItemTrig.registerTrigeditWindowFragment(control)
   local fragment = ZO_SimpleSceneFragment:New(control, "ItemTrigBlockMostKeys")
   ItemTrig.SCENE_TRIGEDIT:AddFragment(fragment)
   SCENE_MANAGER:RegisterTopLevel(control, false)
   return fragment
end

--
-- THEMING HELPERS
--
-- Used in cases where virtual controls can't be relied on because ESO's XML 
-- parser, or its virtual control system, or Dibella only knows what, breaks 
-- for unknown reasons.
--
ItemTrig.theming = {}
function ItemTrig.theming.listBackground(control)
   ItemTrig.fadeToBottom(control, ItemTrig.theme.LIST_BACKGROUND_TOP, ItemTrig.theme.LIST_BACKGROUND_BOTTOM)
end
function ItemTrig.theming.listBorder(control)
   control:SetColor(unpack(ItemTrig.theme.LIST_BORDER))
end
function ItemTrig.theming.listEnd(control)
   ItemTrig.fadeToBottom(control, {0,0,0,0.5}, {0,0,0,0})
end