ItemTrig.ItemInterface = {}
local ItemInterface = ItemTrig.ItemInterface

function ItemTrig.bagToInterfaceList(bag)
   --
   -- For most bags, iterating over every slot is as simple as incrementing 
   -- a number from 0 to the bag size. However, there are some bags that 
   -- require us to use API calls to iterate over them (I guess they have 
   -- non-contiguous indices?). Zenimax wrote a helper function to automate 
   -- this for us: ZO_GetNextBagSlotIndex.
   --
   local list = {}
   local slot = ZO_GetNextBagSlotIndex(bag)
   while slot do
      if HasItemInSlot(bag, slot) then
         table.insert(list, ItemInterface:new(bag, slot))
      end
      slot = ZO_GetNextBagSlotIndex(bag, slot)
   end
   return list
end
function ItemTrig.forEachBagSlot(bag, functor)
   local slot = ZO_GetNextBagSlotIndex(bag)
   while slot do
      if HasItemInSlot(bag, slot) then
         local interface = ItemInterface:new(bag, slot)
         if functor(interface) then
            return
         end
      end
      slot = ZO_GetNextBagSlotIndex(bag, slot)
   end
end

function ItemTrig.getNaiveItemNameFor(id)
   --
   -- This won't work for items that can vary, like armor and weapons, but 
   -- it should work for items that exhibit minimal variation, like stolen 
   -- goods.
   --
   return GetItemLinkName("|H1:item:" .. id .. ":0:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|hUnknown Name|h")
end

local StackTools = {
   eventPrefix   = nil,
   listening     = false,
   pendingSplits = {},
}
ItemTrig.ItemStackTools = StackTools
do
   --
   -- Some of the operations we're able to perform require us to split a stack 
   -- of items. However, there is no synchronous function to split an item 
   -- stack; we can request a stack split, but that request will be carried out 
   -- asynchronously. As such, we need to use an event listener to know when the 
   -- request has been completed.
   --
   -- There's another wrinkle: if we want to split multiple stacks on the same 
   -- frame, then a naive approach will cause these operations to conflict: both 
   -- operations will try to use the same slot as a destination, because:
   --
   --    1. Operation A requests a stack split:
   --
   --        * We search for a free bag slot, and find one.
   --
   --        * We queue a move to that slot.
   --
   --        * Until that move completes, after our code has finished, the slot 
   --          will continue to read as free.
   --
   --    2. Operation B requests a stack split:
   --
   --        * We search for a free bag slot. Because Operation A has been queued 
   --          but not actually carried out yet, we find the slot that it already 
   --          asked to move to.
   --
   --        * CONFLICT!
   --
   -- The StackTools singleton is designed to prevent this. If anything in this 
   -- file needs to split a stack or even just find an empty bag slot, it should 
   -- rely on StackTools:split(...) and StackTools:findFreeSlot(...).
   --
   -- An add-on using this system must call the setup(...) method once loaded, so 
   -- that this system registers the events it needs in order to function. If the 
   -- add-on has teardown routines, it can likewise call the teardown() method.
   --
   local function _listener(eventCode, bagIndex, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
      local bagData = StackTools.pendingSplits[bagIndex]
      if not bagData then
         return
      end
      local slotData = bagData[slotIndex]
      if not slotData then
         return
      end
      local deferred = slotData.deferred
      if slotData.id == GetItemId(bagIndex, slotIndex) then
         if slotData.count == GetSlotStackSize(bagIndex, slotIndex) then
            --
            -- If the item slot is what we expect -- same ID as the original 
            -- item, and same count as was queued to split -- then signal a 
            -- successful stack split.
            --
            deferred:resolve(bagIndex, slotIndex)
         end
      end
      bagData[slotIndex] = nil
      if deferred:isPending() then
         --
         -- The item slot wasn't what we expected. Signal an invalid stack 
         -- state suggesting a failed stack split.
         --
         deferred:reject(bagIndex, slotIndex)
      end
   end
   --
   function StackTools:earmarkSlot(bag, slot, id, count)
      if not self.pendingSplits[bag] then
         self.pendingSplits[bag] = {}
      end
      local registration = {
         id       = id,
         count    = count,
         deferred = ItemTrig.Deferred:new(),
      }
      self.pendingSplits[bag][slot] = registration
      return registration.deferred
   end
   function StackTools:findFreeSlot(bag)
      --
      -- Returns the first slot in (bag) that is both currently free and 
      -- not being used as the destination for a pending "split stack" op-
      -- eration. If there are no free slots, returns nil.
      --
      local slot = FindFirstEmptySlotInBag(bag)
      if not slot then
         return
      end
      local pending = self.pendingSplits[bag]
      if not pending then
         return slot
      end
      while slot and (pending[slot] or HasItemInSlot(bag, slot)) do
         slot = ZO_GetNextBagSlotIndex(bag, slot)
      end
      return slot
   end
   function StackTools:setup(eventPrefix)
      if self.listening then
         self:teardown()
      end
      self.eventPrefix = eventPrefix
      local namespace = eventPrefix .. "SplitStackListener"
      EVENT_MANAGER:RegisterForEvent (namespace, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, _listener)
      EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, false)
      --EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
      EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
      self.listening = true
   end
   function StackTools:slotIsEarmarked(bag, slot)
      local pending = self.pendingSplits[bag]
      if not pending then
         return false
      end
      return pending[slot] ~= nil
   end
   function StackTools:split(interface, count)
      --
      -- Attempt to split the stack represented by an ItemInterface. If this 
      -- function fails, it returns a boolean and an error code. If it works, 
      -- it returns a Deferred.
      --
      -- If the stack split succeeds and is detected by our system, then the 
      -- deferred will be resolved with the destination bag index and slot 
      -- index. If the stack split appears to be invalid (i.e. we detect a 
      -- different item, or the wrong quantity of item, in the destination 
      -- bag slot), then the deferred will be rejected with the destination 
      -- bag index and slot index.
      --
      if not self.listening then
         return false, ItemInterface.FAILURE_MOD_NOT_SETUP
      end
      local bag  = interface.bag
      local free = self:findFreeSlot(interface.bag)
      if not free then
         return false, ItemInterface.FAILURE_CANNOT_SPLIT_STACK
      end
      CallSecureProtected("RequestMoveItem", bag, interface.slot, bag, free, count)
      return self:earmarkSlot(bag, free, interface.id, count):promise()
   end
   function StackTools:teardown()
      local namespace = self.eventPrefix .. "SplitStackListener"
      EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
      self.listening = false
   end
