if not ItemTrig then return end
if not ItemTrig.OpcodeBase then return end

local ItemInterface = ItemTrig.ItemInterface

local _s = GetString

local ActionBase = {}
ActionBase.__index = ActionBase
function ActionBase:new(name, formatString, args, func, extra)
   return ItemTrig.OpcodeBase:new(name, formatString, args, func, extra)
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
         local text = args[1] or ""
         if ItemInterface:is(context) then -- transform text
            --
            -- TODO: Find a way to document this in the UI. We should add 
            -- an "explanation" key to the arg, and the opcode-arg editor 
            -- should show that as plain text below the textbox.
            --
            text = string.gsub(text, "$%(name%)",  context.name)
            text = string.gsub(text, "$%(price%)", context.sellValue)
         end
         CHAT_SYSTEM:AddMessage(text)
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
   [5] = ActionBase:new( -- Destroy Item
      _s(ITEMTRIG_STRING_ACTIONNAME_DESTROYITEM),
      _s(ITEMTRIG_STRING_ACTIONDESC_DESTROYITEM),
      {
         [1] = {
            type = "boolean",
            enum = {
               [1] = _s(ITEMTRIG_STRING_OPCODEARG_DESTROYITEM_WHOLESTACK),
               [2] = _s(ITEMTRIG_STRING_OPCODEARG_DESTROYITEM_ONLYADDED),
            },
            default  = false,
            --disabled = true, -- until we get it working
            allowedEntryPoints = { ItemTrig.ENTRY_POINT_ITEM_ADDED },
         }
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         if context:isInvalid() then
            return ItemTrig.OPCODE_FAILED, {}
         end
         local count = nil
         if state.entryPoint == ItemTrig.ENTRY_POINT_ITEM_ADDED then
            if args[1] then
               count = context.entryPointData.countAdded or 0
            end
         end
         local result, errorCode = context:destroy(count)
         if not result then
            local extra = { code = errorCode, why = nil }
            if errorCode == ItemInterface.FAILURE_CANNOT_SPLIT_STACK then
               extra.why = GetString(ITEMTRIG_STRING_ACTIONERROR_DESTROYITEM_CANT_SPLIT)
            elseif errorCode == ItemInterface.FAILURE_ITEM_IS_LOCKED then
               extra.why = GetString(ITEMTRIG_STRING_ACTIONERROR_DESTROYITEM_LOCKED)
            end
            return ItemTrig.OPCODE_FAILED, extra
         end
      end
   ),
   [6] = ActionBase:new( -- Modify Junk Flag
      _s(ITEMTRIG_STRING_ACTIONNAME_MODIFYJUNKFLAG),
      _s(ITEMTRIG_STRING_ACTIONDESC_MODIFYJUNKFLAG),
      {
         [1] = {
            type = "boolean",
            enum = {
               [1] = _s(ITEMTRIG_STRING_OPCODEARG_MODIFYJUNKFLAG_OFF),
               [2] = _s(ITEMTRIG_STRING_OPCODEARG_MODIFYJUNKFLAG_ON),
            },
            default  = true,
         }
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         if context:isInvalid() then
            return ItemTrig.OPCODE_FAILED, {}
         end
         if not item:modifyJunkState(args[1]) then
            --
            -- TODO: alert if the item can't be junk.
            --
            return ItemTrig.OPCODE_FAILED, {}
         end
      end
   ),
   [7] = ActionBase:new( -- Launder
      _s(ITEMTRIG_STRING_ACTIONNAME_LAUNDER),
      _s(ITEMTRIG_STRING_ACTIONDESC_LAUNDER),
      {
         [1] = {
            type    = "number",
            default = 9999,
         }
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         if context:isInvalid() then
            return ItemTrig.OPCODE_FAILED, {}
         end
         item:launder(args[1])
      end,
      { -- extra data for this opcode
         allowedEntryPoints = { ItemTrig.ENTRY_POINT_FENCE }
      }
   ),
   [8] = ActionBase:new( -- Sell Or Fence
      _s(ITEMTRIG_STRING_ACTIONNAME_SELLORFENCE),
      _s(ITEMTRIG_STRING_ACTIONDESC_SELLORFENCE),
      {
         [1] = {
            type    = "number",
            default = 9999,
         }
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         if context:isInvalid() then
            return ItemTrig.OPCODE_FAILED, {}
         end
         item:sell(args[1])
      end,
      { -- extra data for this opcode
         allowedEntryPoints = { ItemTrig.ENTRY_POINT_BARTER, ItemTrig.ENTRY_POINT_FENCE }
      }
   ),
}
ItemTrig.countActions = table.getn(ItemTrig.tableActions)
for i = 1, ItemTrig.countActions do
   ItemTrig.tableActions[i].opcode = i
end

ItemTrig.TRIGGER_ACTION_COMMENT    = ItemTrig.tableActions[4]
ItemTrig.TRIGGER_ACTION_RUN_NESTED = ItemTrig.tableActions[3]
