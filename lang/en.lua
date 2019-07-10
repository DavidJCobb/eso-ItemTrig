ZO_CreateStringId("ITEMTRIG_STRING_UI_GENERIC_CONFIRM_YES", "Yes")
ZO_CreateStringId("ITEMTRIG_STRING_UI_GENERIC_CONFIRM_NO", "No")
ZO_CreateStringId("ITEMTRIG_STRING_UI_GENERIC_CONFIRM_TITLE", "Are you sure?") -- confirmation prompt window title, if none is specified
ZO_CreateStringId("ITEMTRIG_STRING_GENERIC_TRUNCATION_MARKER", "...")
--
--
-- CHAT COMMAND BEHAVIOR
--
--
ZO_CreateStringId("ITEMTRIG_STRING_CHAT_BAD_SUBCOMMAND",          "Type |cFFA020/itemtrig help|r to view the list of valid commands.")
ZO_CreateStringId("ITEMTRIG_STRING_CHAT_SUBCOMMAND_DESC_EDIT",    "Open the trigger editor.")
--ZO_CreateStringId("ITEMTRIG_STRING_CHAT_SUBCOMMAND_DESC_HELP",    "List all ItemTrig chat commands. Do |cFFA020/itemtrig help TextHere|r to search.") -- this is a bit excessive for the number of commands we offer, lol
ZO_CreateStringId("ITEMTRIG_STRING_CHAT_SUBCOMMAND_DESC_HELP",    "List all ItemTrig chat commands.")
ZO_CreateStringId("ITEMTRIG_STRING_CHAT_SUBCOMMAND_DESC_OPTIONS", "Open ItemTrig's options menu.")
--
ZO_CreateStringId("ITEMTRIG_STRING_CHAT_SUBCOMMAND_EXEC_HELP_HEADER", "|cFFA020|l0:1:1:15%:1.5:FFA020|lItemTrig chat commands:|l|r")
ZO_CreateStringId("ITEMTRIG_STRING_CHAT_SUBCOMMAND_EXEC_HELP_SEARCH", "|cFFA020|l0:1:1:15%:1.5:FFA020|lItemTrig chat commands (filter: <<1>>):|l|r")
ZO_CreateStringId("ITEMTRIG_STRING_CHAT_SUBCOMMAND_EXEC_HELP_ITEM",   "|cFFA020<<1>>|r: <<2>>")
--
--
-- OPTIONS
--
--
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONBUTTON_EDITTRIGGERS", "Edit triggers...")
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONDESC_EDITTRIGGERS", "Click here to edit the rules you've set for handling items.")
--
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONNAME_UPDATEGALLERYTRIGGERS", "Keep imported triggers up to date")
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONDESC_UPDATEGALLERYTRIGGERS", "ItemTrig offers a \"gallery\" of pre-made triggers that you can import for your own use. If this setting is enabled, then imported triggers will be kept up to date: if future versions of the mod change a gallery trigger, then the imported trigger will change to match it. Note that editing an imported trigger will sever the link and prevent it from auto-updating.")
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
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONNAME_BANKTRIGGERSALLOWDESTROY", "Banked items: allow destroy")
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONDESC_BANKTRIGGERSALLOWDESTROY", "Control whether triggers are allowed to destroy banked items. This option does not affect deconstruction.")
--
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONNAME_PRETENDACTIONS", "Pretend Mode")
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONDESC_PRETENDACTIONS", "If this is enabled, then ItemTrig will not take any actions on your items. Instead, it will simply log what it would have done.")
--
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONHEADER_LOGGING", "Logging")
--
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONNAME_LOGALLITEMACTIONS", "Log actions taken on items")
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONDESC_LOGALLITEMACTIONS", "Log whenever an action is taken on an item to destroy it, get rid of it, or otherwise move it.")
--
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONNAME_LOGTRIGGERFAILURES", "Log trigger failures")
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONDESC_LOGTRIGGERFAILURES", "Log every time a trigger stops early due to an error.")
--
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONNAME_COLLAPSESAMETRIGFAILS", "Collapse duplicate failure messages")
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONDESC_COLLAPSESAMETRIGFAILS", "Causes certain kinds of trigger failures to only show a single message. If you have ten triggers trying to deposit into a full bank, you don't need ten error messages telling you your bank is full, right?")
--
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONHEADER_UI", "UI settings")

