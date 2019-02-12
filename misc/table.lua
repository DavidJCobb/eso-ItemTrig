if not ItemTrig then return end

function ItemTrig.assign(tablevar, ...)
   local others = {...}
   for i = 1, table.getn(others) do
      local other = others[i]
      if other then
         for k, v in pairs(other) do
            tablevar[k] = v
         end
      end
   end
   return tablevar
end
function ItemTrig.assignDeep(tablevar, ...)
   local others = {...}
   for i = 1, table.getn(others) do
      if others[i] then
         others[i] = ItemTrig.deepCopy(others[i])
      end
   end
   ItemTrig.assign(tablevar, unpack(others))
   return tablevar
end
function ItemTrig.compact(tablevar)
   for i = 1, table.getn(tablevar) do
      if tablevar[i] == nil then
         tablevar[i] = tablevar[i + 1]
         tablevar[i + 1] = nil
      end
   end
end
function ItemTrig.deepCopy(tablevar)
   assert(type(tablevar) ~= "userdata", "This function can't deep-copy a control.")
   if type(tablevar) ~= "table" then
      return tablevar
   end
   local result = {}
   for k, _ in pairs(tablevar) do
      local v = rawget(tablevar, k)
      if type(v) == "table" then
         result[k] = ItemTrig.deepCopy(v)
      else
         result[k] = v
      end
   end
   setmetatable(result, getmetatable(tablevar))
   return result
end
function ItemTrig.firstIn(tablevar)
   for i = 1, table.getn(tablevar) do
      if tablevar[i] ~= nil then
         return tablevar[i]
      end
   end
end
function ItemTrig.indexOf(tablevar, e)
   for i = 1, table.getn(tablevar) do
      if tablevar[i] == e then
         return i
      end
   end
end
function ItemTrig.remove(tablevar, x)
   if type(x) == "number" then -- remove at index
      tablevar[x] = nil
      ItemTrig.compact(tablevar)
   elseif type(x) == "function" then
      local changed = false
      for i = 1, table.getn(tablevar) do
         local test = x(i, tablevar[i])
         if test then
            changed = true
            tablevar[i] = nil
         end
      end
      if changed then
         ItemTrig.compact(tablevar)
      end
   end
end
function ItemTrig.swapBackward(tablevar, i)
   if i - 1 > 0 then
      ItemTrig.swapIndices(tablevar, i, i - 1)
      return true
   end
   return false
end
function ItemTrig.swapForward(tablevar, i)
   if i + 1 <= table.getn(tablevar) then
      ItemTrig.swapIndices(tablevar, i, i + 1)
      return true
   end
   return false
end
function ItemTrig.swapIndices(tablevar, i, j)
   tablevar[i], tablevar[j] = tablevar[j], tablevar[i]
end