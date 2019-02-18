ItemTrig.Set = {}
local Set = ItemTrig.Set
Set.meta = {
   __add =
      function(x)
         if type(x) == "number" then
            self:insert(x)
            return self
         end
         return self:union(x)
      end,
   __index = Set,
}
function Set:new(array)
   local result = {}
   setmetatable(result, self.meta)
   if array then
      for _, v in pairs(array) do
         result:insert(v)
      end
   end
   return result
end
function Set:assign(other)
   assert(self ~= Set,   "This method must be called on an instance.")
   assert(Set:is(other), "Cannot complement a Set with a non-Set.")
   self:clear()
   for k in pairs(other) do
      self[k] = true
   end
end
function Set:clear()
   assert(self ~= Set, "This method must be called on an instance.")
   for k in pairs(self) do
      self[k] = nil
   end
end
function Set:clone()
   assert(self ~= Set, "This method must be called on an instance.")
   local result = Set:new()
   self:forEach(function(i) result:insert(i) end)
   return result
end
function Set:complement(other) -- "the relative complement of other in self"
   --
   -- Returns a Set consisting of all members of self that are not also 
   -- members of other.
   --
   assert(self ~= Set,   "This method must be called on an instance.")
   assert(Set:is(other), "Cannot complement a Set with a non-Set.")
   local result = Set:new()
   for k in pairs(self) do
      result[k] = (self[k] and not other[k]) or nil
   end
   return result
end
function Set:empty()
   assert(self ~= Set, "This method must be called on an instance.")
   for k in pairs(self) do
      return false
   end
   return true
end
function Set:equal(other)
   assert(self ~= Set,   "This method must be called on an instance.")
   if other == nil then
      return false
   end
   assert(Set:is(other), "Cannot compare a Set to a non-Set.")
   for k in pairs(self) do
      if not other[k] then
         return false
      end
   end
   for k in pairs(other) do
      if not self[k] then
         return false
      end
   end
   return true
end
function Set:first()
   assert(self ~= Set, "This method must be called on an instance.")
   for k in pairs(self) do
      return k
   end
   return nil
end
function Set:forEach(functor)
   assert(self ~= Set, "This method must be called on an instance.")
   for k in pairs(self) do
      if self[k] then
         if functor(k) then
            break
         end
      end
   end
end
function Set:has(item)
   assert(self ~= Set, "This method must be called on an instance.")
   assert(type(item) == "number", "Items must be numeric.")
   return self[item]
end
function Set:insert(item)
   assert(self ~= Set, "This method must be called on an instance.")
   if Set:is(item) then
      for k, v in pairs(item) do
         self[k] = v or nil
      end
      return
   end
   assert(type(item) == "number", "You can only insert numbers or Sets (which are unioned).")
   self[item] = true
end
function Set:intersection(other)
   assert(self ~= Set, "This method must be called on an instance.")
   assert(Set:is(other), "Cannot intersect a Set with a non-Set.")
   local result = Set:new()
   for k, _ in pairs(self) do
      result[k] = other[k]
   end
   for k, _ in pairs(other) do
      result[k] = self[k]
   end
   return result
end
function Set:is(instance) -- static method
   assert(self == Set, "This method must be called on the class.")
   return getmetatable(instance) == Set.meta
end
function Set:map(x, y)
   --
   -- If (x) is an array, then for each index (i) in the set, push (x[i]) 
   -- onto a new array and return the new array.
   --
   -- If (x) is a function, then for each index (i) in the set, call x(i); 
   -- if the result is non-nil or if (y) is truthy, then push the result 
   -- onto a new array; return the new array. Here, (y) is a switch to 
   -- control whether we want to save even a returned nil.
   --
   assert(self ~= Set, "This method must be called on an instance.")
   if type(x) == "function" then
      local results = {}
      self:forEach(function(i)
         local result = x(i)
         if y or result ~= nil then
            table.insert(results, result)
         end
      end)
      return results
   end
   assert(type(x) == "table", "This method must be given an array or a function.")
   local results = {}
   self:forEach(function(i)
      if x[i] ~= nil then
         table.insert(results, x[i])
      end
   end)
   return results
end
function Set:remove(item)
   assert(self ~= Set, "This method must be called on an instance.")
   if Set:is(item) then
      for k, v in pairs(item) do
         self[k] = nil
      end
      return
   end
   assert(type(item) == "number", "You can only insert numbers or Sets (which are unioned).")
   self[item] = nil
end
function Set:toArray()
   assert(self ~= Set, "This method must be called on an instance.")
   local result = {}
   for k in pairs(self) do
      table.insert(result, k)
   end
   return result
end
function Set:union(other)
   assert(self ~= Set,   "This method must be called on an instance.")
   assert(Set:is(other), "Cannot union a Set with a non-Set.")
   local result = Set:new()
   for k in pairs(self) do
      result[k] = true
   end
   for k in pairs(other) do
      result[k] = true
   end
   return result
end