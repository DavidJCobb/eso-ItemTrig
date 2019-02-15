if not ItemTrig then return end
if not ItemTrig.OpcodeBase then return end

local _s = GetString

local ActionBase = {}
ActionBase.__index = ActionBase
function ActionBase:new(name, formatString, args, func)
   return ItemTrig.OpcodeBase:new(name, formatString, args, func)
end

ItemTrig.Action = {}
ItemTrig.Action.__index = ItemTrig.Action
function ItemTrig.Action:new(base, args)
   return ItemTrig.Opcode:new(base, args, ItemTrig.tableActions, "action")
end

ItemTrig.tableActions = {
   [1] = ActionBase:new( -- Return
      _s(ITEMTRIG_STRING_ACTIONNAME_RETURN),
      _s(ITEMTRIG_STRING_ACTIONDESC_RETURN),
      {},
      function(state, context, args)
         return ItemTrig.RETURN_FROM_TRIGGER
      end
   ),
   [2] = ActionBase:new( -- Log Message
      _s(ITEMTRIG_STRING_ACTIONNAME_LOG),
      _s(ITEMTRIG_STRING_ACTIONDESC_LOG),
      {
         [1] = { type = "string", placeholder = _s(ITEMTRIG_STRING_OPCODEARG_PLACEHOLDER_TEXT) },
      },
      function(state, context, args)
         CHAT_SYSTEM:AddMessage(args[1])
      end
   ),
   [3] = ActionBase:new( -- Run Nested Trigger
      _s(ITEMTRIG_STRING_ACTIONNAME_RUNNESTED),
      _s(ITEMTRIG_STRING_ACTIONDESC_RUNNESTED),
      {
         [1] = { type = "trigger" },
      },
      function(state, context, args)
         local r = args[1]:exec(context)
         if r == ItemTrig.RETURN_FROM_TRIGGER then
            return r
         end
      end
   ),
   [4] = ActionBase:new( -- Comment
      _s(ITEMTRIG_STRING_ACTIONNAME_COMMENT),
      _s(ITEMTRIG_STRING_ACTIONDESC_COMMENT),
      {
         [1] = { type = "string", multiline = true, placeholder = _s(ITEMTRIG_STRING_OPCODEARG_PLACEHOLDER_TEXT) },
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

ItemTrig.TRIGGER_ACTION_COMMENT    = ItemTrig.tableActions[4]
ItemTrig.TRIGGER_ACTION_RUN_NESTED = ItemTrig.tableActions[3]
