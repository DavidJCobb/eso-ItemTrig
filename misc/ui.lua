if not ItemTrig then return end

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
function ItemTrig.offsetLeft(control)
   local parent = control:GetParent()
   if parent then
      return control:GetLeft() - parent:GetLeft()
   else
      return control:GetLeft()
   end
end
function ItemTrig.offsetRight(control)
   local parent = control:GetParent()
   if parent then
      return control:GetRight() - parent:GetLeft()
   else
      return control:GetRight()
   end
end
function ItemTrig.offsetTop(control)
   local parent = control:GetParent()
   if parent then
      return control:GetTop() - parent:GetTop()
   else
      return control:GetTop()
   end
end
function ItemTrig.offsetBottom(control)
   local parent = control:GetParent()
   if parent then
      return control:GetBottom() - parent:GetTop()
   else
      return control:GetBottom()
   end
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
   ItemTrig.fadeToBottom(control, {0,0,0,1}, {0.01, 0.01, 0.01, 0.95})
end