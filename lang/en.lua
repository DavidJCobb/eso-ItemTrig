ZO_CreateStringId("ITEMTRIG_STRING_UI_GENERIC_CONFIRM_YES", "Yes")
ZO_CreateStringId("ITEMTRIG_STRING_UI_GENERIC_CONFIRM_NO", "No")
ZO_CreateStringId("ITEMTRIG_STRING_UI_GENERIC_CONFIRM_TITLE", "Are you sure?") -- confirmation prompt window title, if none is specified
--
ZO_CreateStringId("ITEMTRIG_STRING_UI_TRIGGERLIST_TITLE", "ItemTrig")
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
--
ZO_CreateStringId("ITEMTRIG_STRING_CONDITIONNAME_CRAFTED", "Crafted By Player")
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
--
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONNAME_LAUNDER", "Launder")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_LAUNDER", "Launder <<1>> of the item.")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONERROR_LAUNDERITEM_ZENIMAX_MAX_COUNT", "Add-ons can only launder 98 items every time the fence window is open. Close the fence window and reopen it to launder more items.")
--
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONNAME_SELLORFENCE", "Sell or Fence")
ZO_CreateStringId("ITEMTRIG_STRING_ACTIONDESC_SELLORFENCE", "Sell <<1>> of the item.")
