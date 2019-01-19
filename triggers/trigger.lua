if not ItemTrig then return end

ItemTrig.Trigger = {}
ItemTrig.Trigger.__index = ItemTrig.Trigger
function ItemTrig.Trigger:new()
   local result = {}
   setmetatable(result, self)
   result.name        = ""
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
function ItemTrig.Trigger:exec(context)
--CHAT_SYSTEM:AddMessage("== Executing trigger " .. self.name .. "...") -- debug
   self.state.using_or   = false
   self.state.matched_or = false
   for i = 1, table.getn(self.conditions) do
      local c = self.conditions[i]
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
--CHAT_SYSTEM:AddMessage(c:format()) -- debug
         local r = c:exec(self.state, context)
         if not (r == nil) then
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
--else CHAT_SYSTEM:AddMessage("Condition skipped, since the OR matched") -- debug
      end
   end
--CHAT_SYSTEM:AddMessage("== Trigger conditions matched.") -- debug
   --
   -- All conditions matched.
   --
   for i = 1, table.getn(self.actions) do
      local a = self.actions[i]
--CHAT_SYSTEM:AddMessage(a:format()) -- debug
      local r = a:exec(self.state, context)
      if r == ItemTrig.RETURN_FROM_TRIGGER then
--CHAT_SYSTEM:AddMessage("== Early return from trigger " .. self.name .. ".") -- debug
         return r
      end
   end
--CHAT_SYSTEM:AddMessage("== All triggers executed.") -- debug
   return true
end
function ItemTrig.Trigger:serialize()
   return ItemTrig.serializeTrigobject(self)
end