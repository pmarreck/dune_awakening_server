---json
{
  "schema": "dune-guide/v1",
  "title": "Imperial Testing Stations",
  "description": "Every numbered Imperial Testing Station (ecolab) by region in Hagga Basin, the Deep Desert and the Overland Map, what they drop (Servoks, Particle Capacitors) and their bosses.",
  "kind": "location",
  "section": "zones",
  "tags": ["imperial testing station", "ecolab", "dungeon", "old imperial", "servoks", "particle capacitor", "poi", "loot"],
  "aliases": ["ITS", "Ecolab", "Testing Station", "Buried Testing Station", "Forgotten Testing Station", "CB_Ecolab_Bronze_Green"],
  "region": "Hagga Basin, Deep Desert, Overland Map",
  "related": ["zones/loot-components-by-region", "zones/deep-desert", "zones/overland-map", "zones/shipwrecks"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Imperial Testing Stations

Quick answer: Old Imperial facilities (the map filter calls them "Imperial Testing Stations", internally "ecolabs"; game text) and the main source of Servoks and Particle Capacitors, whose tier depends on the region (game text). Hagga Basin has 13 numbered stations (game text; wiki, https://awakening.wiki/Imperial_Testing_Stations). Each is also a respawn type (`SPAWN_LOC_Ecolab`, game text). Bases cannot claim over them (official blog 2025).

## Hagga Basin (names and regions from game text map keys)

| Region | Stations | Component tier inside |
|---|---|---|
| Hagga Basin South | No. 2 | Advanced Servoks and Particle Capacitor, the starter tier (`OldImperialComponent1`/`2`, item data; their descriptions name no region) |
| Vermillius Gap | No. 197 (west, journey), No. 13, No. 10 (east, journey) | Servoks, Particle Capacitor ("in the Vermilius Gap") |
| Jabal Eifrit | No. 76, No. 117, No. 63 | Enhanced Servoks, Enhanced Particle Capacitor |
| Hagga Rift | No. 23, No. 29 | Enhanced (shared tier with Jabal Eifrit) |
| Shield Wall | No. 142, No. 60, No. 17 | Efficient Servoks, Efficient Particle Capacitor |
| The O'odham | No. 163, No. 71 | Efficient (shared tier with the Shield Wall) |

Sheol has no numbered station in the map keys, though Optimized Servoks and Charged Particle Capacitors are described as from "Imperial Testing Stations in the Sheol" (game text). Advanced Servoks and Particle Capacitors (probably the starter tier) are also sold by several traders (see [merchant-directory](merchant-directory.frontmatter.md)).

## Deep Desert

Shield Wall stations No. 185, 148, 37, 93, 186 and 217, plus random "Buried Testing Station" markers elsewhere in the grid (game text). Advanced Servoks and Advanced Particle Capacitors come from here (game text). The Deep Desert "Advanced Servoks" (`D_OldImperialComponent11` by the id pattern, inferred) shares its display name with the starter `OldImperialComponent1` (item data), so check the item id or tooltip before trading.

## Overland Map stations (instanced)

| Station | Theme | Boss (game text) |
|---|---|---|
| No. 136 | Fire | Masano the Burned |
| No. 24 | Darkness | Doctor Lemenger |
| No. 152 | Electricity | Planetologist Takulki |
| No. 195 | Poison | Burrbridge |
| No. 89 | Radiation | Lieutenant Aman |

Themes from game text descriptions; see [overland-map](overland-map.frontmatter.md). These run as five `CB_Ecolab_Bronze_Green_*` maps on this server (verified on this server, `data/maps.tsv`); which file is which station is unverified.

A "Forgotten Testing Station" belongs to the Lost Harvest DLC (game text).
