---
description: "Installed vehicle modules keep durability in vehicle_modules.stats (CurrentDurability, DecayedMaxDurability); DT_BaseItems only has the item form (100) plus RepairDurabilityPercentageDecay=0.2, so full module values must come from earlier backups or observation."
datetime: 2026-10-13T23:41:19-04:00 # EDT
tags: [vehicles, durability, database, backups, pg-restore, buggy, game-data]
---
2026-10-14: restoring a Mk4 buggy. DT_BaseItems rows give MaxDurability=100 (inventory form) and RepairDurabilityPercentageDecay=0.2 (each torch repair permanently loses 20% of the repaired amount). The module blueprints and DT_Vehicle* tables carry no durability; C_VehicleModuleDurability is a 0-1 UI curve. Removing DecayedMaxDurability restores the template maximum. Historical values: `pg_restore --data-only -t vehicle_modules -f - <backup>/dune_sb_*.dump`; a part's first reading after brief use (e.g. 1748.03 after 24 s) reveals its full value (Mk4 buggy engine/PSU: 1750).
