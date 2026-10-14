---json
{
  "schema": "dune-guide/v1",
  "title": "Sandcrawler and Carrier Ornithopter (vehicle spice harvesting)",
  "description": "How large-scale spice harvesting works: the Mk6 Sandcrawler with Vacuum and Centrifuge, its unique parts, and the Carrier Ornithopter that drops it on a field and lifts it out before the worm.",
  "kind": "system",
  "section": "spice",
  "tags": ["sandcrawler", "carrier ornithopter", "spice harvester", "vacuum", "centrifuge", "spice header", "spice container", "harvest spice vehicle", "deep desert", "mk6", "carryall"],
  "aliases": ["harvester", "carryall", "SandcrawlerChassis_6", "SandcrawlerSpiceHeader_6", "SandcrawlerSpiceContainer_6", "SandcrawlerLocomotion_Unique_WormThreat_06", "SandcrawlerSpiceContainer_Unique_Capacity_6", "SandcrawlerSpiceHeader_Unique_YieldIncrease_6", "SandcrawlerEngine_Unique_Speed_06", "OrnithopterTransportChassis_6", "OrnithopterTransportLocomotion_Unique_Speed_6", "ContainerVehicle"],
  "related": ["spice/deep-desert-spice", "spice/harvesting-worm-risk", "spice/spice-fields", "endgame/deep-desert"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Sandcrawler and Carrier Ornithopter

The Sandcrawler is the Plastanium-tier (Mk6) spice harvester: it vacuums Spice Sand from a wide area as it drives across a field, and it is the most efficient method (wiki, https://awakening.wiki/Spice_Fields, 2026-09-19). It is too slow to reach fields or escape worms on its own, so a Carrier Ornithopter drops it on the field and lifts it off: "The Carrier Ornithopter unlocks its full potential, allowing us to deploy and recover Sandcrawlers as needed" (game text). It harvests spice only, not flour sand (wiki).

## Building it

Assembly and parts are covered in [../vehicles.md](../vehicles.md). In short (game text; wiki, https://awakening.wiki/Sandcrawler, 2026-09-01):

- Required: Chassis, Cabin, Engine, PSU and 2 Treads, all Mk6 (`SandcrawlerChassis_6`, `SandcrawlerHull_6`, `SandcrawlerEngine_6`, `SandcrawlerGenerator_6`, `SandcrawlerLocomotion_6`; item data).
- To harvest you need both the Vacuum (`SandcrawlerSpiceHeader_6`, the scoop) and the Centrifuge (`SandcrawlerSpiceContainer_6`, storage): "A Spice Container is also required for the header to function" (game text). Gathered sand goes into the Centrifuge automatically (wiki).
- Uniques (game text; item data): Dampened Sandcrawler Treads (`SandcrawlerLocomotion_Unique_WormThreat_06`, lower vibration, so more time before a worm), Upgraded Regis Spice Container (more storage), Upgraded Regis Spice Header (yield increase, by its id `..._YieldIncrease_6`), Walker Sandcrawler Engine (faster: "When every second on the sands counts"). Capacities and rates are not published (unverified).
- It cannot travel on the Overland map and cannot be stored in the Vehicle Backup Tool (wiki).
- The Deep Desert journey "Operational Readiness" walks you through researching the Sandcrawler Mk6 Assembly, building Vacuum and Centrifuge Mk6, fueling it and building a Carrier Ornithopter Mk6 (game text).

## Carrier Ornithopter

Mk6 only, pilot plus five seats; it lifts Sandcrawlers "or other vehicles" and the Carrier Ornithopter Cargo Container (`ContainerVehicle`) (game text; see [../vehicles.md](../vehicles.md)). The journey task "Transport a Vehicle with an Ornithopter" covers the harness (game text). Unique parts include the Roc Carrier Wing (speed) and the Steady Carrier Boost Module Mk6 (less heat) (item data).

## A harvesting run

1. Scout the field from the air; in the Deep Desert medium fields start at row D and the large one at row F (wiki).
2. Drop the Sandcrawler on the field, harvest, and keep the carrier close.
3. When the worm comes, lift the crawler off. The journey also teaches using a Thumper to draw the worm away from the Sandcrawler (task "Use a Thumper to distract a worm away from the Sandcrawler", game text).
4. Fly the load to a base with a Spice Refinery. Cargo inside carried vehicles can be reached at settlement banker and market terminals (wiki, https://awakening.wiki/Carrier_Ornithopter).

Risks: "both are vulnerable and valuable targets" (game text). A worm destroys the vehicle and its cargo (game text). On this server, a vehicle is immune to the worm for 900 seconds after you exit it and for 7,200 seconds after a server restart (`Vehicle.SandwormInvulnerabilitySecondsOnExit=900`, `...OnServerRestart=7200`, server config); this protects parked vehicles, not one you are driving (inferred from the names; unverified in game).

## Skills

- Mechanic (Planetologist) passives Sandcrawler Yield ("harvest spice more efficiently"), Vehicle Mining and Heat Management (prescience) (game text).
- This server sets `Dune.GlobalVehicleMiningOutputMultiplier=3.0` (server config); whether the Sandcrawler counts as vehicle mining is unverified.
