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

ItemTrig.OpcodeQuantityArg = {}
ItemTrig.OpcodeQuantityArg.__index = ItemTrig.OpcodeQuantityArg
local OpcodeQuantityArg = ItemTrig.OpcodeQuantityArg
function OpcodeQuantityArg:new(qualifier, number, alternate, base)
   local result = setmetatable({}, self)
   result.qualifier = qualifier or "E" -- string: "E", "GTE", "LTE", "NE"
   result.number    = number    or 0
   result.alternate = alternate -- string; reserved
   result.base      = base      -- base argument
   if alternate and not number then
      result.number = nil
   end
   --
   -- The currently-unused "alternate" field is intended to allow 
   -- the user to specify a computed value for use as the number. 
   -- For example, if the user wants to compare something to the 
   -- current level of their character, you might allow an altern-
   -- ate value such as "PlayerLevel".
   --
   -- If the number is nil, then the alternate will be used.
   --
   return result
end
function OpcodeQuantityArg:test(num)
   local q = self.qualifier
   local n = self.number
   if not n then
      --
      -- TODO: Use the "alternate" field to determine a point 
      -- of comparison. This may require that a "context" 
      -- argument be added to this function. It will also 
      -- likely require that we define a map on the base arg-
      -- ument, i.e.
      --
      --    alternates[KEY] == function(context) return context.someNumber end
      --
      -- and then we
      --
      --    n = self.base.alternates[self.alternate](context)
      --
      -- and fall through.
      --
      return false -- for now
   end
   if q == "E" then -- equal
      return num == n
   elseif q == "GTE" then -- at least
      return num >= n
   elseif q == "LTE" then -- at most
      return num <= n
   elseif q == "NE" then -- not equal
      return num ~= n
   end
   return false
end
function OpcodeQuantityArg:is(obj)
   assert(self == OpcodeQuantityArg, "This method must be called on the class.")
   if type(obj) ~= "table" then
      return false
   end
   return getmetatable(obj) == self
end
function OpcodeQuantityArg:clone()
   local result = OpcodeQuantityArg:new()
   result.qualifier = self.qualifier
   result.number    = self.number
   result.alternate = self.alternate
   result.base      = self.base
   return result
end
function OpcodeQuantityArg:from(tbl, base)
   return self:new(tbl.qualifier, tbl.number, tbl.alternate, base)
end
function OpcodeQuantityArg:isValid()
   local base = self.base
   if not base then
      return true
   end
   local n = self.number
   if not n then
      --
      -- TODO: Validate the "alternate" field against allowed values.
      --
      return false
   end
   if base.enum then
      if not base.enum[n] then
         return false
      end
   end
   if base.min and n < base.min then
      return false
   end
   if base.max and n > base.max then
      return false
   end
   if base.requireInteger then
      if math.floor(n) ~= n then
         return false
      end
   end
   return true
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
      result.deprecated         = extra.deprecated or false -- Indicates that the opcode is deprecated and should not be made available in the UI
      result.explanation        = extra.explanation or nil
      result.neverSkip          = extra.neverSkip or false -- Indicates that a condition shouldn't be skipped when doing short-circuiting for ORs
   end
   return result
end
function ItemTrig.OpcodeBase:allowsEntryPoint(entryPoint)
   local allowed = self.allowedEntryPoints
   if not allowed then
      return true
   end
   return ItemTrig.indexOf(allowed, entryPoint) ~= nil
end
function ItemTrig.OpcodeBase:forEachInArgumentEnum(index, functor)
   local arg      = self.args[tonumber(index)]
   local enum     = arg.enum
   local disabled = arg.disabledEnumIndices
   if arg.enumIsContiguous then
      for k, v in ipairs(enum) do
         if not (disabled and disabled:has(k)) then
            functor(k, v)
         end
      end
   elseif arg.enumSortsByKey then
      local keys = ItemTrig.keysIn(enum)
      table.sort(keys)
      for _, k in ipairs(keys) do
         local v = enum[k]
         if not (disabled and disabled:has(k)) then
            functor(k, v)
         end
      end
   else
      for k, v in pairs(enum) do
         if not (disabled and disabled:has(k)) then
            functor(k, v)
         end
      end
   end
