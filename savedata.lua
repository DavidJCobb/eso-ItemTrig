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

local _savedataVersion = 1
local _defaults = {
   serializedTriggers = {}
}
do -- Define default triggers.
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

ItemTrig.saveData = ZO_SavedVars:NewAccountWide("ItemTrigSavedata", _savedataVersion, nil, _defaults)

local function _saveTriggers(tList)
   ItemTrig.saveData.serializedTriggers = prepTriggersToSave(tList)
end
local function _loadTriggers()
   local s = table.concat(ItemTrig.saveData.serializedTriggers)
   if s:len() == 0 then
      return {}
   end
   return ItemTrig.parseTrigger(s)
end

ItemTrig.Savedata = {
   triggers = {},
}
function ItemTrig.Savedata:save()
   _saveTriggers(self.triggers)
end
function ItemTrig.Savedata:load()
   self.triggers = _loadTriggers()
end