if not ItemTrig then return end

ItemTrig.OpcodeBase = {}
ItemTrig.OpcodeBase.__index = ItemTrig.OpcodeBase
function ItemTrig.OpcodeBase:new(name, formatString, args, func)
   local result = {}
   setmetatable(result, self)
   result.opcode = nil -- number
   result.name   = name
   result.format = formatString
   result.args   = args or {} -- array
   result.func   = func
   return result
end

ItemTrig.Opcode = {}
ItemTrig.Opcode.__index = ItemTrig.Opcode
function ItemTrig.Opcode:new(base, args, opTable)
   if type(base) == "number" then
      base = opTable[base]
   end
   local result = {}
   setmetatable(result, self)
   result.base = base
   result.args = args or {} -- array
   return result
end
function ItemTrig.Opcode:exec(state, context)
   return self.base.func(state, context, self.args)
end
function ItemTrig.Opcode:format()
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
function ItemTrig.Opcode:serialize()
   return ItemTrig.serializeTrigobject(self)
end