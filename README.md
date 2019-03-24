# eso-ItemTrig
An attempt at making a trigger-based alternative to the Elder Scrolls Online add-on Dustman. ItemTrig is available for download [from ESOUI](https://www.esoui.com/downloads/info2312-ItemTrig.html) or [NexusMods](https://www.nexusmods.com/elderscrollsonline/mods/134).

The sort of stuff I'd like to enable are things like:

## Sample triggers

**Deconstruct intricate**
**Entry points:** Crafting Menu Opened
**Conditions:**
The item [is] an [any equippable].
The item [is] intricate.
The current crafting station [is appropriate for] this item.
The player [has not] maxed out their [crafting skill for this item] skill.
**Actions:**
Deconstruct the item.

**Deconstruct worthless equipment**
**Entry points:** Crafting Menu Opened
**Conditions:**
The item [is] an [any equippable].
The item's rarity is [at most Normal].
The item's sell value is [at most 0].
The current crafting station [is appropriate for] this item.
**Actions:**
Deconstruct the item.

**Sell trash**
**Entry points:** Merchant Menu Opened
**Conditions:**
The item's rarity is [at most Worn].
The item [is] a [Trash].
**Actions:**
Sell [9999] of the item.
