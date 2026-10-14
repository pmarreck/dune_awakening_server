---json
{
  "schema": "dune-guide/v1",
  "title": "Gathering efficiently",
  "description": "Getting more out of each resource trip: Cutteray Analysis Mode, the Static Compactor, which Cutteray tier mines what, and where early materials come from.",
  "kind": "tip",
  "section": "tips",
  "tags": ["gathering", "mining", "cutteray", "analysis mode", "static compactor", "flour sand", "spice sand", "salvage", "plant fiber", "fuel cells", "ore", "power pack"],
  "aliases": ["how to mine", "more yield", "where to find copper"],
  "related": ["tips/daily-and-weekly-routines", "tips/inventory-and-volume", "tips/worm-avoidance"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Gathering efficiently

**Quick answer.** Always mine in Cutteray Analysis Mode and trace the structural weaknesses it shows: that gives "greater resource amounts" (game text). Use a Static Compactor for Flour Sand and Spice Sand, and remember that both lie on open sand where the worm hears you (game text).

## Tools

| Tool | Tip |
|---|---|
| Cutteray | Needs a working Power Pack, which recharges when you stop (game text). Analysis Mode shows weak lines to trace for more yield; it also cuts open some doors (game text). |
| Static Compactor | Harvests Flour Sand and Spice Sand, uncovers buried treasure after storms, and clears fire and poison clouds (game text). |
| Scanner | Shows resources, components and hazards in range (game text). |
| Dew Reaper | Best at dawn (game text). |

## Cutteray tiers

Mk1 copper, granite, salvage, iron; Mk2 adds carbon and erythrite; Mk3 basalt and aluminum; Mk4 jasmium; Mk5 titanium and stravidium; Mk6 all, at higher yields (wiki, https://awakening.wiki/Cutteray). If a node will not mine, your Cutteray is a tier too low.

## Where early materials come from

| Material | Where (source) |
|---|---|
| Plant Fiber | Grows all across Arrakis; makes Healkits and makeshift clothing (game text). |
| Salvaged Metal | Small pieces on the ground by hand, wrecks with the Cutteray (game text). |
| Rocks and ore pieces | Loose on the ground; enough to craft a first Cutteray (game text). |
| Fuel Cells | Scavenger camps (game text). |
| Copper ore | Hagga Basin South (community, pre-1.5, game8). |
| Flour Sand | White dust clouds on open sand (game text). |
| Iron | Vermillius Gap, "iron-rich sands" (wiki, https://awakening.wiki/Hagga_Basin). |

## Worm-aware harvesting

- Picking up harvested spice or flour sand adds worm threat each time (server config: `HarvestSpicePickupThreatUnit=10`, `HarvestFlourSandPickupThreatUnit=10`), and the meter does not drain while you stay on sand (server config). Harvest in short bursts with a rock exit in sight.
- A spice field is a worm magnet, and a spice blow's shockwave "destroys everything nearby" (game text).

## This server

Mining output is three times default for hand and vehicle mining (`Dune.GlobalMiningOutputMultiplier=3.0`, `Dune.GlobalVehicleMiningOutputMultiplier=3.0`, server config).
