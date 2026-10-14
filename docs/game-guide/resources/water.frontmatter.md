---json
{
  "schema": "dune-guide/v1",
  "title": "Water",
  "description": "Water as a crafting and refining resource: where it comes from (dew, blood, corpses, windtraps) and which refining recipes drink the most.",
  "kind": "resource",
  "section": "resources",
  "tags": ["water", "dew", "blood", "windtrap", "deathstill", "refining", "literjon", "cistern", "dew reaper", "blood extractor"],
  "aliases": ["WaterItem", "mL water"],
  "region": "Everywhere (by method)",
  "related": ["resources/dew-reaper", "resources/blood-extractor", "resources/spice-sand", "tips/water-discipline"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Water

Water is both survival and an ingredient: refineries "require significant amounts of water" (game text) and most fabricator recipes above copper list some milliliters. Item id `WaterItem`, stacks to 500 (item data); recipes count it in mL and draw from base water storage (hotfix 1.5.3.5 fixed fabricators and refineries failing to see water in base storage, patch notes, https://duneawakening.com/news/dune-awakening-console-release-patch-notes/).

## Sources

| Source | Tool | Notes |
|---|---|---|
| Dew on primrose flowerfields at dawn | [Dew Reaper / Dew Scythe](dew-reaper.frontmatter.md) into a literjon or water tank | game text |
| Blood from corpses | [Blood Extractor](blood-extractor.frontmatter.md) into a Blood Sack, then a Blood Purifier at base | game text |
| Corpses | Carried to a Deathstill, which turns the body into water | game text ("Corpse" item, id `Corpse`, item data) |
| Mouse Corpse (`Mouse_Corpse`) | Drink "some blood as a last resort" | game text |
| Windtraps and cisterns | Base buildings; windtraps need filters (Makeshift, Standard, Particulate, Advanced Particulate) | game text; see [bases-and-building.md](../bases-and-building.md) |
| Dew Flowers, stillsuit catchpockets | Personal hydration only | game text, see [survival-combat-crafting.md](../survival-combat-crafting.md) |

## Thirstiest recipes

| Recipe | Water per batch | Source |
|---|---|---|
| Large Spice Refinery: 10,000 Spice Sand | 75,000 mL | wiki |
| Medium Spice Refinery: 750 Spice Sand | 7,000 mL | wiki |
| Plastanium Ingot | 1,250 mL each | wiki |
| Duraluminum Ingot | 500 or 650 mL each (wiki pages disagree) | wiki |
| Cutteray Mk6 | 700 mL | wiki, https://awakening.wiki/Cutteray_Mk6 |
| Aluminum Ingot | 200 mL each | wiki |
| Copper Ingot | none | wiki |

Plan water before an aluminum or plastanium refining run: 100 Plastanium Ingots need 125,000 mL (arithmetic from the wiki recipe).