end

--
-- ITEMINTERFACE
--
-- This class can be used to cache data for a bag slot all at once, allowing 
-- you to work with that bag slot without repeating API calls.
--

--[[
   As of 2/17/2019, benchmarks suggest that when creating an item interface from 
   the "item added" event, it takes an average of 11.5ms to create 400 interfaces, 
   or an average of 0.02875ms to create a single interface. The longest time we 
   observed in tests was (21 / 400) ms for an Alchemy Bottle picked up from the 
   world; the shortest was (6 / 400) ms.
]]--

--[[
   TODO: Potential lazy getters to implement:
   
    - GetItemLaunderPrice(bag, slot)
    - IsItemFromCrownCrate(bag, slot)
    - IsItemFromCrownStore(bag, slot)
    - IsItemSoulGem(bag, slot)
]]--

local _lazyGetterMappings = {
   --
   -- Given a key K and a value V in this table, if you try to access 
   -- the K field on an ItemInterface, then the V function is called, 
   -- passed that interface as an argument. The V function's return 
   -- value will be written to the ItemInterface. So, these functions 
   -- retrieve data only when it's needed, and that data then gets 
   -- cached and reused. This is handled by ItemInterface.meta.
   --
   alchemyTraits =
      function(i)
         if i.invalid then
            return {}
         end
         if i.craftingType ~= ITEMTYPE_REAGENT then
            return {}
         end
         local function _handle(...)
            local numTraits = select("#", ...) / ALCHEMY_TRAIT_STRIDE
            if numTraits < 1 then
               return {}
            end
            local traitData = {}
            for i = 1, numTraits do
               local offset = (i - 1) * ALCHEMY_TRAIT_STRIDE + 1
               traitData[i] = {
                  name         = select(offset, ...),
                  icon         = select(offset + 1, ...),
                  matchIcon    = select(offset + 2, ...),
                  cancellingTraitName = select(offset + 3, ...),
                  conflictIcon = select(offset + 4, ...),
               }
            end
            return traitData
         end
         return _handle(GetAlchemyItemTraits(i.bag, i.slot))
      end,
   canBeJunk      = function(i) return i.invalid and nil or CanItemBeMarkedAsJunk(i.bag, i.slot) end,
   canBeLocked    = function(i) return i.invalid and nil or CanItemBePlayerLocked(i.bag, i.slot) end,
   countTotal     = function(i) return i.invalid and nil or GetItemTotalCount(i.bag, i.slot) end,
   forcedNonDeconstructable =
      function(i)
         if i.invalid then
            return nil
         end
         --
         -- This is the check used to show the "this item cannot be 
         -- deconstructed" message in item tooltips -- most relevant 
         -- to jewelry that existed prior to the Summerset update, I 
         -- think. This check was, as of this writing, found at:
         --
         -- esoui/publicallingames/tooltip/itemtooltips.lua
         --
         return IsItemLinkForcedNotDeconstructable(i.link) and not IsItemLinkContainer(i.link)
      end,
   formattedName    = function(i) return LocalizeString("<<1>>", i.name) end,
   hasJunkFlag      = function(i) return i.invalid and nil or IsItemJunk(i.bag, i.slot) end,
   isCrownCrateItem = function(i) return i.invalid and nil or IsItemFromCrownCrate(i.bag, i.slot) end,
   isCrownStoreItem = function(i) return i.invalid and nil or IsItemFromCrownStore(i.bag, i.slot) end,
   isResearchable   = function(i) return i.invalid and nil or CanItemLinkBeTraitResearched(i.link) end,
   itemFilters      = function(i) return i.invalid and {} or {GetItemFilterTypeInfo(i.bag, i.slot)} end,
}

