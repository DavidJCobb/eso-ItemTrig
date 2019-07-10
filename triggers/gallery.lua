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

--[[
   THE TRIGGER GALLERY
   
   This is a list of pre-made triggers that the user can "import" into their 
   own trigger list.
   
   As of 1.0.9, each gallery trigger has a galleryID, which must be a unique 
   number. If a user imports a gallery trigger and never edits it, and if we 
   later make changes to the gallery trigger, then we can use the galleryID 
   to identify and update the imported trigger. This only works for top-level 
   triggers, and only top-level triggers should have a galleryID.
   
   Note also that an imported gallery trigger will only update if its name 
   matches the gallery trigger with the same galleryID. This may cause problems 
   if a user changes the language they play on, or if we rename a trigger, but 
   it's a useful check just to ~really~ make sure I don't make a destructive 
   mistake.
   
   If the add-on is loaded on my ESO account (@DavidJCobb), then a check will 
   be run to ensure that every gallery trigger has a unique ID. The first one 
   that fails to meet this requirement will throw an error (which means that 
   repeated /reloadui calls are needed if multiple mistakes were made).
]]--

function ItemTrig.retrieveTriggerGallery()
   --
   -- Latest galleryID as of July 10, 2019: 12
   -- See explanation above.
   --
   local gallery = {}
   do -- Deconstruct "intricate" gear for bonus XP
      local t = Trigger:new()
      t.name        = GetString(ITEMTRIG_STRING_GALLERY_DECONSTRUCTINTRICATE_NAME)
      t.entryPoints = { ItemTrig.ENTRY_POINT_CRAFTING }
      t.galleryID   = 1
      local cl = t.conditions
      local al = t.actions
      --
      cl[1] = Condition:new(15, { false }) -- The item [is not] locked
      cl[2] = Condition:new(24, { true }) -- The item [is] intricate
      cl[3] = Condition:new(35, { true }) -- Current crafting station [is] appropriate for this item
      cl[4] = Condition:new(50, { true }) -- Can Deconstruct
      
      -- TODO: Can Deconstruct tests the crafting station; we don't need Cond#35
      
      --
      al[1] = Action:new(9) -- Deconstruct the item.
      --
      table.insert(gallery, t)
   end
   do -- Sell "ornate" gear for additional gold
      local t = Trigger:new()
      t.name        = GetString(ITEMTRIG_STRING_GALLERY_SELLORNATE_NAME)
      t.entryPoints = { ItemTrig.ENTRY_POINT_BARTER }
      t.galleryID   = 2
      local cl = t.conditions
      local al = t.actions
      --
      cl[1] = Condition:new(15, { false }) -- The item [is not] locked
      cl[2] = Condition:new(23, { true }) -- The item [is] ornate.
      cl[3] = Condition:new( 4, { false }) -- The item [is not] stolen
      --
      al[1] = Action:new(8, { 9999 }) -- Sell [9999] of the item.
      --
      table.insert(gallery, t)
   end
   do -- Deconstruct worthless equipment
      local t = Trigger:new()
      t.name        = GetString(ITEMTRIG_STRING_GALLERY_DECONSTRUCTWORTHLESS_NAME)
      t.entryPoints = { ItemTrig.ENTRY_POINT_CRAFTING }
      t.galleryID   = 3
      local cl = t.conditions
      local al = t.actions
      --
      cl[1] = Condition:new(15, { false }) -- The item [is not] locked
      cl[2] = Condition:new( 7, { true, -9 }) -- Added item [is] an [any equippable]
      cl[3] = Condition:new( 6, { { qualifier = "LTE", number = ITEM_QUALITY_NORMAL } }) -- Rarity is [at most Normal]
      cl[4] = Condition:new(31, { { qualifier = "LTE", number = 0 } }) -- Sell value is [at most 0]
      cl[5] = Condition:new(35, { true }) -- Current crafting station [is] appropriate for this item
      cl[6] = Condition:new(50, { true }) -- Can Deconstruct
      
      -- TODO: Can Deconstruct tests the crafting station; we don't need Cond#35
      
      --
      al[1] = Action:new(9) -- Deconstruct the item.
      --
      table.insert(gallery, t)
   end
   do -- Refine raw materials automatically
      local t = Trigger:new()
      t.name        = GetString(ITEMTRIG_STRING_GALLERY_REFINE_NAME)
      t.entryPoints = { ItemTrig.ENTRY_POINT_CRAFTING }
      t.galleryID   = 12
      local cl = t.conditions
      local al = t.actions
      --
      cl[1] = Condition:new( 7, { -7 })   -- Item Type: any unrefined material
      cl[2] = Condition:new(49, { true }) -- Can Refine
      --
      al[1] = Action:new(14, {}) -- Refine
      --
      table.insert(gallery, t)
   end
   do -- Sell trash
      local t = Trigger:new()
      t.name        = GetString(ITEMTRIG_STRING_GALLERY_SELLTRASH_NAME)
      t.entryPoints = { ItemTrig.ENTRY_POINT_BARTER }
      t.galleryID   = 4
      local cl = t.conditions
      local al = t.actions
      --
      cl[1] = Condition:new( 7, { true, ITEMTYPE_TRASH }) -- The item [is] a [Trash]
      cl[2] = Condition:new(15, { false }) -- The item [is not] locked
      cl[3] = Condition:new( 4, { false }) -- The item [is not] stolen
      --
      al[1] = Action:new(8, { 9999 }) -- Sell as many as possible.
      --
      table.insert(gallery, t)
   end
   do -- Sell common non-crafted poisons
      local t = Trigger:new()
      t.name        = GetString(ITEMTRIG_STRING_GALLERY_SELLLOOTEDPOISONS_NAME)
      t.entryPoints = { ItemTrig.ENTRY_POINT_BARTER }
      t.galleryID   = 5
      local cl = t.conditions
      local al = t.actions
      --
      cl[1] = Condition:new( 7, { true, ITEMTYPE_POISON }) -- The item [is] a [Poison]
      cl[2] = Condition:new(15, { false }) -- The item [is not] locked
      cl[3] = Condition:new( 6, { { qualifier = "LTE", number = ITEM_QUALITY_NORMAL } }) -- Rarity is [at most Normal]
      cl[4] = Condition:new( 8, { false }) -- The item [was not] crafted by a player
      --
      al[1] = Action:new(7, { 9999 }) -- Sell as many as possible.
      --
      table.insert(gallery, t)
   end
   do -- Destroy common style materials past one stack, unless withdrawn or purchased
      local t = Trigger:new()
      t.name        = GetString(ITEMTRIG_STRING_GALLERY_DESTROYEXCESSSTYLEMATS_NAME)
      t.entryPoints = { ItemTrig.ENTRY_POINT_ITEM_ADDED }
      t.galleryID   = 6
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
      t.galleryID   = 7
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
      t.galleryID   = 8
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
      t.galleryID   = 9
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
      t.galleryID   = 10
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
   do -- This trigger will never run
      local t = Trigger:new()
      t.name        = GetString(ITEMTRIG_STRING_GALLERY_NEVEREXAMPLE_NAME)
      t.entryPoints = { ItemTrig.ENTRY_POINT_ITEM_ADDED }
      t.galleryID   = 11
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
   if GetDisplayName() == "@DavidJCobb" then -- double-check gallery IDs in case we make a mistake
      local seen = {}
      for i = 1, #gallery do
         local trigger = gallery[i]
         local id      = trigger.galleryID
         if not id then
            error("Gallery trigger at index " .. i .. " is missing a unique ID!")
         else
            if seen[id] then
               error("Gallery trigger ID " .. tostring(id) .. " appears more than once! Second occurrence was at " .. i .. ".")
            else
               seen[id] = true
            end
         end
      end
   end
   return gallery
end