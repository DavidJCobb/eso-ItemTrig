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

function ItemTrig.countStolen(bag)
   local totalItems  = 0
   local totalStacks = 0
   local slot = ZO_GetNextBagSlotIndex(bag)
   while slot do
      if HasItemInSlot(bag, slot) then
         if IsItemStolen(bag, slot) then
            local _, stack, _, _, _, _, _, _ = GetItemInfo(bag, slot)
            totalStacks = totalStacks + 1
            totalItems  = totalItems  + stack
         end
      end
      slot = ZO_GetNextBagSlotIndex(bag, slot)
   end
   return totalItems, totalStacks
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
            deferred:resolve(bagIndex, slotIndex, slotData.extra)
         end
      end
      bagData[slotIndex] = nil
      if deferred:isPending() then
         --
         -- The item slot wasn't what we expected. Signal an invalid stack 
         -- state suggesting a failed stack split.
         --
         deferred:reject(bagIndex, slotIndex, slotData.extra)
      end
   end
   --
   function StackTools:earmarkSlot(bag, slot, id, count, extra)
      --
      -- The (bag) and (slot) parameters are the item's destination. The 
      -- (id) and (count) parameters are the item ID of the item you're 
      -- moving, and the count that the slot should have if your move 
      -- operation completes successfully. (This is not the same as the 
      -- count that you're moving, if you're moving to an existing  
      -- stack.)
      --
      if not self.pendingSplits[bag] then
         self.pendingSplits[bag] = {}
      end
      local registration = {
         id       = id,
         count    = count,
         deferred = ItemTrig.Deferred:new(),
         extra    = extra
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
   function StackTools:send(sourceBag, sourceSlot, destBag, count)
      --
      -- Send an item to another bag. Note that this function is, 
      -- as of this writing, untested.
      --
      if not count then
         count = GetSlotStackSize(sourceBag, sourceSlot)
      end
      if count < 1 then
         return ItemTrig.Deferred:resolve():promise()
      end
      if destBag == BAG_VIRTUAL then
         PickupInventoryItem(sourceBag, sourceSlot, count)
         PlaceInInventory(BAG_VIRTUAL, 0)
         return ItemTrig.Deferred:resolve():promise()
      end
      local free = self:findFreeSlot(destBag)
      if not free then
         return ItemTrig.Deferred:reject():promise()
      end
      local id = GetItemId(sourceBag, sourceSlot)
      CallSecureProtected("RequestMoveItem", sourceBag, sourceSlot, destBag, free, count)
      return self:earmarkSlot(destBag, free, id, count):promise()
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

local APILimits = {}
ItemTrig.ItemAPILimits = APILimits
do
   --
   -- APILimits
   --
   -- Some item-related APIs have a hard limit on the number of actions you 
   -- can perform per frame; exceeding this limit will cause the player to 
   -- be disconnected from the server. This singleton manages the limits.
   --
   -- An add-on using this system must call the setup(...) method once loaded, so 
   -- that this system registers the events it needs in order to function. If the 
   -- add-on has teardown routines, it can likewise call the teardown() method.
   --
   ItemTrig.assign(APILimits, {
      limits = {
         autoLaunders = 100,
      },
      safeties = { -- stop X below the limit, to be considerate to other add-ons
         autoLaunders = 2,
      },
      state = {},
      --
      eventPrefix = nil,
      listening   = false,
   })
   function APILimits:capToLimit(name, count)
      assert(name,  "You must specify a limit name.")
      assert(count, "You must specify a count.")
      assert(self.limits[name], "Invalid limit name: " .. tostring(name) .. ".")
      local limit = self.limits[name] - (self.safeties[name] or 0)
      local state = self.state[name] or 0
      if state + count <= limit then
         return count
      end
      return math.max(0, limit - state)
   end
   function APILimits:trackOperation(name, count)
      assert(name,  "You must specify a limit name.")
      assert(count, "You must specify a count.")
      assert(self.limits[name], "Invalid limit name: " .. tostring(name) .. ".")
      self.state[name] = (self.state[name] or 0) + count
   end
   --
   function APILimits:capLaunder(count)
      return self:capToLimit("autoLaunders", count)
   end
   function APILimits:didLaunder(count)
      return self:trackOperation("autoLaunders", count)
   end
   --
   local function _listener(eventCode, ...)
      if eventCode == EVENT_OPEN_FENCE then
         APILimits.state.autoLaunders = 0
      end
   end
   function APILimits:teardown()
      local namespace = self.eventPrefix .. "ItemAPILimitsListener"
      EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_OPEN_FENCE)
      self.listening = false
   end
   function APILimits:setup(eventPrefix)
      if self.listening then
         self:teardown()
      end
      self.eventPrefix = eventPrefix
      local namespace = eventPrefix .. "ItemAPILimitsListener"
      EVENT_MANAGER:RegisterForEvent (namespace, EVENT_OPEN_FENCE, _listener)
      self.listening = true
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
    - IsItemSoulGem(bag, slot)
]]--

