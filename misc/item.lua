ItemTrig.ItemInterface = {}
local ItemInterface = ItemTrig.ItemInterface

ItemInterface.__index = ItemInterface
function ItemInterface:new(bagIndex, slotIndex)
   local result = setmetatable({}, self)
   ItemTrig.assign(result, {
      bag  = bagIndex,
      slot = slotIndex,
      id   = GetItemId(bagIndex, slotIndex),
      link = GetItemLink(bagIndex, slotIndex),
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
   do -- GetItemInfo
      local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, quality = GetItemInfo(bagIndex, slotIndex)
      ItemTrig.assign(result, {
         count     = stack,
         equipType = equipType,
         icon      = icon,
         style     = itemStyleId,
         locked    = locked,
         meetsUsageRequirement = meetsUsageRequirement,
         quality   = quality,
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
function ItemInterface:validate()
   local link = GetItemLink(self.bag, self.slot)
   if link ~= self.link then
      self.invalid = true
   end
   return not self:isInvalid()
end