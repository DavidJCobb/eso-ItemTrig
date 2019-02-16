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
   do -- Define default triggers (just testing, for now).
      local tList = {}
      do
         local t = ItemTrig.Trigger:new()
         t.name = "Test trigger 01"
         table.insert(t.conditions, ItemTrig.Condition:new(3, {false}))  -- Always/Never
         table.insert(t.actions, ItemTrig.Action:new(2, {"Hello, world!"})) -- Log Message
         --
         table.insert(tList, t)
      end
      do
         local t = ItemTrig.Trigger:new()
         t.name = "Test trigger 02"
         table.insert(t.conditions, ItemTrig.Condition:new(3, {false}))  -- Always/Never
         table.insert(t.actions, ItemTrig.Action:new(2, {"Salutations, globe!"})) -- Log Message
         --
         table.insert(tList, t)
      end
      do
         local t = ItemTrig.Trigger:new()
         t.name    = "Test trigger 03"
         t.enabled = false
         table.insert(t.conditions, ItemTrig.Condition:new(3, {false}))  -- Always/Never
         table.insert(t.actions, ItemTrig.Action:new(4, {"This is a comment action."})) -- Comment
         table.insert(t.actions, ItemTrig.Action:new(2, {"'Sup, Nirn?"})) -- Log Message
         --
         table.insert(tList, t)
      end
      _defaults.serializedTriggers = _prepTriggersToSave(tList)
   end
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
   --[[local success, interface = pcall(savedVars.character, savedVars, characterID)
   if not success then
      return {}
   end]]--
   local interface = savedVars:character(characterID)
   local s = table.concat(interface:data().serializedTriggers or {})
   if s:len() == 0 then
      return {}
   end
   return ItemTrig.parseTrigger(s)
end