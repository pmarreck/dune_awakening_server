---json
{
  "schema": "dune-guide/v1",
  "title": "Jasmium Crystal",
  "description": "Tier 5 crystal grown in the radioactive pools of the Sheol; needs a Cutteray Mk4 and radiation protection, and turns Aluminum Ingots into Duraluminum.",
  "kind": "resource",
  "section": "resources",
  "tags": ["jasmium", "crystal", "tier 5", "sheol", "radiation", "duraluminum", "cutteray mk4", "mining"],
  "aliases": ["JasmiumCrystal", "jasmine crystal", "jasmium ore"],
  "region": "Sheol (southwest Hagga Basin)",
  "related": ["resources/duraluminum-ingot", "resources/aluminum-ingot", "resources/agave-seeds", "resources/cutteray", "zones/sheol"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Jasmium Crystal

Jasmium grows in "the radioactive pools in Sheol" (game text, equipment progression tutorial), the irradiated southwest corner of Hagga Basin. You need a Cutteray Mk4, "capable of mining jasmium crystals, which are a necessity to refine duraluminum" (game text), and protection from radiation. Its only use is Duraluminum.

| Fact | Value | Source |
|---|---|---|
| Item id | `JasmiumCrystal`, stacks to 500 | item data |
| Mining tier | Tier 5 | game text, mining info card |
| Tool | Industrial Cutteray Mk4 or better; the game text unique "Cutter of Al'Gha'Hir" (+10% jasmium) is not in this build's item list | game text; item data |
| Where | Pools of irradiated water inside rock outcrops in the Sheol; guides describe yellowish puddles and a central crater with six or seven nodes where radiation builds fast | game text; community, https://www.method.gg/dune-awakening/where-to-find-and-farm-jasmium-crystals-in-dune-awakening (pre-1.5) |
| Protection | Radiation Suit Mk4 is the usual minimum; Iodine Pills reduce radiation further | community, same and https://wp-prod.icy-veins.com/how-to-find-jasmium-crystals-in-dune-awakening-without-dying/ (pre-1.5) |
| Map marker | "Jasmium Crystal" | game text |
| Vendor base price | 60 Solari | wiki, https://awakening.wiki/Jasmium_Crystal (edited 2026-10-05) |

Game text flavor agrees with the danger: a contract says "Jasmium mining is something you better do quickly, unless you want to die of radiation poisoning" (game text). Contracts also ask for jasmium deliveries to Pinnacle Station (game text).

## Refining (Duraluminum)

| Refinery | Input | Output | Time |
|---|---|---|---|
| Medium Ore Refinery | 1 Aluminum Ingot + 4 Jasmium Crystal + water | 1 Duraluminum Ingot | 5 s |
| Large Ore Refinery | 1 Aluminum Ingot + 3 Jasmium Crystal + water | 1 Duraluminum Ingot | 4 s |

The water amount disagrees on the wiki: the Duraluminum Ingot page says 500 mL, the Jasmium Crystal page 650 mL (both edited 2026-10-05). Check the refinery screen.

Jasmium yield by cutteray (wiki, unit not stated): Mk4 72, Mk5 114, Mk6 149.

Rarity: Sheol only in Hagga Basin. Node positions can move with the Coriolis storm (community, pre-1.5; the wiki says Hagga Basin nodes move at each storm).
