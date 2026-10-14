---json
{
  "schema": "dune-guide/v1",
  "title": "Power Pack",
  "description": "The backpack battery that powers cutterays, compactors, scanners, shields and suspensors: tiers, power pool, recharge and recipes.",
  "kind": "item",
  "section": "resources",
  "tags": ["power pack", "power", "battery", "energy", "cutteray", "shield", "tool", "old sparky"],
  "aliases": ["PowerPack", "PowerPack5", "PowerPack2", "PowerPack6", "PowerPack3", "PowerPack7", "PowerPack4", "powerpack"],
  "related": ["resources/cutteray", "resources/static-compactor", "resources/scanners"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Power Pack

Cutterays, compactors, scanners, dew reapers, Holtzman shields and suspensor belts all draw from the equipped Power Pack (game text). A bigger pack lets you mine longer between pauses; it recharges when you stop using power (game text, as cited in [survival-combat-crafting.md](../survival-combat-crafting.md)).

| Pack (id) | Power pool | Regen per second | Recipe | Source |
|---|---|---|---|---|
| Improvised Power Pack (`PowerPack`) | 100 | 8 | 1 Salvaged Metal | wiki, https://awakening.wiki/Improvised_Power_Pack |
| Power Pack Mk1 (`PowerPack5`) | 150 | 12 | 5 Copper Ingot + 3 Particle Capacitor; Fabricator | wiki, https://awakening.wiki/Power_Pack_Mk1 |
| Power Pack Mk2 (`PowerPack2`) | 200 | 16 | 8 Iron Ingot + 5 Particle Capacitor; Fabricator | wiki, https://awakening.wiki/Power_Pack_Mk2 |
| Power Pack Mk3 (`PowerPack6`) | 300 | 24 | 9 Steel Ingot + 8 Particle Capacitor + 6 Cobalt Paste + 70 mL; Survival Fabricator | wiki, https://awakening.wiki/Power_Pack_Mk3 |
| Power Pack Mk4 (`PowerPack3`) | 400 | 32 | 18 Aluminum Ingot + 11 Particle Capacitor + 9 Cobalt Paste + 169 mL; Survival Fabricator | wiki, https://awakening.wiki/Power_Pack_Mk4 |
| Power Pack Mk5 (`PowerPack7`) | 600 | 48 | 12 Duraluminum Ingot + 11 Particle Capacitor + 12 Cobalt Paste + 12 Irradiated Slag + 260 mL; Survival Fabricator | wiki, https://awakening.wiki/Power_Pack_Mk5 |
| Power Pack Mk6 (`PowerPack4`) | 800 | 64 | 30 Plastanium Ingot + 18 Particle Capacitor + 23 Cobalt Paste + 27 Spice Melange + 25 Irradiated Core + 530 mL; Advanced Survival Fabricator | wiki, https://awakening.wiki/Power_Pack_Mk6 |

Ids from item data; note the ids are not in Mk order. Wiki pages edited 2026-10-05. Regen is 8% of the pool per second on every tier (arithmetic), so a full refill takes about 12.5 s at any tier.

Uniques (game text; ids from item data): Old Sparky Mk1 to Mk4 and Young Sparky Mk5 and Mk6 (`PowerPack_Unique_Regen_01..06`, faster recharge, slightly smaller pool), Accelerator Power Pack (`PowerPack_Unique_Capacity_06`, "radioactive power pack with high durability"), Purifier Power Pack (`PowerPack_Unique_PoisRadMitigation_06`, a field that protects against radiation and toxins, useful for jasmium runs).

Compare against tool draw: a Cutteray Mk6 uses 153.7, a Handheld Resource Scanner 75 (wiki), so the Mk6 laser needs a big pack.
