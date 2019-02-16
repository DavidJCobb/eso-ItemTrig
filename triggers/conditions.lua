if not ItemTrig then return end
if not ItemTrig.OpcodeBase then return end

local ItemInterface = ItemTrig.ItemInterface

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
   [4] = ConditionBase:new( -- Stolen
      _s(ITEMTRIG_STRING_CONDITIONNAME_STOLEN),
      _s(ITEMTRIG_STRING_CONDITIONDESC_STOLEN),
      {
         [1] = { type = "boolean", enum = {[1] = _s(ITEMTRIG_STRING_OPCODEARG_STOLEN_NO), [2] = _s(ITEMTRIG_STRING_OPCODEARG_STOLEN_YES)} },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         if args[1] then
            return context.stolen
         end
         return not context.stolen
      end
   ),
   [5] = ConditionBase:new( -- Level
      _s(ITEMTRIG_STRING_CONDITIONNAME_LEVEL),
      _s(ITEMTRIG_STRING_CONDITIONDESC_LEVEL),
      {
         [1] = { type = "quantity" },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         return ItemTrig.testQuantity(args[1], context.level)
      end
   ),
   [6] = ConditionBase:new( -- Rarity
      _s(ITEMTRIG_STRING_CONDITIONNAME_RARITY),
      _s(ITEMTRIG_STRING_CONDITIONDESC_RARITY),
      {
         [1] = {
            type = "quantity",
            enum = {
               [ITEM_QUALITY_TRASH]     = GetString(SI_ITEMQUALITY0),
               [ITEM_QUALITY_NORMAL]    = GetString(SI_ITEMQUALITY1),
               [ITEM_QUALITY_MAGIC]     = GetString(SI_ITEMQUALITY2),
               [ITEM_QUALITY_ARCANE]    = GetString(SI_ITEMQUALITY3),
               [ITEM_QUALITY_ARTIFACT]  = GetString(SI_ITEMQUALITY4),
               [ITEM_QUALITY_LEGENDARY] = GetString(SI_ITEMQUALITY5),
            },
         },
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         return ItemTrig.testQuantity(args[1], context.quality)
      end
   ),
}
ItemTrig.countConditions = table.getn(ItemTrig.tableConditions)
for i = 1, ItemTrig.countConditions do
   ItemTrig.tableConditions[i].opcode = i
end

ItemTrig.TRIGGER_CONDITION_COMMENT = ItemTrig.tableConditions[1]