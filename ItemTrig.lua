ItemTrig = {
   name    = "ItemTrig",
   windows = {},
   windowClasses = {},
   eventState = {
      isInBank       = false,
      isInBarter     = false,
      isInCrafting   = false,
      isInFence      = false,
      isInGuildBank  = false,
      isInMail       = false,
      inCraftingType = 0,
   },
   prefs = {}
}
do -- Accessors for prefs
   function ItemTrig.prefs:exists(name)
      assert(name, "Invalid pref name.")
      local base = self[name]
      if type(base) ~= "table" then
         return false
      end
      return true
   end
   function ItemTrig.prefs:get(name)
      assert(ItemTrig.Savedata.prefs, "Prefs have not been loaded.")
      local base = self[name]
      if ItemTrig.Savedata.prefs[name] ~= nil then
         return ItemTrig.Savedata.prefs[name]
      end
      return base.default
   end
   function ItemTrig.prefs:set(name, value)
      assert(self:exists(name),       "There is no " .. tostring(name) .. " pref.")
      assert(ItemTrig.Savedata.prefs, "Prefs have not been loaded.")
      ItemTrig.Savedata.prefs[name] = value
   end
end
do -- Registry for windows
   --[[--
      System for handling windows such that the window classes don't need to 
      be in the global scope.
   --]]--
   function ItemTrig:registerWindow(name, class)
      assert(type(name) == "string", "Bad window name.")
      assert(self.windowClasses[name] == nil, "Window " .. name .. " is already registered.")
      self.windowClasses[name] = class
   end
   function ItemTrig:setupWindow(name, control)
      assert(self.windows[name] == nil, "The " .. name .. " window already exists.")
      self.windows[name] = self.windowClasses[name]:install(control)
   end
end

local CraftingStationQueueCoordinator = {}
local DeconstructQueueObserver = { queueName = "deconstruct" }
do -- CraftingStationQueueCoordinator
   --
   -- This singleton coordinates other singletons in order to carry out 
   -- tasks after crafting station triggers have run. The main tasks we 
   -- carry out are the deconstruction of items specifically requested 
   -- by triggers, and the mass refinement of all raw materials (if that 
   -- was requested by triggers).
   --
   -- The original intention was to allow triggers to request the refine-
   -- ment of individual materials, and to handle this using the same 
   -- queueing system as deconstruction. Unfortunately, however, the 
   -- logistics behind refinement are tricky -- and largely hardcoded 
   -- into the game. As such, refinement requires an entirely separate 
   -- system.
   --
   function CraftingStationQueueCoordinator:fire()
      self._waiting = { DeconstructQueueObserver } -- array
      self:next()
   end
   function CraftingStationQueueCoordinator:next()
      local list  = self._waiting
      local count = #list
      if count < 1 then
         self:after()
         return
      end
      local observer = list[count]
      list[count] = nil
      local attempt = ItemTrig.ItemQueues:start(observer.queueName, observer)
      if attempt == false then
         --
         -- The task didn't run because it wasn't given anything to do.
         --
         self:next()
         return
      end
   end
   function CraftingStationQueueCoordinator:after()
      ItemTrig.MassMaterialRefinementManager:afterTriggers()
   end
