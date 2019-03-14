local QuestInterface = {}
ItemTrig.QuestInterface = QuestInterface

function ItemTrig.questByName(name)
   name = name:lower()
   local count = GetNumJournalQuests()
   for i = 1, count do
      local current = GetJournalQuestName(i)
      if current:lower() == name then
         return ItemTrig.QuestInterface:new(i)
      end
   end
end

local IQuestCondition = {}
do
   IQuestCondition.__index = IQuestCondition
   function IQuestCondition:new(step, index, data)
      local result = setmetatable({ step = step, index = index }, self)
      ItemTrig.assign(result, data)
      return result
   end
   function IQuestCondition:getQuest()
      return self.step.quest
   end
   function IQuestCondition:isFulfilledByItem(a, b)
      local bag  = a
      local slot = b
      if ItemTrig.ItemInterface and ItemTrig.ItemInterface:is(a) then
         bag  = a.bag
         slot = a.slot
      end
      return DoesItemFulfillJournalQuestCondition(bag, slot, self:getQuest().index, self.step.index, self.index)
   end
end

local IQuestStep = {}
do
   IQuestStep.__index = IQuestStep
   function IQuestStep:new(quest, index, data)
      local result = setmetatable({ quest = quest, index = index }, self)
      ItemTrig.assign(result, data)
      return result
   end
   function IQuestStep:forEachCondition(functor)
      for i = 1, #self.conditions do
         if functor(self.conditions[i]) then
            return
         end
      end
   end
end

QuestInterface.meta = {
   __index = QuestInterface
}
function QuestInterface:new(journalIndex)
   local result = setmetatable({}, self.meta)
   result.index = journalIndex
   do -- GetJournalQuestInfo
      local name, backgroundText, activeStepText, activeStepType, activeStepTrackerOverrideText, completed, tracked, questLevel, pushed, questType, instanceDisplayType = GetJournalQuestInfo(journalIndex)
      ItemTrig.assign(result, {
         activeStepText = activeStepText,
         activeStepType = activeStepType,
         activeStepTrackerOverrideText = activeStepTrackerOverrideText,
         backgroundText = backgroundText,
         instanceDisplayType = instanceDisplayType,
         isComplete     = completed,
         isPushed       = pushed,
         isTracked      = tracked,
         level          = questLevel,
         name           = name,
      })
   end
   ItemTrig.assign(result, {
      initialZone   = GetJournalQuestStartingZone(journalIndex),
      isCurrentZone = IsJournalQuestInCurrentMapZone(journalIndex),
      repeatType    = GetJournalQuestRepeatType(journalIndex), -- QuestRepeatableType
   })
   do -- Steps
      local count = GetJournalQuestNumSteps(journalIndex)
      result.steps = {}
      for i = 1, count do
         local step = {}
         local cCount
         do -- Get data.
            local text, visibility, stepType, trackerOverrideText, cC = GetJournalQuestStepInfo(journalIndex, i)
            cCount = cC
            ItemTrig.assign(step, {
               conditions = {},
               text       = text, -- journal text
               textShort  = trackerOverrideText, -- objective text
               type       = stepType,
               visibility = visibility,
            })
         end
         step = IQuestStep:new(result, i, step)
         result.steps[i] = step
         --
         for j = 1, cCount do
            local condition = {}
            do -- Get data.
               local text, current, max, isFail, complete, isCreditShared, visible, condType = GetJournalQuestConditionInfo(journalIndex, i, j)
               ItemTrig.assign(condition, {
                  current         = current, -- for "get X of Y" conditions and such
                  isCompleted     = complete,
                  isCreditShared  = isCreditShared,
                  isFailCondition = isFail,
                  isVisible       = visible,
                  max             = max, -- for "get X of Y" conditions and such
                  text            = text,
                  type            = condType,
               })
            end
            condition = IQuestCondition:new(step, j, condition)
            result.steps[i].conditions[j] = condition
         end
      end
   end
   return result
end
function QuestInterface:forEachStep(functor)
   for i = 1, #self.steps do
      if functor(self.steps[i]) then
         return
      end
   end
end
function QuestInterface:itemFulfillsAnyObjective(a, b)
   local result = false
   self:forEachStep(function(step)
      step:forEachCondition(function(condition)
         if condition:isFulfilledByItem(a, b) then
            result = true
            return true
         end
      end)
      if result then
         return true
      end
   end)
   return result
end