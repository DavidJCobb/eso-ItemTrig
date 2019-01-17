if not ItemTrig then return end

local cc_TRIGGER_START    = "$"
local cc_TRIGGER_NAME_END = "<"
local cc_TRIGGER_END      = ">"
local cc_OPCODE_START     = "("
local cc_OPCODE_END       = ")"
local cc_OPCODE_ARG_START = "@"
local cc_OPCODE_ARG_END   = "#"
local cc_COND_LIST_START  = "{"
local cc_ACTN_LIST_START  = "["
local cc_OPCODE_LIST_END  = "}"
local cc_SUBST_TRIG_INDEX = "^"

local allControlCodes = table.concat({
   cc_TRIGGER_START,
   cc_TRIGGER_NAME_END,
   cc_TRIGGER_END,
   cc_OPCODE_START,
   cc_OPCODE_END,
   cc_OPCODE_ARG_START,
   cc_OPCODE_ARG_END,
   cc_COND_LIST_START,
   cc_ACTN_LIST_START,
   cc_OPCODE_LIST_END,
   cc_SUBST_TRIG_INDEX,
}, "")

local pattern_TRIGGER     = "%b" .. cc_TRIGGER_START .. cc_TRIGGER_END
local pattern_TRIGGERNAME = "%b" .. cc_TRIGGER_START .. cc_TRIGGER_NAME_END
local pattern_TRIGGERBODY = "%b" .. cc_TRIGGER_NAME_END .. cc_TRIGGER_END
local pattern_CONDITIONS  = "%b" .. cc_COND_LIST_START .. cc_OPCODE_LIST_END
local pattern_ACTIONS     = "%b" .. cc_ACTN_LIST_START .. cc_OPCODE_LIST_END
local pattern_OPCODE      = "%b" .. cc_OPCODE_START .. cc_OPCODE_END
local pattern_OPCODEARG   = "%b" .. cc_OPCODE_ARG_START  .. cc_OPCODE_ARG_END
local pattern_OPCODEINDEX = "^(%d+)[" .. cc_OPCODE_ARG_START .. cc_OPCODE_END .. "]"

local format_OPCODEARG = cc_OPCODE_ARG_START .. "%s" .. cc_OPCODE_ARG_END

local function toSafeString(s)
   return s:gsub("\\", "\\\\"):gsub("[" .. allControlCodes .. "]", 
      function(c)
         return "\\" .. string.byte(c) .. "%%"
      end
   )
end
local function fromSafeString(s)
   return s:gsub("\\(%d+)", function(substr) return string.char(0 + substr) end):gsub("\\\\", "\\")
end

local function serializeOpcode(o)
   local count = table.getn(o.args)
   if count > 0 then
      local safeArgs = {}
      --
      -- We can't just jam the arguments into a string directly; we 
      -- need to convert them, sanitize them, and so on.
      --
      -- Strings should have any syntax characters for our markup 
      -- escaped. Booleans should be serialized as numbers to save 
      -- on size. Triggers need to actually have their "serialize" 
      -- method called. So on and so forth.
      --
      for i = 1, count do
         safeArgs[i] = o.args[i]
         if type(safeArgs[i]) == "string" then
            safeArgs[i] = toSafeString(tostring(o.args[i]))
         elseif type(safeArgs[i]) == "boolean" then
            safeArgs[i] = tostring(o.args[i] and 1 or 0)
         elseif getmetatable(safeArgs[i]) == ItemTrig.Trigger then
            safeArgs[i] = o.args[i]:serialize( )
         end
         safeArgs[i] = string.format(format_OPCODEARG, safeArgs[i])
      end
      return cc_OPCODE_START .. tostring(o.base.opcode) .. table.concat(safeArgs, "") .. cc_OPCODE_END
   end
   return cc_OPCODE_START .. tostring(o.base.opcode) .. cc_OPCODE_END
