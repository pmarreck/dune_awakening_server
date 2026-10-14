---json
{
  "schema": "dune-guide/v1",
  "title": "Copper Ore",
  "description": "Tier 1 ore from Hagga Basin South and beyond, mined with any cutteray and refined into Copper Ingots at any ore refinery.",
  "kind": "resource",
  "section": "resources",
  "tags": ["copper", "ore", "tier 1", "cutteray", "hagga basin south", "early game", "mining"],
  "aliases": ["AzuriteOre", "azurite", "copper"],
  "region": "Hagga Basin South and most of Hagga Basin; Deep Desert",
  "related": ["resources/copper-ingot", "resources/cutteray", "resources/granite-stone", "zones/hagga-basin-south"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Copper Ore

Copper Ore is the first ore you mine. It comes from copper deposits "in Hagga Basin South and beyond" (game text, equipment progression tutorial), and even the starting Improvised Cutteray can mine it (game text). Refine it into Copper Ingots at any Ore Refinery.

| Fact | Value | Source |
|---|---|---|
| Item id | `AzuriteOre`, stacks to 500 | item data |
| Mining tier | Tier 1 ("Copper, Granite, Salvaged Metal") | game text, mining info card |
| Tool | Improvised Cutteray or better | game text |
| Where | Hagga Basin South and beyond; the wiki adds "many regions" of Hagga Basin and the Deep Desert | game text; wiki, https://awakening.wiki/Copper_Ore (edited 2026-10-05) |
| Vendor base price | 5 Solari | wiki, same page |

## Refining

| Refinery | Input | Output | Time |
|---|---|---|---|
| Small Ore Refinery | 4 Copper Ore | 1 Copper Ingot | 5 s |
| Medium Ore Refinery | 3 Copper Ore | 1 Copper Ingot | 4 s |
| Large Ore Refinery | 2 Copper Ore | 1 Copper Ingot | 3 s |

No water is needed (wiki, https://awakening.wiki/Copper_Ore). Bigger refineries need fewer ore per ingot, which is the main reason to upgrade them.

## Yield by tool

The wiki's "Mining Yield" for the copper/granite/salvage group rises with the cutteray: Improvised 40, Mk1 48, Mk2 72, Mk3 104, Mk4 136, Mk5 168, Mk6 200; Sim's Cutter 63 (wiki, https://awakening.wiki/Cutteray and the per-tool pages, edited 2026-08-29 to 2026-10-05). The unit is not stated; treat the numbers as relative. Tracing weak lines in Analysis Mode gives "greater resource amounts" (game text).

Rarity: common. Copper is the basis of tier 1 (copper) gear, the Cutteray Mk1 and Power Pack Mk1 (see [copper-ingot](copper-ingot.frontmatter.md)).
