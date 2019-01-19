# eso-ItemTrig
An attempt at making a trigger-based alternative to the Elder Scrolls Online add-on Dustman. The sort of stuff I'd like to enable are things like:

## Sample triggers

**Name:** Deconstruct intricate items.  
**Entry points:** Opening a crafting menu  
**Conditions:**  
The item [is] intricate.  
You [have not] maxed out your crafting skill for this item.  
The item [doesn’t have] a researchable trait.  
The item's trait [is not] [Nirnhoned].  
**Actions:**  
Deconstruct all of these items.

**Name:** Thieving: Common Treasures  
**Entry points:** opening a fence menu; item added to inventory  
**Conditions:**  
The item [is] stolen.  
The item [is] [treasure].  
The item’s rarity is [less than green].  
**Actions:**  
Run nested trigger.  
... **Name:** Stockpile items useful for The Covetous Countess.  
... **Conditions:**  
... Comment: [Conditions to be determined once I figure out an optimal strat for the CC. Nested trigger no-op'd in the meantime.]  
... This condition is [never] true.  
... **Actions:**  
... Launder all of these items.  
... Stop processing the top-level trigger.  
Destroy all of these items.

**Name:** Protect purchases
**Entry points:** item purchased  
**Conditions:**  
This condition is [always] true.  
**Actions:**  
Exempt this item from all trigger processing for [15 minutes].
