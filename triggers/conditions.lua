if not ItemTrig then return end
if not ItemTrig.OpcodeBase then return end

local _s = GetString

local ConditionBase = {}
ConditionBase.__index = ConditionBase
function ConditionBase:new(name, formatString, args, func)
   return ItemTrig.OpcodeBase:new(name, formatString, args, func)
end

ItemTrig.Condition = {}
ItemTrig.Condition.__index = ItemTrig.Condition
function ItemTrig.Condition:new(base, args)
   return ItemTrig.Opcode:new(base, args, ItemTrig.tableConditions, "condition")
end

ItemTrig.tableConditions = {
   [1] = ConditionBase:new( -- Comment
      _s(ITEMTRIG_STRING_CONDITIONNAME_COMMENT),
      _s(ITEMTRIG_STRING_CONDITIONDESC_COMMENT),
      {
         [1] = { type = "string", multiline = true, placeholder = _s(ITEMTRIG_STRING_OPCODEARG_PLACEHOLDER_TEXT) },
      },
      function(state, context, args)
         return nil
      end
   ),
   [2] = ConditionBase:new( -- Set And/Or
      _s(ITEMTRIG_STRING_CONDITIONNAME_SETANDOR),
      _s(ITEMTRIG_STRING_CONDITIONDESC_SETANDOR),
      {
         [1] = { type = "boolean", enum = {[1] = _s(ITEMTRIG_STRING_OPCODEARG_SETANDOR_AND), [2] = _s(ITEMTRIG_STRING_OPCODEARG_SETANDOR_OR)} },
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
   [3] = ConditionBase:new( -- Always/Never
      _s(ITEMTRIG_STRING_CONDITIONNAME_ALWAYS),
      _s(ITEMTRIG_STRING_CONDITIONDESC_ALWAYS),
      {
         [1] = { type = "boolean", enum = {[1] = _s(ITEMTRIG_STRING_OPCODEARG_ALWAYS_NEVER), [2] = _s(ITEMTRIG_STRING_OPCODEARG_ALWAYS_ALWAYS)} },
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

ItemTrig.TRIGGER_CONDITION_COMMENT = ItemTrig.tableConditions[1]