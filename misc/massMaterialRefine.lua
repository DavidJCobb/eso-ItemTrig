
--
-- In item.lua, you'll find a system called ItemQueues, which is used 
-- to queue operations to be taken on item stacks after triggers have 
-- run. The queueing system in this file is a little different. It's 
-- not possible to refine raw materials on a per-item-stack basis: 
-- if you tell the game to refine, say, 20 ore in the player's pack, 
-- the game may actively ignore you and refine ore in their Craft Bag 
-- instead. Specifically, the game always prefers to refine raw mate-
-- rials in the Craft Bag, before then refining raw materials in the 
-- bag, even if the game was originally  told to refine items in the 
-- bag.
--
-- Among other things, this means that it's impossible to measure the 
-- progress of a "refine" queue if that queue only looks at one bag 
-- slot at a time, rather than treating bag slots as a collective.
--
-- Thus, the MassMaterialRefinementQueue. This queue groups multiple 
-- bag slots by item ID. We still need a bag slot in order to trigger 
-- a refine operation -- we can't tell the game to refine an item ID, 
-- even though the game is clearly treating our request that way (more 
-- or less) -- but we organize and track things by ID.
--
-- The MassMaterialRefinementManager acts as a layer between the queue 
-- and the rest of ItemTrig. The Manager allows us to queue the refine-
-- ment of all items available to the current crafting station, OR of 
-- just specific item IDs. The user is able to choose when using the 
-- Mass Refine action in any trigger.
--

local function _tradeskillErrorIsRefine(tsr)
   if tsr == CRAFTING_RESULT_INTERRUPTED                -- 18: "Interrupted"
   or tsr == CRAFTING_RESULT_ITEM_NOT_REFINEABLE        -- "Item is not refinable"
   or tsr == CRAFTING_RESULT_NEED_REFINE_RANK           -- "Your rank is too low to refine that"
   or tsr == CRAFTING_RESULT_NEED_SPACE_TO_REFINE       -- "Your inventory is full."
   or tsr == CRAFTING_RESULT_NO_ITEM_TO_REFINE          -- "You must refine an item"
   or tsr == CRAFTING_RESULT_UNKNOWN_SKILL_REFINE       -- "You are not trained in the crrect tradeskill to refine that"
   or tsr == CRAFTING_RESULT_WRONG_TARGET_REFINE        -- "You must be at a crafting station to refine"
   then
      return true
   end
   return false
end

local ItemBaseForm = {} -- forward-declare
-- Member functions defined later on.

local function _isFCOISProtected(bag, slot)
   if not FCOIS then
      return false
   end
   if IsInGamepadPreferredMode() then
      --
      -- As of July 10, 2019, FCOIS does not initialize properly if you start your session 
      -- with the game's Gamepad Mode enabled. Attempting to query any of its protections 
      -- after bad initialization will throw an error.
      --
      -- NOTE: This check could probably be done better. We need to know whether the user 
      -- was in Gamepad Mode when add-ons loaded, NOT whether they are CURRENTLY in Game-
      -- pad Mode.
      --
      local test, result = pcall(FCOIS.IsDeconstructionLocked, bag, slot)
      if not test then
         --
         -- Yep, FCOIS is broken and its API is throwing errors. Nothing we can do.
         --
         return false
      end
   end
   return FCOIS.IsRefinementLocked(bag, slot) or FCOIS.IsJewelryRefinementLocked(bag, slot)
end

