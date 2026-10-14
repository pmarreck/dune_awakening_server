---json
{
  "schema": "dune-guide/v1",
  "title": "Iron Ore",
  "description": "Tier 2 ore found in the Vermillius Gap; needs a Cutteray Mk1 or better and refines into Iron Ingots, then Steel.",
  "kind": "resource",
  "section": "resources",
  "tags": ["iron", "ore", "tier 2", "vermillius gap", "cutteray mk1", "steel", "mining"],
  "aliases": ["MagnetiteOre", "magnetite", "iron"],
  "region": "Vermillius Gap (Western and Eastern)",
  "related": ["resources/iron-ingot", "resources/steel-ingot", "resources/carbon-ore", "resources/cutteray", "zones/vermillius-gap"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Iron Ore

Iron Ore comes from the Vermillius Gap, north of the starting area: "Iron Ore found in Vermillius Gap" (game text, equipment progression tutorial). Mine it with a Cutteray Mk1 ("Cutteray capable of mining iron", game text) or better, and refine it into Iron Ingots at any Ore Refinery.

| Fact | Value | Source |
|---|---|---|
| Item id | `MagnetiteOre`, stacks to 500 | item data |
| Mining tier | Tier 2 | game text, mining info card |
| Tool | Cutteray Mk1 or better; unique Olef's Quickcutter yields extra iron; game text also describes a "Miner's Delight" (+20% iron, +10% aluminum) that is not in this build's item list | game text |
| Where | Vermillius Gap; "Iron-rich sands" | game text; wiki, https://awakening.wiki/Hagga_Basin |
| Terrain | Rocky ground, mountaintops, sometimes inside caves | community, https://deltiasgaming.com/?p=256111 (pre-1.5) |
| Vendor base price | 10 Solari | wiki, https://awakening.wiki/Iron_Ore (edited 2026-10-05) |

Reaching the Gap from the south means a sand crossing exposed to sandworms; see [tips/crossing-the-vermillius-gap](../tips/crossing-the-vermillius-gap.frontmatter.md).

## Refining

| Refinery | Input | Output | Time |
|---|---|---|---|
| Small Ore Refinery | 5 Iron Ore + 25 mL water | 1 Iron Ingot | 10 s |
| Medium Ore Refinery | 4 Iron Ore + 25 mL water | 1 Iron Ingot | 7 s |
| Large Ore Refinery | 3 Iron Ore + 25 mL water | 1 Iron Ingot | 5 s |

(wiki, https://awakening.wiki/Iron_Ore.) Iron Ingot plus Carbon Ore makes Steel ([steel-ingot](steel-ingot.frontmatter.md)).

## Yield by tool

Wiki iron yield values: Mk1 36, Mk2 48, Mk3 72, Mk4 104, Mk5 136, Mk6 168 (wiki per-tool pages, edited 2026-10-05; unit not stated). The overview page at https://awakening.wiki/Cutteray shows 56 for the Mk1, which disagrees with the Mk1's own page; the per-tool figure fits the progression better. Sim's Cutter has "only basic Iron yields" (game text).

Rarity: common inside the Gap, absent from Hagga Basin South.
