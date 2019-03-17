local Trigger   = ItemTrig.Trigger
local Action    = ItemTrig.Action
local Condition = ItemTrig.Condition
local OpcodeQuantityArg = ItemTrig.OpcodeQuantityArg

-- FLAG: Condition 9 (Added Item Cause) is subject to API limits: as of this 
-- writing, we cannot differentiate between an item moving between two bags 
-- and an item's stack being split within one bag, so we cannot check whether 
-- an item was withdrawn from the bank.
--
local CAN_CHECK_WHETHER_ADDED_ITEM_WAS_WITHDRAWN = false

local ITEM_NAME_LOCKPICK = ItemTrig.getNaiveItemNameFor(30357)

function ItemTrig.retrieveTriggerGallery()
   local gallery = {}
   do -- Deconstruct "intricate" gear for bonus XP
      local t = Trigger:new()
      t.name        = GetString(ITEMTRIG_STRING_GALLERY_DECONSTRUCTINTRICATE_NAME)
      t.entryPoints = { ItemTrig.ENTRY_POINT_CRAFTING }
      local cl = t.conditions
      local al = t.actions
      --
      cl[1] = Condition:new(35, { true }) -- Current crafting station [is] appropriate for this item
      cl[2] = Condition:new(24, { true }) -- The item [is] intricate
      --
      al[1] = Action:new(9) -- Deconstruct the item.
      --
      table.insert(gallery, t)
   end
   do -- Sell "ornate" gear for additional gold
      local t = Trigger:new()
      t.name        = GetString(ITEMTRIG_STRING_GALLERY_SELLORNATE_NAME)
      t.entryPoints = { ItemTrig.ENTRY_POINT_BARTER }
      local cl = t.conditions
      local al = t.actions
      --
      cl[1] = Condition:new(23, { true }) -- The item [is] ornate.
      --
      al[1] = Action:new(8, { 9999 }) -- Sell [9999] of the item.
      --
      table.insert(gallery, t)
   end
   do -- This trigger will never run
      local t = Trigger:new()
      t.name        = GetString(ITEMTRIG_STRING_GALLERY_NEVEREXAMPLE_NAME)
      t.entryPoints = { ItemTrig.ENTRY_POINT_ITEM_ADDED }
      local cl = t.conditions
      local al = t.actions
      --
      cl[1] = Condition:new(1, { GetString(ITEMTRIG_STRING_GALLERY_NEVEREXAMPLE_COMMENT) }) -- Comment
      cl[2] = Condition:new(3, { false }) -- [Never].
      --
      al[1] = Action:new(2, { GetString(ITEMTRIG_STRING_GALLERY_NEVEREXAMPLE_MESSAGE) }) -- Log Message
      --
      table.insert(gallery, t)
   end
   do -- Destroy common style materials past one stack, unless withdrawn or purchased
      local t = Trigger:new()
      t.name        = GetString(ITEMTRIG_STRING_GALLERY_DESTROYEXCESSSTYLEMATS_NAME)
      t.entryPoints = { ItemTrig.ENTRY_POINT_ITEM_ADDED }
      local cl = t.conditions
      local al = t.actions
      --
      local i = 0
      cl[1] = Condition:new(10, { true }) -- Added item [is] a new stack
      cl[2] = Condition:new( 9, { false, 1 }) -- Added item [was not] [purchased]
      if CAN_CHECK_WHETHER_ADDED_ITEM_WAS_WITHDRAWN then
         cl[3] = Condition:new( 9, { false, 3 }) -- Added item [was not] [withdrawn]
         i = 1
      end
      cl[3 + i] = Condition:new( 7, { true, ITEMTYPE_STYLE_MATERIAL }) -- Added item [is] a [style material]
      cl[4 + i] = Condition:new(17, { true, -2 }) -- Added item's style [is] [any racial style]
      cl[5 + i] = Condition:new(11, { BAG_BACKPACK, { qualifier = "GTE", number = 200 } }) -- [Player inventory] contains [at least 200]
      --
      al[1] = Action:new(5, { false }) -- Destroy [the entire stack]
      --
      table.insert(gallery, t)
   end
   do -- Destroy low-rarity stolen goods, but stockpile Covetous Countess goods
      local t = Trigger:new()
      t.name = GetString(ITEMTRIG_STRING_GALLERY_DESTROYSTOLENCRAPTREASURE_NAME)
      t.entryPoints = { ItemTrig.ENTRY_POINT_ITEM_ADDED }
      local cl = t.conditions
      local al = t.actions
      --
      cl[1] = Condition:new(10, { true }) -- Added item [is] a new stack
      cl[2] = Condition:new( 4, { true }) -- Added item [is] stolen
      cl[3] = Condition:new( 7, { true, ITEMTYPE_TREASURE }) -- Item type [is] [Treasure]
      cl[4] = Condition:new( 6, { { qualifier = "LTE", number = ITEM_QUALITY_NORMAL } }) -- Rarity is [at most Normal]
      --
      do -- Run Nested Trigger: ...Unless we can stockpile them for The Covetous Countess
         local t = Trigger:new()
         t.name = GetString(ITEMTRIG_STRING_GALLERY_DESTROYSTOLENCRAPTREASURE_NAME_NESTED_01)
         local clNested = t.conditions
         local alNested = t.actions
         clNested[1] = Condition:new( 2, { true }) -- Use [OR] for conditions
         --
         -- There are multiple overlapping pairs between all of the Covetous 
         -- Countess objectives; you can cover all five potential objectives 
         -- using three items, so it's just a matter of deciding on a spec-
         -- ific trio to use. I'm going with:
         --
         -- Ayleid House Idol
         -- Pocket Rules For Kick the Khajiit
         -- Logic Fob
         --
         clNested[2] = Condition:new(12, { ItemTrig.getNaiveItemNameFor(61737), false }) -- Item name [is] [Ayleid House Idol]
         clNested[3] = Condition:new(12, { ItemTrig.getNaiveItemNameFor(74581), false }) -- Item name [is] [Pocket Rules For Kick the Khajiit]
         clNested[4] = Condition:new(12, { ItemTrig.getNaiveItemNameFor(64409), false }) -- Item name [is] [Logic Fob]
         --
         alNested[1] = Action:new(4, { GetString(ITEMTRIG_STRING_GALLERY_DESTROYSTOLENCRAPTREASURE_COMMENT) }) -- Comment
         alNested[2] = Action:new(1) -- Stop execution of the top-level trigger
         --
         al[1] = Action:new(3, { t })
      end
      al[2] = Action:new(5, { true }) -- Destroy [the whole stack]
      --
      table.insert(gallery, t)
   end
   do -- Launder the Covetous Countess items
      local t = Trigger:new()
      t.name        = GetString(ITEMTRIG_STRING_GALLERY_LAUNDERCOVETOUSCOUNTESS_NAME)
      t.entryPoints = { ItemTrig.ENTRY_POINT_FENCE }
      local cl = t.conditions
      local al = t.actions
      --
      cl[1] = Condition:new( 4, { true }) -- Added item [is] stolen
      cl[2] = Condition:new(36, { { qualifier = "GTE", number = 1 } }) -- Player can still launder
      cl[3] = Condition:new( 2, { true }) -- Use [OR] for conditions
      cl[4] = Condition:new(12, { ItemTrig.getNaiveItemNameFor(61737), false }) -- Item name [is] [Ayleid House Idol]
      cl[5] = Condition:new(12, { ItemTrig.getNaiveItemNameFor(74581), false }) -- Item name [is] [Pocket Rules For Kick the Khajiit]
      cl[6] = Condition:new(12, { ItemTrig.getNaiveItemNameFor(64409), false }) -- Item name [is] [Logic Fob]
      --
      al[1] = Action:new(7, { 9999 }) -- Launder as many as possible.
      --
      table.insert(gallery, t)
   end
   do -- Destroy stolen junk
      local t = Trigger:new()
      t.name        = GetString(ITEMTRIG_STRING_GALLERY_DESTROYSTOLENJUNK_NAME)
      t.entryPoints = { ItemTrig.ENTRY_POINT_ITEM_ADDED }
      local cl = t.conditions
      local al = t.actions
      --
      cl[ 1] = Condition:new(10, { true }) -- Added item [is] a new stack
      cl[ 2] = Condition:new( 4, { true }) -- Added item [is] stolen
      cl[ 3] = Condition:new( 2, { true }) -- Use [OR].
      cl[ 4] = Condition:new(33, { true }) -- Added item [is] clothes
      cl[ 5] = Condition:new( 7, { true, -9 }) -- Added item [is] an [any equippable]
      cl[ 6] = Condition:new( 7, { true, -2 }) -- Added item [is] an [any food or drink]
      cl[ 7] = Condition:new( 7, { true, ITEMTYPE_INGREDIENT }) -- Added item [is] an [ingredient]
      cl[ 8] = Condition:new( 7, { true, ITEMTYPE_POTION }) -- Added item [is] a [potion]
      cl[ 9] = Condition:new( 7, { true, ITEMTYPE_POISON }) -- Added item [is] a [poison]
      cl[10] = Condition:new( 7, { true, ITEMTYPE_STYLE_MATERIAL }) -- Added item [is] a [style material]
      cl[11] = Condition:new(12, { ITEM_NAME_LOCKPICK, false }) -- Item name [is] [Lockpick]
      --
      do -- Run Nested Trigger: Exempt rare style materials
         local t = Trigger:new()
         t.name = GetString(ITEMTRIG_STRING_GALLERY_DESTROYSTOLENJUNK_NAME_NESTED_01)
         local clNested = t.conditions
         local alNested = t.actions
         clNested[1] = Condition:new( 7, { true, ITEMTYPE_STYLE_MATERIAL }) -- Added item [is] a [style material]
         clNested[2] = Condition:new(17, { false, -2 }) -- Item name [is not] [any racial style]
         --
         alNested[1] = Action:new(1) -- Stop execution of the top-level trigger
         --
         al[1] = Action:new(3, { t })
      end
      do -- Run Nested Trigger: Exempt rare equipment
         local t = Trigger:new()
         t.name = GetString(ITEMTRIG_STRING_GALLERY_DESTROYSTOLENJUNK_NAME_NESTED_02)
         local clNested = t.conditions
         local alNested = t.actions
         clNested[1] = Condition:new(7, { true, -9 }) -- Added item [is] an [any equippable]
         clNested[2] = Condition:new(6, { { qualifier = "GTE", number = ITEM_QUALITY_ARCANE } }) -- Rarity is [at least] [Superior]
         --
         alNested[1] = Action:new(1) -- Stop execution of the top-level trigger
         --
         al[2] = Action:new(3, { t })
      end
      do -- Run Nested Trigger: Exempt ingredients that we could use more of
         local t = Trigger:new()
         t.name = GetString(ITEMTRIG_STRING_GALLERY_DESTROYSTOLENJUNK_NAME_NESTED_03)
         local clNested = t.conditions
         local alNested = t.actions
         clNested[1] = Condition:new( 7, { true, ITEMTYPE_INGREDIENT }) -- Added item [is] an [ingredient]
         clNested[2] = Condition:new(11, { BAG_BANK, { qualifier = "LTE", number = 199 } }) -- The player's [bank] has [at most 199] of the item
         --
         alNested[1] = Action:new(1) -- Stop execution of the top-level trigger
         --
         al[3] = Action:new(3, { t })
      end
      do -- Run Nested Trigger: Exempt rare potions and poisons
         local t = Trigger:new()
         t.name = GetString(ITEMTRIG_STRING_GALLERY_DESTROYSTOLENJUNK_NAME_NESTED_04)
         local clNested = t.conditions
         local alNested = t.actions
         clNested[1] = Condition:new(2, { true }) -- Use [OR].
         clNested[2] = Condition:new(7, { true, ITEMTYPE_POTION }) -- Added item [is] a [potion]
         clNested[3] = Condition:new(7, { true, ITEMTYPE_POISON }) -- Added item [is] a [poison]
         clNested[4] = Condition:new(2, { false }) -- Use [AND].
         clNested[5] = Condition:new(6, { { qualifier = "GTE", number = ITEM_QUALITY_ARCANE } }) -- Rarity is [at least] [Superior]
         --
         alNested[1] = Action:new(1) -- Stop execution of the top-level trigger
         --
         al[4] = Action:new(3, { t })
      end
      do -- Run Nested Trigger: Exempt lockpicks if we can carry more of them
         local t = Trigger:new()
         t.name = GetString(ITEMTRIG_STRING_GALLERY_DESTROYSTOLENJUNK_NAME_NESTED_05)
         local clNested = t.conditions
         local alNested = t.actions
         clNested[1] = Condition:new(12, { ITEM_NAME_LOCKPICK, false }) -- Item name [is] [Lockpick]
         clNested[2] = Condition:new(11, { BAG_BANK, { qualifier = "LTE", number = 199 } }) -- The player's [bank] has [at most 199] of the item
         --
         alNested[1] = Action:new(1) -- Stop execution of the top-level trigger
         --
         al[5] = Action:new(3, { t })
      end
      al[6] = Action:new(5, { false }) -- Destroy [the entire stack]
      --
      table.insert(gallery, t)
   end
   do -- Stop later triggers from running on certain item types
      local t = Trigger:new()
      t.name        = GetString(ITEMTRIG_STRING_GALLERY_STOPTRIGGERSEXAMPLE_NAME)
      t.entryPoints = {}
      for k in pairs(ItemTrig.ENTRY_POINT_NAMES) do -- we want all entry points
         t.entryPoints[#t.entryPoints + 1] = k
      end
      local cl = t.conditions
      local al = t.actions
      --
      cl[1] = Condition:new( 2, { true }) -- Use [OR] for conditions
      cl[2] = Condition:new(32, { true }) -- Item [is] a treasure map.
      cl[3] = Condition:new(21, { true, 3 }) -- Item [is] a [Crown Crate or Crown Store] item.
      cl[4] = Condition:new(13, { true }) -- Item [can be] researched.
      cl[5] = Condition:new(34, { true, 1 }) -- Item [is] a [filled] Soul Gem.
      --
      al[1] = Action:new( 4, { GetString(ITEMTRIG_STRING_GALLERY_STOPTRIGGERSEXAMPLE_COMMENT) }) -- Comment
      al[2] = Action:new(10) -- Stop processing triggers on this item
      --
      table.insert(gallery, t)
   end
   return gallery
end