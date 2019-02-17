ItemTrig.ItemInterface = {}
local ItemInterface = ItemTrig.ItemInterface

--[[
   As of 2/17/2019, benchmarks suggest that when creating an item interface from 
   the "item added" event, it takes an average of 11.5ms to create 400 interfaces, 
   or an average of 0.02875ms to create a single interface. The longest time we 
   observed in tests was (21 / 400) ms for an Alchemy Bottle picked up from the 
   world; the shortest was (6 / 400) ms.
]]--

ItemInterface.__index = ItemInterface
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
   return result
end
function ItemInterface:destroy()
   if self:isInvalid() then
      return
   end
   DestroyItem(self.bag, self.slot)
   self.destroyed = true
   self.invalid   = true
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
function ItemInterface:update()
end
function ItemInterface:use()
   if self:isInvalid() then
      return
   end
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