local function _nilIfInvalid(i, r)
   --
   -- Lua doesn't have ternary operators, and the nearest equivalent  
   -- sucks. The equivalent of (a ? b : c) breaks if (b) is ever falsy.
   --
   if i.invalid then
      return nil
   end
   return r
end

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
         local traitData = {}
         for j = 1, GetMaxTraits() do
            local known, name = GetItemLinkReagentTraitInfo(i.link, j)
            traitData[j] = {
               name  = name,
               known = known,
            }
         end
         return traitData
      end,
   alchemyTraitDetails =
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
   canBeJunk      = function(i) return _nilIfInvalid(i, CanItemBeMarkedAsJunk(i.bag, i.slot)) end,
   canBeLocked    = function(i) return _nilIfInvalid(i, CanItemBePlayerLocked(i.bag, i.slot)) end,
   countTotal     = function(i) return _nilIfInvalid(i, GetItemTotalCount(i.bag, i.slot))     end,
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
   formattedName = function(i) return LocalizeString("<<1>>", i.name) end,
   gemifyData =
      function(i)
         if i.invalid then
            return nil
         end
         if not i.isCrownCrateItem then
            return nil
         end
         local itemsPer, gemsPer = GetNumCrownGemsFromItemManualGemification(i.bag, i.slot)
         return {
            itemsPerOperation = itemsPer,
            gemsPerOperation  = gemsPer,
         }
      end,
   hasJunkFlag      = function(i) return _nilIfInvalid(i, IsItemJunk(i.bag, i.slot))              end,
   isBook           = function(i) return _nilIfInvalid(i, IsItemLinkBook(i.link))                 end,
   isBound          = function(i) return _nilIfInvalid(i, IsItemBound(i.bag, i.slot))             end,
   isCrownCrateItem = function(i) return _nilIfInvalid(i, IsItemFromCrownCrate(i.bag, i.slot))    end,
   isCrownStoreItem = function(i) return _nilIfInvalid(i, IsItemFromCrownStore(i.bag, i.slot))    end,
   isKnownLorebook  = function(i) return _nilIfInvalid(i, IsItemLinkBookKnown(i.link))            end,
   isKnownRecipe    = function(i) return _nilIfInvalid(i, IsItemLinkRecipeKnown(i.link))          end, -- provisioning
   isLorebook       = function(i) return _nilIfInvalid(i, IsItemLinkBookPartOfCollection(i.link)) end,
   isPrioritySell   = function(i) return _nilIfInvalid(i, IsItemLinkPrioritySell(i.link))         end,
   isResearchable   = function(i) return _nilIfInvalid(i, CanItemLinkBeTraitResearched(i.link))   end,
   itemFilters      = function(i) return not i.invalid and {GetItemFilterTypeInfo(i.bag, i.slot)} or {} end,
   itemSetData  =
      function(i)
         if i.invalid then
            return nil
         end
         local hasSet, setName, numBonuses, numEquipped, maxEquipped = GetItemLinkSetInfo(i.link)
         return {
            hasSet        = hasSet,
            name          = setName,
            bonusCount    = numBonuses,
            equippedCount = numEquipped,
            maxEquipped   = maxEquipped,
         }
      end,
   recipeType   = function(i) return _nilIfInvalid(i, GetItemLinkRecipeCraftingSkillType(i.link)) end,
   soulGemInfo  =
      function(i)
         if i.invalid then
            return nil
         end
         local tier, filled = GetSoulGemItemInfo(i.bag, i.slot)
         return {
            isFilled  = filled,
            isSoulGem = (tier ~= 0),
            tier      = tier,
         }
      end,
   specialTrait = function(i) return _nilIfInvalid(i, GetItemTraitInformation(i.bag, i.slot)) end,
   treasureTags =
      function(i)
         local tags  = {}
         local count = GetItemLinkNumItemTags(i.link)
         for j = 1, count do
            local text, cat = GetItemLinkItemTagInfo(i.link, j)
            if cat == TAG_CATEGORY_TREASURE_TYPE then
               tags[#tags + 1] = text
            end
         end
         return tags
      end,
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
   ItemInterface.FAILURE_BANK_CANT_STORE_STOLEN  = "BKST" -- You can't store stolen items in the bank.
   ItemInterface.FAILURE_BANK_IS_FULL            = "BKFL" -- The bank is full.
   ItemInterface.FAILURE_BANK_IS_NOT_OPEN        = "BKNO" -- You must have the bank open.
   ItemInterface.FAILURE_CANNOT_DECONSTRUCT      = "DCON" -- This item type can't be deconstructed.
   ItemInterface.FAILURE_CANNOT_FLAG_AS_JUNK     = "NJNK" -- This item type can't be flagged as junk.
   ItemInterface.FAILURE_CANNOT_LOCK             = "NLOK" -- This item type can't be locked.
   ItemInterface.FAILURE_CANNOT_SPLIT_STACK      = "SPLT" -- Cannot split the stack; your inventory is full.
   ItemInterface.FAILURE_ITEM_IS_INVALID         = "INVA" -- The ItemInterface is invalid: the bag slot now contains something different.
   ItemInterface.FAILURE_ITEM_IS_LOCKED          = "LOCK" -- Cannot perform this operation on a locked item.
   ItemInterface.FAILURE_MOD_NOT_SETUP           = "NOPE" -- The mod wasn't set up properly.
   ItemInterface.FAILURE_NORMAL_FENCE_LIMIT      = "FENL" -- You've hit the limit of items you can fence for today.
   ItemInterface.FAILURE_NORMAL_LAUNDER_LIMIT    = "LNDR" -- You've hit the limit of items you can launder for the day.
   ItemInterface.FAILURE_LAUNDER_CANT_AFFORD     = "LNDG" -- You don't have enough gold to launder this item.
   ItemInterface.FAILURE_LAUNDER_NOT_STOLEN      = "LDNS" -- You can't launder something that isn't stolen!
   ItemInterface.FAILURE_ZENIMAX_LAUNDER_LIMIT   = "ZLND" -- We've hit the maximum number of items Zenimax allows add-ons to launder every time the fence is opened.
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
function ItemInterface:canGemify()
   if self:isInvalid() then
      return
   end
   if self.locked then
      return false
   end
   local data = self.gemifyData
   return data.itemsPerOperation > 0 and data.gemsPerOperation > 0
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
   --
   -- TODO: We need to use ExtractEnchantingItem for glyphs
   --
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
function ItemInterface:hasFilterType(ft)
   for i = 1, #self.itemFilters do
      if self.itemFilters[i] == ft then
         return true
      end
   end
   return false
end
function ItemInterface:is(instance)
   assert(self == ItemInterface, "This is a static method.")
   if instance then
      return getmetatable(instance) == self.meta
   end
   return false
end
function ItemInterface:isClothes()
   --
   -- "Clothes" here refers to equippable clothing that confers no 
   -- armor. This does not include disguises.
   --
   if self.type ~= ITEMTYPE_ARMOR or self.armorType ~= ARMORTYPE_NONE then
      return false
   end
   if self.equipType == EQUIP_TYPE_NECK -- Jewelry check
   or self.equipType == EQUIP_TYPE_RING
   then
      return false
   end
   if self.equipType == EQUIP_TYPE_INVALID then
      return false
   end
   return true
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
   if not self.stolen then
      return false, self.FAILURE_LAUNDER_NOT_STOLEN
   end
   if not count then
      count = self.count
   end
   if count > self.count then
      count = self.count
   end
   local willFail = false
   do -- Constrain the launder count based on the number of available launder operations.
      local max, used = GetFenceLaunderTransactionInfo()
      local remaining = max - used
      if count > remaining then
         willFail = self.FAILURE_NORMAL_LAUNDER_LIMIT
         count    = remaining
         if count < 1 then
            return false, willFail
         end
      end
   end
   do -- Constrain the launder count based on the player's gold.
      local cost = GetItemLaunderPrice(self.bag, self.slot)
      local gold = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
      if (cost * count) > gold then
         willFail = self.FAILURE_LAUNDER_CANT_AFFORD
         count    = math.floor(gold / cost)
         if count < 1 then
            return false, willFail
         end
      end
   end
   do -- Constrain the launder count based on the add-on limit, AND update the currently used launders.
      count = APILimits:capLaunder(count)
      if count < 1 then
         return false, self.FAILURE_ZENIMAX_LAUNDER_LIMIT
      end
   end
   LaunderItem(self.bag, self.slot, count)
   APILimits:didLaunder(count)
   self:onModifyingAction("launder", count)
   self:updateCount(-count)
   if willFail then
      return false, willFail
   end
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
do
   local _mapArmorTypes = {
      [ARMORTYPE_LIGHT]  = CRAFTING_TYPE_CLOTHIER,
      [ARMORTYPE_MEDIUM] = CRAFTING_TYPE_CLOTHIER,
      [ARMORTYPE_HEAVY]  = CRAFTING_TYPE_BLACKSMITHING,
   }
   local _mapWeaponTypes = {
      [WEAPONTYPE_AXE]               = CRAFTING_TYPE_BLACKSMITHING,
      [WEAPONTYPE_BOW]               = CRAFTING_TYPE_WOODWORKING,
      [WEAPONTYPE_DAGGER]            = CRAFTING_TYPE_BLACKSMITHING,
      [WEAPONTYPE_FIRE_STAFF]        = CRAFTING_TYPE_WOODWORKING,
      [WEAPONTYPE_FROST_STAFF]       = CRAFTING_TYPE_WOODWORKING,
      [WEAPONTYPE_HAMMER]            = CRAFTING_TYPE_BLACKSMITHING,
      [WEAPONTYPE_HEALING_STAFF]     = CRAFTING_TYPE_WOODWORKING,
      [WEAPONTYPE_LIGHTNING_STAFF]   = CRAFTING_TYPE_WOODWORKING,
      [WEAPONTYPE_SHIELD]            = CRAFTING_TYPE_WOODWORKING,
      [WEAPONTYPE_SWORD]             = CRAFTING_TYPE_BLACKSMITHING,
      [WEAPONTYPE_TWO_HANDED_AXE]    = CRAFTING_TYPE_BLACKSMITHING,
      [WEAPONTYPE_TWO_HANDED_HAMMER] = CRAFTING_TYPE_BLACKSMITHING,
      [WEAPONTYPE_TWO_HANDED_SWORD]  = CRAFTING_TYPE_BLACKSMITHING,
   }
   function ItemInterface:pertinentCraftingType()
      if self.craftingSkill ~= CRAFTING_TYPE_INVALID then
         return self.craftingSkill
      end
      if self.type == ITEMTYPE_RECIPE then
         return self.recipeType
      end
      if self.armorType ~= ARMORTYPE_NONE then
         return _mapArmorTypes[self.armorType]
      end
      if self.weaponType ~= WEAPONTYPE_NONE then
         return _mapWeaponTypes[self.weaponType]
      end
      if self.equipType == EQUIP_TYPE_NECK
      or self.equipType == EQUIP_TYPE_RING
      then
         return CRAFTING_TYPE_JEWELRYCRAFTING
      end
      local it = self.type
      if it == ITEMTYPE_POISON_BASE
      or it == ITEMTYPE_POTION_BASE
      or it == ITEMTYPE_REAGENT
      then
         return CRAFTING_TYPE_ALCHEMY
      end
      if it == ITEMTYPE_BLACKSMITHING_MATERIAL
      or it == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL
      or it == ITEMTYPE_BLACKSMITHING_BOOSTER
      then
         return CRAFTING_TYPE_BLACKSMITHING
      end
      if it == ITEMTYPE_CLOTHIER_MATERIAL
      or it == ITEMTYPE_CLOTHIER_RAW_MATERIAL
      or it == ITEMTYPE_CLOTHIER_BOOSTER
      then
         return CRAFTING_TYPE_CLOTHIER
      end
      if it == ITEMTYPE_ENCHANTING_RUNE_ASPECT
      or it == ITEMTYPE_ENCHANTING_RUNE_ESSENCE
      or it == ITEMTYPE_ENCHANTING_RUNE_POTENCY
      or it == ITEMTYPE_GLYPH_ARMOR
      or it == ITEMTYPE_GLYPH_JEWELRY
      or it == ITEMTYPE_GLYPH_WEAPON
      then
         return CRAFTING_TYPE_ENCHANTING
      end
      if it == ITEMTYPE_JEWELRYCRAFTING_BOOSTER
      or it == ITEMTYPE_JEWELRYCRAFTING_MATERIAL
      or it == ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER
      or it == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL
      or it == ITEMTYPE_JEWELRY_RAW_TRAIT
      or it == ITEMTYPE_JEWELRY_TRAIT
      then
         return CRAFTING_TYPE_JEWELRYCRAFTING
      end
      if it == ITEMTYPE_INGREDIENT
      or it == ITEMTYPE_DRINK
      or it == ITEMTYPE_FOOD
      then
         return CRAFTING_TYPE_PROVISIONING
      end
      if it == ITEMTYPE_WOODWORKING_MATERIAL
      or it == ITEMTYPE_WOODWORKING_RAW_MATERIAL
      or it == ITEMTYPE_WOODWORKING_BOOSTER
      then
         return CRAFTING_TYPE_WOODWORKING
      end
      return CRAFTING_TYPE_INVALID
   end
end
function ItemInterface:sell(count)
   if self:isInvalid() then
      return false, ItemInterface.FAILURE_ITEM_IS_INVALID
   end
   if self.locked then
      return false, ItemInterface.FAILURE_ITEM_IS_LOCKED
   end
   if not count then
      count = self.count
   end
   if count > self.count then
      count = self.count
   end
   local willFail = false
   do
      local max, used = GetFenceSellTransactionInfo()
      local remaining = max - used
      if count > remaining then
         willFail = true
         count    = remaining
         if remaining == 0 then
            return false, self.FAILURE_NORMAL_FENCE_LIMIT
         end
      end
   end
   SellInventoryItem(self.bag, self.slot, count)
   self:onModifyingAction("sell", count)
   self:updateCount(-count)
   if willFail then
      return false, self.FAILURE_NORMAL_FENCE_LIMIT
   end
   return true
end
function ItemInterface:storeInBank(count)
   if self:isInvalid() then
      return false, self.FAILURE_ITEM_IS_INVALID
   end
   if not IsBankOpen() then
      return false, self.FAILURE_BANK_IS_NOT_OPEN
   end
   if self.stolen then
      return false, self.FAILURE_BANK_CANT_STORE_STOLEN
   end
   if not DoesBagHaveSpaceFor(BAG_BANK, self.bag, self.slot) then
      return false, self.FAILURE_BANK_IS_FULL
   end
   if not (count and count <= self.count) then
      count = self.count
   end
   CallSecureProtected("PickupInventoryItem", self.bag, self.slot, count)
   CallSecureProtected("PlaceInTransfer")
   self:updateCount(-count)
   self:onModifyingAction("deposit-bank", count)
   return true
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