ItemInterface.meta = {
   __index =
      function(interface, key)
         local function _safe_thiscall(method, ...)
            return ItemInterface[method](interface, ...)
         end
         --
         local value = rawget(interface, key)
         if value ~= nil then
            return value
         end
         if _lazyGetterMappings[key] then
            --
            -- Handle properties that are only stored on demand.
            --
            interface[key] = _lazyGetterMappings[key](interface)
            return rawget(interface, key)
         end
         return ItemInterface[key]
      end,
}
do -- define failure reasons for member functions
   ItemInterface.FAILURE_CANNOT_DECONSTRUCT    = "DCON" -- This item type can't be deconstructed.
   ItemInterface.FAILURE_CANNOT_FLAG_AS_JUNK   = "NJNK" -- This item type can't be flagged as junk.
   ItemInterface.FAILURE_CANNOT_LOCK           = "NLOK" -- This item type can't be locked.
   ItemInterface.FAILURE_CANNOT_SPLIT_STACK    = "SPLT" -- Cannot split the stack; your inventory is full.
   ItemInterface.FAILURE_ITEM_IS_INVALID       = "INVA" -- The ItemInterface is invalid: the bag slot now contains something different.
   ItemInterface.FAILURE_ITEM_IS_LOCKED        = "LOCK" -- Cannot perform this operation on a locked item.
   ItemInterface.FAILURE_MOD_NOT_SETUP         = "NOPE" -- The mod wasn't set up properly.
   ItemInterface.FAILURE_ZENIMAX_LAUNDER_LIMIT = "ZLND" -- We've hit the maximum number of items Zenimax allows add-ons to launder every time the fence is opened.
