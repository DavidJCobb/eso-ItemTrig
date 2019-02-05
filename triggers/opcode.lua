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
function ItemTrig.OpcodeBase:getArgumentArchetype(index)
   local arg = self.args[tonumber(index)]
   if arg.type == "string" then
      if arg.multiline then
         return "multiline"
      end
      return "string"
   elseif arg.type == "boolean" then
      if arg.enum then
         return "enum"
      end
      return "checkbox"
   elseif arg.type == "number" then
      if arg.enum then
         return "enum"
      end
      return arg.type
   else
      --
      -- "quantity"
      --
      return arg.type
   end
end
function ItemTrig.OpcodeBase:getArgumentDefaultValue(index)
   local arg = self.args[tonumber(index)]
   assert(arg ~= nil, "Invalid argument index.")
   if arg.default ~= nil then
      return arg.default
   end
   local t = arg.type
   if t == "boolean" then
      return false
   elseif t == "number" then
      if arg.enum then
         return ItemTrig.firstIn(arg.enum) -- defined in /misc/table.lua
      end
      return 0
   elseif t == "quantity" then
      return {
         qualifier = "E",
         number    = 0
      }
   elseif t == "string" then
      if arg.enum then
         return ItemTrig.firstIn(arg.enum) -- defined in /misc/table.lua
      end
      return ""
   end
   do -- log error
      local eIndex = tostring(tonumber(index))
      if type(index) ~= "number" then
         eIndex = eIndex .. " (specified as " .. tostring(index) .. ")"
      end
      local eOpcode = self.name
      if type(self.opcode) == "number" then
         eOpcode = string.format("%#%d (%s)", self.opcode, eOpcode)
      end
      assert(false,
         string.format(
            "ItemTrig.OpcodeBase:getArgumentDefaultValue choked on opcode %s argument %s with type %s.",
            eOpcode,
            eIndex,
            tostring(t)
         )
      )
   end
end

--[[--
   ARGUMENTS
   
   Argument types determine what kind of value an opcode can have, where-
   as argument archetypes determine how that value is displayed to the 
   user and made available for editing. These are the available argument 
   types:
      
      boolean
      
      number
      
      quantity
         A table with fields "qualifier" and "number." The qualifier 
         must be one of the following strings representing a relational 
         operator: "GTE" "LTE" "E"
         
         The number is a point of comparison to which that relational 
         operator is applied. For example, the quantity represented as 
         "GTE 5" or "at least 5" would match numbers 5 and above.
      
      string
         The argument may have an additional field, "multiline," which 
         is a boolean indicating whether the user should be presented 
         with a multi-line textbox when editing the value. If this field 
         is not present, it defaults to false.
         
         The argument may have an additional field, "placeholder," which 
         is shown to the user if the argument is an empty string.
   
   Any argument can have a "default" field, which indicates the default 
   value for the argument when creating an opcode through the UI.
   
   Most arguments can have an additional field, "enum," which can be used 
   to restrict the range of available values and determine how those 
   values are displayed. When the user edits an enum option, they will be 
   presented with a combobox. The "enum" field should be a table.
   
   Enum behavior varies for some types:
   
      boolean
         The [1] key in the enum is the display text for false values, 
         and the [2] key in the enum is the display text for true.
         
         If the enum object has a "checkboxText" field whose value is a 
         string, then when the user edits the argument, they will be 
         presented with an appropriately labeled checkbox rather than a 
         combobox; the enum's [1] and [2] keys will still be used when 
         formatting the argument for display in any other context.
      
      number
         The argument value is treated as a key in the enum; the corres-
         ponding value in the enum is what is shown.
      
      quantity
         This type cannot have an enum.
      
      string
         This type cannot have an enum.
   
--]]--

ItemTrig.Opcode = {}
ItemTrig.Opcode.__index = ItemTrig.Opcode
function ItemTrig.Opcode:new(base, args, opTable, opType)
   if type(base) == "number" then
      base = opTable[base]
   end
   local result = {}
   setmetatable(result, self)
   result.base = base
   result.args = args or {} -- array
   result.type = opType
   return result
