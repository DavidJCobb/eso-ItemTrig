local Trigger   = ItemTrig.Trigger
local Action    = ItemTrig.Action
local Condition = ItemTrig.Condition

-- FLAG: Condition 9 (Added Item Cause) is subject to API limits: as of this 
-- writing, we cannot differentiate between an item moving between two bags 
-- and an item's stack being split within one bag, so we cannot check whether 
-- an item was withdrawn from the bank.
--
local CAN_CHECK_WHETHER_ADDED_ITEM_WAS_WITHDRAWN = false

function ItemTrig.retrieveTriggerGallery()
   local gallery = {}
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
      al[2] = Action:new(2, { GetString(ITEMTRIG_STRING_GALLERY_DESTROYEXCESSSTYLEMATS_MESSAGE) }) -- Log
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
      local i = 0
      cl[1] = Condition:new(10, { true }) -- Added item [is] a new stack
      cl[2] = Condition:new( 9, { false, 1 }) -- Added item [was not] [purchased]
      if CAN_CHECK_WHETHER_ADDED_ITEM_WAS_WITHDRAWN then
         cl[3] = Condition:new( 9, { false, 3 }) -- Added item [was not] [withdrawn]
      end
      cl[3 + i] = Condition:new( 7, { true, ITEMTYPE_TREASURE }) -- Item type [is] [Treasure]
      cl[4 + i] = Condition:new( 6, { { qualifier = "LTE", number = ITEM_QUALITY_NORMAL } }) -- Rarity is [at most Normal]
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
         clNested[2] = Condition:new(12, { false, ItemTrig.getNaiveItemNameFor(61737) }) -- Item name [is] [Ayleid House Idol]
         clNested[3] = Condition:new(12, { false, ItemTrig.getNaiveItemNameFor(74581) }) -- Item name [is] [Pocket Rules For Kick the Khajiit]
         clNested[4] = Condition:new(12, { false, ItemTrig.getNaiveItemNameFor(64409) }) -- Item name [is] [Logic Fob]
         --
         alNested[1] = Action:new(1) -- Stop execution of the top-level trigger
         --
         al[1] = Action:new(3, { t })
      end
      al[2] = Action:new(5, { true }) -- Destroy [the whole stack]
      al[3] = Action:new(2, { GetString(ITEMTRIG_STRING_GALLERY_DESTROYSTOLENCRAPTREASURE_MESSAGE) }) -- Log message
      --
      table.insert(gallery, t)
   end
   return gallery
end