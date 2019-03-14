if not ItemTrig then return end

function ItemTrig.executeTriggerList(list, entryPoint, context, options)
   if not options then
      options = {
         --
         -- OPTION: eventRecipient
         --
         -- A struct; if the following member functions exist, they will 
         -- be called as appropriate:
         --
         -- thiscall onTriggerFail(trigger, details)
         -- thiscall onTriggerMiss(trigger, details)
         --
         eventRecipient   = nil,
         --
         -- OPTION: stripBadTriggers
         --
         -- If this option is true, then triggers will be removed from the 
         -- trigger list if they fail due to having an opcode with an in-
         -- compatible entry point, or due to having an opcode that fails 
         -- run-time validation.
         --
         -- This option was implemented in order to prevent log spam when 
         -- a trigger fails for these reasons. Some of our trigger entry 
         -- points involve us running a trigger list on every item in the 
         -- player's inventory, which means that without this option, a 
         -- trigger failing for these reasons would log an error for every 
         -- single item the player is carrying. With this option, it logs 
         -- once, and we then decline to execute it until the next entry 
         -- point.
         --
         -- Note that this option WILL modify the list you pass in as an 
         -- argument (which is how the skipping even works), so you should 
         -- pass a copy of the original trigger list (i.e. don't pass a 
         -- direct reference to the user's savedata) if you're using it.
         --
         stripBadTriggers = false,
      }
   end
   local eventRecipient = options.eventRecipient
   if entryPoint then
      local filtered = ItemTrig.filterTriggerList(list, entryPoint)
      if options.stripBadTriggers then
         --
         -- Normally, it'd be sufficient to just overwrite (list) with the 
         -- return value of the (filterTriggerList) call. However, this 
         -- doesn't work with the (stripBadTriggers) option.
         --
         ItemTrig.overwriteTable(list, filtered)
      else
         list = filtered
      end
   end
   for i = 1, #list do
      local trigger = list[i]
      if trigger then
         if eventRecipient then
            eventRecipient.topLevelTrigger = list[i]
         end
         local result, extra = trigger:exec(context, entryPoint, options)
         if result == ItemTrig.RUN_NO_MORE_TRIGGERS then
            return result
         end
         if options.stripBadTriggers then
            if result == ItemTrig.WRONG_ENTRY_POINT
            or result == ItemTrig.OPCODE_INVALID
            then
               list[i] = nil
            end
         end
         if context:isInvalid() then -- NOTE: Assumes context instanceof ItemInterface
            break
         end
      end
   end
   if eventRecipient then
      eventRecipient.topLevelTrigger = nil
   end
end
function ItemTrig.filterTriggerList(list, entryPoint)
   assert(list, "You must specify a list.")
   local filtered = {}
   local mapping  = {} -- list[mapping[i]] == filtered[i]
   for i = 1, #list do
      local trigger = list[i]
      if trigger:allowsEntryPoint(entryPoint) then
         table.insert(filtered, trigger)
         table.insert(mapping,  i)
      end
   end
   return filtered, mapping
end

local function _formatOpcodeEPMismatch(opcode)
   local s = ""
   if opcode.type == "action" then
      s = GetString(ITEMTRIG_STRING_ERROR_ACTION_ENTRYPOINT_LIMIT)
   elseif opcode.type == "condition" then
      s = GetString(ITEMTRIG_STRING_ERROR_CONDITION_ENTRYPOINT_LIMIT)
   end
   local names = ""
   do
      local allowed = opcode.base.allowedEntryPoints
      if allowed then
         names = {}
         for i = 1, #allowed do
            names[#names + 1] = ItemTrig.ENTRY_POINT_NAMES[allowed[i]] or "???"
         end
         names = table.concat(names, ", ")
      end
   end
   return zo_strformat(s, names)
end

ItemTrig.Trigger = {}
ItemTrig.Trigger.__index = ItemTrig.Trigger
function ItemTrig.Trigger:new()
   local result = {}
   setmetatable(result, self)
   result.name        = GetString(ITEMTRIG_STRING_DEFAULT_TRIGGER_NAME)
   result.enabled     = true
   result.entryPoints = {}
   result.conditions  = {} -- array
   result.actions     = {} -- array
   result.state = {
      using_or   = false,
      matched_or = false,
      log_a_miss = false,
   }
   return result
end
function ItemTrig.Trigger:clone(deep)
   --
   -- If (deep) is truthy, then nested triggers are also cloned; 
   -- otherwise, actions that have nested triggers will contain 
   -- references to the original trigger.
   --
   -- The serialization code can't account for a trigger being in 
   -- two places at once; the trigger will end up duplicated when 
   -- you save and load. Shallow cloning should only be used for 
   -- cases like copying a trigger for UI-related purposes, i.e. 
   -- an editor that only commits changes if you click "OK" or 
   -- something.
   --
   if deep == nil then -- default arg
      deep = true
   end
   local result = {}
   setmetatable(result, getmetatable(self))
   result.name        = self.name
   result.enabled     = self.enabled
   result.entryPoints = self.entryPoints
   result.conditions  = {} -- array
   result.actions     = {} -- array
   result.state = {
      using_or   = false,
      matched_or = false,
      entryPoint = nil,
   }
   for i = 1, #self.conditions do
      result.conditions[i] = self.conditions[i]:clone(deep)
   end
   for i = 1, #self.actions do
      result.actions[i] = self.actions[i]:clone(deep)
   end
   return result
end
function ItemTrig.Trigger:copyAssign(other, deep)
   --
   -- Overwrite a trigger with another trigger; use in places 
   -- where you need to replace a trigger that you have a ref-
   -- erence to (i.e. simply using the "=" operator would 
   -- replace the variable rather than overwriting what it 
   -- pointed to).
   --
   self.name        = other.name
   self.enabled     = other.enabled or false
   self.entryPoints = other.entryPoints or {}
   if deep then
      ZO_ClearNumericallyIndexedTable(self.conditions)
      ZO_ClearNumericallyIndexedTable(self.actions)
      --
      for i = 1, #other.conditions do
         self.conditions[i] = other.conditions[i]:clone(deep)
      end
      for i = 1, #other.actions do
         self.actions[i] = other.actions[i]:clone(deep)
      end
   else
      self.conditions = other.conditions
      self.actions    = other.actions
      self.state      = other.state
   end
end
function ItemTrig.Trigger:allowsEntryPoint(entryPoint)
   return not not ItemTrig.indexOf(self.entryPoints, entryPoint)
end
function ItemTrig.Trigger:getDescription()
   --
   -- If a trigger's first condition or action is a comment, then 
   -- that comment can be used as a trigger description.
   --
   local c = self.conditions[1]
   if c then
      if c.base == ItemTrig.TRIGGER_CONDITION_COMMENT then
         if c.args[1] ~= "" then
            return c.args[1]
         end
      end
   end
   local a = self.actions[1]
   if a then
      if a.base == ItemTrig.TRIGGER_ACTION_COMMENT then
         if a.args[1] ~= "" then
            return a.args[1]
         end
      end
   end
   return ""
end
function ItemTrig.Trigger:is(obj)
   assert(self == ItemTrig.Trigger, "This method must be called on the class.")
   return getmetatable(obj) == self
end
function ItemTrig.Trigger:debugDump()
   d("== Printing trigger " .. self.name .. "...")
   d("= Conditions")
   for i = 1, #self.conditions do
      d("   " .. self.conditions[i]:format())
   end
   d("= Actions")
   for i = 1, #self.actions do
      d("   " .. self.actions[i]:format())
   end
end
function ItemTrig.Trigger:exec(context, entryPoint, options)
   local function _logMiss(opcode, index, extra)
      local recipient = self.state.options.eventRecipient
      if not (recipient and recipient.onTriggerMiss) then
         return
      end
      local details = extra
      if type(extra) ~= "table" then
         details = { data = extra }
      end
      details.context = context
      details.opcode  = opcode
      details.index   = index
      recipient:onTriggerMiss(self, details)
   end
   local function _logFailure(opcode, index, extra)
      local recipient = self.state.options.eventRecipient
      if not (recipient and recipient.onTriggerFail) then
         return
      end
      if opcode.base == ItemTrig.TRIGGER_ACTION_RUN_NESTED then
         --
         -- This opcode isn't the one that failed. It was an opcode inside 
         -- of the nested trigger, and we will already have signalled that 
         -- failure.
         --
         return
      end
      local details = extra
      if type(extra) ~= "table" then
         details = { data = extra }
      end
      details.context = context
      details.opcode  = opcode
      details.index   = index
      recipient:onTriggerFail(self, details)
   end
   local function _validateOpcodeArgs(opcode)
      local result, index, code = opcode:validateArgs()
      if not result then
         local extra = { code = code }
         if code == ItemTrig.OPCODE_ARGUMENT_INVALID_WRONG_TYPE then
            extra.why = GetString(ITEMTRIG_STRING_ERROR_ACTION_ARGUMENT_TYPE_ERROR)
         elseif code == ItemTrig.OPCODE_ARGUMENT_INVALID_BAD_VALUE then
            extra.why = GetString(ITEMTRIG_STRING_ERROR_ACTION_ARGUMENT_VALUE_ERROR)
         elseif code == ItemTrig.OPCODE_ARGUMENT_INVALID_UNKNOWN_TYPE then
            extra.why = GetString(ITEMTRIG_STRING_ERROR_ACTION_ARGUMENT_TYPE_UNKNOWN)
         end
         return false, extra
      end
      return true
   end
   --
   if not self.enabled then
      return false
   end
   if not options then
      options = {}
   end
   --
   self.state.using_or   = false
   self.state.matched_or = false
   self.state.entryPoint = entryPoint or nil
   self.state.log_a_miss = false
   self.state.options    = options
   for i = 1, #self.conditions do
      local c = self.conditions[i]
      if entryPoint and not c:allowsEntryPoint(entryPoint) then
         local extra = { opcode = c, why = _formatOpcodeEPMismatch(c) }
         _logFailure(c, i, extra)
         self:resetRuntimeState()
         return ItemTrig.WRONG_ENTRY_POINT, extra
      end
      if c.base.neverSkip or not (self.state.using_or and self.state.matched_or) then
         do -- Validation.
            local result, extra = _validateOpcodeArgs(c)
            if not result then
               _logFailure(c, i, extra)
               self:resetRuntimeState()
               return ItemTrig.OPCODE_INVALID, extra
            end
         end
         --
         -- Short-circuit evaluation for ORs:
         --
         -- If we're testing conditions as an OR list, and we've already 
         -- matched one condition, then don't bother running any more 
         -- unless they're flagged as "never skip." The main purpose of 
         -- the "never skip" flag is to avoid skipping the condition that 
         -- switches us between OR and AND.
         --
         local r, extra = c:exec(self.state, context)
         if r == nil then
            --
            -- If a condition returns nil, then we don't treat it as true 
            -- or false, and we just continue down the condition list. We 
            -- mainly use this for conditions that alter processing logic 
            -- or set processing flags.
            --
            if extra == ItemTrig.PLEASE_LOG_TRIG_MISS then
               --
               -- A condition has asked that we log a detailed message if 
               -- the rest of the trigger's conditions end up not matching.
               --
               self.state.log_a_miss = true
            end
         else
            if r == ItemTrig.OPCODE_FAILED then
               _logFailure(c, i, extra)
               self:resetRuntimeState()
               return false, extra
            end
            if self.state.using_or then
               if r then
                  self.state.matched_or = true
               end
            elseif not r then
               --
               -- Condition didn't match, and we're using AND.
               --
               if self.state.log_a_miss then
                  local code = (extra == ItemTrig.NO_OR_CONDITIONS_HIT) and extra or nil
                  _logMiss(c, i, { code = code })
               end
               self:resetRuntimeState()
               return false
            end
         end
      end
   end
   if self.state.using_or then
      if not self.state.matched_or then
         if self.state.log_a_miss then
            _logMiss(nil, nil, { code = ItemTrig.NO_OR_CONDITIONS_HIT })
         end
         self:resetRuntimeState()
         return false
      end
   end
   --
   -- All conditions matched.
   --
   for i = 1, #self.actions do
      local a = self.actions[i]
      if entryPoint and not a:allowsEntryPoint(entryPoint) then
         local extra = { opcode = a, why = _formatOpcodeEPMismatch(a) }
         _logFailure(a, i, extra)
         self:resetRuntimeState()
         return ItemTrig.WRONG_ENTRY_POINT, extra
      end
      do -- Validation.
         local result, extra = _validateOpcodeArgs(a)
         if not result then
            _logFailure(a, i, extra)
            self:resetRuntimeState()
            return ItemTrig.OPCODE_INVALID, extra
         end
      end
      local r, extra = a:exec(self.state, context)
      if r == ItemTrig.RETURN_FROM_TRIGGER or r == ItemTrig.RUN_NO_MORE_TRIGGERS then
         self:resetRuntimeState()
         return r
      end
      if r == ItemTrig.OPCODE_FAILED then
         _logFailure(a, i, extra)
         self:resetRuntimeState()
         return r, extra
      end
      if r == ItemTrig.WRONG_ENTRY_POINT then
         --
         -- This error occurred in a nested trigger, and should already 
         -- have been reported.
         --
         self:resetRuntimeState()
         return r, extra
      end
   end
   self:resetRuntimeState()
   return true
end
function ItemTrig.Trigger:insertActionAfter(opcode, index)
   if index then
      table.insert(self.actions, index + 1, opcode)
   else
      table.insert(self.actions, opcode)
   end
end
function ItemTrig.Trigger:insertConditionAfter(opcode, index)
   if index then
      table.insert(self.conditions, index + 1, opcode)
   else
      table.insert(self.conditions, opcode)
   end
end
function ItemTrig.Trigger:resetRuntimeState()
   self.state.using_or   = false
   self.state.matched_or = false
   self.state.entryPoint = nil
   self.state.log_a_miss = false
   self.state.options    = nil
end
function ItemTrig.Trigger:serialize()
   return ItemTrig.serializeTrigobject(self)
end