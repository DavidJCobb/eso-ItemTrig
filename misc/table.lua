if not ItemTrig then return end

function ItemTrig.assign(tablevar, ...)
   for i = 1, select("#", ...) do
      local other = select(i, ...)
      if other then
         for k, v in pairs(other) do
            tablevar[k] = v
         end
      end
   end
   return tablevar
end
function ItemTrig.assignDeep(tablevar, ...)
   local others = {}
   local count  = 1
   for i = 1, select("#", ...) do
      local other = select(i, ...)
      if other then
         others[count] = ItemTrig.deepCopy(other)
         count = count + 1
      end
   end
   ItemTrig.assign(tablevar, unpack(others))
   return tablevar
end
function ItemTrig.compact(tablevar)
   for i = 1, #tablevar do
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
function ItemTrig.firstKeyIn(tablevar)
   if tablevar[1] then
      return 1
   end
   local lowest = nil
   for k, v in pairs(tablevar) do
      if tonumber(k) then
         k = tonumber(k)
         if lowest == nil then
            lowest = k
         elseif lowest > k then
            lowest = k
         end
      end
   end
   return lowest
end
function ItemTrig.firstIn(tablevar)
   local key = ItemTrig.firstKeyIn(tablevar)
   if key then
      return tablevar[key]
   end
end
function ItemTrig.indexOf(tablevar, e)
   for i = 1, #tablevar do
      if tablevar[i] == e then
         return i
      end
   end
end
function ItemTrig.hasCyclicalReferences(tablevar, options)
   --
   -- NOTE: Function is untested.
   --
   local KEY_IS_WALKED = " cyclical check has walked here " -- spaces in the key name make it unlikely for anyone to use it
   local function _cleanup()
      if options.dontCleanWalked then
         return
      end
      for _, v in pairs(options.walkedList) do
         v[KEY_IS_WALKED] = nil
      end
      tablevar[KEY_IS_WALKED] = nil
   end
   options = ItemTrig.assign(
      {
         honorMetatables = true,  -- NOTE: even if this is true, we don't iterate over __index keys due to Lua limitations
         walkedList      = {},    -- for removing the key
         dontCleanWalked = false, -- for recursive calls, should be true
      },
      options or {}
   )
   local recurseOptions = {
      honorMetatables = options.honorMetatables,
      walkedList      = options.walkedList,
      dontCleanWalked = true
   }
   tablevar[KEY_IS_WALKED] = true
   for k,v in pairs(tablevar) do
      if k ~= KEY_IS_WALKED then
         if not options.honorMetatables then
            v = rawget(tablevar, k)
         end
         if type(v) == "table" then
            if v[KEY_IS_WALKED] then
               _cleanup()
               return true
            end
            v[KEY_IS_WALKED] = true
            table.insert(options.walkedList, v)
            if ItemTrig.hasCyclicalReferences(v, recurseOptions) then
               _cleanup()
               return true
            end
         end
      end
   end
   _cleanup()
   return false
end
function ItemTrig.moveToAfter(tablevar, i, target)
   if i > target then
      target = target + 1
   end
   if target > #tablevar then
      return nil
   end
   local element = tablevar[i]
   table.remove(tablevar, i)
   table.insert(tablevar, target, element)
   return target + 1
end
function ItemTrig.moveToBefore(tablevar, i, target)
   if target < 1 then
      return nil
   end
   local element = tablevar[i]
   if i < target then
      table.remove(tablevar, i)
      table.insert(tablevar, target - 1, element)
      return target - 1
   elseif i > target then
      table.remove(tablevar, i)
      table.insert(tablevar, target, element)
      return target
   end
   return nil
end
function ItemTrig.remove(tablevar, x)
   if type(x) == "number" then -- remove at index
      tablevar[x] = nil
      ItemTrig.compact(tablevar)
   elseif type(x) == "function" then
      local changed = false
      for i = 1, #tablevar do
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
   if i + 1 <= #tablevar then
      ItemTrig.swapIndices(tablevar, i, i + 1)
      return true
   end
   return false
end
function ItemTrig.swapIndices(tablevar, i, j)
   tablevar[i], tablevar[j] = tablevar[j], tablevar[i]
end
function ItemTrig.valuesOverlap(a, b)
   for k, v in pairs(a) do
      for l, w in pairs(b) do
         if v == w then
            return true
         end
      end
   end
   return false
end