end
local RefineQueueObserver = { idMap = {} }
do -- RefineQueueObserver
   --
   -- The RefineQueueObserver is meant to be used with the MassMaterialRefinementQueue 
   -- system, and is supplied to it by way of MassMaterialRefinementManager. This 
   -- observer is a little bit different from DeconstructQueueObserver both because of 
   -- the different queue system, and because of the observer's own differing needs.
   --
   -- A single item stack can be refined multiple times, but we don't want to generate 
   -- a notification for each refine operation; rather, we want to group sequential 
   -- operations taken on the same material. So instead of
   --
   --    Refined Rubedite Ore x10.
   --    Refined Rubedite Ore x10.
   --    Refined Rubedite Ore x10.
   --    Refined Rough Ruby Ash x10.
   --
   -- we want to display
   --
   --    Refined Rubedite Ore x30.
   --    Refined Rough Ruby Ash x10.
   --
   RefineQueueObserver.lastStack = {
      id   = nil,
      name = nil,
      link = nil,
   }
   function RefineQueueObserver:_resetLastRefinedItem()
      self.lastStack.id   = nil
      self.lastStack.name = nil
      self.lastStack.link = nil
   end
   function RefineQueueObserver:_logLastRefinedItem()
      local ls = self.lastStack
      if ls.id then
         --local name    = ls.name
         local name    = ls.link
         local message = GetString(ITEMTRIG_STRING_LOG_REFINE)
         local initial = self.idMap[ls.id].count
         local bag, _, craftBag = GetItemLinkStacks(ls.link)
         local current = bag + craftBag
         --
         local count = initial - current
         self.idMap[ls.id].count = current
         CHAT_SYSTEM:AddMessage(LocalizeString(message, name, count))
         self:_resetLastRefinedItem()
      end
   end
   function RefineQueueObserver:onAnyStop()
      self:_resetLastRefinedItem()
      self.idMap = {}
      CraftingStationQueueCoordinator:next()
   end
   function RefineQueueObserver:onAbort()
      if ItemTrig.prefs:get("logging/actionsTaken") == false then
         return
      end
      self:_logLastRefinedItem()
      CHAT_SYSTEM:AddMessage(GetString(ITEMTRIG_STRING_REFINEOBSERVER_ABORT))
   end
   function RefineQueueObserver:onComplete()
      if ItemTrig.prefs:get("logging/actionsTaken") == false then
         return
      end
      self:_logLastRefinedItem()
      CHAT_SYSTEM:AddMessage(GetString(ITEMTRIG_STRING_REFINEOBSERVER_COMPLETE))
   end
   function RefineQueueObserver:onFailure(item, code, why)
      if ItemTrig.prefs:get("logging/actionsTaken") == false then
         return
      end
      self:_logLastRefinedItem()
      --
      local text = {}
      text[1] = LocalizeString(GetString(ITEMTRIG_STRING_REFINEOBSERVER_FAILURE), item.formattedName)
      if code then
         if code == item.FAILURE_ITEM_IS_LOCKED then
            why = GetString(ITEMTRIG_STRING_ACTIONERROR_REFINE_LOCKED)
         elseif code == item.FAILURE_CANNOT_REFINE then
            why = GetString(ITEMTRIG_STRING_ACTIONERROR_REFINE_WRONG_TYPE)
         elseif code == item.FAILURE_WRONG_CRAFTING_STATION then
            why = GetString(ITEMTRIG_STRING_ACTIONERROR_REFINE_WRONG_STATION)
         elseif code == item.FAILURE_FCOIS_DISALLOWS then
            why = GetString(ITEMTRIG_STRING_ACTIONERROR_REFINE_FCOIS)
         elseif code == item.FAILURE_NOT_ENOUGH_TO_REFINE then
            why = GetString(ITEMTRIG_STRING_ACTIONERROR_REFINE_NOT_ENOUGH)
         end
         if why then
            text[2] = LocalizeString(GetString(ITEMTRIG_STRING_REFINEOBSERVER_FAILURE_WHY), why)
         end
      elseif why then
         text[2] = LocalizeString(GetString(ITEMTRIG_STRING_REFINEOBSERVER_FAILURE_WHY), why)
      end
      CHAT_SYSTEM:AddMessage(table.concat(ItemTrig.stripNils(text, 2), "\n"))
   end
   function RefineQueueObserver:onInterrupted()
      if ItemTrig.prefs:get("logging/actionsTaken") == false then
         return
      end
      CHAT_SYSTEM:AddMessage(GetString(ITEMTRIG_STRING_REFINEOBSERVER_INTERRUPT))
   end
   function RefineQueueObserver:onSingleSuccess(item)
      local ls = self.lastStack;
      if item.id ~= ls.id then
         if ItemTrig.prefs:get("logging/actionsTaken") then
            self:_logLastRefinedItem()
         end
         ls.id   = item.id
         ls.name = item.name
         ls.link = item.link
      end
   end
   function RefineQueueObserver:onStart(idMap)
      self.idMap = idMap
      self:_resetLastRefinedItem()
      if ItemTrig.prefs:get("logging/actionsTaken") == false then
         return
      end
      local text = LocalizeString(GetString(ITEMTRIG_STRING_REFINEOBSERVER_START), count)
      CHAT_SYSTEM:AddMessage(text)
   end
