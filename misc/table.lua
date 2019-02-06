if not ItemTrig then return end

function ItemTrig.assign(tablevar, ...)
   local others = {...}
   for i = 1, table.getn(others) do
      local other = others[i]
      for k, v in pairs(other) do
         tablevar[k] = v
      end
   end
end
function ItemTrig.firstIn(tablevar)
   for i = 1, table.getn(tablevar) do
      if tablevar[i] ~= nil then
         return tablevar[i]
      end
   end
end