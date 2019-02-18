ItemTrig = {
   name    = "ItemTrig",
   windows = {},
   windowClasses = {},
   eventState = {
      isInBank       = false,
      isInBarter     = false,
      isInCrafting   = false,
      isInGuildBank  = false,
      isInMail       = false,
      inCraftingType = 0,
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

local function PerfTest(extra)
   local testcount = 100
   if extra ~= "" and extra ~= " " then
      if tonumber(extra) then
         testcount = tonumber(extra)
         if testcount > 1000000 then
            testcount = 1000000
         elseif testcount < 0 then
            testcount = 10
         end
      end
   end
   
   -------------
   
   local t = ItemTrig.Trigger:new()
   t.name = "Test trigger"
   table.insert(t.conditions, ItemTrig.Condition:new(3, {true}))  -- Always/Never
   table.insert(t.conditions, ItemTrig.Condition:new(2, {true}))  -- Set And/Or
   table.insert(t.conditions, ItemTrig.Condition:new(3, {true}))  -- Always/Never
   table.insert(t.conditions, ItemTrig.Condition:new(3, {false})) -- Always/Never
   table.insert(t.actions, ItemTrig.Action:new(2, {"Hello, world!"})) -- Log Message
   
   local n = ItemTrig.Trigger:new()
   n.name = "Nested test trigger"
   table.insert(n.conditions, ItemTrig.Condition:new(3, {true}))  -- Always/Never
   table.insert(n.actions, ItemTrig.Action:new(2, {"I am nested!"})) -- Log Message
   table.insert(n.actions, ItemTrig.Action:new(1)) -- Return
   
   table.insert(t.actions, ItemTrig.Action:new(3, {n})) -- Run Nested Trigger
   table.insert(t.actions, ItemTrig.Action:new(2, {"After nested!"})) -- Log Message
   
   -------------
   
   local diff
   ItemTrig.pertTestStart()
   for i = 1, testcount do
      s = t:serialize()
   end
   diff = ItemTrig.perfTestEnd()
   CHAT_SYSTEM:AddMessage("Serializating " .. testcount .. " times took " .. diff .. " ms.")
   --
   local tparsed
   s = t:serialize()
   d(s)
   ItemTrig.pertTestStart()
   for i = 1, testcount do
      tparsed = ItemTrig.parseTrigger(s)
   end
   diff = ItemTrig.perfTestEnd()
   CHAT_SYSTEM:AddMessage("Parsing " .. testcount .. " times took " .. diff .. " ms.")
end

local function ShowWin()
   ItemTrig.windows.triggerList:show()
end

local function _ItemAddedHandler(eventCode, bagIndex, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
   if updateReason == INVENTORY_UPDATE_REASON_DURABILITY_CHANGE then
      return
   end
   if stackCountChange < 1 then
      return
   end
   local item = ItemTrig.ItemInterface:new(bagIndex, slotIndex)
   item.entryPoint = ItemTrig.ENTRY_POINT_ITEM_ADDED
   item.entryPointData = {
      countAdded    = stackCountChange,
      --
      crafting      = ItemTrig.eventState.isInCrafting,
      purchased     = ItemTrig.eventState.isInBarter,
      takenFromMail = ItemTrig.eventState.isInMail,
      withdrawn     = ItemTrig.eventState.isInBank or ItemTrig.eventState.isInGuildBank or false,
   }
   --d(zo_strformat("Added item <<3>>. <<1>> now obtained; we now have <<2>>.", stackCountChange, item.count, item.name))
   --
   local tList = ItemTrig.filterTriggerList(ItemTrig.Savedata.triggers, ItemTrig.ENTRY_POINT_ITEM_ADDED)
   for i = 1, table.getn(tList) do
      local trigger = tList[i]
      local result  = trigger:exec(item, ItemTrig.ENTRY_POINT_ITEM_ADDED)
      if item:isInvalid() then
         break
      end
   end
end

local function Initialize()
   ItemTrig.Savedata:load()
   SLASH_COMMANDS["/cobbperftest"] = PerfTest
   SLASH_COMMANDS["/cobbshowwin"]  = ShowWin
   SLASH_COMMANDS["/cobbstartinvtest"] = InventoryFilterTest
   --
   do -- register item-added handler
      EVENT_MANAGER:RegisterForEvent ("ItemTrig", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, _ItemAddedHandler)
      EVENT_MANAGER:AddFilterForEvent("ItemTrig", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, true)
      EVENT_MANAGER:AddFilterForEvent("ItemTrig", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
      --
      -- Some notes:
      --
      --  - I'm not sure whether splitting a stack normally fires this 
      --    event, but it seems our filters are preventing us from 
      --    responding to stacks being split, which is good. That's 
      --    what we want: we only want to react to actual new items 
      --    being added, as opposed to any slot change.
      --
   end
   do -- register open/close handlers for menus that can give us items
      local function _onOpenClose(eventCode, ...)
         ItemTrig.eventState.isInBank      = eventCode == EVENT_OPEN_BANK
         ItemTrig.eventState.isInBarter    = eventCode == EVENT_OPEN_STORE
         ItemTrig.eventState.isInCrafting  = eventCode == EVENT_CRAFTING_STATION_INTERACT
         ItemTrig.eventState.isInGuildBank = eventCode == EVENT_OPEN_GUILD_BANK
         ItemTrig.eventState.isInMail      = eventCode == EVENT_MAIL_OPEN_MAILBOX
         --
         if eventCode == EVENT_CRAFTING_STATION_INTERACT then
            ItemTrig.eventState.inCraftingType = select(2, ...) or 0 -- craftSkill
         else
            ItemTrig.eventState.inCraftingType = 0
         end
      end
      EVENT_MANAGER:RegisterForEvent("ItemTrig", EVENT_OPEN_BANK,          _onOpenClose)
      EVENT_MANAGER:RegisterForEvent("ItemTrig", EVENT_CLOSE_BANK,         _onOpenClose)
      EVENT_MANAGER:RegisterForEvent("ItemTrig", EVENT_OPEN_STORE,         _onOpenClose)
      EVENT_MANAGER:RegisterForEvent("ItemTrig", EVENT_CLOSE_STORE,        _onOpenClose)
      EVENT_MANAGER:RegisterForEvent("ItemTrig", EVENT_OPEN_GUILD_BANK,    _onOpenClose)
      EVENT_MANAGER:RegisterForEvent("ItemTrig", EVENT_CLOSE_GUILD_BANK,   _onOpenClose)
      EVENT_MANAGER:RegisterForEvent("ItemTrig", EVENT_MAIL_OPEN_MAILBOX,  _onOpenClose)
      EVENT_MANAGER:RegisterForEvent("ItemTrig", EVENT_MAIL_CLOSE_MAILBOX, _onOpenClose)
      EVENT_MANAGER:RegisterForEvent("ItemTrig", EVENT_CRAFTING_STATION_INTERACT,     _onOpenClose)
      EVENT_MANAGER:RegisterForEvent("ItemTrig", EVENT_END_CRAFTING_STATION_INTERACT, _onOpenClose)
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