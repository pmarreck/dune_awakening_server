---json
{
  "schema": "dune-guide/v1",
  "title": "Carbon Ore",
  "description": "Tier 3 ore from Jabal Eifrit that is combined with Iron Ingots to make Steel; needs a Cutteray Mk2.",
  "kind": "resource",
  "section": "resources",
  "tags": ["carbon", "ore", "tier 3", "steel", "jabal eifrit", "cutteray mk2", "dolomite", "mining"],
  "aliases": ["DolomiteRock", "dolomite", "carbon"],
  "region": "Jabal Eifrit (especially Al-janub)",
  "related": ["resources/steel-ingot", "resources/iron-ore", "resources/erythrite-crystal", "resources/cutteray", "zones/jabal-eifrit"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Carbon Ore

Carbon Ore is "found in Jabal Eifrit" (game text, equipment progression tutorial) and is the second ingredient of Steel. You need a Cutteray Mk2, "capable of mining carbon, which is a necessity to refine steel" (game text). It is never refined on its own: it goes into the refinery together with an Iron Ingot.

| Fact | Value | Source |
|---|---|---|
| Item id | `DolomiteRock`, stacks to 500 | item data |
| Mining tier | Tier 3 ("Carbon and Erythrite") | game text, mining info card |
| Tool | Cutteray Mk2 or better; Callie's Breaker yields extra carbon and erythrite | game text |
| Where | Jabal Eifrit; guides single out Jabal Eifrit Al-janub, north of the Eastern Vermillius Gap | game text; community, https://deltiasgaming.com/?p=227885 (pre-1.5) |
| Looks like | White crystal formations growing out of brownish rock; loose pieces can be picked up | community, https://beebom.com/dune-awakening-carbon-ore-location/amp/ (pre-1.5) |
| Hazards | Slaver territory with quicksand around it | community, same; game text names quicksand as deadly |
| Vendor base price | 20 Solari | wiki, https://awakening.wiki/Carbon_Ore (edited 2026-10-05) |

## Refining (Steel)

| Refinery | Input | Output | Time |
|---|---|---|---|
| Small Ore Refinery | 1 Iron Ingot + 4 Carbon Ore + 50 mL water | 1 Steel Ingot | 5 s |
| Medium Ore Refinery | 1 Iron Ingot + 3 Carbon Ore + 50 mL water | 1 Steel Ingot | 4 s |
| Large Ore Refinery | 1 Iron Ingot + 2 Carbon Ore + 50 mL water | 1 Steel Ingot | 3 s |

(wiki, https://awakening.wiki/Carbon_Ore.) Game text agrees steel can be made "at any Ore Refinery".

Carbon yield by cutteray (wiki, unit not stated): Mk2 45, Mk3 60, Mk4 90, Mk5 130, Mk6 170. "Carbon Block" (`D_Carbon`) and "Jasmium Dust" (`D_JasmiumDust`) exist in item data with a `D_` prefix and are not obtainable refined forms (item data; the `D_` prefix marks unused items elsewhere in the data, inference).

Rarity: uncommon; "not as common as Copper or Iron" (community, beebom, pre-1.5).
