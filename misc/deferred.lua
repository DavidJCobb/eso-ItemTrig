if not ItemTrig then return end

--[[--
   A Deferred allows you to defer some operation, or the reaction to some 
   operation, until later; this is useful for when an operation executes 
   asynchronously from its caller, or across multiple call stacks.
   
   One example of a situation where you could use a deferred is the 
   showing of a confirmation dialog, and the performing of an operation 
   if and only if the user clicks "Yes" in that dialog. The dialog can 
   return a Deferred, and "resolve" it if the user clicks "Yes" or 
   "reject" it if the user clicks "No;" the thing that opened the dialog 
   can attach callbacks for each.
   
   A Promise is a read-only Deferred.
--]]--

local DEFERRED_STATE_PENDING  = 0
local DEFERRED_STATE_RESOLVED = 1
local DEFERRED_STATE_REJECTED = 2
local PROMISE_KEY_NAME = " promise"

local Promise = {}
do -- Class definition
   Promise.__index = Promise
   function Promise:new(deferred)
      assert(deferred ~= nil)
      assert(getmetatable(deferred) == ItemTrig.Deferred)
      local result = {
         deferred = deferred
      }
      setmetatable(result, self)
      deferred[PROMISE_KEY_NAME] = result
      return result
   end
   function Promise:done(...)
      assert(self ~= Promise, "This method must be called on an instance.")
      return self.deferred:done(...)
   end
   function Promise:fail(...)
      assert(self ~= Promise, "This method must be called on an instance.")
      return self.deferred:fail(...)
   end
   function Promise:always(...)
      assert(self ~= Promise, "This method must be called on an instance.")
      return self.deferred:always(...)
   end
   function Promise:promise()
      assert(false, "This method must be called on a Deferred, not a Promise.")
   end
   Promise.resolve = Promise.promise
   Promise.reject  = Promise.promise
end
ItemTrig.Promise = Promise

ItemTrig.Deferred = {}
local Deferred = ItemTrig.Deferred
Deferred.__index = Deferred
function Deferred:new()
   local result = {
      state = DEFERRED_STATE_PENDING,
      resolveCallbacks = {},
      rejectCallbacks  = {},
   }
   result[PROMISE_KEY_NAME] = nil
   setmetatable(result, self)
   return result
end
function Deferred:promise()
   assert(self ~= Deferred, "This method must be called on an instance.")
   if self[PROMISE_KEY_NAME] then
      --
      -- Only create one Promise for any given Deferred.
      --
      return self[PROMISE_KEY_NAME]
   end
   return Promise:new(self)
end
function Deferred:done(callback, context)
   assert(self ~= Deferred, "This method must be called on an instance.")
   assert(callback ~= nil,  "You must specify a callback.")
   if self.state ~= DEFERRED_STATE_PENDING then
      if self.state == DEFERRED_STATE_RESOLVED then
         callback(context, self)
      end
      return
   end
   table.insert(self.resolveCallbacks, { func = callback, context = context })
   return self
end
function Deferred:fail(callback, context)
   assert(self ~= Deferred, "This method must be called on an instance.")
   assert(callback ~= nil,  "You must specify a callback.")
   if self.state ~= DEFERRED_STATE_PENDING then
      if self.state == DEFERRED_STATE_REJECTED then
         callback(context, self)
      end
      return
   end
   table.insert(self.rejectCallbacks, { func = callback, context = context })
   return self
end
function Deferred:always(callback, context)
   assert(self ~= Deferred, "This method must be called on an instance.")
   assert(callback ~= nil,  "You must specify a callback.")
   if self.state ~= DEFERRED_STATE_PENDING then
      callback(context, self)
      return
   end
   table.insert(self.resolveCallbacks, { func = callback, context = context })
   table.insert(self.rejectCallbacks,  { func = callback, context = context })
   return self
end
function Deferred:resolve(...)
   if self == Deferred then
      --
      -- Calling resolve on the class returns an already-resolved Deferred. 
      -- Calling it on an instance resolves the instance.
      --
      local instance = self:new()
      instance:resolve(...)
      return instance
   end
   if self.state ~= DEFERRED_STATE_PENDING then
      return
   end
   self.state = DEFERRED_STATE_RESOLVED
   for i = 1, table.getn(self.resolveCallbacks) do
      local meta = self.resolveCallbacks[i]
      meta.func(meta.context, self, ...)
   end
   self.resolveCallbacks = {}
   self.rejectCallbacks  = {}
end
function Deferred:reject(...)
   if self == Deferred then
      --
      -- Calling reject on the class returns an already-rejected Deferred. 
      -- Calling it on an instance rejects the instance.
      --
      local instance = self:new()
      instance:reject(...)
      return instance
   end
   if self.state ~= DEFERRED_STATE_PENDING then
      return
   end
   self.state = DEFERRED_STATE_REJECTED
   for i = 1, table.getn(self.rejectCallbacks) do
      local meta = self.rejectCallbacks[i]
      meta.func(meta.context, self, ...)
   end
   self.resolveCallbacks = {}
   self.rejectCallbacks  = {}
end