end
function ItemInterface:new(bagIndex, slotIndex)
   local result = setmetatable({}, self.meta)
   ItemTrig.assign(result, {
      bag  = bagIndex,
      slot = slotIndex,
      id   = GetItemId(bagIndex, slotIndex),
      link = GetItemLink(bagIndex, slotIndex),
      --
      entryPoint     = "none", -- for trigger processing
      entryPointData = {},
      --
      armorType     = GetItemArmorType(bagIndex, slotIndex),
      bound         = IsItemBound(bagIndex, slotIndex),
      countTotal    = nil, -- lazy getter, via metatable
      creator       = GetItemCreatorName(bagIndex, slotIndex) or "",
      level         = GetItemLevel(bagIndex, slotIndex),
      locked        = IsItemPlayerLocked(bagIndex, slotIndex),
      name          = GetItemName(bagIndex, slotIndex), -- NOTE: This is a raw value and may have LocalizeString-intended format codes on the end.
      --quality       = GetItemQuality(bagIndex, slotIndex),
      requiredChamp = GetItemRequiredChampionPoints(bagIndex, slotIndex),
      requiredLevel = GetItemRequiredLevel(bagIndex, slotIndex),
      --sellValue     = GetItemSellValueWithBonuses(bagIndex, slotIndex),
      stolen        = IsItemStolen(bagIndex, slotIndex),
      trait         = GetItemTrait(bagIndex, slotIndex),
      uniqueID      = GetItemUniqueId(bagIndex, slotIndex),
      weaponType    = GetItemWeaponType(bagIndex, slotIndex),
   })
   do -- state
      ItemTrig.assign(result, {
         destroyed = false,
         invalid   = false,
      })
   end
   do -- bag totals
      local bag, bank, craftBag = GetItemLinkStacks(result.link)
      ItemTrig.assign(result, {
         totalBag      = bag,
         totalBank     = bank,
         totalCraftBag = craftBag,
      })
   end
   do -- GetItemCraftingInfo
      local craftingSkill, itemType, c1, c2, c3 = GetItemCraftingInfo(bagIndex, slotIndex)
      ItemTrig.assign(result, {
         craftingSkill = craftingSkill, -- CRAFTING_TYPE_ALCHEMY, CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_CLOTHIER, CRAFTING_TYPE_ENCHANTING, CRAFTING_TYPE_INVALID, CRAFTING_TYPE_PROVISIONING, CRAFTING_TYPE_WOODWORKING
         craftingType  = itemType,
         craftingExtra = { [1] = c1, [2] = c2, [3] = c3 },
      })
   end
   do -- GetItemInfo
      local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, quality = GetItemInfo(bagIndex, slotIndex)
      ItemTrig.assign(result, {
         count     = stack,
         equipType = equipType,
         icon      = icon,
         style     = itemStyleId,
         --locked    = locked, -- Feb. 21 2019: the API is buggy; this variable can sometimes be wrong
         meetsUsageRequirement = meetsUsageRequirement,
         quality   = quality, -- this would be better described as "rarity"
         sellValue = sellPrice or 0,
      })
   end
   do -- GetItemType
      local itemType, specType = GetItemType(bagIndex, slotIndex)
      result.type     = itemType
      result.specType = specType
   end
   do -- runestones
      --
      -- TODO: only if runestone
      --
      result.runestoneName = GetRunestoneTranslatedName(bagIndex, slotIndex)
   end
   return result
end
function ItemInterface:canDeconstruct()
   if self.craftingType == ITEMTYPE_GLYPH_WEAPON
   or self.craftingType == ITEMTYPE_GLYPH_ARMOR
   or self.craftingType == ITEMTYPE_GLYPH_JEWELRY
   then
      --
      -- As of this writing, the item types eligible for enchanting 
      -- deconstruction can be found at:
      --
      -- esoui/ingame/crafting/keyboard/enchanting_keyboard.lua
      --
      -- in the file-local function DoesEnchantingItemPassFilter.
      --
      return not self.forcedNonDeconstructable -- deconstructable glyph
   end
   local filters = self.itemFilters
   for i = 1, #filters do
      local f = filters[i]
      if f == ITEMFILTERTYPE_WEAPONS
      or f == ITEMFILTERTYPE_ARMOR
      or f == ITEMFILTERTYPE_JEWELRY
      then
         --
         -- As of this writing, the filters that make an item eligible for 
         -- being listed in the "smithing" menu can be found at:
         --
         -- esoui/ingame/crafting/craftingutils.lua
         --
         -- It's worth noting that internally, "smithing" covers blacksmith-
         -- ing, clothier work, jeweling, and woodworking.
         --
         return not self.forcedNonDeconstructable
      end
   end
   return false
end
function ItemInterface:deconstruct()
   if self:isInvalid() then
      return false, self.FAILURE_ITEM_IS_INVALID
   end
   if self.locked then
      return false, self.FAILURE_ITEM_IS_LOCKED
   end
   if not self:canDeconstruct() then
      return false, self.FAILURE_CANNOT_DECONSTRUCT
   end
   ExtractOrRefineSmithingItem(self.bag, self.slot)
   self:onModifyingAction("deconstruct")
   self.invalid   = true
   self.destroyed = true
   return true
end
function ItemInterface:destroy(count)
   if self:isInvalid() then
      return false, self.FAILURE_ITEM_IS_INVALID
   end
   if self.locked then
      return false, self.FAILURE_ITEM_IS_LOCKED
   end
   if count == nil or count >= self.count then
      DestroyItem(self.bag, self.slot)
      self.destroyed = true
      self.invalid   = true
      self:onModifyingAction("destroy", self.count)
      self:updateCount(-self.count)
   else
      if count == 0 then -- don't even bother, lol
         return true
      end
      local result, code = StackTools:split(self, count)
      if not result then
         return false, code
      end
      self.invalid = true
      result:done(function(bag, slot)
         DestroyItem(bag, slot)
         self:onModifyingAction("destroy", count)
      end)
   end
   return true
