---
description: "The server logs 'Now running ServerCommand AddItemToInventory' and no error even when the player's inventory is full; items may drop at their feet, and the database lags an online player's inventory."
datetime: 2026-10-13T23:41:19-04:00 # EDT
tags: [server-commands, give, inventory, admin, debugging, gm-bridge]
---
2026-10-13: Literjons given to an online player never appeared; ids were valid (present in other inventories), the command ran without error. Likely cause a full backpack. The items table is only flushed periodically for online players, so a missing row is not proof. Ask the player to free slots and retry, or have them use &give themselves.