end
do -- DeconstructQueueObserver
   --
   -- This singleton can be used to respond to notable events that occur 
   -- when deconstructing a queue of items. We use this to power the user 
   -- pref to log trigger actions taken on items.
   --
   function DeconstructQueueObserver:onAnyStop()
      CraftingStationQueueCoordinator:next()
   end
   function DeconstructQueueObserver:onAbort()
      if ItemTrig.prefs:get("logging/actionsTaken") == false then
         return
      end
      CHAT_SYSTEM:AddMessage(GetString(ITEMTRIG_STRING_DECONSTRUCTOBSERVER_ABORT))
   end
   function DeconstructQueueObserver:onComplete()
      if ItemTrig.prefs:get("logging/actionsTaken") == false then
         return
      end
      CHAT_SYSTEM:AddMessage(GetString(ITEMTRIG_STRING_DECONSTRUCTOBSERVER_COMPLETE))
   end
   function DeconstructQueueObserver:onFailure(item, code, why)
      if ItemTrig.prefs:get("logging/actionsTaken") == false then
         return
      end
      local text = {}
      text[1] = LocalizeString(GetString(ITEMTRIG_STRING_DECONSTRUCTOBSERVER_FAILURE), item.formattedName)
      if code then
         if code == item.FAILURE_ITEM_IS_LOCKED then
            why = GetString(ITEMTRIG_STRING_ACTIONERROR_DECONSTRUCT_LOCKED)
         elseif code == item.FAILURE_CANNOT_DECONSTRUCT then
            why = GetString(ITEMTRIG_STRING_ACTIONERROR_DECONSTRUCT_WRONG_TYPE)
         elseif code == item.FAILURE_WRONG_CRAFTING_STATION then
            why = GetString(ITEMTRIG_STRING_ACTIONERROR_DECONSTRUCT_WRONG_STATION)
         elseif code == item.FAILURE_FCOIS_DISALLOWS then
            why = GetString(ITEMTRIG_STRING_ACTIONERROR_DECONSTRUCT_FCOIS)
         end
         if why then
            text[2] = LocalizeString(GetString(ITEMTRIG_STRING_DECONSTRUCTOBSERVER_FAILURE_WHY), why)
         end
      elseif why then
         text[2] = LocalizeString(GetString(ITEMTRIG_STRING_DECONSTRUCTOBSERVER_FAILURE_WHY), why)
      end
      CHAT_SYSTEM:AddMessage(table.concat(ItemTrig.stripNils(text, 2), "\n"))
   end
   function DeconstructQueueObserver:onInterrupted()
      if ItemTrig.prefs:get("logging/actionsTaken") == false then
         return
      end
      CHAT_SYSTEM:AddMessage(GetString(ITEMTRIG_STRING_DECONSTRUCTOBSERVER_INTERRUPT))
   end
   function DeconstructQueueObserver:onSingleSuccess(item)
      if ItemTrig.prefs:get("logging/actionsTaken") == false then
         return
      end
      --local name    = item.formattedName
      local name    = item.link
      local message = GetString(ITEMTRIG_STRING_LOG_DECONSTRUCT)
      CHAT_SYSTEM:AddMessage(LocalizeString(message, name))
   end
   function DeconstructQueueObserver:onStart(count)
      if ItemTrig.prefs:get("logging/actionsTaken") == false then
         return
      end
      local text = LocalizeString(GetString(ITEMTRIG_STRING_DECONSTRUCTOBSERVER_START), count)
      CHAT_SYSTEM:AddMessage(text)
   end
end

