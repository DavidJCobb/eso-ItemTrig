if not ItemTrig then return end

-- Define constants needed by other files

ItemTrig.NO_OR_CONDITIONS_HIT = "NOOR"
ItemTrig.PLEASE_LOG_TRIG_MISS = "LOG!"
ItemTrig.OPCODE_FAILED        = "FAIL"
ItemTrig.RETURN_FROM_TRIGGER  = "RETN"
ItemTrig.RUN_NO_MORE_TRIGGERS = "STOP"

ItemTrig.ENTRY_POINT_BARTER     = "BRTR"
ItemTrig.ENTRY_POINT_CRAFTING   = "CRAF"
ItemTrig.ENTRY_POINT_FENCE      = "FENC"
ItemTrig.ENTRY_POINT_ITEM_ADDED = "IADD"
ItemTrig.ENTRY_POINT_NAMES = {
   [ItemTrig.ENTRY_POINT_BARTER]     = GetString(ITEMTRIG_STRING_ENTRYPOINT_BARTER),
   [ItemTrig.ENTRY_POINT_CRAFTING]   = GetString(ITEMTRIG_STRING_ENTRYPOINT_CRAFTING),
   [ItemTrig.ENTRY_POINT_FENCE]      = GetString(ITEMTRIG_STRING_ENTRYPOINT_FENCE),
   [ItemTrig.ENTRY_POINT_ITEM_ADDED] = GetString(ITEMTRIG_STRING_ENTRYPOINT_ITEM_ADDED),
}