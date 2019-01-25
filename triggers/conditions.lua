if not ItemTrig then return end
if not ItemTrig.OpcodeBase then return end

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
   [1] = ConditionBase:new("Comment", "Comment:\n%s",
      {
         [1] = { type = "string", placeholder = "text" },
      },
      function(state, context, args)
         return nil
      end
   ),
   [2] = ConditionBase:new("Set And/Or", "Switch to using %s to evaluate conditions.",
      {
         [1] = { type = "boolean", placeholder = {"AND", "OR"} },
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
         [1] = { type = "boolean", placeholder = {"never", "always"} },
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