if not ItemTrig then return end

local ConditionBase = {}
ConditionBase.__index = ConditionBase
function ConditionBase:new(name, formatString, args, func)
   local result = {}
   setmetatable(result, self)
   result.opcode = nil -- number
   result.name   = name
   result.format = formatString
   result.args   = args or {} -- array
   result.func   = func
   return result
end

ItemTrig.Condition = {}
ItemTrig.Condition.__index = ItemTrig.Condition
function ItemTrig.Condition:new(base, args)
   if type(base) == "number" then
      base = ItemTrig.tableConditions[base]
   end
   local result = {}
   setmetatable(result, self)
   result.base = base
   result.args = args or {} -- array
   return result
end
function ItemTrig.Condition:exec(state, context)
   return self.base.func(state, context, self.args)
end
function ItemTrig.Condition:format()
   local count = table.getn(self.base.args)
   if count == 0 then
      return self.base.format
   end
   local renderArgs = {}
   for i = 1, count do
      local a = self.args[i]
      local p = self.base.args[i].placeholder
      if type(p) == "table" then
         if type(a) == "boolean" then
            renderArgs[i] = p[a and 2 or 1]
         else
            renderArgs[i] = p[a]
         end
      elseif type(p) == "string" then
         renderArgs[i] = p
      else
         renderArgs[i] = a
      end
   end
   return string.format(self.base.format, unpack(renderArgs))
end
function ItemTrig.Condition:serialize()
   return ItemTrig.serializeTrigobject(self)
   --[[
   local count = table.getn(self.args)
   if count > 0 then
      local safeArgs = self.args
      for i = 1, count do
         if type(safeArgs[i]) == "string" then
            safeArgs[i] = string.format("\"%s\"", safeArgs[i]:gsub("\"", "\\\""))
         elseif type(safeArgs[i]) == "boolean" then
            safeArgs[i] = tostring(safeArgs[i] and 1 or 0)
         end
      end
      return tostring(self.base.opcode) .. ":" .. table.concat(safeArgs, ",")
   end
   return tostring(self.base.opcode)
   --]]
end

ItemTrig.tableConditions = {
   [1] = ConditionBase:new("Comment", "Comment:\n%s",
      {
         { type = "string", placeholder = "text" }
      },
      function(state, context, args)
         return nil
      end
   ),
   [2] = ConditionBase:new("Set And/Or", "Switch to using %s to evaluate conditions.",
      {
         { type = "boolean", placeholder = {"AND", "OR"} }
      },
      function(state, context, args)
         if state.using_or == args[1] then
            return nil
         end
         if state.using_or then
            state.using_or = false
            if not state.matched_or then
               --
               -- None of the "OR" conditions matched, so the 
               -- trigger should fail.
               --
               return false
            end
         else
            state.using_or = true
         end
         return nil
      end
   ),
   [3] = ConditionBase:new("Always/Never", "This condition is %s true.",
      {
         { type = "boolean", placeholder = {"never", "always"} }
      },
      function(state, context, args)
         return args[1]
      end
   ),
}
ItemTrig.countConditions = table.getn(ItemTrig.tableConditions)
for i = 1, ItemTrig.countConditions do
   ItemTrig.tableConditions[i].opcode = i
end