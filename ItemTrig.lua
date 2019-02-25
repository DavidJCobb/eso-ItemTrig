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
      fenceAutoLaunderCount = 0,
      fenceAutoFenceCount   = 0,
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

local function ShowWin()
   ItemTrig.windows.triggerList:show()
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
      topLevelTrigger = nil,
   }
   function TriggerExecutionEventHandler:onTriggerFail(trigger, details)
      if ItemTrig.prefs:get("logging/triggerFailures") == false then
         return false
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
local function _processInventory(entryPoint, entryPointData)
   ItemTrig.forEachBagSlot(BAG_BACKPACK, function(item)
      if not _itemShouldRunTriggers(item) then
         return
      end
      item.entryPointData = entryPointData
      ItemTrig.executeTriggerList(ItemTrig.Savedata.triggers, entryPoint, item, { eventRecipient = TriggerExecutionEventHandler })
   end)
end

local _OnItemAdded
local _OnOpenClose
do -- Event handlers
   function _OnItemAdded(eventCode, bagIndex, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
      local item = ItemTrig.ItemInterface:new(bagIndex, slotIndex)
      if item.locked then
         return
      end
      item.entryPointData = {
         countAdded    = stackCountChange,
         --
         crafting      = ItemTrig.eventState.isInCrafting,
         purchased     = ItemTrig.eventState.isInBarter,
         takenFromMail = ItemTrig.eventState.isInMail,
         withdrawn     = ItemTrig.eventState.isInBank or ItemTrig.eventState.isInGuildBank or false,
      }
      --d(zo_strformat("Added item <<3>>. <<1>> now obtained; we now have <<2>>.", stackCountChange, item.count, item.name))
      ItemTrig.executeTriggerList(ItemTrig.Savedata.triggers, ItemTrig.ENTRY_POINT_ITEM_ADDED, item)
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
         elseif eventCode == EVENT_CRAFTING_STATION_INTERACT then
            _processInventory(ItemTrig.ENTRY_POINT_CRAFTING, {
               craftingSkill = select(1, ...) or 0,
            })
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
               for i = 1, table.getn(list) do
                  local item = list[i]
                  if _itemShouldRunTriggers(item) then
                     item.entryPointData = {}
                     ItemTrig.executeTriggerList(ItemTrig.Savedata.triggers, ItemTrig.ENTRY_POINT_FENCE, item, { eventRecipient = TriggerExecutionEventHandler })
                  end
               end
            else
               _processInventory(ItemTrig.ENTRY_POINT_FENCE, {})
            end
         end
      end
   end
end

local function Initialize()
   ItemTrig.registerLAMOptions()
   ItemTrig.Savedata:load()
   SLASH_COMMANDS["/cobbshowwin"]  = ShowWin
   --
   ItemTrig.ItemStackTools:setup("ItemTrig")
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
         local name = interface.formattedName
         if action == "deconstruct" then
            local message = GetString(ITEMTRIG_STRING_LOG_DECONSTRUCT)
            CHAT_SYSTEM:AddMessage(LocalizeString(message, name))
         elseif action == "deposit-bank" then
            local message = GetString(ITEMTRIG_STRING_LOG_DEPOSIT_IN_BANK)
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
   ItemTrig.ItemInterface.validateLaunderOperation =
      function(count)
         local state     = ItemTrig.eventState
         local remaining = 98 - state.fenceAutoLaunderCount
         if remaining < count then
            count = remaining
         end
         state.fenceAutoLaunderCount = state.fenceAutoLaunderCount + count
         return count
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