end
function ItemTrig.Opcode:clone(deep)
   local result = {}
   setmetatable(result, getmetatable(self))
   result.base = self.base
   result.args = {}
   result.type = self.type
   do -- clone args
      local baseArgs = self.base.args
      for i = 1, table.getn(self.args) do
         local a = self.args[i]
         if type(a) == "table" then
            if baseArgs[i].type == "trigger" then
               if deep then
                  result.args[i] = a:clone()
               else
                  result.args[i] = a
               end
            else
               d("ItemTrig WARNING: Problem encountered when cloning opcode: unhandled table type.")
            end
         else
            result.args[i] = a
         end
      end
   end
   return result
end
function ItemTrig.Opcode:copyAssign(other, deep)
   assert(other, "Cannot copy-assign from nil.")
   self.base = other.base
   self.type = other.type
   if deep then
      ZO_ClearNumericallyIndexedTable(self.args)
      --
      for i = 1, table.getn(other.args) do
         local a = other.args[i]
         if type(a) == "table" then
            if self.base.args[i].type == "trigger" then
               self.args[i] = a:clone()
            else
               self.args[i] = a
            end
         else
            self.args[i] = other.args[i]
         end
      end
   else
      self.args = other.args
   end
end
function ItemTrig.Opcode:resetArgs()
   if self.base == nil then
      self.args = {}
      return
   end
   self.args = {}
   local baseArgs = self.base.args
   for i = 1, table.getn(baseArgs) do
      self.args[i] = self.base:getArgumentDefaultValue(i)
   end
end
function ItemTrig.Opcode:exec(state, context)
   return self.base.func(state, context, self.args)
end
function ItemTrig.Opcode:format(argTransform)
   local count = table.getn(self.base.args)
   if count == 0 then
      return self.base.format
   end
   local renderArgs = {}
   for i = 1, count do
      local a = self.args[i]
      local b = self.base.args[i]
      local t = b.type
      if t == "boolean" then
         if b.enum then
            renderArgs[i] = b.enum[a and 2 or 1]
         else
            renderArgs[i] = tostring(a)
         end
      elseif t == "number" then
         if b.enum then
            renderArgs[i] = b.enum[a]
         else
            renderArgs[i] = ZO_LocalizeDecimalNumber(a)
         end
      elseif t == "quantity" then
         if not a then
            renderArgs[i] = GetString(ITEMTRIG_STRING_OPCODEARG_PLACEHOLDER_QUANTITY)
         else
            local format
            local number = ZO_LocalizeDecimalNumber(a.number)
            if a.qualifier == "GTE" then
               format = GetString(ITEMTRIG_STRING_QUALIFIER_ATLEAST)
            elseif a.qualifier == "LTE" then
               format = GetString(ITEMTRIG_STRING_QUALIFIER_ATMOST)
            elseif a.qualifier == "E" then
               format = GetString(ITEMTRIG_STRING_QUALIFIER_EXACTLY)
            else
               format = GetString(ITEMTRIG_STRING_QUALIFIER_INVALID)
            end
            renderArgs[i] = string.format(format, number)
         end
      elseif t == "string" then
         if (not a) or a == "" then
            renderArgs[i] = b.placeholder or ""
         else
            renderArgs[i] = tostring(a)
         end
      else
         renderArgs[i] = tostring(a)
      end
      if argTransform then
         renderArgs[i] = argTransform(renderArgs[i], i)
      end
   end
   --
   -- LocalizeString is a Zenimax-provided native method. The zo_strformat 
   -- function is a wrapper for it that does type-checking on the arguments 
   -- it receives (primarily to handle numbers); since we're using Zenimax's 
   -- functions for decimal numbers anyway, we don't need to bother using 
   -- the wrapper.
   --
   return LocalizeString(self.base.format, unpack(renderArgs))
end
function ItemTrig.Opcode:serialize()
   return ItemTrig.serializeTrigobject(self)
end