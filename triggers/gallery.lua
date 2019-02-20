local Trigger   = ItemTrig.Trigger
local Action    = ItemTrig.Action
local Condition = ItemTrig.Condition

function ItemTrig.retrieveTriggerGallery()
   local gallery = {}
   do -- Destroy style materials past one stack, unless withdrawn or purchased
      local t = Trigger:new()
      t.name        = GetString(ITEMTRIG_STRING_GALLERY_DESTROYEXCESSSTYLEMATS_NAME)
      t.entryPoints = { ItemTrig.ENTRY_POINT_ITEM_ADDED }
      local cl = t.conditions
      local al = t.actions
      --
      cl[1] = Condition:new(10, { true }) -- Added item [is] a new stack
      cl[2] = Condition:new( 9, { false, 1 }) -- Added item [was not] [purchased]
      cl[3] = Condition:new( 9, { false, 3 }) -- Added item [was not] [withdrawn]
      cl[4] = Condition:new( 7, { true, ITEMTYPE_STYLE_MATERIAL }) -- Added item [is] a [style material]
      cl[5] = Condition:new(11, { BAG_BACKPACK, { qualifier = "GTE", number = 200 } }) -- [Player inventory] contains [at least 200]
      --
      al[1] = Action:new(5, { false }) -- Destroy [the entire stack]
      al[2] = Action:new(2, { GetString(ITEMTRIG_STRING_GALLERY_DESTROYEXCESSSTYLEMATS_MESSAGE) }) -- Log
      --
      table.insert(gallery, t)
   end
   return gallery
end