if not ItemTrig then return end

-- Define constants needed by other files

ItemTrig.OPCODE_FAILED       = 0x4641494C -- "FAIL"
ItemTrig.RETURN_FROM_TRIGGER = 0x5245544E -- "RETN"

ItemTrig.ENTRY_POINT_BARTER     = 0x42525452 -- "BRTR"
ItemTrig.ENTRY_POINT_CRAFTING   = 0x43524146 -- "CRAF"
ItemTrig.ENTRY_POINT_FENCE      = 0x46454E43 -- "FENC"
ItemTrig.ENTRY_POINT_ITEM_ADDED = 0x49414444 -- "IADD"