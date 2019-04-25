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

local function _doPretend(context, action)
   --
   -- We have a userpref that allows us to "pretend" to do an 
   -- action: instead of actually acting on the item, we just 
   -- log what we would've done.
   --
   -- Trigger actions need to manually check the pref; if it's 
   -- true, they need to call this function and return before 
   -- doing anything else. (Checking for other errors first is 
   -- allowed and encouraged.) When calling this function, the 
   -- actions should pass (context) and a string; this string 
   -- will be used to get the localized verb for the action.
   --
   context.invalid = true
   if action then
      local key = _G["ITEMTRIG_STRING_PRETEND_" .. action]
      if key then
         local base = GetString(ITEMTRIG_STRING_PRETENDBASE)
         local verb = GetString(key)
         local text = LocalizeString(base, verb, context.formattedName)
         CHAT_SYSTEM:AddMessage(text)
      end
   end
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
         [1] = {
            type = "string",
            placeholder = _s(ITEMTRIG_STRING_OPCODEARG_PLACEHOLDER_TEXT),
            explanation = _s(ITEMTRIG_STRING_ACTIONEXPLANATION_LOG),
         },
      },
      function(state, context, args)
         local text = args[1] or ""
         if ItemInterface:is(context) then -- transform text
            local substitutions = {
               countTotalBag = context.totalBag,
               creator       = context.creator,
               level         = context.level,
               name          = context.formattedName,
               price         = context.sellValue,
               style         = ItemTrig.gameEnums.styles[context.style or ITEMSTYLE_NONE],
            }
            if state.entryPoint == ItemTrig.ENTRY_POINT_ITEM_ADDED then
               substitutions.countAdded = context.entryPointData.countAdded or 0
            end
            local function _substitute(token)
               if substitutions[token] ~= nil then
                  return tostring(substitutions[token])
               end
               return "$(" .. token .. ")"
            end
            text = text:gsub("$%((%a+)%)", _substitute)
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
         local r, extra = args[1]:exec(context, state.entryPoint, state.options)
         if r == ItemTrig.RETURN_FROM_TRIGGER
         or r == ItemTrig.RUN_NO_MORE_TRIGGERS
         or r == ItemTrig.WRONG_ENTRY_POINT
         then
            return r, extra
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
         if context.bag == BAG_BANK then
            if not ItemTrig.prefs:get("bank/allowDestroy") then
               return ItemTrig.OPCODE_FAILED, { why = GetString(ITEMTRIG_STRING_ACTIONERROR_DESTROYITEM_NO_BANKED) }
            end
            if state.entryPoint ~= ItemTrig.ENTRY_POINT_BANK then
               return ItemTrig.OPCODE_FAILED, { why = GetString(ITEMTRIG_STRING_ACTIONERROR_DESTROYITEM_NOT_AT_BANK) }
            end
         end
         if ItemTrig.prefs:get("pretendActions") then
            _doPretend(context, "DESTROYITEM")
            return ItemTrig.RUN_NO_MORE_TRIGGERS
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
         if ItemTrig.prefs:get("pretendActions") then
            local task = "JUNKFLAGMODIFY"
            if args[1] then
               task = "JUNKFLAGSET"
            else
               task = "JUNKFLAGCLEAR"
            end
            return _doPretend(context, task)
         end
         local result, errorCode = context:modifyJunkState(args[1])
         if not result then
            local extra = { code = errorCode, why = nil }
            if errorCode == ItemInterface.FAILURE_CANNOT_FLAG_AS_JUNK then
               extra.why = GetString(ITEMTRIG_STRING_ACTIONERROR_JUNK_NOT_ALLOWED)
            end
            return ItemTrig.OPCODE_FAILED, extra
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
            requireInteger = true,
            min = 0,
         }
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         if context:isInvalid() then
            return ItemTrig.OPCODE_FAILED, {}
         end
         if ItemTrig.prefs:get("pretendActions") then
            return _doPretend(context, "LAUNDER")
         end
         local result, errorCode = context:launder(args[1])
         if not result then
            local extra = { code = errorCode, why = nil }
            if errorCode == ItemInterface.FAILURE_ZENIMAX_LAUNDER_LIMIT then
               extra.why = GetString(ITEMTRIG_STRING_ACTIONERROR_LAUNDERITEM_ZENIMAX_MAX_COUNT)
            elseif errorCode == ItemInterface.FAILURE_NORMAL_LAUNDER_LIMIT then
               extra.why = GetString(ITEMTRIG_STRING_ACTIONERROR_LAUNDERITEM_NORMAL_MAX_COUNT)
            elseif errorCode == ItemInterface.FAILURE_LAUNDER_CANT_AFFORD then
               extra.why = GetString(ITEMTRIG_STRING_ACTIONERROR_LAUNDERITEM_CANT_AFFORD)
            elseif errorCode == ItemInterface.FAILURE_LAUNDER_NOT_STOLEN then
               extra.why = GetString(ITEMTRIG_STRING_ACTIONERROR_LAUNDERITEM_NOT_STOLEN)
            end
            return ItemTrig.OPCODE_FAILED, extra
         end
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
            requireInteger = true,
            min = 0,
         }
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         if context:isInvalid() then
            return ItemTrig.OPCODE_FAILED, {}
         end
         if ItemTrig.prefs:get("pretendActions") then
            _doPretend(context, "SELLORFENCE")
            return ItemTrig.RUN_NO_MORE_TRIGGERS
         end
         local result, errorCode = context:sell(args[1])
         if not result then
            local extra = { code = errorCode, why = nil }
            if errorCode == ItemInterface.FAILURE_NORMAL_FENCE_LIMIT then
               extra.why = GetString(ITEMTRIG_STRING_ACTIONERROR_SELLORFENCE_NORMAL_MAX_FENCE)
            elseif errorCode == ItemInterface.FAILURE_ITEM_IS_LOCKED then
               extra.why = GetString(ITEMTRIG_STRING_ACTIONERROR_SELLORFENCE_LOCKED)
            end
            return ItemTrig.OPCODE_FAILED, extra
         end
      end,
      { -- extra data for this opcode
         allowedEntryPoints = { ItemTrig.ENTRY_POINT_BARTER, ItemTrig.ENTRY_POINT_FENCE }
      }
   ),
   [9] = ActionBase:new( -- Deconstruct
      _s(ITEMTRIG_STRING_ACTIONNAME_DECONSTRUCT),
      _s(ITEMTRIG_STRING_ACTIONDESC_DECONSTRUCT),
      {},
      function(state, context, args)
         assert(ItemInterface:is(context))
         if ItemTrig.prefs:get("pretendActions") then
            _doPretend(context, "DECONSTRUCT")
            return ItemTrig.RUN_NO_MORE_TRIGGERS
         end
         ItemTrig.ItemQueues:queueDeconstruct(context)
         return ItemTrig.RUN_NO_MORE_TRIGGERS
      end,
      { -- extra data for this opcode
         allowedEntryPoints = { ItemTrig.ENTRY_POINT_CRAFTING, ItemTrig.ENTRY_POINT_BANK_CRAFTING }
      }
   ),
   [10] = ActionBase:new( -- Stop Running Triggers
      _s(ITEMTRIG_STRING_ACTIONNAME_STOPRUNNINGTRIGGERS),
      _s(ITEMTRIG_STRING_ACTIONDESC_STOPRUNNINGTRIGGERS),
      {},
      function(state, context, args)
         return ItemTrig.RUN_NO_MORE_TRIGGERS
      end,
      {
         explanation = _s(ITEMTRIG_STRING_ACTIONEXPLANATION_STOPRUNNINGTRIGGERS),
      }
   ),
   [11] = ActionBase:new( -- Deposit In Bank
      _s(ITEMTRIG_STRING_ACTIONNAME_DEPOSITINBANK),
      _s(ITEMTRIG_STRING_ACTIONDESC_DEPOSITINBANK),
      {
         [1] = {
            type    = "number",
            default = 9999,
            requireInteger = true,
            min = 0,
         }
      },
      function(state, context, args)
         assert(ItemInterface:is(context))
         if ItemTrig.prefs:get("pretendActions") then
            _doPretend(context, "DEPOSITINBANK")
            return ItemTrig.RUN_NO_MORE_TRIGGERS
         end
         local result, errorCode = context:storeInBank(args[1])
         if not result then
            local extra = { code = errorCode, why = nil }
            if errorCode == ItemInterface.FAILURE_BANK_CANT_STORE_STOLEN then
               extra.why = GetString(ITEMTRIG_STRING_ACTIONERROR_DEPOSITINBANK_STOLEN)
            elseif errorCode == ItemInterface.FAILURE_BANK_IS_FULL then
               extra.why = GetString(ITEMTRIG_STRING_ACTIONERROR_DEPOSITINBANK_FULL)
            elseif errorCode == ItemInterface.FAILURE_BANK_IS_NOT_OPEN then
               extra.why = GetString(ITEMTRIG_STRING_ACTIONERROR_DEPOSITINBANK_NOT_OPEN)
            elseif errorCode == ItemInterface.FAILURE_ZENIMAX_DEPOSIT_LIMIT then
               extra.why = GetString(ITEMTRIG_STRING_ACTIONERROR_DEPOSITINBANK_ZENIMAX_MAX_COUNT)
            elseif errorCode == ItemInterface.FAILURE_BANK_CHARACTER_BOUND then
               extra.why = GetString(ITEMTRIG_STRING_ACTIONERROR_DEPOSITINBANK_CHAR_BOUND)
            end
            return ItemTrig.OPCODE_FAILED, extra
         end
      end,
      {
         allowedEntryPoints = { ItemTrig.ENTRY_POINT_BANK }
      }
   ),
}
ItemTrig.countActions = #ItemTrig.tableActions
for i = 1, ItemTrig.countActions do
   ItemTrig.tableActions[i].opcode = i
end

ItemTrig.TRIGGER_ACTION_COMMENT    = ItemTrig.tableActions[4]
ItemTrig.TRIGGER_ACTION_RUN_NESTED = ItemTrig.tableActions[3]