end
function ItemTrig.OpcodeBase:getArgumentArchetype(index)
   local arg = self.args[tonumber(index)]
   if arg.type == "string" then
      if arg.enum then
         return "enum"
      end
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
   elseif arg.type == "signature" then
      return "enum"
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
   elseif t == "list<number>" then
      return {}
   elseif t == "number" then
      if arg.enum then
         return ItemTrig.firstKeyIn(arg.enum) -- defined in /misc/table.lua
      end
      return 0
   elseif t == "quantity" then
      return OpcodeQuantityArg:new()
   elseif t == "signature" then
      return ItemTrig.firstKeyIn(arg.enum) -- defined in /misc/table.lua
   elseif t == "sound" then
      return "NONE"
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
      
      list<number>
         An array of numbers.
      
      number
      
      quantity
         A table with fields "qualifier" and "number." The qualifier 
         must be one of the following strings representing a relational 
         operator: "GTE" "LTE" "E"
         
         The number is a point of comparison to which that relational 
         operator is applied. For example, the quantity represented as 
         "GTE 5" or "at least 5" would match numbers 5 and above.
      
      signature
         A value stored as a string, but only alterable as an enum.
      
      sound
         The ID of a sound, i.e. given SOUNDS.WHATEVER it'd be "WHATEVER".
      
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
      
      list<number>
         The argument values are treated as keys in the enum; the corres-
         ponding values in the enum are what is shown.
      
      number
         The argument value is treated as a key in the enum; the corres-
         ponding value in the enum is what is shown.
      
      quantity
         The enum limits the allowed "number" values.
      
      signature
         The argument value is treated as a key in the enum; the corres-
         ponding value in the enum is what is shown.
      
      string
         The argument value is treated as a key in the enum; the corres-
         ponding value in the enum is what is shown.
   
   ARGUMENT EXTRA FIELDS
   
      allowedEntryPoints
         An array of entry points. If the opcode is used in a trigger 
         that doesn't run on one of these entry points, then the argument 
         will not be shown as configurable in the UI; it'll be plain-text 
         and non-alterable.
         
         This is enforced by UI code.
      
      autocompleteSet
         If the argument is a string, then this field can be used to 
         define autocomplete entries in the UI. If the field is a table, 
         then its values will be the autocomplete entries. If the field 
         is a function, then it will be called when the UI needs it; if 
         it returns a table, then that table's values will be the auto-
         complete entries (this allows for lazy initialization when 
         dealing with particularly large sets).
         
         Note that ItemTrig offers a userpref to globally disable auto-
         complete, and I intend to have that default to "disable it" 
         until I figure out how to theme ZO_AutoComplete or else make 
         my own replacement for it.
      
      disabled
         If this is truthy, then the argument will not be shown as config-
         urable in the UI; it'll be plain-text and non-alterable. Useful 
         for dummying out work-in-progress functionality.
         
         This is enforced by Opcode:format.
      
      disabledEnumIndices
         This should be an instant of Set whose entries are indices in the 
         argument's enum. These indices will be hidden from the UI -- that 
         is, users will not be able to select them. Useful for dummying out 
         work-in-progress functionality.
         
         This is enforced by OpcodeBase:forEachInArgumentEnum.\
      
      doNotSortEnum
         If this is set to true, then the argument's enum won't be sorted 
         in the UI. This will not work properly unless (enumIsContiguous) 
         is also set.
      
      enumIsContiguous
         If the argument's enum uses a contiguous range of integer keys 
         starting at 1 (i.e. if it's an array), then you can set this to 
         true. This will change how OpcodeBase:forEachInArgumentEnum 
         iterates over the enum (using ipairs instead of pairs). The main 
         use of this field is to allow (doNotSortEnum) to work properly.
      
      enumSortsByKey
         If specified, then OpcodeBase:forEachInArgumentEnum will sort the 
         enum's keys before iterating over them. Don't use this alongside 
         (doNotSortEnum) or (enumIsContiguous); the UI already checks for 
         this and declines to do its own sorting.
      
      explanation
         Text explaining the meaning of the argument. The UI can display it 
         when the user is editing the argument's value.
      
      max
         If this number is specified, then the argument's value will not be 
         considered valid if it is above this number.
         
         Only valid for number and quantity arguments.
      
      min
         If this number is specified, then the argument's value will not be 
         considered valid if it is below this number.
         
         Only valid for number and quantity arguments.
      
      requireInteger
         If this field is truthy, then the argument's value will not be 
         considered valid if it is a non-integer number.
         
         Only valid for number and quantity arguments.
   
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
   if base then -- correct quantity arguments
      --
      -- Quantity arguments can be passed in as OpcodeQuantityArg instances 
      -- or as tables. Either way, we at the very least need to correct the 
      -- OpcodeQuantityArg::base field, so we may as well allow and handle 
      -- bare tables.
      --
      local a = result.args
      local b = result.base.args
      for i = 1, #a do
         if b.type == "quantity" then
            if OpcodeQuantityArg:is(a) then
               a.base = b[i]
            else
               if type(a) == "table" then
                  local number    = a.number
                  local qualifier = a.qualifier or "E"
                  local alternate = a.alternate
                  result.args[i] = OpcodeQuantityArg:new(qualifier, number, alternate, b[i])
               end
            end
         end
      end
   end
   do -- setup default argument values
      local specified = args and #args or 0
      local count     = #base.args
      if specified < count then
         for i = specified + 1, count do
            result.args[i] = base:getArgumentDefaultValue(i)
         end
      end
   end
   return result
end
function ItemTrig.Opcode:allowsEntryPoint(...)
   if not self.base then
      return false
   end
   return self.base:allowsEntryPoint(...)
end
function ItemTrig.Opcode:clone(deep)
   local result = {}
   setmetatable(result, getmetatable(self))
   result.base = self.base
   result.args = {}
   result.type = self.type
   do -- clone args
      local baseArgs = self.base.args
      for i = 1, #self.args do
         local a = self.args[i]
         if type(a) == "table" then
            if baseArgs[i].type == "trigger" then
               if deep then
                  result.args[i] = a:clone()
               else
                  result.args[i] = a
               end
            elseif baseArgs[i].type == "list<number>" then
               result.args[i] = ItemTrig.assign({}, a)
            elseif baseArgs[i].type == "quantity" then
               if OpcodeQuantityArg:is(a) then
                  result.args[i] = a:clone()
               else
                  result.args[i] = OpcodeQuantityArg:from(a, self.base)
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
      for i = 1, #other.args do
         local a = other.args[i]
         if type(a) == "table" then
            local baseType = self.base.args[i].type
            if baseType == "trigger" then
               self.args[i] = a:clone()
            elseif baseType == "quantity" then
               if OpcodeQuantityArg:is(a) then
                  self.args[i] = a:clone()
               else
                  self.args[i] = OpcodeQuantityArg:from(a, self.base)
               end
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
   for i = 1, #self.base.args do
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
   for i = 1, #baseArgs do
      self.args[i] = self.base:getArgumentDefaultValue(i)
   end
end
function ItemTrig.Opcode:exec(state, context)
   return self.base.func(state, context, self.args)
end
function ItemTrig.Opcode:format(argTransform, fmtTransform)
   local count = #self.base.args
   if count == 0 then
      if fmtTransform then
         return fmtTransform(self.base.format)
      end
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
      elseif t == "list<number>" then
         renderArgs[i] = "<list...>"
         local items = a or {}
         if b.enum then
            items = {}
            for k, v in ipairs(a or {}) do
               local entry = b.enum[v]
               if type(entry) == "function" then
                  entry = entry(v)
               end
               if not entry then
                  entry = ZO_LocalizeDecimalNumber(v or 0)
               end
               items[k] = entry
            end
         end
         renderArgs[i] = ZO_GenerateCommaSeparatedList(items)
      elseif t == "number" then
         if b.enum then
            renderArgs[i] = b.enum[a]
            if type(renderArgs[i]) == "function" then
               renderArgs[i] = renderArgs[i](a)
            end
            if not renderArgs[i] then
               renderArgs[i] = ZO_LocalizeDecimalNumber(a or 0)
            end
         else
            renderArgs[i] = ZO_LocalizeDecimalNumber(a or 0)
         end
      elseif t == "quantity" then
         if not a then
            renderArgs[i] = GetString(ITEMTRIG_STRING_OPCODEARG_PLACEHOLDER_QUANTITY)
         else
            local format
            local number
            if b.enum then
               number = b.enum[a.number]
               if type(number) == "function" then
                  number = number(a.number)
               end
               if not number then
                  number = ZO_LocalizeDecimalNumber(a.number or 0)
               end
            else
               number = ZO_LocalizeDecimalNumber(a.number or 0)
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
      elseif t == "signature" then
         assert(b.enum ~= nil, "Signature arguments must use enums.")
         renderArgs[i] = b.enum[a]
      elseif t == "sound" then
         local key = "ITEMTRIG_SOUND_" .. tostring(a)
         local s   = GetString(_G[key])
         if s and s ~= "" then
            renderArgs[i] = s
         else
            s = tostring(a)
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
   local fmt = self.base.format
   if fmtTransform then
      fmt = fmtTransform(fmt)
   end
   return LocalizeString(fmt, unpack(renderArgs))
end
function ItemTrig.Opcode:serialize()
   return ItemTrig.serializeTrigobject(self)
end
function ItemTrig.Opcode:validateArgs()
   local count = #self.base.args
   for i = 1, count do
      local a = self.args[i]
      local b = self.base.args[i]
      local t = b.type
      if t == "boolean" then
         if a ~= true and a ~= false then
            return false, i, ItemTrig.OPCODE_ARGUMENT_INVALID_WRONG_TYPE
         end
      elseif t == "list<number>" then
         if type(a) ~= "table" then
            return false, i, ItemTrig.OPCODE_ARGUMENT_INVALID_WRONG_TYPE
         end
         for k, v in pairs(a) do
            if type(v) ~= "number" and not tonumber(v) then
               return false, i, ItemTrig.OPCODE_ARGUMENT_INVALID_BAD_VALUE
            end
            if b.enum then
               if not b.enum[v] then
                  return false, i, ItemTrig.OPCODE_ARGUMENT_INVALID_BAD_VALUE
               end
               local dei = b.disabledEnumIndices
               if dei and dei:has(tonumber(v)) then
                  return false, i, ItemTrig.OPCODE_ARGUMENT_INVALID_BAD_VALUE
               end
            end
         end
      elseif t == "number" then
         if type(a) ~= "number" and not tonumber(a) then
            return false, i, ItemTrig.OPCODE_ARGUMENT_INVALID_WRONG_TYPE
         end
         if b.enum then
            if not b.enum[a] then
               return false, i, ItemTrig.OPCODE_ARGUMENT_INVALID_BAD_VALUE
            end
            local dei = b.disabledEnumIndices
            if dei and dei:has(tonumber(a)) then
               return false, i, ItemTrig.OPCODE_ARGUMENT_INVALID_BAD_VALUE
            end
         else
            if b.min and a < b.min then
               return false, i, ItemTrig.OPCODE_ARGUMENT_INVALID_BAD_VALUE
            end
            if b.max and a > b.max then
               return false, i, ItemTrig.OPCODE_ARGUMENT_INVALID_BAD_VALUE
            end
            if b.requireInteger and math.floor(a) ~= a then
               return false, i, ItemTrig.OPCODE_ARGUMENT_INVALID_BAD_VALUE
            end
         end
      elseif t == "quantity" then
         if not OpcodeQuantityArg:is(a) then
            return false, i, ItemTrig.OPCODE_ARGUMENT_INVALID_WRONG_TYPE
         end
         if not a:isValid() then
            return false, i, ItemTrig.OPCODE_ARGUMENT_INVALID_BAD_VALUE
         end
      elseif t == "signature" then
         if type(a) ~= "string" then
            return false, i, ItemTrig.OPCODE_ARGUMENT_INVALID_WRONG_TYPE
         end
         if a:len() ~= 4 then
            return false, i, ItemTrig.OPCODE_ARGUMENT_INVALID_BAD_VALUE
         end
      elseif t == "sound" then
         if type(a) ~= "string" then
            return false, i, ItemTrig.OPCODE_ARGUMENT_INVALID_WRONG_TYPE
         end
         if not SOUNDS[a] then
            return false, i, ItemTrig.OPCODE_ARGUMENT_INVALID_BAD_VALUE
         end
      elseif t == "string" then
         if type(a) ~= "string" then
            return false, i, ItemTrig.OPCODE_ARGUMENT_INVALID_WRONG_TYPE
         end
      elseif t == "trigger" then
         if not ItemTrig.Trigger:is(a) then
            return false, i, ItemTrig.OPCODE_ARGUMENT_INVALID_WRONG_TYPE
         end
      else
         return false, i, ItemTrig.OPCODE_ARGUMENT_INVALID_UNKNOWN_TYPE
      end
   end
   return true
end