local TriggerExecutionEventHandler
do
   --
   -- This singleton can be used to receive information on when a trigger 
   -- fails to run to completion, or when a trigger is skipped because its 
   -- conditions don't match. We use this to power the user pref to log a 
   -- trigger failure, and to honor the "Log Trigger Miss" condition.
   --
   TriggerExecutionEventHandler = {
      topLevelTrigger  = nil,
      loggedErrorCodes = {}, -- key = code; value = number of faulting triggers
   }
   ItemTrig.TriggerExecutionEventHandler = TriggerExecutionEventHandler
   function TriggerExecutionEventHandler:setup()
      --
      -- ItemInterface isn't loaded before we declare TriggerExecutionEventHandler.
      --
      local ItemInterface = ItemTrig.ItemInterface
      self.ERROR_CODES_THAT_CAN_BE_CONSIDERED_DUPLICATES = {
         [ItemInterface.FAILURE_BANK_IS_FULL]           = true,
         [ItemInterface.FAILURE_BANK_IS_NOT_OPEN]       = true,
         [ItemInterface.FAILURE_NORMAL_FENCE_LIMIT]     = true,
         [ItemInterface.FAILURE_NORMAL_LAUNDER_LIMIT]   = true,
         [ItemInterface.FAILURE_ZENIMAX_DEPOSIT_LIMIT]  = true,
         [ItemInterface.FAILURE_ZENIMAX_LAUNDER_LIMIT]  = true,
         [ItemInterface.FAILURE_WRONG_CRAFTING_STATION] = true,
      }
   end
   --
   function TriggerExecutionEventHandler:onStart() -- not called by trigger.lua
      self.loggedErrorCodes = {}
   end
   function TriggerExecutionEventHandler:onTriggerFail(trigger, details)
      if ItemTrig.prefs:get("logging/triggerFailures") == false then
         return false
      end
      if details.code then
         local code = details.code
         if self.ERROR_CODES_THAT_CAN_BE_CONSIDERED_DUPLICATES[code] then
            if ItemTrig.prefs:get("logging/collapseSameErrors") then
               self.loggedErrorCodes[code] = (self.loggedErrorCodes[code] or 0) + 1
               if self.loggedErrorCodes[code] > 1 then
                  return
               end
            end
         end
      end
      local text = {}
      text[1] = LocalizeString(GetString(ITEMTRIG_STRING_LOG_TRIGFAIL_BASE))
      text[2] = LocalizeString(GetString(ITEMTRIG_STRING_LOG_TRIGFAIL_ITEM), details.context.formattedName)
      text[3] = LocalizeString(GetString(ITEMTRIG_STRING_LOG_TRIGFAIL_TRIG), trigger.name)
      if trigger ~= self.topLevelTrigger then
         text[4] = LocalizeString(GetString(ITEMTRIG_STRING_LOG_TRIGFAIL_TRIG_TOP), self.topLevelTrigger.name)
      end
      if details.opcode then
         local opcode = details.opcode
         if opcode.type == "condition" then
            text[5] = GetString(ITEMTRIG_STRING_LOG_TRIGFAIL_OP_C)
         elseif opcode.type == "action" then
            text[5] = GetString(ITEMTRIG_STRING_LOG_TRIGFAIL_OP_A)
         end
         local formatted = ItemTrig.truncateString(opcode:format(), 240)
         text[5] = LocalizeString(text[5] or "", formatted)
      end
      if details.why then
         text[6] = LocalizeString(GetString(ITEMTRIG_STRING_LOG_TRIGFAIL_REASON), details.why)
      elseif details.errorCode then
         text[6] = LocalizeString(GetString(ITEMTRIG_STRING_LOG_TRIGFAIL_ERRORCODE), details.errorCode)
      end
      CHAT_SYSTEM:AddMessage(table.concat(ItemTrig.stripNils(text, 6), "\n"))
   end
   function TriggerExecutionEventHandler:onTriggerMiss(trigger, details)
      local text = {}
      text[1] = LocalizeString(GetString(ITEMTRIG_STRING_LOG_TRIGMISS_BASE))
      text[2] = LocalizeString(GetString(ITEMTRIG_STRING_LOG_TRIGMISS_ITEM), details.context.formattedName)
      text[3] = LocalizeString(GetString(ITEMTRIG_STRING_LOG_TRIGMISS_TRIG), trigger.name)
      if trigger ~= self.topLevelTrigger then
         text[4] = LocalizeString(GetString(ITEMTRIG_STRING_LOG_TRIGMISS_TRIG_TOP), self.topLevelTrigger.name)
      end
      if details.opcode then
         local opcode = details.opcode
         local formatted = ItemTrig.truncateString(opcode:format(), 240)
         text[5] = LocalizeString(GetString(ITEMTRIG_STRING_LOG_TRIGMISS_COND), formatted, details.index)
         if details.code == ItemTrig.NO_OR_CONDITIONS_HIT then
            text[6] = GetString(ITEMTRIG_STRING_LOG_TRIGMISS_NO_ORS)
         end
      else
         if details.code == ItemTrig.NO_OR_CONDITIONS_HIT then
            text[5] = GetString(ITEMTRIG_STRING_LOG_TRIGMISS_BAD_TAIL_ORS)
         end
      end
      CHAT_SYSTEM:AddMessage(table.concat(ItemTrig.stripNils(text, 6), "\n"))
   end
   function TriggerExecutionEventHandler:onEnd() -- not called by trigger.lua
      if ItemTrig.prefs:get("logging/triggerFailures") == false then
         return false
      end
      if ItemTrig.prefs:get("logging/collapseSameErrors") then
         local showedHeader = false
         for k, v in pairs(self.loggedErrorCodes) do
            if v > 1 then
               local key = "ITEMTRIG_STRING_LOG_TRIGFAILGROUP_" .. k
               local str = GetString(_G[key])
               if str ~= "" then
                  if not showedHeader then
                     CHAT_SYSTEM:AddMessage(LocalizeString(GetString(ITEMTRIG_STRING_LOG_TRIGFAILGROUP), v))
                     showedHeader = true
                  end
                  CHAT_SYSTEM:AddMessage(str)
               end
            end
         end
      end
   end