end
function ItemInterface:is(instance)
   assert(self == ItemInterface, "This is a static method.")
   if instance then
      return getmetatable(instance) == self.meta
   end
   return false
end
function ItemInterface:isDestroyed()
   return self.destroyed
end
function ItemInterface:isInvalid()
   return self.invalid
end
function ItemInterface:launder(count)
   if self:isInvalid() then
      return false, self.FAILURE_ITEM_IS_INVALID
   end
   if not count then
      count = self.count
   end
   if count > self.count then
      count = self.count
   end
   count = ItemInterface.validateLaunderOperation(count)
   if count < 1 then
      return false, self.FAILURE_ZENIMAX_LAUNDER_LIMIT
   end
   LaunderItem(self.bag, self.slot, count)
   self:onModifyingAction("launder", count)
   self:updateCount(-count)
   return true
end
function ItemInterface:modifyJunkState(flag)
   if self:isInvalid() then
      return false, ItemInterface.FAILURE_ITEM_IS_INVALID
   end
   if self.canBeJunk then
      SetItemIsJunk(self.bag, self.slot, flag)
      self.hasJunkFlag = IsItemJunk(self.bag, self.slot)
      local result = self.hasJunkFlag == flag
      if result then
         self:onModifyingAction("modifyJunkState", flag)
      end
      return result
   end
   return false, ItemInterface.FAILURE_CANNOT_FLAG_AS_JUNK
end
function ItemInterface:modifyLockState(flag)
   if self:isInvalid() then
      return false, ItemInterface.FAILURE_ITEM_IS_INVALID
   end
   if self.canBeLocked then
      SetItemIsPlayerLocked(self.bag, self.slot, flag)
      self.locked = IsItemPlayerLocked(self.bag, self.slot)
      local result = self.locked == flag
      if result then
         self:onModifyingAction("modifyLockState", flag)
      end
      return result
   end
   return false, ItemInterface.FAILURE_CANNOT_LOCK
end
function ItemInterface:onModifyingAction(action, ...)
   --
   -- The environment -- the broader add-on that this system is being 
   -- used in -- should override this function on the class, to run 
   -- code whenever an action is taken that will modify an item.
   --
   -- The (action) parameter is a string.
   --
end
function ItemInterface:sell(count)
   if self:isInvalid() then
      return
   end
   if not count then
      count = self.count
   end
   if count > self.count then
      count = self.count
   end
   SellInventoryItem(self.bag, self.slot, count)
   self:onModifyingAction("sell", count)
   self:updateCount(-count)
end
function ItemInterface:totalForBag(bag)
   if self.bag == BAG_BACKPACK then
      return self.totalBag
   elseif self.bag == BAG_BANK then
      return self.totalBank
   elseif self.bag == BAG_SUBSCRIBER_BANK then
      return self.totalCraftBag
   end
end
function ItemInterface:updateCount(change)
   if change < 0 and -change > self.count then
      change = -self.count
   end
   self.count = self.count + change
   if self.bag == BAG_BACKPACK then
      self.totalBag = self.totalBag + change
   elseif self.bag == BAG_BANK then
      self.totalBank = self.totalBank + change
   elseif self.bag == BAG_SUBSCRIBER_BANK then
      self.totalCraftBag = self.totalCraftBag + change
   end
end
function ItemInterface:use()
   if self:isInvalid() then
      return
   end
   --
   -- TODO: Should we check CanInteractWithItem first?
   --
   UseItem(self.bag, self.slot) -- TODO: this only works out of combat; what happens if called while in combat? does it throw an error?
   self.count = select(2, GetItemInfo(self.bag, self.slot))
   if self.count == 0 then
      self.invalid = true
   end
end
function ItemInterface:validate()
   local link = GetItemLink(self.bag, self.slot)
   if link ~= self.link then
      self.invalid = true
   end
   return not self:isInvalid()
end
function ItemInterface.validateLaunderOperation(count) -- static method; uses stdcall, not thiscall
   --
   -- The environment -- the broader add-on that this system is being 
   -- used in -- should override this function on the class, to check 
   -- whether a launder operation is possible. Zenimax only allows 98 
   -- automated launders every time the fence window is opened.
   --
   return count
end