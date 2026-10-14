---json
{
  "schema": "dune-guide/v1",
  "title": "Keeping your vehicles alive",
  "description": "Habits that stop vehicles being eaten, wrecked by storms, stranded without fuel or lost when you change maps, and how to get one back.",
  "kind": "tip",
  "section": "tips",
  "tags": ["vehicle", "sandbike", "ornithopter", "buggy", "parking", "fuel", "vehicle backup tool", "recovery", "garage", "sheltered", "worm", "storm"],
  "aliases": ["lost my sandbike", "where to park", "vehicle destroyed"],
  "related": ["tips/worm-avoidance", "tips/sandstorms", "tips/base-safety", "tips/safe-travel"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Keeping your vehicles alive

**Quick answer.** Park on rock inside your own claim and under a roof, carry fuel and a Welding Torch, store a spare sandbike in the Vehicle Backup Tool, and store or fly out any vehicle before you change maps (game text). If one is destroyed, Recovery mode in the Vehicle Backup Tool rebuilds it for Solari and some maximum durability, but not its cargo (game text).

## Parking

- Unsheltered vehicles take sandstorm damage; vehicles parked outside your land claim "gradually decay over time, even if they are sheltered" (game text). Keep them in your base, ideally behind a Garage Door.
- The Vehicle Management console shows "Sheltered" with a percentage, or "Unsheltered", "At Risk" (game text). Aim for Sheltered.
- Never park on open sand. A worm destroys vehicles it catches on servers with "Sandworm Vehicle Destruction" on (game text).

## Driving and flying

- Ground vehicles cross sand faster than walking but still make vibration, and the threat meter does not drain on sand (game text; server config). Do not stop on sand.
- Boosting builds heat; the HUD warns "Increased temperature", then "Overheated" (game text).
- Fuel: vehicles burn Vehicle Fuel Cells refined at a Chemical Refinery, not raw Fuel Cells (game text). HUD warnings run "Low fuel", "Running on fumes", "Out of fuel" (game text). Carry a spare cell.
- In an ornithopter, climb when a worm is near; low flight is still vulnerable (wiki, https://awakening.wiki/Sandworm).
- Changing maps: "Any vehicle left behind will be destroyed and can only be recovered using the Vehicle Backup Tool" (game text).

## Backup and recovery

- The Vehicle Backup Tool stores a Sandbike, Scout Ornithopter or Treadwheel (empty inventory, no passengers) and restores it later; on this server one tool held two sandbikes and read "2/10" (game text; verified on this server).
- Recovery mode rebuilds a recently destroyed vehicle for Solari and maximum durability; inventory modules are lost; it works in PvE areas or inside your own claim; vehicles whose chassis was at critically low maximum durability are permanently lost (game text).
- Repair with a Welding Torch and welding wire (game text). Details in the [vehicles chapter](../vehicles.md).

## This server

Sandstorm damage to vehicles is set to about 20% of default: 1 per tick in small storms and 1.4 in large ones, against Funcom's 5 and 7 (server config, `UserGame.ini`, operator comment "a forgotten vehicle is dinged, not wrecked"). Repairs do not lower maximum durability here (`bEnableItemMaxDurabilityLoss=False`, server config); whether that also covers vehicle modules on this build is unverified (patch notes 1.5.15.0 fixed the setting for vehicle parts). The engine settings also set `Vehicle.SandwormInvulnerabilitySecondsOnExit=900` and `...OnServerRestart=7200`, commented "Seconds of invulnerability from sandworm on specific situations" (server config); what exactly "on exit" covers is unverified, so do not rely on it.
