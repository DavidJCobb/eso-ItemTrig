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

ItemInterface.__index = ItemInterface
do -- define failure reasons for member functions
   ItemInterface.FAILURE_CANNOT_SPLIT_STACK = 0x53504C54
   ItemInterface.FAILURE_ITEM_IS_INVALID    = 0x494E5641
   ItemInterface.FAILURE_ITEM_IS_LOCKED     = 0x4C4F434B
end
function ItemInterface:new(bagIndex, slotIndex)
   local result = setmetatable({}, self)
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
      creator       = GetItemCreatorName(bagIndex, slotIndex),
      level         = GetItemLevel(bagIndex, slotIndex),
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
   do -- link-dependent information
      ItemTrig.assign(result, {
         name = GetItemLinkName(result.link),
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
         locked    = locked,
         meetsUsageRequirement = meetsUsageRequirement,
         quality   = quality, -- this would be better described as "rarity"
         sellValue = sellPrice,
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
function ItemInterface:canBeJunk()
   if self.canBeJunk == nil then
      self.canBeJunk = CanItemBeMarkedAsJunk(self.bag, self.slot)
   end
   return self.canBeJunk
end
function ItemInterface:destroy(count)
   if self:isInvalid() then
      return false, self.FAILURE_ITEM_IS_INVALID
   end
   if self.locked then
      return false, self.FAILURE_ITEM_IS_LOCKED
   end
   if count == nil or count > self.count then
      DestroyItem(self.bag, self.slot)
      self.destroyed = true
      self.invalid   = true
   else
      --
      -- To destroy just some of the stack, we need to split the stack and 
      -- then destroy the new stack.
      --
      local targetSlot = FindFirstEmptySlotInBag(self.bag)
      if not targetSlot then
         return false, self.FAILURE_CANNOT_SPLIT_STACK
      end
      assert(false, "We don't currently have a way to implement this. The API is too limiting.")
      --[[
      RequestMoveItem(self.bag, self.slot, self.bag, targetSlot, count)
      local targetID = GetItemId(self.bag, targetSlot)
      if targetID ~= self.id then
         return false, self.FAILURE_CANNOT_SPLIT_STACK
      end
      DestroyItem(self.bag, targetSlot)
      self.count = GetSlotStackSize(self.bag, self.slot)
      if self.count < 1 then
         self.invalid = true
      end
      ]]--
   end
   return true
end
function ItemInterface:is(instance)
   assert(self == ItemInterface, "This is a static method.")
   if instance then
      return getmetatable(instance) == self
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
      return
   end
   LaunderItem(self.bag, self.slot, count or self.count)
end
function ItemInterface:modifyJunkState(flag)
   if self:isInvalid() then
      return false
   end
   if self:canBeJunk() then
      SetItemIsJunk(self.bag, self.slot, flag)
      self.locked = IsItemJunk(self.bag, self.slot)
      return self.locked == flag
   end
   return false
end
function ItemInterface:modifyLockState(flag)
   if self:isInvalid() then
      return
   end
   SetItemIsPlayerLocked(self.bag, self.slot, flag)
   self.locked = IsItemPlayerLocked(self.bag, self.slot)
end
function ItemInterface:sell(count)
   if self:isInvalid() then
      return
   end
   SellInventoryItem(self.bag, self.slot, count or self.count)
end
function ItemInterface:update()
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