end
local function serializeTrigger(t)
   local c = {}
   local a = {}
   for i = 1, table.getn(t.conditions) do
      table.insert(c, t.conditions[i]:serialize())
   end
   for i = 1, table.getn(t.actions) do
      table.insert(a, t.actions[i]:serialize())
   end
   c = table.concat(c, "")
   a = table.concat(a, "")
   return string.format("%s%s%s%s%s%s%s%s%s%s",
      cc_TRIGGER_START, t.name, cc_TRIGGER_NAME_END,
      cc_COND_LIST_START, c, cc_OPCODE_LIST_END,
      cc_ACTN_LIST_START, a, cc_OPCODE_LIST_END,
      cc_TRIGGER_END
   )
end
--
local _Parser = {}
_Parser.__index = _Parser
function _Parser:new()
   local result = {}
   setmetatable(result, self)
   result.currentTrig = ""
   result.triggerList = {}
   result.triggers    = {}
   result.pendingOpcodesWithTriggerArgs = {}
   return result
end
function _Parser:warn(s)
   local cutoff = true
   if s:len() > 200 then
      s = s:sub(1, 200)
   end
   if self.currentTrig == "" then
      d("WARNING: " .. s)
   else
      d("WARNING in trigger " .. self.currentTrig .. ": " .. s)
   end
   if cutoff then
      d("(Previous warning cut off due to length, to mitigate chatbox scrolling bugs.")
   end
end
function _Parser:_parseOpcode(s, opcodeClass)
   if not s:find(cc_OPCODE_ARG_START) then
      --
      -- This opcode has no arguments.
      --
      return opcodeClass:new(0 + s)
   end
   local iOpcode  = 0 + s:match(pattern_OPCODEINDEX)
   local oCurrent = opcodeClass:new(iOpcode)
   local baseArgs = oCurrent.base.args
   local j = 1
   for arg in s:gmatch(pattern_OPCODEARG) do
      arg = arg:sub(2, -2)
      local aType = baseArgs[j].type
      if aType == "string" then
         oCurrent.args[j] = fromSafeString(arg)
      elseif aType == "boolean" then
         --
         -- Booleans should always be serialized as "0" or "1".
         --
         oCurrent.args[j] = false
         if arg ~= "0" then
            oCurrent.args[j] = true
         end
      elseif aType == "number" then
         oCurrent.args[j] = 0 + arg
      elseif aType == "trigger" then
         --
         -- See comments in _Parser:parse.
         --
         if arg:sub(1, 1) == cc_SUBST_TRIG_INDEX then
            table.insert(self.pendingOpcodesWithTriggerArgs, oCurrent) -- inserts a reference, not a copy
            oCurrent.args[j] = 0 + arg:sub(2)
         else
            oCurrent.args[j] = nil
            self:warn("Parsed opcode had a bad trigger code: " .. tostring(arg))
         end
      else
         oCurrent.args[j] = arg
         self:warn("Parsed opcode had an unrecognized argument type " .. tostring(aType))
      end
      j = j + 1
   end
   return oCurrent
end
function _Parser:_parseTrigger(s)
   local t     = ItemTrig.Trigger:new()
   local sTrig = s:match(pattern_TRIGGER) -- don't strip the start and end, or we'll break the trigger-name and trigger-body lines
   t.name      = sTrig:match(pattern_TRIGGERNAME):sub(2, -2)
   self.currentTrig = t.name -- for _Parse:warn
   sTrig       = sTrig:match(pattern_TRIGGERBODY):sub(2, -2)
   local cond  = sTrig:match(pattern_CONDITIONS):sub(2, -2)
   local actn  = sTrig:match(pattern_ACTIONS):sub(2, -2)
   sTrig = nil -- ditch the string ASAP to save memory
   --
   for word in cond:gmatch(pattern_OPCODE) do
      local condition = self:_parseOpcode(word:sub(2, -2), ItemTrig.Condition)
      table.insert(t.conditions, condition)
   end
   cond = nil -- ditch the string ASAP to save memory
   --
   for word in actn:gmatch(pattern_OPCODE) do
      local action = self:_parseOpcode(word:sub(2, -2), ItemTrig.Action)
      table.insert(t.actions, action)
   end
   actn = nil -- ditch the string ASAP to save memory
   --
   self.currentTrig = ""
   return t
