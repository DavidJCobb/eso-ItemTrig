ItemTrig.SkillCache = { linesByType = {} }
local SkillCache = ItemTrig.SkillCache

local function _skillLineIsMaxed(skillLineData)
   local lastXP, nextXP, currentXP = skillLineData:GetRankXPValues()
   return (nextXP == 0) or (nextXP == currentXP)
end

function SkillCache:isCraftingSkillLineMaxed(craftingType)
   local line, i = GetCraftingSkillLineIndices(craftingType)
   local data = (self.linesByType[line] or {})[i]
   if data then
      return data.maxed
   end
end
function SkillCache:update()
   for k, _ in pairs(ItemTrig.gameEnums.craftingTypes) do
      local t, i = GetCraftingSkillLineIndices(k)
      self.linesByType[t] = self.linesByType[t] or {}
      self.linesByType[t][i] = {
         skillType = t,
         index     = i,
         data      = SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(k, i)
      }
      local line = self.linesByType[t][i]
      if line.data then
         line.maxed = _skillLineIsMaxed(line.data)
      end
   end
end