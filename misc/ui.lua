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