ZO_CreateStringId("ITEMTRIG_STRING_OPTIONNAME_THEME", "UI color scheme")
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONDESC_THEME", "What do you want ItemTrig to look like?")
--
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONNAME_ALLOWESCFORCECLOSE", "Esc force-closes the editor")
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONDESC_ALLOWESCFORCECLOSE", "Control whether the Esc key force-closes the editor and discards unsaved changes")
--
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONNAME_TRIGGERARGAUTOCOMPLETE", "Trigger argument autocomplete")
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONDESC_TRIGGERARGAUTOCOMPLETE", "Enable auto-complete for trigger arguments that support it")
--
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONHEADER_EXTRA", "Extra features")
--
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONNAME_ROBUSTFENCING", "Robust Fencing")
ZO_CreateStringId("ITEMTRIG_STRING_OPTIONDESC_ROBUSTFENCING", "For the \"Fence\" entry point, sort items by value before running triggers on them, so that the most valuable items are fenced or laundered first.")
--
--
-- USER INTERFACE
--
--
ZO_CreateStringId("ITEMTRIG_STRING_UI_THEMENAME_DARK",       "Dark")
ZO_CreateStringId("ITEMTRIG_STRING_UI_THEMEDESC_DARK",       "A dark theme that uses colors from ESO's PC interface: black and grey, with teal highlights.")
ZO_CreateStringId("ITEMTRIG_STRING_UI_THEMENAME_OLDDESKTOP", "Old Desktop")
ZO_CreateStringId("ITEMTRIG_STRING_UI_THEMEDESC_OLDDESKTOP", "A theme inspired by desktop UIs from the 1990s: grey windows, with orange highlights instead of blue for some added flair.")
--
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGERLIST_TITLE", "ItemTrig")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGERLIST_FILTER_SHOW_ALL", "Show All Triggers")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGERLIST_BUTTON_ADD", "New")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGERLIST_BUTTON_EDIT", "Edit")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGERLIST_BUTTON_MOVEUP", "Move Up")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGERLIST_BUTTON_MOVEDOWN", "Move Down")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGERLIST_BUTTON_DELETE", "Delete")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGERLIST_CONFIRM_DELETE", "Are you sure you want to delete this trigger? This mod doesn't offer Ctrl+Z, you know!")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGERLIST_HAS_NO_TRIGGERS",       "Click the \"New\" button to create a trigger, or click the \"Import\" button to copy some pre-made ones! :)")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGERLIST_ALL_TRIGGERS_FILTERED", "None of your triggers are set to run during this entry point.")
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
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGEREDIT_BUTTON_DUPLICATE", "Duplicate")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGEREDIT_BUTTON_DELETE", "Delete")
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGERLIST_BUTTON_IMPORT", "Import...")
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
ZO_CreateStringId("ITEMTRIG_STRING_UI_OPCODEARGEDIT_NUMBER_ALLOWED_MAX",       "You must use a number less than or equal to <<1>>.")
ZO_CreateStringId("ITEMTRIG_STRING_UI_OPCODEARGEDIT_NUMBER_ALLOWED_MIN",       "You must use a number greater than or equal to <<1>>.")
ZO_CreateStringId("ITEMTRIG_STRING_UI_OPCODEARGEDIT_NUMBER_ALLOWED_MINMAX",    "You must use a number between <<1>> and <<2>>, inclusive.")
ZO_CreateStringId("ITEMTRIG_STRING_UI_OPCODEARGEDIT_NUMBER_ALLOWED_INT",       "You must use an integer. Fractional numbers are not allowed.")
ZO_CreateStringId("ITEMTRIG_STRING_UI_OPCODEARGEDIT_NUMBER_ALLOWED_INTMAX",    "You must use an integer less than or equal to <<1>>.")
ZO_CreateStringId("ITEMTRIG_STRING_UI_OPCODEARGEDIT_NUMBER_ALLOWED_INTMIN",    "You must use an integer greater than or equal to <<1>>.")
ZO_CreateStringId("ITEMTRIG_STRING_UI_OPCODEARGEDIT_NUMBER_ALLOWED_INTMINMAX", "You must use an integer between <<1>> and <<2>>, inclusive.")
--
ZO_CreateStringId("ITEMTRIG_STRING_UI_IMPORTLIST_TITLE", "Import trigger...")
ZO_CreateStringId("ITEMTRIG_STRING_UI_IMPORTLIST_LABEL_IMPORTSOURCE", "Import from:")
ZO_CreateStringId("ITEMTRIG_STRING_UI_IMPORTLIST_BUTTON_IMPORT", "Import")
ZO_CreateStringId("ITEMTRIG_STRING_UI_IMPORTLIST_TRIGGERENTRYPOINT", "Entry point(s): <<1>>")
ZO_CreateStringId("ITEMTRIG_STRING_UI_IMPORTLIST_TRIGGERENTRYPOINTSEPARATOR", ", ")
ZO_CreateStringId("ITEMTRIG_STRING_UI_IMPORTLIST_TRIGGERENTRYPOINTNONE", "[none set]")
ZO_CreateStringId("ITEMTRIG_STRING_UI_IMPORTLIST_HAS_NO_TRIGGERS",       "This character doesn't have any triggers to import.")
ZO_CreateStringId("ITEMTRIG_STRING_UI_IMPORTLIST_ALL_TRIGGERS_FILTERED", "The current display filters are hiding all triggers.") -- This should not appear
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
ZO_CreateStringId("ITEMTRIG_STRING_SPECITEMTYPE_DRINKUNIQUE", "Drink, Unique Drink")
ZO_CreateStringId("ITEMTRIG_STRING_SPECITEMTYPE_FURNISHINGMATALCHEMY",      "Furnishing Material, Alchemy")
ZO_CreateStringId("ITEMTRIG_STRING_SPECITEMTYPE_FURNISHINGMATCLOTHING",     "Furnishing Material, Clothier")
ZO_CreateStringId("ITEMTRIG_STRING_SPECITEMTYPE_FURNISHINGMATENCHANTING",   "Furnishing Material, Enchanting")
ZO_CreateStringId("ITEMTRIG_STRING_SPECITEMTYPE_FURNISHINGMATJEWELRY",      "Furnishing Material, Jewelry")
ZO_CreateStringId("ITEMTRIG_STRING_SPECITEMTYPE_FURNISHINGMATPROVISIONING", "Furnishing Material, Provisioning")
ZO_CreateStringId("ITEMTRIG_STRING_SPECITEMTYPE_FURNISHINGMATSMITHING",     "Furnishing Material, Blacksmithing")
ZO_CreateStringId("ITEMTRIG_STRING_SPECITEMTYPE_FURNISHINGMATWOODWORKING",  "Furnishing Material, Woodworking")
ZO_CreateStringId("ITEMTRIG_STRING_SPECITEMTYPE_PREFIX_DRINK",     "Drink, <<1>>")
ZO_CreateStringId("ITEMTRIG_STRING_SPECITEMTYPE_PREFIX_ENCHRUNE",  "Enchanting, <<1>>")
ZO_CreateStringId("ITEMTRIG_STRING_SPECITEMTYPE_PREFIX_FOOD",      "Food, <<1>>")
ZO_CreateStringId("ITEMTRIG_STRING_SPECITEMTYPE_PREFIX_FURNITURE", "Furniture, <<1>>")
ZO_CreateStringId("ITEMTRIG_STRING_SPECITEMTYPE_PREFIX_REAGENT",   "Alchemy Reagent, <<1>>")
ZO_CreateStringId("ITEMTRIG_STRING_SPECITEMTYPE_PREFIX_SIEGE",     "Siege, <<1>>")
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
-- This is a list of known treasure categories. This is used by the 
-- trigger system, so these strings need to exactly match the ones 
-- shown for these categories in any given language.
--
-- Where possible, each string is annotated with a comment identifying 
-- a treasure item (by ID and name) that has only that category.
--
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_ARTWORK",             "Artwork") -- 64358: Autographed Calling Card
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_CHILDRENSTOYS",       "Children's Toys")
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_COSMETICS",           "Cosmetics")
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_DEVICES",             "Devices")
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_DISHESANDCOOKWARE",   "Dishes and Cookware") -- 61263: Cherrywood Morsel Bowl
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_DOLLS",               "Dolls") -- 64365: Bloody Buttons' Ragamuffin
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_DRINKWARE",           "Drinkware") -- 61850: "Ancient" Clay Goblet
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_DRYGOODS",            "Dry Goods") -- 61382: Bolt of Red Fabric
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_FISHINGSUPPLIES",     "Fishing Supplies") -- 64455: Crawler Tube
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_FURNISHINGS",         "Furnishings") -- 61821: Argonian Darkwood Tabletop
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_GAMES",               "Games") -- 64381: Bag of Letter Tiles
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_GROOMINGITEMS",       "Grooming Items") -- 62810: Boarbristle Brush
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_LIGHTS",              "Lights") -- 61358: Brass Candle Snuffer
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_LINENS",              "Linens")
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_MAGICCURIOSITIES",    "Magic Curiosities") -- 64389: Portal Seed
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_MAPS",                "Maps") -- 62081: Caravan Schedule
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_MEDICALSUPPLIES",     "Medical Supplies") -- 62883: False Eye
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_MUSICALINSTRUMENTS",  "Musical Instruments") -- 138919: Aldmeri Sheet Music
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_ODDITIES",            "Oddities") -- 61442: Commemorative Imperial Coins
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_RELIC",               "Relic") -- 73781: Akaviri Armistice Banquet Tray -- NOTE: Is this only used for Kari's Hit List?
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_RITUALOBJECTS",       "Ritual Objects") -- 64408: Dried Prayer Garlands
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_SCRIVENERSUPPLIES",   "Scrivener Supplies") -- 62584: Carved Pumice Stone
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_SMITHINGEQUIPMENT",   "Smithing Equipment") -- 64442: Spool of Bendy Wire
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_STATUES",             "Statues") -- 61536: Glass Owl Curio
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_TOOLS",               "Tools") -- 62784: Copper Measures
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_TRIFLESANDORNAMENTS", "Trifles and Ornaments") -- 61555: Colorful Pottery
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_UTENSILS",            "Utensils") -- 64326: Cast Iron Toothed Spoon
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_WALLDECOR",           "Wall Décor") -- 62179: Pewter Portrait Frame
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_WARDROBEACCESSORIES", "Wardrobe Accessories") -- 61107: Common Buckle
ZO_CreateStringId("ITEMTRIG_STRING_TREASURECAT_WRITINGS",            "Writings") -- 61207: Cheaply Bound Journal

