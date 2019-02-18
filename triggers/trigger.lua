if not ItemTrig then return end

function ItemTrig.executeTriggerList(list, entryPoint, context)
   if entryPoint then
      list = ItemTrig.filterTriggerList(list, entryPoint)
   end
   for i = 1, table.getn(list) do
      local result, extra = list[i]:exec(context, entryPoint)
      if result == ItemTrig.OPCODE_FAILED then
         d("Failed to execute an opcode.")
         d(extra)
         return result, extra
      end
      if context:isInvalid() then -- NOTE: Assumes context instanceof ItemInterface
         break
      end
   end
end
function ItemTrig.filterTriggerList(list, entryPoint)
   local filtered = {}
   local mapping  = {} -- list[mapping[i]] == filtered[i]
   for i = 1, table.getn(list) do
      local trigger = list[i]
      if ItemTrig.indexOf(trigger.entryPoints, entryPoint) then
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
      local allowed = opcode.allowedEntryPoints
      if allowed then
         names = {}
         for i = 1, table.getn(allowed) do
            local name = ItemTrig.ENTRY_POINT_NAMES[allowed[i]] or "???"
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
      matched_or = false
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
   for i = 1, table.getn(self.conditions) do
      result.conditions[i] = self.conditions[i]:clone(deep)
   end
   for i = 1, table.getn(self.actions) do
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
      for i = 1, table.getn(other.conditions) do
         self.conditions[i] = other.conditions[i]:clone(deep)
      end
      for i = 1, table.getn(other.actions) do
         self.actions[i] = other.actions[i]:clone(deep)
      end
   else
      self.conditions = other.conditions
      self.actions    = other.actions
      self.state      = other.state
   end
end
function ItemTrig.Trigger:getDescription()
   --
   -- If a trigger's first condition or action is a comment, then 
   -- that comment can be used as a trigger description.
   --
   if table.getn(self.conditions) > 0 then
      local c = self.conditions[1]
      if c.base == ItemTrig.TRIGGER_CONDITION_COMMENT then
         if c.args[1] ~= "" then
            return c.args[1]
         end
      end
   end
   if table.getn(self.actions) > 0 then
      local a = self.actions[1]
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
   CHAT_SYSTEM:AddMessage("== Printing trigger " .. self.name .. "...")
   CHAT_SYSTEM:AddMessage("= Conditions")
   for i = 1, table.getn(self.conditions) do
      CHAT_SYSTEM:AddMessage("   " .. self.conditions[i]:format())
   end
   CHAT_SYSTEM:AddMessage("= Actions")
   for i = 1, table.getn(self.actions) do
      CHAT_SYSTEM:AddMessage("   " .. self.actions[i]:format())
   end
end
function ItemTrig.Trigger:exec(context, entryPoint)
--CHAT_SYSTEM:AddMessage("== Executing trigger " .. self.name .. "...") -- debug
   if not self.enabled then
      return false
   end
   self.state.using_or   = false
   self.state.matched_or = false
   self.state.entryPoint = entryPoint or nil
   for i = 1, table.getn(self.conditions) do
      local c = self.conditions[i]
      if entryPoint and not c:allowsEntryPoint(entryPoint) then
         return ItemTrig.OPCODE_FAILED, { opcode = c, why = _formatOpcodeEPMismatch(c) }
      end
      if c.never_skip or not (self.state.using_or and self.state.matched_or) then
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
         if not (r == nil) then
            if r == ItemTrig.OPCODE_FAILED then
               --
               -- TODO: option to log when a trigger halts due to a failed 
               -- opcode. The (extra) variable should be a table that *may* 
               -- have a "why" field whose string value is a human-readable 
               -- clarification on why the opcode failed.
               --
               r = false
               return r, extra
            end
            --
            -- If a condition returns nil, then we don't treat it as true 
            -- or false, and we just continue down the condition list.
            --
            if self.state.using_or then
               if r then
                  self.state.matched_or = true
               end
            elseif not r then
               return false
            end
         end
      end
   end
   if self.state.using_or then
      if not self.state.matched_or then
         return false
      end
   end
   --
   -- All conditions matched.
   --
   for i = 1, table.getn(self.actions) do
      local a = self.actions[i]
      if entryPoint and not a:allowsEntryPoint(entryPoint) then
         return ItemTrig.OPCODE_FAILED, { opcode = a, why = _formatOpcodeEPMismatch(c) }
      end
      local r, extra = a:exec(self.state, context)
      if r == ItemTrig.RETURN_FROM_TRIGGER then
         return r
      end
      if r == ItemTrig.OPCODE_FAILED then
         --
         -- TODO: option to log when a trigger halts due to a failed opcode. 
         -- The (extra) variable should be a table that *may* have a "why" 
         -- field whose string value is a human-readable clarification on 
         -- why the opcode failed.
         --
         return r, extra
      end
   end
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
function ItemTrig.Trigger:serialize()
   return ItemTrig.serializeTrigobject(self)
end