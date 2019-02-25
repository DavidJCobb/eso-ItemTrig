ZO_CreateStringId("ITEMTRIG_STRING_UI_GENERIC_CONFIRM_YES", "Yes")
ZO_CreateStringId("ITEMTRIG_STRING_UI_GENERIC_CONFIRM_NO", "No")
ZO_CreateStringId("ITEMTRIG_STRING_UI_GENERIC_CONFIRM_TITLE", "Are you sure?") -- confirmation prompt window title, if none is specified
ZO_CreateStringId("ITEMTRIG_STRING_GENERIC_TRUNCATION_MARKER", "...")
--
--
-- OPTIONS
--
--
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONBUTTON_EDITTRIGGERS", "Edit triggers...")
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONDESC_EDITTRIGGERS", "Click here to edit the rules you've set for handling items.")
--
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONHEADER_ALLOWTRIGGERS", "Allow triggers to run on...")
--
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONNAME_ALLOWTRIGGERSONCROWNCRATEITEMS", "Crown Crate items")
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONDESC_ALLOWTRIGGERSONCROWNCRATEITEMS", "Control whether triggers are run on Crown Crate items.")
--
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONNAME_ALLOWTRIGGERSONCROWNSTOREITEMS", "Crown Store items")
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONDESC_ALLOWTRIGGERSONCROWNSTOREITEMS", "Control whether triggers are run on Crown Store items.")
--
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONNAME_ALLOWTRIGGERSONLOCKEDITEMS", "Locked items")
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONDESC_ALLOWTRIGGERSONLOCKEDITEMS", "Control whether triggers are run on locked items.")
--
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONHEADER_LOGGING", "Logging")
--
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONNAME_LOGALLITEMACTIONS", "Log actions taken on items")
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONDESC_LOGALLITEMACTIONS", "Log whenever an action is taken on an item to destroy it, get rid of it, or otherwise move it.")
--
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONNAME_LOGTRIGGERFAILURES", "Log trigger failures")
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONDESC_LOGTRIGGERFAILURES", "Log every time a trigger stops early due to an error.")
--
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONHEADER_EXTRA", "Extra features")
--
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONNAME_TRIGGERARGAUTOCOMPLETE", "Trigger argument autocomplete")
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONDESC_TRIGGERARGAUTOCOMPLETE", "Enable auto-complete for trigger arguments that support it")
--
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONNAME_ROBUSTFENCING", "Robust Fencing")
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONDESC_ROBUSTFENCING", "For the \"Fence\" entry point, sort items by value before running triggers on them, so that the most valuable items are fenced or laundered first.")
--
--
-- USER INTERFACE
--
--
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGERLIST_TITLE", "ItemTrig")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGERLIST_FILTER_SHOW_ALL", "Show All Triggers")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGERLIST_BUTTON_ADD", "New")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGERLIST_BUTTON_EDIT", "Edit")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGERLIST_BUTTON_MOVEUP", "Move Up")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGERLIST_BUTTON_MOVEDOWN", "Move Down")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGERLIST_BUTTON_DELETE", "Delete")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGERLIST_CONFIRM_DELETE", "Are you sure you want to delete this trigger? This mod doesn't offer Ctrl+Z, you know!")
--
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGEREDIT_TITLE_NEW", "Create trigger...")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGEREDIT_TITLE_EDIT", "Edit trigger...")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGEREDIT_TITLE_NEW_NESTED",  "Create trigger (top-level is <<1>>)...")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGEREDIT_TITLE_EDIT_NESTED", "Edit trigger (top-level is <<1>>)...")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGEREDIT_LABEL_TRIGGER_NAME", "Name: ")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGEREDIT_LABEL_TRIGGER_ENTRYPOINTS", "Entry points: ")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGEREDIT_BUTTON_ADD", "New")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGEREDIT_BUTTON_EDIT", "Edit")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGEREDIT_BUTTON_MOVEUP", "Move Up")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGEREDIT_BUTTON_MOVEDOWN", "Move Down")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGEREDIT_BUTTON_DELETE", "Delete")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGEREDIT_LABEL_CONDITIONS", "Conditions:")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGEREDIT_LABEL_ACTIONS", "Actions:")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGEREDIT_BUTTON_SAVE", "OK")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGEREDIT_BUTTON_CANCEL", "Cancel")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGEREDIT_ABANDON_UNSAVED_CHANGES", "Are you sure you want to discard your unsaved changes?")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGEREDIT_CONFIRM_DELETE_C", "Are you sure you want to delete this condition?")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGEREDIT_CONFIRM_DELETE_A", "Are you sure you want to delete this action?")
--
ZO_CreateStringId("ITEMTRIG_STRING_UI_OPCODEEDIT_TITLE", "Edit opcode...")
ZO_CreateStringId("ITEMTRIG_STRING_UI_OPCODEEDIT_TITLE_C", "Edit condition...")
ZO_CreateStringId("ITEMTRIG_STRING_UI_OPCODEEDIT_TITLE_A", "Edit action...")
ZO_CreateStringId("ITEMTRIG_STRING_UI_OPCODEEDIT_TITLE_C_NEW", "New condition...")
ZO_CreateStringId("ITEMTRIG_STRING_UI_OPCODEEDIT_TITLE_A_NEW", "New action...")
ZO_CreateStringId("ITEMTRIG_STRING_UI_OPCODEEDIT_LABEL_TYPE", "Type: ")
ZO_CreateStringId("ITEMTRIG_STRING_UI_OPCODEEDIT_BUTTON_SAVE", "OK")
ZO_CreateStringId("ITEMTRIG_STRING_UI_OPCODEEDIT_BUTTON_CANCEL", "Cancel")
ZO_CreateStringId("ITEMTRIG_STRING_UI_OPCODEEDIT_ABANDON_UNSAVED_CHANGES", "Are you sure you want to discard your unsaved changes?")
--
ZO_CreateStringId("ITEMTRIG_STRING_UI_OPCODEARGEDIT_TITLE", "Edit value...")
ZO_CreateStringId("ITEMTRIG_STRING_UI_OPCODEARGEDIT_BUTTON_SAVE", "OK")
ZO_CreateStringId("ITEMTRIG_STRING_UI_OPCODEARGEDIT_BUTTON_CANCEL", "Cancel")
ZO_CreateStringId("ITEMTRIG_STRING_UI_OPCODEARGEDIT_ABANDON_UNSAVED_CHANGES", "Are you sure you want to discard your unsaved changes?")
--
--
-- GAME
--
-- Some of Zenimax's localized strings are confusable. For example, in 
-- the English localization, the string "Raw Material" is used to refer 
-- to raw materials in general, but also to specific raw material types 
-- that exist for each crafting skill.
--
-- Moreover, there are quite a few enums that the game doesn't actually 
-- expose; for example, there is no enum for alchemy effects, and you 
-- can only receive an effect's name as a string when querying what 
-- effects a potion or reagent has.
--
--
ZO_CreateStringId("ITEMTRIG_STRING_ITEMTYPE_RAWSTYLEMATERIAL",  "Raw Style Material")
ZO_CreateStringId("ITEMTRIG_STRING_ITEMTYPE_RAWMATCLOTHING",    "Raw Material, Clothier")
ZO_CreateStringId("ITEMTRIG_STRING_ITEMTYPE_RAWMATJEWELRY",     "Raw Material, Jewelry")
ZO_CreateStringId("ITEMTRIG_STRING_ITEMTYPE_RAWMATSMITHING",    "Raw Material, Blacksmithing")
ZO_CreateStringId("ITEMTRIG_STRING_ITEMTYPE_RAWMATWOODWORKING", "Raw Material, Woodworking")
ZO_CreateStringId("ITEMTRIG_STRING_ITEMTYPE_REFINEDMATCLOTHING",    "Refined Material, Clothier")
ZO_CreateStringId("ITEMTRIG_STRING_ITEMTYPE_REFINEDMATJEWELRY",     "Refined Material, Jewelry")
ZO_CreateStringId("ITEMTRIG_STRING_ITEMTYPE_REFINEDMATSMITHING",    "Refined Material, Blacksmithing")
ZO_CreateStringId("ITEMTRIG_STRING_ITEMTYPE_REFINEDMATWOODWORKING", "Refined Material, Woodworking")
--
ZO_CreateStringId("ITEMTRIG_STRING_ITEMSTYLE_NONE", "[none]")
--
-- The strings below need to exactly match the alchemy effect names seen 
-- when brewing potions and poisons. They are used by a trigger condition 
-- to check an ingredient's known effects; the API only allows us to do 
-- this using strings.
--
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_BREACH",              "Breach") -- Reduces your Spell resistance by ____ for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_COWARDICE",           "Cowardice") -- Increases your Ultimate cost by __% for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_DEFILE",              "Defile") -- Reduces your healing taken by __% for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_DETECTION",           "Detection") -- Increase your Stealth Detection by __ meters for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_ENERVATION",          "Enervation") -- Reduces your Critical Damage by __% for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_ENTRAPMENT",          "Entrapment") -- Stuns for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_FRACTURE",            "Fracture") -- Reduces your Physical Resistance by ____ for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_GRADUALRAVAGEHEALTH", "Gradual Ravage Health") -- Ravage ____ Health per second for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_HINDRANCE",           "Hindrance") -- Reduces your movement speed by __% for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_INCREASEARMOR",       "Increase Armor") -- Increases your Physical Resistance by ____ for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_INCREASESPELLPOWER",  "Increase Spell Power") -- Increases your spell damage by ____ for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_INCREASESPELLRESIST", "Increase Spell Resist") -- Increases your Spell Resistance by ____ for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_INCREASEWEAPONPOWER", "Increase Weapon Power") -- Increases your weapon damage by __% for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_INVISIBLE",       "Invisible") -- Vanish for _ seconds.
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_LINGERINGHEALTH", "Lingering Health") -- Restore ____ Health per second for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_MAIM",            "Maim") -- Reduces all damage you deal by __% for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_PROTECTION",      "Protection") -- Reduces your damage taken by __% for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_RAVAGEHEALTH",    "Ravage Health") -- Ravage ____ Health immediately. Ravage an additional __ Health every second for _ seconds.
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_RAVAGEMAGICKA",   "Ravage Magicka") -- Increases the cost of Magicka abilities by __% for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_RAVAGESTAMINA",   "Ravage Stamina") -- Increases the cost of Stamina abilities by __% for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_RESTOREHEALTH",   "Restore Health") -- Restore ____ Health immediately.
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_RESTOREMAGICKA",  "Restore Magicka") -- Restore ____ Magicka immediately.
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_RESTORESTAMINA",  "Restore Stamina") -- Restore ____ Stamina immediately.
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_SPEED",           "Speed") -- Increases your movement speed by __% for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_SPELLCRITICAL",   "Spell Critical") -- Gives you ____ Spell Critical Rating for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_UNCERTAINTY",     "Uncertainty") -- Reduces all critical ratings by ____ for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_UNSTOPPABLE",     "Unstoppable") -- Become immune to knockback and disabling effects for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_VITALITY",        "Vitality") -- Increases your healing taken by __% for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_VULNERABILITY",   "Vulnerability") -- Increases your damage taken by __% for _ seconds
ZO_CreateStringId("ITEMTRIG_STRING_ALCHEMYEFFECT_WEAPONCRITICAL",  "Weapon Critical") -- Gives you ____ Weapon Critical Rating for _ seconds
--
--
-- MISCELLANEOUS
--
--
ZO_CreateStringId("ITEMTRIG_STRING_LOG_DECONSTRUCT",     "|cFFA020ItemTrig:|r Deconstructed <<1>>.")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_DEPOSIT_IN_BANK", "|cFFA020ItemTrig:|r Deposited <<1>> x|cFFFF00<<2>>|r in the bank.")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_DESTROY",         "|cFFA020ItemTrig:|r Destroyed <<1>> x|cFFFF00<<2>>|r.")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_LAUNDER",         "|cFFA020ItemTrig:|r Laundered <<1>> x|cFFFF00<<2>>|r.")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_SELL",            "|cFFA020ItemTrig:|r Sold <<1>> x|cFFFF00<<2>>|r.")
--
-- Messages shown when a trigger stops due to an error, if the player has 
-- fault logging enabled. We use black-colored dots to indent the text; 
-- leading spaces will be stripped out.
--
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGFAIL_BASE",      "|cFFA020ItemTrig: Encountered an error in a trigger.|r")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGFAIL_ITEM",      "|c000000...|r|cFFA020Item:|r <<1>>")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGFAIL_TRIG",      "|c000000...|r|cFFA020Faulting Trigger:|r <<1>>")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGFAIL_TRIG_TOP",  "|c000000...|r|cFFA020Containing Top-Level Trigger:|r <<1>>")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGFAIL_OP_C",      "|c000000...|r|cFFA020Condition:|r <<1>>")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGFAIL_OP_A",      "|c000000...|r|cFFA020Action:|r <<1>>")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGFAIL_REASON",    "|c000000...|r<<1>>")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGFAIL_ERRORCODE", "|c000000...|r|cFFA020Error code:|r <<1>>")
--
-- Messages shown when a trigger's conditions fail to match, if the missed 
-- condition was preceded by a "Log Trigger Miss" condition. We use black-
-- colored dots to indent the text; leading spaces will be stripped out.
--
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGMISS_BASE",      "|cFFA020ItemTrig: A trigger's conditions didn't match.|r")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGMISS_ITEM",      "|c000000...|r|cFFA020Item:|r <<1>>")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGMISS_TRIG",      "|c000000...|r|cFFA020Missed Trigger:|r <<1>>")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGMISS_TRIG_TOP",  "|c000000...|r|cFFA020Containing Top-Level Trigger:|r <<1>>")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGMISS_COND",      "|c000000...|r|cFFA020<<i:2>> condition:|r <<1>>")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGMISS_NO_ORS",    "|c000000...|rNone of the OR-linked conditions had matched by this point.")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGMISS_BAD_TAIL_ORS", "|c000000...|rNone of the OR-linked conditions at the end matched.")
--
--
-- SYSTEM
--
--
ZO_CreateStringId("ITEMTRIG_STRING_DEFAULT_TRIGGER_NAME", "Unnamed trigger")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_PLACEHOLDER_QUANTITY", "quantity")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_PLACEHOLDER_TEXT", "text")
--
ZO_CreateStringId("ITEMTRIG_STRING_QUALIFIER_ATLEAST", "at least %s") -- format strings for quantity values
ZO_CreateStringId("ITEMTRIG_STRING_QUALIFIER_ATMOST",  "at most %s")
ZO_CreateStringId("ITEMTRIG_STRING_QUALIFIER_EXACTLY", "exactly %s")
ZO_CreateStringId("ITEMTRIG_STRING_QUALIFIER_NOTEQ",   "not equal to %s")
ZO_CreateStringId("ITEMTRIG_STRING_QUALIFIER_INVALID", "????? %s")
ZO_CreateStringId("ITEMTRIG_STRING_QUALIFIERPREFIX_ATLEAST", "at least") -- these are the drop-down items when picking a qualifier
ZO_CreateStringId("ITEMTRIG_STRING_QUALIFIERPREFIX_ATMOST",  "at most")
ZO_CreateStringId("ITEMTRIG_STRING_QUALIFIERPREFIX_EXACTLY", "exactly")
ZO_CreateStringId("ITEMTRIG_STRING_QUALIFIERPREFIX_NOTEQ",   "not equal to")
--
ZO_CreateStringId("ITEMTRIG_STRING_ENTRYPOINT_NONE_SELECTED", "[None selected. When should your trigger run?]")
ZO_CreateStringId("ITEMTRIG_STRING_ENTRYPOINT_BANK",       "Bank Opened")
ZO_CreateStringId("ITEMTRIG_STRING_ENTRYPOINT_BARTER",     "Merchant Menu Opened")
ZO_CreateStringId("ITEMTRIG_STRING_ENTRYPOINT_CRAFTING",   "Crafting Menu Opened")
ZO_CreateStringId("ITEMTRIG_STRING_ENTRYPOINT_FENCE",      "Fence Menu Opened")
ZO_CreateStringId("ITEMTRIG_STRING_ENTRYPOINT_ITEM_ADDED", "Item Added")
--
ZO_CreateStringId("ITEMTRIG_STRING_ERROR_ACTION_ENTRYPOINT_LIMIT",    "This action can only run from the following entry points: <<1>>")
ZO_CreateStringId("ITEMTRIG_STRING_ERROR_CONDITION_ENTRYPOINT_LIMIT", "This condition can only run from the following entry points: <<1>>")
--
--
-- CONDITIONS
-- Condition descriptions use Zenimax format strings, wherein arguments 
-- are specified by index. This allows them to be used out-of-order rel-
-- ative to how the mod is coded.
--
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_COMMENT", "Comment")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_COMMENT", "Comment:\n<<1>>")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_SETANDOR", "Set And/Or")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_SETANDOR", "Switch to using <<1>> to evaluate conditions.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_SETANDOR_AND", "AND")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_SETANDOR_OR",  "OR")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_ALWAYS", "Always/Never")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_ALWAYS", "This condition is <<1>> true.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ALWAYS_ALWAYS", "always")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ALWAYS_NEVER",  "never")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_STOLEN", "Stolen")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_STOLEN", "The item <<1>> stolen.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_STOLEN_NO",  "is not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_STOLEN_YES", "is")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_LEVEL", "Item Level")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_LEVEL", "The item's level is <<1>>.")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_RARITY", "Item Rarity")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_RARITY", "The item's rarity is <<1>>.")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_ITEMTYPE", "Item Type")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_ITEMTYPE", "The item <<1>> a <<2>>.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMTYPE_NO",  "is not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMTYPE_YES", "is")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMTYPE_ANYSOLVENT",     "[any alchemy solvent]")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMTYPE_ANYFOODORDRINK", "[any food or drink]")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMTYPE_ANYGLYPH",       "[any enchanting glyph]")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMTYPE_ANYRUNE",        "[any enchanting rune]")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMTYPE_ANYCRAFTMAT",    "[any crafting material]")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMTYPE_ANYTRAITMAT",    "[any trait material]")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMTYPE_ANYUNREFINED",   "[any unrefined material]")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMTYPE_ANYREFINED",     "[any refined material]")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_CRAFTED", "Crafted By Player (Yes/No)")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_CRAFTED", "The item <<1>> crafted by a player.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CRAFTED_NO",  "was not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CRAFTED_YES", "was")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_ADDEDITEMCAUSE", "Added Item Cause")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_ADDEDITEMCAUSE", "The item <<1>> added to the player's inventory because <<2>>.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ADDEDITEMCAUSE_NO",  "was not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ADDEDITEMCAUSE_YES", "was")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ADDEDITEMCAUSE_PURCHASED",      "they purchased it")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ADDEDITEMCAUSE_MAILGIFT",       "they got it in the mail")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ADDEDITEMCAUSE_BANKWITHDRAWAL", "they withdrew it from a bank")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ADDEDITEMCAUSE_CRAFTING",       "they got it from a crafting station")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_ADDEDITEMISNEWSTACK", "Added Item Is New Stack")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_ADDEDITEMISNEWSTACK", "The item <<1>> a new stack.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ADDEDITEMISNEWSTACK_NO",  "is not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ADDEDITEMISNEWSTACK_YES", "is")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_TOTALCOUNT", "Total Count")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_TOTALCOUNT", "The player's <<1>> contains <<2>> of the item.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_TOTALCOUNT_BACKPACK", "inventory")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_TOTALCOUNT_BANK",     "bank")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_TOTALCOUNT_CRAFTBAG", "craft bag")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_ITEMNAME", "Item Name")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_ITEMNAME", "The item's name <<2>> <<1>>.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMNAME_WHOLE",     "is")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMNAME_SUBSTRING", "contains")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_CANBERESEARCHED", "Can Be Researched")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_CANBERESEARCHED", "The item <<1>> be researched.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CANBERESEARCHED_NO",  "can't")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CANBERESEARCHED_YES", "can")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_CREATORNAME", "Crafted By Player (Name)")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_CREATORNAME", "The item was crafted by a character whose name <<2>> <<1>>.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CREATORNAME_WHOLE",     "is")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CREATORNAME_SUBSTRING", "contains")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_LOCKED", "Locked")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_LOCKED", "The item <<1>> locked.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_LOCKED_NO",  "is not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_LOCKED_YES", "is")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_JUNK", "Junk")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_JUNK", "The item <<1>> flagged as junk.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_JUNK_NO",  "is not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_JUNK_YES", "is")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_ITEMSTYLE", "Item Style")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_ITEMSTYLE", "The item's style <<1>> <<2>>.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMSTYLE_NO",  "is not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMSTYLE_YES", "is")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMSTYLE_ANYALLIANCE", "[any alliance style]")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMSTYLE_ANYRACIAL",   "[any racial style]")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMSTYLE_ANYNONSTYLE", "[no style]")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_ALCHEMYEFFECTS", "Alchemy Effects")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_ALCHEMYEFFECTS", "The reagent <<1>> a known effect named <<2>>.")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONEXPLANATION_ALCHEMYEFFECTS", "Due to game engine limitations, this condition can only check the effects your character has discovered.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ALCHEMYEFFECTS_NO",  "does not have")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ALCHEMYEFFECTS_YES", "has")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_LOGTRIGGERMISS", "Log Trigger Miss")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_LOGTRIGGERMISS", "Log debugging information if this trigger's conditions don't match.")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONEXPLANATION_LOGTRIGGERMISS", "If this condition is reached, then a detailed message will be logged if the trigger's conditions don't match. Only conditions after this one will log a message.")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_PRIORITYSELL", "Priority Sell")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_PRIORITYSELL", "The item <<1>> basically useless and only good for selling.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_PRIORITYSELL_NO",  "is not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_PRIORITYSELL_YES", "is")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_CROWNITEM", "Crown Item")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_CROWNITEM", "The item <<1>> <<2>>.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CROWNITEM_NO",  "is not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CROWNITEM_YES", "is")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CROWNITEM_STORE",  "a Crown Store item")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CROWNITEM_CRATE",  "a Crown Crate item")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CROWNITEM_ANY",  "a Crown Crate or Crown Store item")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_ENLIGHTENED", "Enlightened")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_ENLIGHTENED", "The player-character <<1>> Enlightened and will earn experience at a boosted rate.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ENLIGHTENED_NO",  "is not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ENLIGHTENED_YES", "is")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_ORNATE", "Ornate")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_ORNATE", "The item <<1>> ornate.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ORNATE_NO",  "is not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ORNATE_YES", "is")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_INTRICATE", "Intricate")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_INTRICATE", "The item <<1>> intricate.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_INTRICATE_NO",  "is not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_INTRICATE_YES", "is")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_ITEMTRAIT_ARMOR", "Item Trait (Armor)")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_ITEMTRAIT_ARMOR", "The armor's trait <<1>> <<2>>.")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_ITEMTRAIT_JEWELRY", "Item Trait (Jewelry)")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_ITEMTRAIT_JEWELRY", "The jewelry's trait <<1>> <<2>>.")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_ITEMTRAIT_WEAPON", "Item Trait (Weapon)")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_ITEMTRAIT_WEAPON", "The weapon's trait <<1>> <<2>>.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMTRAIT_NO",  "is not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMTRAIT_YES", "is")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_ITEMFILTER", "Item Category")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_ITEMFILTER", "The item <<1>> to the <<2>> category.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMFILTER_NO",  "does not belong")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMFILTER_YES", "belongs")
--
--
-- ACTIONS
-- Action descriptions use Zenimax format strings, wherein arguments are 
-- specified by index. This allows them to be used out-of-order relative 
-- to how the mod is coded.
--
--
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONNAME_RETURN", "Return")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_RETURN", "Stop executing the top-level trigger.")
--
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONNAME_LOG", "Log Message")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_LOG", "Log a message in the chatbox:\n<<1>>")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONEXPLANATION_LOG", "You can specify the following format codes in your message:\n\n$(countTotalBag) = The total amount of the item in your inventory\n$(creator) = The character who crafted the item\n$(level) = The item's level\n$(name) = The item's name\n$(price) = The item's price\n$(style) = The item's style")
--
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONNAME_RUNNESTED", "Run Nested Trigger")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_RUNNESTED", "Execute a nested trigger:\n<<1>>")
--
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONNAME_COMMENT", "Comment")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_COMMENT", "Comment:\n<<1>>")
--
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONNAME_DESTROYITEM", "Destroy Stack")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_DESTROYITEM", "Destroy <<1>>.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_DESTROYITEM_WHOLESTACK", "this stack of items")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_DESTROYITEM_ONLYADDED",  "the items that were added")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_DESTROYITEM_LOCKED",     "The item is locked.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_DESTROYITEM_CANT_SPLIT", "Your inventory is full. In order to destroy just the incoming items, you must have one slot to spare.")
--
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONNAME_MODIFYJUNKFLAG", "Modify Junk Flag")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_MODIFYJUNKFLAG", "<<1>> the item as junk.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_MODIFYJUNKFLAG_OFF", "Unmark")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_MODIFYJUNKFLAG_ON",  "Mark")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_JUNK_NOT_ALLOWED", "This item can't be flagged as junk.")
--
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONNAME_LAUNDER", "Launder")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_LAUNDER", "Launder <<1>> of the item.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_LAUNDERITEM_ZENIMAX_MAX_COUNT", "Add-ons can only launder 98 items every time the fence window is open. Close the fence window and reopen it to launder more items.")
--
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONNAME_SELLORFENCE", "Sell or Fence")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_SELLORFENCE", "Sell <<1>> of the item.")
--
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONNAME_DECONSTRUCT", "Deconstruct")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_DECONSTRUCT", "Deconstruct the item.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_DECONSTRUCT_LOCKED",     "The item is locked.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_DECONSTRUCT_WRONG_TYPE", "This item can't be deconstructed.")
--
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONNAME_STOPRUNNINGTRIGGERS", "Stop Running Triggers")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_STOPRUNNINGTRIGGERS", "Stop all ongoing trigger processing for this item.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONEXPLANATION_STOPRUNNINGTRIGGERS", "This action will immediately stop running triggers on the current item; you can use it to block the rest of your triggers from running on certain kinds of items. Note that this only applies to the one time that this action runs. If this action doesn't run when triggers are processed in the future, then the item will be processed again.")
--
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONNAME_DEPOSITINBANK", "Deposit In Bank")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_DEPOSITINBANK", "Deposit <<1>> of the item in the player's bank.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_DEPOSITINBANK_FULL",     "The bank is full.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_DEPOSITINBANK_NOT_OPEN", "Cannot deposit items in the bank if you aren't viewing the bank.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_DEPOSITINBANK_STOLEN",   "You can't store stolen items in the bank.")
--
--
-- GALLERY
-- Strings used by pre-made triggers that the player can copy.
--
-- Some of these strings are passed to the "Log Message" trigger action. That 
-- action allows you to specify format codes, like $(name), which will be 
-- replaced with data about the item being acted on. When translating these 
-- messages, leave those strings intact.
--
--
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_DESTROYEXCESSSTYLEMATS_NAME",    "Destroy common style materials past one stack, unless withdrawn or purchased")
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_DESTROYEXCESSSTYLEMATS_MESSAGE", "You have a full stack of $(name) already. Destroying the $(countAdded) that were added.")
--
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_DESTROYSTOLENCRAPTREASURE_NAME",           "Destroy low-rarity stolen treasures")
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_DESTROYSTOLENCRAPTREASURE_NAME_NESTED_01", "...Unless we can stockpile them for The Covetous Countess")
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_DESTROYSTOLENCRAPTREASURE_MESSAGE",        "Destroyed incoming $(name).")
