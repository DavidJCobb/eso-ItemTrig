if not ItemTrig then return end

local function _prepTriggersToSave(tList)
   local s = {}
   for i = 1, #tList do
      s[i] = tList[i]:serialize()
   end
   s = table.concat(s)
   --
   -- serialized strings are capped at 2000 chars; we need to split them up
   --
   s = ItemTrig.splitByCount(s, 1500)
   return s
end

local savedVars = ItemTrig.ISavedata:new("ItemTrigSavedata", nil, 2)
--
-- If we change the savedata format, we'll want to call:
--
--    savedVars:addUpdateRoutine(myFunction)
--
-- where myFunction takes two args: an ISavedataCharacter instance and 
-- its prior version. Update routines will be run in order, so we can 
-- just keep adding 'em and literally update from version to version.
--
do -- Define defaults
   local _defaults = {
      serializedTriggers = {}
   }
   savedVars.defaults = _defaults
end


local function _saveTriggers(characterID, tList)
   savedVars:character(characterID):data().serializedTriggers = _prepTriggersToSave(tList)
end

ItemTrig.Savedata = {
   interface = savedVars,
   prefs     = nil, -- if not nil, then it is a field in the character data; should autosave
   triggers  = {},
}
function ItemTrig.Savedata:save(characterID)
   _saveTriggers(characterID, self.triggers)
end
function ItemTrig.Savedata:load(characterID)
   local character = savedVars:character(characterID)
   local cData     = character:data()
   do -- set up prefs
      local p = cData.prefs
      if not p then
         cData.prefs = {}
         p = cData.prefs
      end
      self.prefs = p
   end
   self.triggers = self:loadTriggersFor(characterID)
   if ItemTrig.prefs:get("updateGalleryTriggers") ~= false then -- update gallery triggers, if need be
      local gallery -- lazy load
      local indexedGallery = {}
      local function _lazyLoad()
         gallery = ItemTrig.retrieveTriggerGallery()
         for i = 1, #gallery do
            local t = gallery[i]
            if t.galleryID then
               indexedGallery[t.galleryID] = t
            end
         end
      end
      --
      local list = self.triggers
      for i = 1, #list do
         local trigger = list[i]
         local id      = trigger.galleryID
         if id then
            if not gallery then
               _lazyLoad()
            end
            if indexedGallery[id] then
               trigger:updateGalleryTrigger(indexedGallery[id]) -- checks and whatnot are done here
            end
         end
      end
   end
   do -- update triggers
      if character._initiallyLoadedVersion < 2 then
         --
         -- Condition "Total Count" uses the wrong enum value to 
         -- identify the Craft Bag.
         --
         local baseToUpdate = ItemTrig.tableConditions[11]
         for i = 1, #self.triggers do
            local trigger = self.triggers[i]
            local cList   = trigger.conditions
            for j = 1, #cList do
               local condition = cList[j]
               if condition.base == baseToUpdate then
                  local bagIndex = condition.args[1]
                  if bagIndex == BAG_SUBSCRIBER_BANK then
                     condition.args[1] = BAG_VIRTUAL
                  end
               end
            end
         end
         --
         character:setIsUpToDate()
      end
   end
end

function ItemTrig.Savedata:loadTriggersFor(characterID)
   local interface = savedVars:character(characterID)
   do -- saved triggers
      local s = table.concat(interface:data().serializedTriggers or {})
      if s:len() == 0 then
         return {}
      end
      return ItemTrig.parseTrigger(s)
   end
end