end

local function _onBeforeRunTriggers()
   ItemTrig.SkillCache:update()
   TriggerExecutionEventHandler:onStart()
end
local function _onAfterRunTriggers()
   TriggerExecutionEventHandler:onEnd()
end
local function _itemShouldRunTriggers(item)
   local prefs = ItemTrig.prefs
   if item.locked then
      if prefs:get("runTriggersOn/lockedItems") == false then
         return false
      end
   end
   if prefs:get("runTriggersOn/crownCrateItems") == false then
      if item.isCrownCrateItem then
         return false
      end
   end
   if prefs:get("runTriggersOn/crownStoreItems") == false then
      if item.isCrownStoreItem then
         return false
      end
   end
   return true
end
local function _processBank(entryPoint, entryPointData)
   local list = ItemTrig.assign({}, ItemTrig.Savedata.triggers)
   local stop = false
   --
   local function functor(item)
      if not _itemShouldRunTriggers(item) then
         return
      end
      item.entryPointData = entryPointData
      local result = ItemTrig.executeTriggerList(list, entryPoint, item,
         {
            eventRecipient   = TriggerExecutionEventHandler,
            stripBadTriggers = true,
         }
      )
      if result == ItemTrig.RUN_NO_MORE_TRIGGERS then
         stop = true
      end
   end
   --
   _onBeforeRunTriggers()
   ItemTrig.forEachBagSlot(BAG_BANK, functor)
   if not stop then
      ItemTrig.forEachBagSlot(BAG_SUBSCRIBER_BANK, functor)
   end
   _onAfterRunTriggers()
end
local function _processInventory(entryPoint, entryPointData)
   _onBeforeRunTriggers()
   local list = ItemTrig.assign({}, ItemTrig.Savedata.triggers)
   ItemTrig.forEachBagSlot(BAG_BACKPACK, function(item)
      if not _itemShouldRunTriggers(item) then
         return
      end
      item.entryPointData = entryPointData
      ItemTrig.executeTriggerList(list, entryPoint, item,
         {
            eventRecipient   = TriggerExecutionEventHandler,
            stripBadTriggers = true,
         }
      )
   end)
   _onAfterRunTriggers()
end
local function _processItemList(entryPoint, entryPointData, items)
   _onBeforeRunTriggers()
   local list = ItemTrig.assign({}, ItemTrig.Savedata.triggers)
   for i = 1, #items do
      local item = items[i]
      if not _itemShouldRunTriggers(item) then
         return
      end
      item.entryPointData = entryPointData
      ItemTrig.executeTriggerList(list, entryPoint, item,
         {
            eventRecipient   = TriggerExecutionEventHandler,
            stripBadTriggers = true,
         }
      )
   end
   _onAfterRunTriggers()
