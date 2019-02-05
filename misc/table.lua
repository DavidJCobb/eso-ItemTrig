if not ItemTrig then return end

function ItemTrig.firstIn(tablevar)
   for i = 1, table.getn(tablevar) do
      if tablevar[i] ~= nil then
         return tablevar[i]
      end
   end
end