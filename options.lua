assert(ItemTrig.ThemeManager, "bad file load order")

do -- define prefs
   ItemTrig.assign(ItemTrig.prefs, {
      ["logging/actionsTaken"]       = { default = false },
      ["logging/collapseSameErrors"] = { default = true },
      ["logging/triggerFailures"]    = { default = false },
      ["robustFencing"]           = { default = true },
      ["pretendActions"]          = { default = false },
      ["runTriggersOn/crownCrateItems"] = { default = false },
      ["runTriggersOn/crownStoreItems"] = { default = false },
      ["runTriggersOn/lockedItems"]     = { default = false },
      ["bankTriggers/allowDestroy"]     = { default = false },
      ["ui/allowEscForceClose"]    = { default = true },
      ["ui/opcodeArgAutocomplete"] = { default = false },
      ["ui/theme"]                 = { default = "OldDesktop" },
   })
end
local prefs = ItemTrig.prefs

local menu = {
   name        = "ItemTrig",
   displayName = "ItemTrig",
   type        = "panel",
}
local options = {
   {
      type    = "button",
      name    = GetString(ITEMTRIG_STRING_OPTIONBUTTON_EDITTRIGGERS),
      tooltip = GetString(ITEMTRIG_STRING_OPTIONDESC_EDITTRIGGERS),
      width   = "half",
      func    =
         function()
            local pauseMenuScene = SCENE_MANAGER:GetScene("gameMenuInGame")
            if pauseMenuScene:GetState() == SCENE_SHOWN then
               SCENE_MANAGER:Hide(pauseMenuScene.name)
            end
            ItemTrig.windows.triggerList:show()
         end,
   },
   {
      type = "header",
      name = GetString(ITEMTRIG_STRING_OPTIONHEADER_ALLOWTRIGGERS),
   },
   {  -- Only pretend to take actions
      --
      type    = "checkbox",
      name    = GetString(ITEMTRIG_STRING_OPTIONNAME_PRETENDACTIONS),
      tooltip = GetString(ITEMTRIG_STRING_OPTIONDESC_PRETENDACTIONS),
      getFunc = function()  return prefs:get("pretendActions") end,
      setFunc = function(v) prefs:set("pretendActions", v) end,
   },
   {  -- NEEDS TESTING
      -- Allow triggers to run on Crown Crate items
      --
      type    = "checkbox",
      name    = GetString(ITEMTRIG_STRING_OPTIONNAME_ALLOWTRIGGERSONCROWNCRATEITEMS),
      tooltip = GetString(ITEMTRIG_STRING_OPTIONDESC_ALLOWTRIGGERSONCROWNCRATEITEMS),
      getFunc = function()  return prefs:get("runTriggersOn/crownCrateItems") end,
      setFunc = function(v) prefs:set("runTriggersOn/crownCrateItems", v) end,
   },
   {  -- NEEDS TESTING
      -- Allow triggers to run on Crown Store items
      --
      type    = "checkbox",
      name    = GetString(ITEMTRIG_STRING_OPTIONNAME_ALLOWTRIGGERSONCROWNSTOREITEMS),
      tooltip = GetString(ITEMTRIG_STRING_OPTIONDESC_ALLOWTRIGGERSONCROWNSTOREITEMS),
      getFunc = function()  return prefs:get("runTriggersOn/crownStoreItems") end,
      setFunc = function(v) prefs:set("runTriggersOn/crownStoreItems", v) end,
   },
   {  -- Allow triggers to run on locked items
      --
      type    = "checkbox",
      name    = GetString(ITEMTRIG_STRING_OPTIONNAME_ALLOWTRIGGERSONLOCKEDITEMS),
      tooltip = GetString(ITEMTRIG_STRING_OPTIONDESC_ALLOWTRIGGERSONLOCKEDITEMS),
      getFunc = function()  return prefs:get("runTriggersOn/lockedItems") end,
      setFunc = function(v) prefs:set("runTriggersOn/lockedItems", v) end,
   },
   {  -- Allow triggers to destroy banked items
      --
      type    = "checkbox",
      name    = GetString(ITEMTRIG_STRING_OPTIONNAME_BANKTRIGGERSALLOWDESTROY),
      tooltip = GetString(ITEMTRIG_STRING_OPTIONDESC_BANKTRIGGERSALLOWDESTROY),
      getFunc = function()  return prefs:get("bank/allowDestroy") end,
      setFunc = function(v) prefs:set("bank/allowDestroy", v) end,
   },
   {
      type = "header",
      name = GetString(ITEMTRIG_STRING_OPTIONHEADER_LOGGING),
   },
   {  -- Log all actions taken on an item
      --
      type    = "checkbox",
      name    = GetString(ITEMTRIG_STRING_OPTIONNAME_LOGALLITEMACTIONS),
      tooltip = GetString(ITEMTRIG_STRING_OPTIONDESC_LOGALLITEMACTIONS),
      getFunc = function()  return prefs:get("logging/actionsTaken") end,
      setFunc = function(v) prefs:set("logging/actionsTaken", v) end,
   },
   {  -- Log when a trigger stops due to an error
      --
      type    = "checkbox",
      name    = GetString(ITEMTRIG_STRING_OPTIONNAME_LOGTRIGGERFAILURES),
      tooltip = GetString(ITEMTRIG_STRING_OPTIONDESC_LOGTRIGGERFAILURES),
      getFunc = function()  return prefs:get("logging/triggerFailures") end,
      setFunc = function(v) prefs:set("logging/triggerFailures", v) end,
   },
   {  -- Collapse certain trigger-failure errors together when they occur multiple times at once
      --
      type    = "checkbox",
      name    = GetString(ITEMTRIG_STRING_OPTIONNAME_COLLAPSESAMETRIGFAILS),
      tooltip = GetString(ITEMTRIG_STRING_OPTIONDESC_COLLAPSESAMETRIGFAILS),
      getFunc = function()  return prefs:get("logging/collapseSameErrors") end,
      setFunc = function(v) prefs:set("logging/collapseSameErrors", v) end,
   },
   {
      type = "header",
      name = GetString(ITEMTRIG_STRING_OPTIONHEADER_UI),
   },
   ItemTrig.assign(
      {  -- Control whether Esc force-closes the editor without saving
         --
         type    = "dropdown",
         name    = GetString(ITEMTRIG_STRING_OPTIONNAME_THEME),
         tooltip = GetString(ITEMTRIG_STRING_OPTIONDESC_THEME),
         getFunc = function() return prefs:get("ui/theme") end,
         setFunc =
            function(v)
               prefs:set("ui/theme", v)
               ItemTrig.ThemeManager:switchTo(v)
            end,
      },
      ItemTrig.ThemeManager:setupOptions()
   ),
   {  -- Control whether Esc force-closes the editor without saving
      --
      type    = "checkbox",
      name    = GetString(ITEMTRIG_STRING_OPTIONNAME_ALLOWESCFORCECLOSE),
      tooltip = GetString(ITEMTRIG_STRING_OPTIONDESC_ALLOWESCFORCECLOSE),
      getFunc = function()  return prefs:get("ui/allowEscForceClose") end,
      setFunc = function(v) prefs:set("ui/allowEscForceClose", v) end,
   },
   {  -- Enable auto-complete for trigger arguments that support it
      --
      type    = "checkbox",
      name    = GetString(ITEMTRIG_STRING_OPTIONNAME_TRIGGERARGAUTOCOMPLETE),
      tooltip = GetString(ITEMTRIG_STRING_OPTIONDESC_TRIGGERARGAUTOCOMPLETE),
      getFunc = function()  return prefs:get("ui/opcodeArgAutocomplete") end,
      setFunc = function(v) prefs:set("ui/opcodeArgAutocomplete", v) end,
   },
   {
      type = "header",
      name = GetString(ITEMTRIG_STRING_OPTIONHEADER_EXTRA),
   },
   {  -- Pre-sort items in the "fence" entry point, by value, descending
      --
      type    = "checkbox",
      name    = GetString(ITEMTRIG_STRING_OPTIONNAME_ROBUSTFENCING),
      tooltip = GetString(ITEMTRIG_STRING_OPTIONDESC_ROBUSTFENCING),
      getFunc = function()  return prefs:get("robustFencing") end,
      setFunc = function(v) prefs:set("robustFencing", v) end,
   },
}

function ItemTrig.registerLAMOptions()
   local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")
   LAM:RegisterAddonPanel("ItemTrigOptionsMenu", menu)
   LAM:RegisterOptionControls("ItemTrigOptionsMenu", options)
end