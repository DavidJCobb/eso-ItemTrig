if not ItemTrig then return end

local DEFERRED_STATE_PENDING  = 0
local DEFERRED_STATE_RESOLVED = 1
local DEFERRED_STATE_REJECTED = 2

ItemTrig.Deferred = {}
ItemTrig.Deferred.__index = ItemTrig.Deferred
function ItemTrig.Deferred:new()
   local result = {
      state = DEFERRED_STATE_PENDING,
      resolveCallbacks = {},
      rejectCallbacks  = {},
   }
   setmetatable(result, self)
   return result
end
function ItemTrig.Deferred:done(callback, context)
   if self.state ~= DEFERRED_STATE_PENDING then
      if self.state == DEFERRED_STATE_RESOLVED then
         callback(self, context)
         return
      end
      return
   end
   table.insert(self.resolveCallbacks, { func = callback, context = context })
   return self
end
function ItemTrig.Deferred:fail(callback, context)
   if self.state ~= DEFERRED_STATE_PENDING then
      if self.state == DEFERRED_STATE_REJECTED then
         callback(self, context)
         return
      end
      return
   end
   table.insert(self.rejectCallbacks, { func = callback, context = context })
   return self
end
function ItemTrig.Deferred:resolve(...)
   if self.state ~= DEFERRED_STATE_PENDING then
      return
   end
   self.state = DEFERRED_STATE_PENDING
   for i = 1, table.getn(self.resolveCallbacks) do
      local meta = self.resolveCallbacks[i]
      meta.func(meta.context, self, ...)
   end
end
function ItemTrig.Deferred:reject(...)
   if self.state ~= DEFERRED_STATE_PENDING then
      return
   end
   self.state = DEFERRED_STATE_PENDING
   for i = 1, table.getn(self.rejectCallbacks) do
      local meta = self.rejectCallbacks[i]
      meta.func(meta.context, self, ...)
   end
end