local KnownMaterials = {
   list = {}, -- array of ItemBaseForm
   map  = {}, -- ItemBaseForm indexed by id
}
do -- KnownMaterials: map of all materials we intend to mass-refine
   function KnownMaterials:clear()
      self.list = {}
      self.map  = {}
   end
   function KnownMaterials:forEach(functor)
      for _,v in pairs(self.list) do
         if functor(v) then
            return
         end
      end
   end
   function KnownMaterials:getTopmost()
      return self.list[#self.list]
   end
   function KnownMaterials:lookupById(id)
      return self.map[id]
   end
   function KnownMaterials:pop()
      self.list[#self.list] = nil
   end
   function KnownMaterials:register(base)
      self.map[base.id] = base
      self.list[#self.list + 1] = base
   end
   function KnownMaterials:_scanBag(filterFunc, bag)
      local function _canRefine(bag, slot, link)
         if IsItemPlayerLocked(bag, slot) then
            return false
         end
         local cit = GetCraftingInteractionType()
         if cit ~= GetItemCraftingInfo(bag, slot) then
            --
            -- Raw style materials can be refined at any station and don't 
            -- have a tradeskill type AFAIK; everything else should fail 
            -- here.
            --
            if GetItemType(bag, slot) ~= ITEMTYPE_RAW_MATERIAL then
               return false
            end
         end
         if not (CanItemBeRefined or CanItemBeSmithingExtractedOrRefined)(bag, slot, cit) then
            return false
         end
         local refinesTo = GetItemLinkRefinedMaterialItemLink(link)
         if (not refinesTo) or refinesTo == "" then
            return false
         end
         local countBag, _, countCraftBag = GetItemLinkStacks(link)
         if countBag + countCraftBag < GetRequiredSmithingRefinementStackSize() then
            return false
         end
         if _isFCOISProtected(bag, slot) then
            return false
         end
         return true
      end
      --
      local slot = ZO_GetNextBagSlotIndex(bag)
      while slot do
         if HasItemInSlot(bag, slot) then
            local link = GetItemLink(bag, slot)
            if _canRefine(bag, slot, link) then
               local id = GetItemId(bag, slot)
               if (not filterFunc) or filterFunc(bag, slot) then
                  local base = ItemBaseForm:new(id) -- automatically reuses existing
                  base = ItemBaseForm:new(id)
                  base.link = GetItemLink(bag, slot)
                  base:addSlot(bag, slot)
               end
            end
         end
         slot = ZO_GetNextBagSlotIndex(bag, slot)
      end
   end
   function KnownMaterials:build(filterFunc)
      self:clear()
      self:_scanBag(filterFunc, BAG_BACKPACK)
      self:_scanBag(filterFunc, BAG_VIRTUAL)
      --
      do -- count the totals on each item, and filter out items that we don't have enough of
         local enough  = {}
         local length  = 0
         local indexed = {}
         for _, v in pairs(self.list) do
            local countBag, _, countCraftBag = GetItemLinkStacks(v.link)
            v.total = countBag + countCraftBag
            if v.total >= 0 then
               length = length + 1
               enough[length] = v
               indexed[v.id] = v
            end
         end
         self.list = enough
         self.map  = indexed
      end
   end
   function KnownMaterials:getAllTotals()
      local map = {}
      for _, v in pairs(self.list) do
         map[v.id] = { link = v.link, count = v.total }
      end
      return map
   end
end

do -- ItemBaseForm: a single material type as listed in KnownMaterials
   function ItemBaseForm:new(id)
      local existing = KnownMaterials:lookupById(id)
      if existing then
         return existing
      end
      local result = setmetatable({}, { __index = self })
      result.link    = nil
      result.id      = id
      result.entries = {}
      KnownMaterials:register(result)
      return result
   end
   function ItemBaseForm:addSlot(bag, slot)
      self.entries[#self.entries + 1] = { bag = bag, slot = slot }
   end
   function ItemBaseForm:getTopmost()
      return self.entries[#self.entries]
   end
   function ItemBaseForm:popSlot()
      self.entries[#self.entries] = nil
   end
end

local Queue = {
   running         = false,
   targetMaterial  = nil,
   targetSlot      = nil,
   targetInterface = nil,
   observer        = nil,
}
ItemTrig.MassMaterialRefinementQueue = Queue
do -- MassMaterialRefinementQueue
   local ABORT_QUEUE = "STOP"
   local DONE_QUEUE  = "DONE"
   local NOT_DEFINED = "XXXX"
   function Queue:start(observer, filterFunc)
      if self.running then
         return
      end
      self.running  = true
      self.observer = observer
      self.targetMaterial  = nil
      self.targetSlot      = nil
      self.targetInterface = nil
      KnownMaterials:build(filterFunc)
      if not KnownMaterials:getTopmost() then
         if observer and observer.onCantStartOnEmpty then
            observer:onCantStartOnEmpty()
         end
         self.running  = false
         self.observer = nil
         return
      end
      if observer and observer.onStart then
         observer:onStart(KnownMaterials:getAllTotals())
      end
      --[[
      --
      -- AN EVALUATION OF THE MASS REFINE/DECONSTRUCT FEATURE INTRODUCED 
      -- IN VERSION 100028:
      --
      --  * Most crafting errors no longer fire; INTERRUPTED is the only 
      --    one I could force experimentally. AddItemToDeconstructMessage 
      --    does most validation already and just returns false if the 
      --    item fails to queue.
      --
      --    EVENT_CRAFT_FAILED hasn't been extended to give us any way to 
      --    easily tell which items in a transaction have failed.
      --
      --  * EVENT_CRAFT_COMPLETE still fires
      --
      if GetAPIVersion() > 100027 then -- TEST TEST TEST
d("TESTING NEW REFINE CODE...")
         PrepareDeconstructionMessage()
         KnownMaterials:forEach(function(materialType)
            local entry = materialType:getTopmost()
            if not entry then
               return
            end
            local bag   = entry.bag
            local slot  = entry.slot
            local count = GetSlotStackSize(bag, slot)
            if AddItemToDeconstructMessage(bag, slot, count) then
               d(LocalizeString("Queued <<1>> for refine...", GetItemLink(bag, slot)))
            else
               d(LocalizeString("Failed to queue <<1>> for refine.", GetItemLink(bag, slot)))
            end
         end)
         SendDeconstructionMessage()
         self.running  = nil
         self.observer = nil
d("TESTED NEW REFINE CODE.")
         return
      end]]--
      self:advance()
   end
   function Queue:stop()
      KnownMaterials:clear()
      self.targetMaterial  = nil
      self.targetSlot      = nil
      self.targetInterface = nil
      self.observer = nil
      self.running  = false
   end
   function Queue:advance()
      self.targetInterface = nil
      if not self.targetMaterial then
         self.targetMaterial = KnownMaterials:getTopmost()
      end
      local base = self.targetMaterial
      if base and not self.targetSlot then
         self.targetSlot = base:getTopmost()
      end
      local entry = self.targetSlot
      if not entry then
         if self.observer and self.observer.onComplete then
            self.observer:onComplete()
         end
         self:stop()
         return
      end
      self.targetInterface = ItemTrig.ItemInterface:new(entry.bag, entry.slot)
      ExtractOrRefineSmithingItem(entry.bag, entry.slot)
   end
   function Queue:callback(eventCode, ...)
      if not self.running then
         return
      end
      if eventCode == EVENT_END_CRAFTING_STATION_INTERACT then
         if self.observer and self.observer.onInterrupted then
            self.observer:onInterrupted()
         end
         self:stop()
         return
      end
      if eventCode == EVENT_INVENTORY_IS_FULL then
         --
         -- API version 100028 no longer fires EVENT_CRAFT_FAILED if the 
         -- inventory is full; we get this instead
         --
         if GetCraftingInteractionType() ~= CRAFTING_TYPE_INVALID then
            local slotsRequested = select(1, ...)
            local slotsAvailable = select(2, ...)
            local failureString = zo_strformat(SI_INVENTORY_ERROR_INSUFFICIENT_SPACE, slotsRequested - slotsAvailable)
            if self.observer and self.observer.onFailure then
               self.observer:onFailure(self.targetInterface, nil, failureString)
            end
            --
            -- We can't deconstruct any more items if the inventory is too full 
            -- to deconstruct any single item.
            --
            if self.observer and self.observer.onAbort then
               self.observer:onAbort()
            end
            self:stop()
            return
         end
      end
      if eventCode == EVENT_CRAFT_COMPLETED then
         local skill = select(1, ...)
         if GetCraftingInteractionType() == CRAFTING_TYPE_INVALID then
            --
            -- Player has left the crafting station.
            --
            if self.observer and self.observer.onInterrupted then
               self.observer:onInterrupted()
            end
            self:stop()
            return
         end
         local base  = self.targetMaterial
         local entry = self.targetSlot
         local bag   = entry.bag
         local slot  = entry.slot
         if self.observer.onSingleSuccess then
            self.observer:onSingleSuccess(self.targetInterface)
         end
         local countBag, _, countCraftBag = GetItemLinkStacks(base.link)
         local stackDepleted = (GetItemLink(bag, slot) ~= base.link)
         if stackDepleted then -- stack depleted
            base:popSlot()
            if self.observer and self.observer.onStackConsumed then
               self.observer:onStackConsumed(self.targetInterface)
            end
         end
         if countBag + countCraftBag < GetRequiredSmithingRefinementStackSize() then
            KnownMaterials:pop()
            self.targetMaterial  = nil
            self.targetSlot = nil
            if (not stackDepleted) and self.observer and self.observer.onStackConsumed then
               self.observer:onStackConsumed(self.targetInterface)
            end
         end
         self:advance()
         return
      end
      if eventCode == EVENT_CRAFT_FAILED then -- operation failed or aborted
         if GetCraftingInteractionType() == CRAFTING_TYPE_INVALID then
            --
            -- Player has left the crafting station.
            --
            if self.observer and self.observer.onInterrupted then
               self.observer:onInterrupted()
            end
            self:stop()
            return
         end
         local tsr = select(1, ...)
         if _tradeskillErrorIsRefine(tsr) then
            local failureString = GetString("SI_TRADESKILLRESULT", tsr)
            if self.observer and self.observer.onFailure then
               self.observer:onFailure(self.targetInterface, nil, failureString)
            end
         end
         table.remove(self.items, 1)
         if tsr == CRAFTING_RESULT_NEED_SPACE_TO_REFINE then
            --
            -- We can't deconstruct any more items if the inventory is too full 
            -- to deconstruct any single item.
            --
            if self.observer and self.observer.onAbort then
               self.observer:onAbort()
            end
            self:stop()
            return
         end
      end
      self:advance()
   end

   local function _listener(eventCode, ...)
      if Queue.running then
         Queue:callback(eventCode, ...)
      end
   end
   local namespace = "ItemTrigMassMaterialRefinementQueueListener"
   EVENT_MANAGER:RegisterForEvent(namespace, EVENT_CRAFT_COMPLETED, _listener)
   EVENT_MANAGER:RegisterForEvent(namespace, EVENT_CRAFT_FAILED, _listener)
   EVENT_MANAGER:RegisterForEvent(namespace, EVENT_INVENTORY_IS_FULL, _listener)
   EVENT_MANAGER:RegisterForEvent(namespace, EVENT_END_CRAFTING_STATION_INTERACT, _listener)
end

local Manager = {
   queued      = false,
   filterByID  = nil,
   materialIDs = {}, -- materialIDs[id] = true
   observer    = nil,
}
ItemTrig.MassMaterialRefinementManager = Manager
local function _filter(bag, slot)
   if not Manager.filterByID then
      return true
   end
   local id = GetItemId(bag, slot)
   if Manager.materialIDs[id] then
      return true
   end
   return false
end
function Manager:afterTriggers()
   if self.queued then
      self.queued = false
      Queue:start(self.observer, _filter)
   end
   self.materialIDs = {}
   self.filterByID  = nil
end
function Manager:queue(id)
   if Queue.running then
      return
   end
   self.queued = true
   if id then
      self.materialIDs[id] = true
      if self.filterByID == nil then
         self.filterByID = true
      end
   else
      self.filterByID = false
   end
end
function Manager:setObserver(observer)
   self.observer = observer
end