local this_module = {}

this_module.cache = {} -- cache[itemLink] == struct of data

function this_module:ItemBase:default_constructor()
   local result = {}
   setmetatable(result, self)
   result.itemLink  = ""
   result.id        = NaN -- GetItemLinkId(itemLink)
   result.name      = ""  -- GetItemLinkName(itemLink)
   result.icon      = ""  -- GetItemLinkInfo(itemLink) -- GetItemLinkIcon(itemLink)
   result.sellPrice = NaN -- GetItemLinkInfo(itemLink)
   result.equipType = NaN -- GetItemLinkInfo(itemLink)
   result.style     = NaN -- GetItemLinkInfo(itemLink)
   result.traitInfo = NaN -- GetItemTraitInformationFromItemLink(itemLink)
   result.type      = NaN -- GetItemLinkItemType(itemLink)
   result.specType  = NaN -- GetItemLinkItemType(itemLink)
   return result
end
function this_module:ItemBase:new(itemLink)
   local result = self.default_constructor()
   result.itemLink = itemLink
   return result
end
function this_module:Item:researchable()
   return CanItemLinkBeTraitResearched(self.itemLink)
end

function this_module.clear()
end

return this_module