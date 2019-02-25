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
   
   Callbacks receive whatever arguments the Deferred is resolved or 
   rejected with. If you specify a "context" when registering a callback, 
   then that will be passed as the first argument (before the resolve/
   reject arguments); this is intended to allow the use of instance 
   methods that need to be thiscall'd as callbacks:
   
      MyThing = {}
      function MyThing:method()
      end
      
      myDeferred:done(MyThing.method, MyThing)
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
   function Promise:isPending(...)
      assert(self ~= Promise, "This method must be called on an instance.")
      return self.deferred:isPending(...)
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
      results          = {},
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
function Deferred:all(...)
   assert(self == Deferred, "This method must be called on the class.")
   --
   local KEY       = " countResolved"
   local aggregate = Deferred:new()
   local count     = select("#", ...)
   local failed    = false
   local results   = {}
   local validIndex = 1
   local validCount = 0
   if count == 0 then
      return self:resolve():promise()
   end
   local function _onSingleDone(index, ...)
      if failed then
         return
      end
      results[index] = {...}
      aggregate[KEY] = (aggregate[KEY] or 0) + 1
      if aggregate[KEY] == validCount then
         aggregate:resolve(results)
      end
   end
   local function _onSingleFail(index, ...)
      failed = true
      aggregate:reject(...)
   end
   for i = 1, count do
      local single = select(i, ...)
      if single then
         single:done(_onSingleDone, validIndex)
         single:fail(_onSingleFail, validIndex)
         validIndex = validIndex + 1
         validCount = validCount + 1
      end
   end
   if validCount == 0 then
      aggregate:resolve()
   end
   return aggregate:promise()
end
function Deferred:done(callback, context)
   assert(self ~= Deferred, "This method must be called on an instance.")
   assert(callback ~= nil,  "You must specify a callback.")
   if self.state ~= DEFERRED_STATE_PENDING then
      if self.state == DEFERRED_STATE_RESOLVED then
         if context then
            callback(context, unpack(self.results))
         else
            callback(unpack(self.results))
         end
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
         if context then
            callback(context, unpack(self.results))
         else
            callback(unpack(self.results))
         end
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
      if context then
         callback(context, unpack(self.results))
      else
         callback(unpack(self.results))
      end
      return
   end
   table.insert(self.resolveCallbacks, { func = callback, context = context })
   table.insert(self.rejectCallbacks,  { func = callback, context = context })
   return self
end
function Deferred:isPending()
   assert(self ~= Deferred, "This method must be called on an instance.")
   return self.state == DEFERRED_STATE_PENDING
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
   self.state   = DEFERRED_STATE_RESOLVED
   self.results = {...}
   for i = 1, #self.resolveCallbacks do
      local meta = self.resolveCallbacks[i]
      if meta.context == nil then
         meta.func(...)
      else
         meta.func(meta.context, ...)
      end
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
   self.state   = DEFERRED_STATE_REJECTED
   self.results = {...}
   for i = 1, #self.rejectCallbacks do
      local meta = self.rejectCallbacks[i]
      if meta.context == nil then
         meta.func(...)
      else
         meta.func(meta.context, ...)
      end
   end
   self.resolveCallbacks = {}
   self.rejectCallbacks  = {}
end