end
local function _processSingleItem(entryPoint, entryPointData, item)
   _onBeforeRunTriggers()
   local list = ItemTrig.assign({}, ItemTrig.Savedata.triggers)
   if not _itemShouldRunTriggers(item) then
      return
   end
   item.entryPointData = entryPointData
   ItemTrig.executeTriggerList(list, entryPoint, item,
      {
         eventRecipient = TriggerExecutionEventHandler,
      }
   )
   _onAfterRunTriggers()
end

local _OnItemAdded
local _OnOpenClose
do -- Event handlers
   function _OnItemAdded(eventCode, bagIndex, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
      local item = ItemTrig.ItemInterface:new(bagIndex, slotIndex)
      local entryPointData = {
         countAdded    = stackCountChange,
         --
         crafting      = ItemTrig.eventState.isInCrafting,
         purchased     = ItemTrig.eventState.isInBarter,
         takenFromMail = ItemTrig.eventState.isInMail,
         withdrawn     = ItemTrig.eventState.isInBank or ItemTrig.eventState.isInGuildBank or false,
      }
      _processSingleItem(ItemTrig.ENTRY_POINT_ITEM_ADDED, entryPointData, item)
   end
   function _OnOpenClose(eventCode, ...)
      ItemTrig.eventState.isInBank      = eventCode == EVENT_OPEN_BANK -- TODO: IsBankOpen()
      ItemTrig.eventState.isInBarter    = eventCode == EVENT_OPEN_STORE
      ItemTrig.eventState.isInCrafting  = eventCode == EVENT_CRAFTING_STATION_INTERACT
      ItemTrig.eventState.isInFence     = eventCode == EVENT_OPEN_FENCE
      ItemTrig.eventState.isInGuildBank = eventCode == EVENT_OPEN_GUILD_BANK -- TODO: IsGuildBankOpen()
      ItemTrig.eventState.isInMail      = eventCode == EVENT_MAIL_OPEN_MAILBOX
      -- TODO: Can we check "trading" state via TRADE_WINDOW:IsTrading() ?
      --
      if eventCode == EVENT_CRAFTING_STATION_INTERACT then
         ItemTrig.eventState.inCraftingType = select(1, ...) or 0 -- craftSkill
      else
         ItemTrig.eventState.inCraftingType = 0
      end
      if eventCode == EVENT_OPEN_FENCE then
         ItemTrig.eventState.fenceAutoLaunderCount = 0
         ItemTrig.eventState.fenceAutoFenceCount   = 0
      end
      --
      do -- trigger entry points
         if eventCode == EVENT_OPEN_BANK and GetBankingBag() == BAG_BANK then
            _processInventory(ItemTrig.ENTRY_POINT_BANK, {})
            _processBank(ItemTrig.ENTRY_POINT_BANK_BANK, {})
         elseif eventCode == EVENT_CRAFTING_STATION_INTERACT then
            local entryPointData = {
               craftingSkill = select(1, ...) or 0,
            }
            _processInventory(ItemTrig.ENTRY_POINT_CRAFTING, entryPointData)
            _processBank(ItemTrig.ENTRY_POINT_BANK_CRAFTING, entryPointData)
            CraftingStationQueueCoordinator:fire()
         elseif eventCode == EVENT_OPEN_STORE then
            _processInventory(ItemTrig.ENTRY_POINT_BARTER, {})
         elseif eventCode == EVENT_OPEN_FENCE then
            if ItemTrig.prefs:get("robustFencing") then
               --
               -- Sort the items to be processed by their sale value, so that 
               -- we always launder and fence the most valuable items first.
               --
               local list = ItemTrig.bagToInterfaceList(BAG_BACKPACK)
               table.sort(list, function(a, b)
                  return b.sellValue < a.sellValue
               end)
               _processItemList(ItemTrig.ENTRY_POINT_FENCE, {}, list)
            else
               _processInventory(ItemTrig.ENTRY_POINT_FENCE, {})
            end
         end
      end
   end
end

local _coreChatCommand
do -- A single chat command with arguments to control behavior
   local HELP_SHOULD_ALLOW_SEARCHING = false
   --
   local _subcommands = {}
   do -- Command definitions
      _subcommands.edit = {
         desc    = GetString(ITEMTRIG_STRING_CHAT_SUBCOMMAND_DESC_EDIT),
         handler = function() ItemTrig.windows.triggerList:show() end,
      }
      _subcommands.help = {
         desc    = GetString(ITEMTRIG_STRING_CHAT_SUBCOMMAND_DESC_HELP),
         handler =
            function(data)
               local search = nil
               if HELP_SHOULD_ALLOW_SEARCHING and data ~= "" then
                  search = ItemTrig.upToFirst(data, " ")
                  if search == "" then
                     search = nil
                  end
               end
               --
               if search then
                  local fmt = GetString(ITEMTRIG_STRING_CHAT_SUBCOMMAND_EXEC_HELP_SEARCH)
                  CHAT_SYSTEM:AddMessage(LocalizeString(fmt, search))
               else
                  CHAT_SYSTEM:AddMessage(GetString(ITEMTRIG_STRING_CHAT_SUBCOMMAND_EXEC_HELP_HEADER))
               end
               --
               local results = {}
               do
                  local index = 1
                  for k, v in pairs(_subcommands) do
                     local show = true
                     if search then
                        show = k:find(search) or v.desc:find(search)
                     end
                     if show then
                        results[index] = k
                        index = index + 1
                     end
                  end
                  table.sort(results)
               end
               local fmt = GetString(ITEMTRIG_STRING_CHAT_SUBCOMMAND_EXEC_HELP_ITEM)
               for i = 1, #results do
                  local name  = results[i]
                  local entry = _subcommands[name]
                  CHAT_SYSTEM:AddMessage(LocalizeString(fmt, name, entry.desc))
               end
            end,
      }
      _subcommands.options = {
         desc    = GetString(ITEMTRIG_STRING_CHAT_SUBCOMMAND_DESC_OPTIONS),
         handler = function() LibStub:GetLibrary("LibAddonMenu-2.0"):OpenToPanel(ItemTrigOptionsMenu) end,
      }
   end
   function _coreChatCommand(extra)
      extra = ItemTrig.trimString(extra or "")
      --
      local subcommand = ItemTrig.upToFirst(extra, " ")
      if _subcommands[subcommand] then
         local data = ItemTrig.trimString(extra:sub(subcommand:len() + 2))
         _subcommands[subcommand].handler(data)
      else
         CHAT_SYSTEM:AddMessage(GetString(ITEMTRIG_STRING_CHAT_BAD_SUBCOMMAND))
      end
   end
end

local function Initialize()
   assert(ItemTrig.tableConditions, GetString(ITEMTRIG_STRING_USER_FACING_ASSERT_BAD_CONDITION_TABLE))
   assert(ItemTrig.tableActions,    GetString(ITEMTRIG_STRING_USER_FACING_ASSERT_BAD_ACTION_TABLE))
   ItemTrig.registerLAMOptions()
   ItemTrig.Savedata:load()
   SLASH_COMMANDS["/itemtrig"] = _coreChatCommand
   --
   TriggerExecutionEventHandler:setup()
   ItemTrig.MassMaterialRefinementManager:setObserver(RefineQueueObserver)
   ItemTrig.ItemQueues:setup("ItemTrig")
   ItemTrig.ItemStackTools:setup("ItemTrig")
   ItemTrig.ItemAPILimits:setup("ItemTrig")
   ItemTrig.ItemInterface.onModifyingAction =
      function(interface, action, ...)
         --
         -- The environment -- the broader add-on that this system is being 
         -- used in -- should override this function on the class, to run 
         -- code whenever an action is taken that will modify an item.
         --
         -- The (action) parameter is a string.
         --
         if ItemTrig.prefs:get("logging/actionsTaken") == false then
            return
         end
         --local name = interface.formattedName
         local name = interface.link
         if action == "deconstruct" then
            local message = GetString(ITEMTRIG_STRING_LOG_DECONSTRUCT)
            CHAT_SYSTEM:AddMessage(LocalizeString(message, name))
         elseif action == "deposit-bank" then
            local message = GetString(ITEMTRIG_STRING_LOG_DEPOSIT_IN_BANK)
            local count   = select(1, ...)
            CHAT_SYSTEM:AddMessage(LocalizeString(message, name, count))
         elseif action == "withdraw-bank" then
            local message = GetString(ITEMTRIG_STRING_LOG_WITHDRAW_FROM_BANK)
            local count   = select(1, ...)
            CHAT_SYSTEM:AddMessage(LocalizeString(message, name, count))
         elseif action == "destroy" then
            local message = GetString(ITEMTRIG_STRING_LOG_DESTROY)
            local count   = select(1, ...)
            CHAT_SYSTEM:AddMessage(LocalizeString(message, name, count))
         elseif action == "launder" then
            local message = GetString(ITEMTRIG_STRING_LOG_LAUNDER)
            local count   = select(1, ...)
            CHAT_SYSTEM:AddMessage(LocalizeString(message, name, count))
         elseif action == "modifyJunkState" then
         elseif action == "modifyLockState" then
         elseif action == "sell" then
            local message = GetString(ITEMTRIG_STRING_LOG_SELL)
            local count   = select(1, ...)
            CHAT_SYSTEM:AddMessage(LocalizeString(message, name, count))
         end
      end
   --
   do -- register item-added handler
      EVENT_MANAGER:RegisterForEvent ("ItemTrig", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, _OnItemAdded)
      EVENT_MANAGER:AddFilterForEvent("ItemTrig", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, true)
      EVENT_MANAGER:AddFilterForEvent("ItemTrig", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
      EVENT_MANAGER:AddFilterForEvent("ItemTrig", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
      --
      -- This event will only fire if an item is added, and splitting a stack 
      -- doesn't count. Good.
      --
      -- TODO: This doesn't fire if we withdraw an item from a bank, presumably 
      -- because moving an item from one bag to another isn't recognized as a 
      -- "new" item.
      --
   end
   do -- register open/close handlers for menus that can give us items
      EVENT_MANAGER:RegisterForEvent("ItemTrig", EVENT_OPEN_BANK,          _OnOpenClose)
      EVENT_MANAGER:RegisterForEvent("ItemTrig", EVENT_CLOSE_BANK,         _OnOpenClose)
      EVENT_MANAGER:RegisterForEvent("ItemTrig", EVENT_OPEN_STORE,         _OnOpenClose)
      EVENT_MANAGER:RegisterForEvent("ItemTrig", EVENT_CLOSE_STORE,        _OnOpenClose)
      EVENT_MANAGER:RegisterForEvent("ItemTrig", EVENT_OPEN_GUILD_BANK,    _OnOpenClose)
      EVENT_MANAGER:RegisterForEvent("ItemTrig", EVENT_CLOSE_GUILD_BANK,   _OnOpenClose)
      EVENT_MANAGER:RegisterForEvent("ItemTrig", EVENT_MAIL_OPEN_MAILBOX,  _OnOpenClose)
      EVENT_MANAGER:RegisterForEvent("ItemTrig", EVENT_MAIL_CLOSE_MAILBOX, _OnOpenClose)
      EVENT_MANAGER:RegisterForEvent("ItemTrig", EVENT_CRAFTING_STATION_INTERACT,     _OnOpenClose)
      EVENT_MANAGER:RegisterForEvent("ItemTrig", EVENT_END_CRAFTING_STATION_INTERACT, _OnOpenClose)
      EVENT_MANAGER:RegisterForEvent("ItemTrig", EVENT_OPEN_FENCE,         _OnOpenClose) -- Closing the fence menu fires the EVENT_CLOSE_STORE event.
   end
   --ItemTrig.ThemeManager:refresh()
   ItemTrig.ThemeManager:switchTo(ItemTrig.prefs:get("ui/theme"))
end
local function OnAddonLoaded(eventCode, addonName)
   if addonName == ItemTrig.name then
      --
      -- Setup our own add-on. This is our entry point.
      --
      Initialize()
   end
end

EVENT_MANAGER:RegisterForEvent(ItemTrig.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)