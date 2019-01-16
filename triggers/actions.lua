if not ItemTrig then return end

local ActionBase = {}
ActionBase.__index = ActionBase
function ActionBase:new(name, formatString, args, func)
   local result = {}
   setmetatable(result, self)
   result.opcode = nil -- number
   result.name   = name
   result.format = formatString
   result.args   = args or {} -- array
   result.func   = func
   return result
end

ItemTrig.Action = {}
ItemTrig.Action.__index = ItemTrig.Action
function ItemTrig.Action:new(base, args)
   if type(base) == "number" then
      base = ItemTrig.tableActions[base]
   end
   local result = {}
   setmetatable(result, self)
   result.base = base
   result.args = args or {} -- array
   return result
end
function ItemTrig.Action:exec(state, context)
   return self.base.func(state, context, self.args)
end
function ItemTrig.Action:format()
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
         if type(a) == "string" then
            renderArgs[i] = a
         else
            renderArgs[i] = tostring(a)
         end
      else
         renderArgs[i] = a
      end
   end
   return string.format(self.base.format, unpack(renderArgs))
end
function ItemTrig.Action:serialize()
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
         elseif getmetatable(safeArgs[i]) == ItemTrig.Trigger then
            safeArgs[i] = safeArgs[i]:serialize()
         end
      end
      return tostring(self.base.opcode) .. ":" .. table.concat(safeArgs, ",")
   end
   return tostring(self.base.opcode)
   --]]
end

ItemTrig.tableActions = {
   [1] = ActionBase:new("Return", "Stop executing the top-level trigger.",
      {},
      function(state, context, args)
         return ItemTrig.RETURN_FROM_TRIGGER
      end
   ),
   [2] = ActionBase:new("Log Message", "Log a message in the chatbox:\n%s",
      {
         { type = "string", placeholder = "text" }
      },
      function(state, context, args)
         CHAT_SYSTEM:AddMessage(args[1])
      end
   ),
   [3] = ActionBase:new("Run Nested Trigger", "Execute a nested trigger.",
      {
         { type = "trigger" }
      },
      function(state, context, args)
         local r = args[1]:exec(context)
         if r == ItemTrig.RETURN_FROM_TRIGGER then
            return r
         end
      end
   ),
   [4] = ActionBase:new("Comment", "Comment:\n%s",
      {
         { type = "string", placeholder = "text" }
      },
      function(state, context, args)
         return nil
      end
   ),
}
ItemTrig.countActions = table.getn(ItemTrig.tableActions)
for i = 1, ItemTrig.countActions do
   ItemTrig.tableActions[i].opcode = i
end
