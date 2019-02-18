if not ItemTrig then return end

-- Define constants needed by other files

ItemTrig.OPCODE_FAILED       = 0x4641494C -- "FAIL"
ItemTrig.RETURN_FROM_TRIGGER = 0x5245544E -- "RETN"

ItemTrig.ENTRY_POINT_ITEM_ADDED = "item-added"