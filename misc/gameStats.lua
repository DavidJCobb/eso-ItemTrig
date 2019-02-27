function ItemTrig.getCurrentCraftingRank(craftingType)
   --
   -- The player's crafting rank (i.e. the crafting skills they 
   -- have) for a given crafting type.
   --
   local stat = NON_COMBAT_BONUS_INVALID -- Will return 0.
   if craftingType == CRAFTING_TYPE_ALCHEMY then
      stat = NON_COMBAT_BONUS_ALCHEMY_LEVEL
   elseif craftingType == CRAFTING_TYPE_BLACKSMITHING then
      stat = NON_COMBAT_BONUS_BLACKSMITHING_LEVEL
   elseif craftingType == CRAFTING_TYPE_CLOTHIER then
      stat = NON_COMBAT_BONUS_CLOTHIER_LEVEL
   elseif craftingType == CRAFTING_TYPE_ENCHANTING then
      stat = NON_COMBAT_BONUS_ENCHANTING_LEVEL
   elseif craftingType == CRAFTING_TYPE_WOODWORKING then
      stat = NON_COMBAT_BONUS_WOODWORKING_LEVEL
   elseif craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
      stat = NON_COMBAT_BONUS_JEWELRYCRAFTING_LEVEL
   end
   return GetNonCombatBonus(stat)
end
function ItemTrig.getProvisioningQualityLimit()
   --
   -- The player cannot cook items rarer than this quality value.
   --
   return GetNonCombatBonus(NON_COMBAT_BONUS_PROVISIONING_RARITY_LEVEL)
end