--
-- COVETOUS COUNTESS
--
-- We have a condition that allows the player to match items against 
-- their current Covetous Countess objective. However, the game doesn't 
-- expose any useful internal values (e.g. unique identifiers for the 
-- quest or its objectives). The only way to detect the quest is to 
-- match its name.
--
ZO_CreateStringId("ITEMTRIG_STRING_COVETOUS_NAME", "The Covetous Countess") -- Quest name; must match exactly
--
--
-- MISCELLANEOUS
--
--
ZO_CreateStringId("ITEMTRIG_STRING_LOG_DECONSTRUCT",        "|cFFA020ItemTrig:|r Deconstructed <<1>>.")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_DEPOSIT_IN_BANK",    "|cFFA020ItemTrig:|r Deposited <<1>> x|cFFFF00<<2>>|r in the bank.")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_DESTROY",            "|cFFA020ItemTrig:|r Destroyed <<1>> x|cFFFF00<<2>>|r.")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_LAUNDER",            "|cFFA020ItemTrig:|r Laundered <<1>> x|cFFFF00<<2>>|r.")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_SELL",               "|cFFA020ItemTrig:|r Sold <<1>> x|cFFFF00<<2>>|r.")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_WITHDRAW_FROM_BANK", "|cFFA020ItemTrig:|r Withdrew <<1>> x|cFFFF00<<2>>|r from the bank.")
--
ZO_CreateStringId("ITEMTRIG_STRING_DECONSTRUCTOBSERVER_START",       "|cFFA020ItemTrig:|r Attempting to deconstruct <<1>> items...")
ZO_CreateStringId("ITEMTRIG_STRING_DECONSTRUCTOBSERVER_FAILURE",     "|cFFA020ItemTrig:|r Failed to deconstruct |cFFFF00<<1>>|r.")
ZO_CreateStringId("ITEMTRIG_STRING_DECONSTRUCTOBSERVER_FAILURE_WHY", "|c000000...|r<<1>>")
ZO_CreateStringId("ITEMTRIG_STRING_DECONSTRUCTOBSERVER_ABORT",       "|cFFA020ItemTrig:|r Deconstruction has stopped early due to the previous error.")
ZO_CreateStringId("ITEMTRIG_STRING_DECONSTRUCTOBSERVER_INTERRUPT",   "|cFFA020ItemTrig:|r Deconstruction interrupted; you left the crafting station!")
ZO_CreateStringId("ITEMTRIG_STRING_DECONSTRUCTOBSERVER_COMPLETE",    "|cFFA020ItemTrig:|r Finished deconstructing items.")

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
-- Messages shown when multiple triggers fail for the same reason, and when 
-- the player has chosen to "collapse" these failures into summaries after 
-- the first listed failure. These are per error code.
--
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGFAILGROUP",      "|cFFA020ItemTrig: <<1>> total triggers failed with the following error:|r")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGFAILGROUP_BKFL", "|c000000...|rCannot deposit items when the bank is full.")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGFAILGROUP_BKNO", "|c000000...|rCannot deposit items when the bank is not open.")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGFAILGROUP_FENL", "|c000000...|rYou've maxed out your fence transactions for the day.")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGFAILGROUP_LNDL", "|c000000...|rYou've maxed out your launder transactions for the day.")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGFAILGROUP_ZDPT", "|c000000...|rZenimax limits how many items an add-on can automatically deposit. Close and reopen the bank to deposit more.")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGFAILGROUP_ZLND", "|c000000...|rZenimax limits how many items an add-on can automatically launder. Close and reopen the fence to launder more.")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGFAILGROUP_ZWTH", "|c000000...|rZenimax limits how many items an add-on can automatically wothdraw. Close and reopen the bank to withdraw more.")
ZO_CreateStringId("ITEMTRIG_STRING_LOG_TRIGFAILGROUP_WCFT", "|c000000...|rThis is the wrong crafting station for this type of item.")
--
--
-- SYSTEM
--
--
ZO_CreateStringId("ITEMTRIG_STRING_USER_FACING_ASSERT_BAD_CONDITION_TABLE", "There is a problem with ItemTrig's trigger condition list. A syntax error or script error may have prevented the list from loading properly. The add-on is not usable in this state; please notify the developer.")
ZO_CreateStringId("ITEMTRIG_STRING_USER_FACING_ASSERT_BAD_ACTION_TABLE",    "There is a problem with ItemTrig's trigger action list. A syntax error or script error may have prevented the list from loading properly. The add-on is not usable in this state; please notify the developer.")
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
ZO_CreateStringId("ITEMTRIG_STRING_ENTRYPOINT_BANK_BANK",     "Bank Opened (run on banked items)")
ZO_CreateStringId("ITEMTRIG_STRING_ENTRYPOINT_BANK_CRAFTING", "Crafting Menu Opened (run on banked items)")
--
ZO_CreateStringId("ITEMTRIG_STRING_ERROR_ACTION_ENTRYPOINT_LIMIT",    "This action can only run from the following entry points: <<1>>")
ZO_CreateStringId("ITEMTRIG_STRING_ERROR_CONDITION_ENTRYPOINT_LIMIT", "This condition can only run from the following entry points: <<1>>")
--
ZO_CreateStringId("ITEMTRIG_STRING_ERROR_ACTION_ARGUMENT_TYPE_ERROR",   "The options' data is incorrect. This trigger will not run again until the next entry point.")
ZO_CreateStringId("ITEMTRIG_STRING_ERROR_ACTION_ARGUMENT_TYPE_UNKNOWN", "One of the options has a value that this mod can't handle. Consider reporting this as a bug, and sending your savedata to the developer. For now, this trigger will not run again until the next entry point.")
ZO_CreateStringId("ITEMTRIG_STRING_ERROR_ACTION_ARGUMENT_VALUE_ERROR",  "One of the options has a value that isn't allowed. This trigger will not run again until the next entry point.")
--
ZO_CreateStringId("ITEMTRIG_STRING_PRETENDBASE", "|cFFA020[Pretend Mode] ItemTrig would have <<1>>|r <<2>>|cFFA020.|r")
ZO_CreateStringId("ITEMTRIG_STRING_PRETEND_DESTROYITEM",      "destroyed")
ZO_CreateStringId("ITEMTRIG_STRING_PRETEND_JUNKFLAGMODIFY",   "modified the junk flag for")
ZO_CreateStringId("ITEMTRIG_STRING_PRETEND_JUNKFLAGSET",      "marked-as-junk")
ZO_CreateStringId("ITEMTRIG_STRING_PRETEND_JUNKFLAGCLEAR",    "unmarked-as-junk")
ZO_CreateStringId("ITEMTRIG_STRING_PRETEND_LAUNDER",          "laundered")
ZO_CreateStringId("ITEMTRIG_STRING_PRETEND_SELLORFENCE",      "sold/fenced")
ZO_CreateStringId("ITEMTRIG_STRING_PRETEND_DECONSTRUCT",      "deconstructed")
ZO_CreateStringId("ITEMTRIG_STRING_PRETEND_DEPOSITINBANK",    "banked")
ZO_CreateStringId("ITEMTRIG_STRING_PRETEND_WITHDRAWFROMBANK", "withdrawn")
--
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEEXPLANATION_GENERIC_EP",    "This opcode can only be used from the \"<<X:1>>\" entry point.")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONEXPLANATION_GENERIC_EP", "This condition can only be used from the \"<<X:1>>\" entry point.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONEXPLANATION_GENERIC_EP",    "This action can only be used from the \"<<X:1>>\" entry point.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEEXPLANATION_GENERIC_EP_MULTI",    "This opcode can only be used from one of these entry points: <<1>>.")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONEXPLANATION_GENERIC_EP_MULTI", "This condition can only be used from one of these entry points: <<1>>.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONEXPLANATION_GENERIC_EP_MULTI",    "This action can only be used from one of these entry points: <<1>>.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEEXPLANATION_GENERIC_EP_MULTI_SEP", "; ")
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
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONEXPLANATION_SETANDOR", "Conditions are AND-linked by default. A switch to OR-linked will not affect later triggers (even nested ones).")
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
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMTYPE_ANYEQUIP",       "[any equippable]")
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
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_CREATORNAME", "The item <<1>> crafted by a character whose name <<2>> <<3>>.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CREATORNAME_NO",  "was not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CREATORNAME_YES", "was")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CREATORNAME_WHOLE",      "is")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CREATORNAME_SUBSTRING",  "contains")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARGEXPLANATION_CREATORNAME", "If you specify \"$(player)\", then this condition will use your character's name.")
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
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_PRIORITYSELL", "Priority Sell [DEPRECATED]")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_PRIORITYSELL", "The item <<1>> basically useless and only good for selling.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_PRIORITYSELL_NO",  "is not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_PRIORITYSELL_YES", "is")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONEXPLANATION_PRIORITYSELL", "This condition was originally intended to check whether an item is \"vendor trash.\" However, it appears that the ESO team has flagged a TON of items as vendor trash when they... aren't. Things like style materials (even rare one!)")
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
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMFILTER_ANYEQUIP", "[any equippable]")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_USAGEREQUIREMENTSMET", "Usage Requirement Met")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_USAGEREQUIREMENTSMET", "The player-character <<1>> the level and Champion Point requirements for using this item.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_USAGEREQUIREMENTSMET_NO",  "does not meet")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_USAGEREQUIREMENTSMET_YES", "meets")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_CRAFTINGRANK", "Crafting Rank")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_CRAFTINGRANK", "This item <<1>> <<2>> crafting rank.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CRAFTINGRANK_NO",  "does not belong to")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CRAFTINGRANK_YES", "belongs to")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CRAFTINGRANK_USABLE", "any craftable")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CRAFTINGRANK_PLAYERMAX", "the highest craftable")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CRAFTINGRANK_AFTERPLAYERMAX", "the one after the highest craftable")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CRAFTINGRANK_MAXTIER", "the highest")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_SALEVALUE", "Sale Value")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_SALEVALUE", "The item can be sold for <<1>> gold.")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_ISTREASUREMAP", "Is Treasure Map")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_ISTREASUREMAP", "The item <<1>> a treasure map.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ISTREASUREMAP_NO",  "is not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ISTREASUREMAP_YES", "is")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_ISCLOTHES", "Is Clothes")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_ISCLOTHES", "The item <<1>> civilian clothes that confer no armor.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ISCLOTHES_NO",  "is not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ISCLOTHES_YES", "is")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_ISSOULGEM", "Is Soul Gem")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_ISSOULGEM", "The item <<1>> a(n) <<2>> soul gem")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ISSOULGEM_NO",  "is not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ISSOULGEM_YES", "is")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ISSOULGEM_EMPTY",    "empty")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ISSOULGEM_FILLED",   "filled")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ISSOULGEM_ANYSTATE", "[any state]")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_CURRENTCRAFTINGSTATIONMATCHES", "Current Crafting Station Matches")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_CURRENTCRAFTINGSTATIONMATCHES", "The current crafting station <<1>> this item.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CURRENTCRAFTINGSTATIONMATCHES_NO",  "isn't appropriate for")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CURRENTCRAFTINGSTATIONMATCHES_YES", "is appropriate for")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_CANLAUNDERCOUNT", "Launders Remaining")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_CANLAUNDERCOUNT", "The player can launder <<1>> more items.")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_CANFENCECOUNT", "Fences Remaining")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_CANFENCECOUNT", "The player can fence <<1>> more items.")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_ISKNOWNRECIPE", "Is Known Recipe/Motif")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_ISKNOWNRECIPE", "The player <<1>> learned how to craft this recipe, pattern, or motif.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ISKNOWNRECIPE_NO",  "has not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ISKNOWNRECIPE_YES", "has")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_TREASURETAG", "Treasure Category")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_TREASURETAG", "The item <<1>> to the <<2>> treasure category.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_TREASURETAG_NO",  "does not belong")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_TREASURETAG_YES", "belongs")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_COVETOUSCOUNTESS", "Covetous Countess")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_COVETOUSCOUNTESS", "The item <<1>> for the Covetous Countess: <<2>>.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_COVETOUSCOUNTESS_NO",  "cannot be used")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_COVETOUSCOUNTESS_YES", "can be used")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_COVETOUSCOUNTESS_CURRENT",                 "current objective")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_COVETOUSCOUNTESS_CHARACTER",               "current character level")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_COVETOUSCOUNTESS_ANY",                     "any objective")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_COVETOUSCOUNTESS_GAMESDOLLSSTATUES",       "games, dolls, and statues")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_COVETOUSCOUNTESS_RITUALSODDITIES",         "ritual objects and oddities")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_COVETOUSCOUNTESS_WRITINGSMAPS",            "writings and maps")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_COVETOUSCOUNTESS_COSMETICSLINENSWARDROBE", "cosmetics, linens, and wardrobe accessories")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_COVETOUSCOUNTESS_DRINKWAREUTENSILSDISHES", "drinkware, utensils, and dishes")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARGEXPLANATION_COVETOUSCOUNTESS_2", "You can test the item against the current Covetous Countess quest objectives, if the quest is active and you haven't delivered the items to the Countess yet. Alternatively, you can test the items against your level: if you're below level 50, then the objective you get depends on your level. (If you're at or above level 50, then testing against your level is the same as \"any objective.\")")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_ISITEMSET", "Item Set (Yes/No)")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_ISITEMSET", "The item <<1>> to an Item Set.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ISITEMSET_NO",  "does not belong")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ISITEMSET_YES", "belongs")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_ITEMSETNAME", "Item Set (Name)")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_ITEMSETNAME", "The item <<1>> to an Item Set whose name <<2>> <<3>>.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMSETNAME_NO",  "does not belong")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMSETNAME_YES", "belongs")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMSETNAME_WHOLE",     "is")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMSETNAME_SUBSTRING", "contains")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_CRAFTINGSKILLMAXED",  "Crafting Skill Maxed")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_CRAFTINGSKILLMAXED",  "The player <<1>> maxed their <<2>> skill.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CRAFTINGSKILLMAXED_NO",   "has not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CRAFTINGSKILLMAXED_YES",  "has")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CRAFTINGSKILLMAXED_ANY",  "[any crafting skill]")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CRAFTINGSKILLMAXED_ALL",  "[all crafting skills]")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_CRAFTINGSKILLMAXED_ITEM", "[crafting skill for this item]")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_SPECIALIZEDITEMTYPE", "Item Type (Detailed)")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_SPECIALIZEDITEMTYPE", "The item <<1>> a <<2>>.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_SPECIALIZEDITEMTYPE_NO",  "is not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_SPECIALIZEDITEMTYPE_YES", "is")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_ITEMLOCATION", "Item Location")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_ITEMLOCATION", "The item <<1>> in <<2>>.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMLOCATION_NO",  "is not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMLOCATION_YES", "is")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMLOCATION_BACKPACK", "the player's backpack")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ITEMLOCATION_BANK",     "the player's bank")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONEXPLANATION_ITEMLOCATION", "ItemTrig offers an option to run triggers on items in your bank, if those triggers have the Bank Opened or Crafting Menu Opened entry points. This option is useful for things like mass deconstructing equipment stored in the bank. If you are not using that option, then this condition isn't useful.")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_BOUND", "Bound")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_BOUND", "The item <<1>> <<2>>.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_BOUND_NO",  "is not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_BOUND_YES", "is")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_BOUND_ANY",  "bound")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_BOUND_CHAR", "Character Bound")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_ARMORTYPE", "Armor Type")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_ARMORTYPE", "The armor <<1>> <<2>>.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ARMORTYPE_NO",  "is not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_ARMORTYPE_YES", "is")
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_WEAPONTYPE", "Weapon Type")
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONDESC_WEAPONTYPE", "The weapon <<1>> a <<2>>.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_WEAPONTYPE_NO",  "is not")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_WEAPONTYPE_YES", "is")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_WEAPONTYPE_1HMELEE",          "[any one-handed melee]")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_WEAPONTYPE_2HMELEE",          "[any two-handed melee]")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_WEAPONTYPE_DESTRUCTIONSTAFF", "[any destruction staff]")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_WEAPONTYPE_STAFF",            "[any staff]")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_WEAPONTYPE_2H",               "[any two-handed]")
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
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONEXPLANATION_LOG", "You can specify the following format codes in your message:\n\n" .. 
   "$(countTotalBag) = The total amount of the item in your inventory\n" .. 
   "$(creator) = The character who crafted the item\n" .. 
   "$(level) = The item's level\n" ..
   "$(link) = The item's link\n" ..
   "$(name) = The item's name\n" ..
   "$(price) = The item's price\n" ..
   "$(style) = The item's style"
)
--
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONNAME_RUNNESTED", "Run Nested Trigger")
   --
   -- Due to code limitations and UI needs, the description for this 
   -- action MUST meet the following requirements:
   --
   --  - The nested trigger name is on the last line.
   --  - The nested trigger name is the only thing on that line.
   --
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_RUNNESTED", "Execute a nested trigger:\n<<1>>")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_RUNNESTED_EDIT", "Execute a nested trigger:")
--
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONNAME_COMMENT", "Comment")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_COMMENT", "Comment:\n<<1>>")
--
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONNAME_DESTROYITEM", "Destroy Stack")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_DESTROYITEM", "Destroy <<1>>.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_DESTROYITEM_WHOLESTACK", "this stack of items")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_DESTROYITEM_ONLYADDED",  "the items that were added")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_DESTROYITEM_LOCKED",      "The item is locked.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_DESTROYITEM_CANT_SPLIT",  "Your inventory is full. In order to destroy just the incoming items, you must have one slot to spare.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_DESTROYITEM_NO_BANKED",   "You have disabled destroying items in the bank.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_DESTROYITEM_NOT_AT_BANK", "You can only destroy banked items while the bank is open.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_DESTROYITEM_FCOIS",       "FCO ItemSaver has been told not to allow this item to be destroyed.")
--
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONNAME_MODIFYJUNKFLAG", "Modify Junk Flag")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_MODIFYJUNKFLAG", "<<1>> the item as junk.")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_MODIFYJUNKFLAG_OFF", "Unmark")
ZO_CreateStringId("ITEMTRIG_STRING_OPCODEARG_MODIFYJUNKFLAG_ON",  "Mark")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_JUNK_NOT_ALLOWED", "This item can't be flagged as junk.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_JUNK_FCOIS",       "FCO ItemSaver has been told not to allow this item to be flagged as junk.")
--
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONNAME_LAUNDER", "Launder")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_LAUNDER", "Launder <<1>> of the item.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_LAUNDERITEM_ZENIMAX_MAX_COUNT", "Add-ons can only launder 98 items every time the fence window is open; more than that and you'll disconnect from the server. Close the fence window and reopen it to launder more items.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_LAUNDERITEM_NORMAL_MAX_COUNT",  "You've hit the limit on how many items you can launder today.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_LAUNDERITEM_CANT_AFFORD",       "You don't have enough money to launder this item.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_LAUNDERITEM_NOT_STOLEN",        "You can't launder an item that isn't stolen.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_LAUNDERITEM_FCOIS",             "FCO ItemSaver has been told not to allow this item to be laundered.")
--
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONNAME_SELLORFENCE", "Sell or Fence")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_SELLORFENCE", "Sell <<1>> of the item.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_SELLORFENCE_NORMAL_MAX_FENCE", "You've hit the limit on how many items you can fence today.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_SELLORFENCE_LOCKED",           "You cannot sell a locked item.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_SELL_OR_FENCE_FCOIS_FENCE",    "FCO ItemSaver has been told not to allow this item to be fenced.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_SELL_OR_FENCE_FCOIS_SELL",     "FCO ItemSaver has been told not to allow this item to be sold.")
--
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONNAME_DECONSTRUCT", "Deconstruct")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_DECONSTRUCT", "Deconstruct the item.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_DECONSTRUCT_LOCKED",        "The item is locked.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_DECONSTRUCT_WRONG_TYPE",    "This item can't be deconstructed.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_DECONSTRUCT_WRONG_STATION", "This is the wrong crafting station.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_DECONSTRUCT_FCOIS",         "FCO ItemSaver has been told not to allow this item to be deconstructed.")
--
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONNAME_STOPRUNNINGTRIGGERS", "Stop Running Triggers")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_STOPRUNNINGTRIGGERS", "Stop all ongoing trigger processing for this item.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONEXPLANATION_STOPRUNNINGTRIGGERS", "This action will immediately stop running triggers on the current item; you can use it to block the rest of your triggers from running on certain kinds of items. Note that this only applies to the one time that this action runs. If this action doesn't run when triggers are processed in the future, then the item will be processed again.")
--
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONNAME_DEPOSITINBANK", "Deposit In Bank")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_DEPOSITINBANK", "Deposit <<1>> of the item in the player's bank.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_DEPOSITINBANK_ZENIMAX_MAX_COUNT", "Add-ons can only deposit 98 items every time the bank window is open; more than that and you'll disconnect from the server. Close the bank window and reopen it to deposit more items.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_DEPOSITINBANK_FULL",       "The bank is full.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_DEPOSITINBANK_NOT_OPEN",   "Cannot deposit items in the bank if you aren't viewing the bank.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_DEPOSITINBANK_STOLEN",     "You can't store stolen items in the bank.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_DEPOSITINBANK_CHAR_BOUND", "You can't deposit items in the bank if they are Character Bound.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_DEPOSITINBANK_FCOIS",      "FCO ItemSaver has been told not to allow this item to be deposited in the bank.")
--
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONNAME_WITHDRAWFROMBANK", "Withdraw From Bank")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_WITHDRAWFROMBANK", "Withdraw <<1>> of the item from the player's bank.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_WITHDRAWFROMBANK_ZENIMAX_MAX_COUNT", "Add-ons can only withdraw 98 items every time the bank window is open; more than that and you'll disconnect from the server. Close the bank window and reopen it to withdraw more items.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_WITHDRAWFROMBANK_FULL",       "Your backpack is full.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_WITHDRAWFROMBANK_NOT_OPEN",   "Cannot withdraw items in the bank if you aren't viewing the bank.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_WITHDRAWFROMBANK_FCOIS",      "FCO ItemSaver has been told not to allow this item to be withdrawn from the bank.")
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
--
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_DESTROYSTOLENCRAPTREASURE_NAME",           "Destroy low-rarity stolen treasures")
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_DESTROYSTOLENCRAPTREASURE_NAME_NESTED_01", "...Unless we can stockpile them for The Covetous Countess")
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_DESTROYSTOLENCRAPTREASURE_COMMENT",        "We want to keep these specific items, so let's force the containing trigger to stop before it gets to destroy them.")
--
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_LAUNDERCOVETOUSCOUNTESS_NAME", "Launder items that we're stockpiling for The Covetous Countess")
--
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_DESTROYSTOLENJUNK_NAME",           "Destroy stolen junk")
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_DESTROYSTOLENJUNK_NAME_NESTED_01", "Exempt rare style materials")
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_DESTROYSTOLENJUNK_NAME_NESTED_02", "Exempt rare equipment")
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_DESTROYSTOLENJUNK_NAME_NESTED_03", "Exempt ingredients that we could use more of")
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_DESTROYSTOLENJUNK_NAME_NESTED_04", "Exempt rare potions and poisons")
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_DESTROYSTOLENJUNK_NAME_NESTED_05", "Exempt lockpicks if we can carry more of them")
--
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_STOPTRIGGERSEXAMPLE_NAME",    "Stop later triggers from running on certain item types")
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_STOPTRIGGERSEXAMPLE_COMMENT", "If the next trigger action runs, then it will stop all processing on the current item. You can put a trigger like this at the very top of your trigger list to make sure that nothing ever runs on certain items. (There are also built-in convenience settings to suppress triggers for locked and Crown items.)")
--
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_DECONSTRUCTINTRICATE_NAME", "Deconstruct \"intricate\" gear for bonus XP")
--
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_DECONSTRUCTWORTHLESS_NAME", "Deconstruct worthless equipment")
--
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_SELLLOOTEDPOISONS_NAME", "Sell common non-crafted poisons")
--
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_SELLTRASH_NAME", "Sell trash")
--
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_SELLORNATE_NAME", "Sell \"ornate\" gear for additional gold")
--
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_NEVEREXAMPLE_NAME",    "Example trigger that will never run")
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_NEVEREXAMPLE_COMMENT", "A \"never\" condition can be used to turn off a trigger for testing purposes. Of course, it's easier to use the trigger's \"enabled\" checkbox.")
ZO_CreateStringId("ITEMTRIG_STRING_GALLERY_NEVEREXAMPLE_MESSAGE", "This message should not appear!")
