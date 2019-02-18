if not ItemTrig then return end

function ItemTrig.testQuantity(quantity, number)
   local q = quantity.qualifier
   local n = quantity.number
   if q == "E" then
      return number == n
   elseif q == "GTE" then -- at least
      return number >= n
   elseif q == "LTE" then -- at most
      return number <= n
   elseif q == "NE" then
      return number ~= n
   end
   return false
end

ItemTrig.OpcodeBase = {}
ItemTrig.OpcodeBase.__index = ItemTrig.OpcodeBase
function ItemTrig.OpcodeBase:new(name, formatString, args, func, extra)
   local result = {}
   setmetatable(result, self)
   result.opcode = nil -- number
   result.name   = name
   result.format = formatString
   result.args   = args or {} -- array
   result.func   = func
   do -- extra-data
      if not extra then
         extra = {}
      end
      result.allowedEntryPoints = extra.allowedEntryPoints or nil -- nil == no limit; else, array
      result.explanation        = extra.explanation or nil
   end
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
   elseif arg.type == "quantity" then
      if arg.enum then
         return "quantity-enum"
      end
      return arg.type
   else
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
         return ItemTrig.firstKeyIn(arg.enum) -- defined in /misc/table.lua
      end
      return 0
   elseif t == "quantity" then
      return {
         qualifier = "E",
         number    = 0
      }
   elseif t == "string" then
      if arg.enum then
         return ItemTrig.firstKeyIn(arg.enum) -- defined in /misc/table.lua
      end
      return ""
   elseif t == "trigger" then
      return ItemTrig.Trigger:new()
   end
   do -- log error
      local eIndex = tostring(tonumber(index))
      if type(index) ~= "number" then
         eIndex = eIndex .. " (specified as " .. tostring(index) .. ")"
      end
      local eOpcode = self.name
      if type(self.opcode) == "number" then
         eOpcode = "#" .. string.format("%d (%s)", self.opcode, eOpcode)
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
   presented with a combobox. The "enum" field should be a table; the 
   allowed values should be the keys, and the displayed values (i.e. 
   friendly names) should be their values.
   
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
         The enum limits the allowed "number" values.
      
      string
         This type cannot have an enum.
   
   ARGUMENT EXTRA FIELDS
   
      allowedEntryPoints
         An array of entry points. If the opcode is used in a trigger 
         that doesn't run on one of these entry points, then the argument 
         will not be shown as configurable in the UI; it'll be plain-text 
         and non-alterable.
         
         This is enforced by UI code.
      
      disabled
         If this is truthy, then the argument will not be shown as config-
         urable in the UI; it'll be plain-text and non-alterable. Useful 
         for dummying out work-in-progress functionality.
         
         This is enforced by Opcode:format.
   
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
            elseif baseArgs[i].type == "quantity" then
               result.args[i] = {
                  qualifier = a.qualifier,
                  number    = a.number,
               }
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
            elseif self.base.args[i].type == "quantity" then
               self.args[i] = {
                  qualifier = a.qualifier,
                  number    = a.number,
               }
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
function ItemTrig.Opcode:isArgumentEffortful(i, change)
   --
   -- If passed a parameter, (change), then it checks whether (change) 
   -- represents an effortful change to the value of the argument (change 
   -- would be the potential new value).
   --
   local b = self.base.args[i]
   local a = self.args[i]
   if b.type == "string" then
      if change then
         if a ~= change and change ~= "" then
            return true
         end
      else
         if a ~= "" then
            return true
         end
      end
   end
   --
   -- TODO: Once we figure something out for editing nested triggers, we'll 
   -- want to revisit this.
   --
   return false
end
function ItemTrig.Opcode:isEffortful()
   for i = 1, table.getn(self.base.args) do
      if self:isArgumentEffortful(i) then
         return true
      end
   end
   return false
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
            if not renderArgs[i] then
               renderArgs[i] = ZO_LocalizeDecimalNumber(a)
            end
         else
            renderArgs[i] = ZO_LocalizeDecimalNumber(a)
         end
      elseif t == "quantity" then
         if not a then
            renderArgs[i] = GetString(ITEMTRIG_STRING_OPCODEARG_PLACEHOLDER_QUANTITY)
         else
            local format
            local number
            if b.enum then
               number = b.enum[a.number]
               if not number then
                  number = ZO_LocalizeDecimalNumber(a.number)
               end
            else
               number = ZO_LocalizeDecimalNumber(a.number)
            end
            if a.qualifier == "GTE" then
               format = GetString(ITEMTRIG_STRING_QUALIFIER_ATLEAST)
            elseif a.qualifier == "LTE" then
               format = GetString(ITEMTRIG_STRING_QUALIFIER_ATMOST)
            elseif a.qualifier == "E" then
               format = GetString(ITEMTRIG_STRING_QUALIFIER_EXACTLY)
            elseif a.qualifier == "NE" then
               format = GetString(ITEMTRIG_STRING_QUALIFIER_NOTEQ)
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
      elseif t == "trigger" then
         renderArgs[i] = a.name
         if not a.name or a.name == "" then
            renderArgs[i] = GetString(ITEMTRIG_STRING_DEFAULT_TRIGGER_NAME)
         end
      else
         renderArgs[i] = tostring(a)
      end
      if argTransform and not b.disabled then
         renderArgs[i] = argTransform(renderArgs[i] or "[error]", i)
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