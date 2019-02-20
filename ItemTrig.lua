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
}

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

local function ShowWin()
   ItemTrig.windows.triggerList:show()
end

local function _OnItemAdded(eventCode, bagIndex, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
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
local function _OnOpenClose(eventCode, ...)
   ItemTrig.eventState.isInBank      = eventCode == EVENT_OPEN_BANK -- TODO: IsBankOpen()
   ItemTrig.eventState.isInBarter    = eventCode == EVENT_OPEN_STORE
   ItemTrig.eventState.isInCrafting  = eventCode == EVENT_CRAFTING_STATION_INTERACT
   ItemTrig.eventState.isInFence     = eventCode == EVENT_OPEN_FENCE
   ItemTrig.eventState.isInGuildBank = eventCode == EVENT_OPEN_GUILD_BANK -- TODO: IsGuildBankOpen()
   ItemTrig.eventState.isInMail      = eventCode == EVENT_MAIL_OPEN_MAILBOX
   -- TODO: Can we check "trading" state via TRADE_WINDOW:IsTrading() ?
   --
   if eventCode == EVENT_CRAFTING_STATION_INTERACT then
      ItemTrig.eventState.inCraftingType = select(2, ...) or 0 -- craftSkill
   else
      ItemTrig.eventState.inCraftingType = 0
   end
   if eventCode == EVENT_OPEN_FENCE then
      ItemTrig.eventState.fenceAutoLaunderCount = 0
      ItemTrig.eventState.fenceAutoFenceCount   = 0
   end
   --
   do -- trigger entry points
      local function _itemShouldRunTriggers(item)
         --
         -- TODO: Return false for quest items.
         --
         if item.locked then -- TODO: Make this a pref.
            return false
         end
         --
         -- TODO: Pref to return false for Crown Store and Crown Crate items, 
         -- to exclude them from triggers.
         --
         return true
      end
      local function _processInventory(entryPoint, entryPointData)
         ItemTrig.forEachBagSlot(BAG_BACKPACK, function(item)
            if not _itemShouldRunTriggers(item) then
               return
            end
            item.entryPointData = entryPointData
            ItemTrig.executeTriggerList(ItemTrig.Savedata.triggers, entryPoint, item)
         end)
      end
      --
      if eventCode == EVENT_CRAFTING_STATION_INTERACT then
         _processInventory(ItemTrig.ENTRY_POINT_CRAFTING, {
            craftingSkill = select(2, ...) or 0,
         })
      elseif eventCode == EVENT_OPEN_STORE then
         _processInventory(ItemTrig.ENTRY_POINT_BARTER, {})
      elseif eventCode == EVENT_OPEN_FENCE then
         if true then -- TODO: Make this a pref: Robust Fencing
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
                  ItemTrig.executeTriggerList(ItemTrig.Savedata.triggers, ItemTrig.ENTRY_POINT_FENCE, item)
               end
            end
         else
            _processInventory(ItemTrig.ENTRY_POINT_FENCE, {})
         end
      end
   end
end

local function Initialize()
   ItemTrig.Savedata:load()
   SLASH_COMMANDS["/cobbshowwin"]  = ShowWin
   --
   ItemTrig.ItemStackTools:setup("ItemTrig")
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