end
function _Parser:parse(s)
   --
   -- In order to parse nested structures properly, we have to separate 
   -- them out first; we'll replace nested ones with an index. So if we 
   -- had something like
   --
   --    "trigger{ a; trigger{ b; trigger{} } }"
   --
   -- then we'd end up with a list of
   --
   --    "trigger{}"
   --    "trigger{ b; ^1 }"
   --    "trigger{ a; ^2 }"
   --
   -- and at that point, we can parse each trigger individually, without 
   -- Lua's pattern-matching choking on the nested structures. After all 
   -- parsing is done, we can replace the placeholders (e.g. "^1") with 
   -- references to the parsed triggers.
   --
   self.triggerList = {}
   do
      local start
      local mid
      local last
      start, mid, last = s:match("^(.*)(" .. pattern_TRIGGER .. ")(.*)$")
      while mid do
         table.insert(self.triggerList, mid)
         --
         -- We need to insert triggers in the order we find them (which is 
         -- reverse-order) in order to properly handle nesting; however, 
         -- that means that top-level triggers will be in reverse-order.
         --
         s = start .. cc_SUBST_TRIG_INDEX .. table.getn(self.triggerList) .. last
         start, mid, last = s:match("^(.*)(" .. pattern_TRIGGER .. ")(.*)$")
      end
   end
   for i = 1, table.getn(self.triggerList) do
      self.triggers[i]    = self:_parseTrigger(self.triggerList[i])
      self.triggerList[i] = nil -- free strings as soon as possible to save on memory
   end
   for i = 1, table.getn(self.pendingOpcodesWithTriggerArgs) do
      local c = self.pendingOpcodesWithTriggerArgs[i]
      local baseArgs = c.base.args
      for j = 1, table.getn(c.args) do
         if baseArgs[j].type == "trigger" then
            if type(c.args[j]) == "number" then
               --
               -- We're using self.triggers to keep track of all found triggers, 
               -- including nested ones, but by the time the function ends, we 
               -- want to return just a list of top-level triggers. A nested 
               -- trigger can't be in two places at once, so once we find it, we 
               -- should remove it from self.triggers such that by the end of 
               -- this loop, only top-level triggers are left behind.
               --
               local index = c.args[j]
               c.args[j] = self.triggers[index]
               self.triggers[index] = nil
--CHAT_SYSTEM:AddMessage("Trigger " .. index .. " of " .. table.getn(self.triggers) .. " is nested.")
            end
         end
      end
   end
   do
      --
      -- We need to solve two problems here. First, our top-level triggers are in 
      -- reverse-order. Second, self.triggers has a bunch of nil entries from when 
      -- we handled nested triggers above. We can solve both problems here, by 
      -- inserting the non-nil copies into a new array *and* prepending them 
      -- instead of appending them.
      --
      local final = {}
      for i = 1, table.getn(self.triggers) do
         if self.triggers[i] ~= nil then
--CHAT_SYSTEM:AddMessage("Parse operation completed; found non-nil trigger")
            table.insert(final, 1, self.triggers[i])
         end
      end
      self.triggers = final
   end
   if table.getn(self.triggers) == 1 then
--CHAT_SYSTEM:AddMessage("Parse operation completed; returning a single trigger")
      return self.triggers[1]
   else
--CHAT_SYSTEM:AddMessage("Parse operation completed; returning " .. table.getn(self.triggers) .. " triggers")
      return self.triggers
   end
end

local function parseTrigger(s)
   local parser = _Parser:new()
   return parser:parse(s)
end

function ItemTrig.serializeTrigobject(o)
   local mt = getmetatable(o)
   if mt == ItemTrig.Condition or mt == ItemTrig.Action then
      return serializeOpcode(o)
   elseif mt == ItemTrig.Trigger then
      return serializeTrigger(o)
   end
end
function ItemTrig.parseTrigger(s)
   return parseTrigger(s)
end