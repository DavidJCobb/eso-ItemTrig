if not ItemTrig then return end

local function _prepTriggersToSave(tList)
   local s = {}
   for i = 1, table.getn(tList) do
      s[i] = tList[i]:serialize()
   end
   s = table.concat(s)
   --
   -- serialized strings are capped at 2000 chars; we need to split them up
   --
   s = ItemTrig.splitByCount(s, 1500)
   return s
end

local savedVars = ItemTrig.ISavedata:new("ItemTrigSavedata", nil, 1)
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
   [" DATA"] = savedVars,
   triggers = {},
}
function ItemTrig.Savedata:save(characterID)
   _saveTriggers(characterID, self.triggers)
end
function ItemTrig.Savedata:load(characterID)
   self.triggers = self:loadTriggersFor(characterID)
end

function ItemTrig.Savedata:loadTriggersFor(characterID)
   local interface = savedVars:character(characterID)
   interface:tryUpdateRoutine()
   do -- saved triggers
      local s = table.concat(interface:data().serializedTriggers or {})
      if s:len() == 0 then
         return {}
      end
      return ItemTrig.parseTrigger(s)
   end
end