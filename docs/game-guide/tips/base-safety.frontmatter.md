---json
{
  "schema": "dune-guide/v1",
  "title": "Keeping your base safe",
  "description": "Power, shelter, storage and backup habits that keep a base running and recoverable, plus what is different on this server.",
  "kind": "tip",
  "section": "tips",
  "tags": ["base", "base safety", "power", "generator", "fuel cells", "shield", "upkeep", "backup", "base reconstruction tool", "permissions", "activity log"],
  "aliases": ["base decay", "my base disappeared", "base power"],
  "related": ["tips/first-base", "tips/sandstorms", "tips/vehicle-safety"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Keeping your base safe

**Quick answer.** Keep the generator fueled: power runs the machines and the base shield, which protects from enemies and reduces sandstorm damage (game text). Keep a current backup in the Base Reconstruction Tool, give friends only the permission level they need, and check the Activity Log when something goes missing (game text).

## Power

- A Fuel-Powered Generator burns Fuel Cells placed in base storage (game text). Scavenger camps are the early source of Fuel Cells (game text).
- The console warns when the base is running out of power (game text). Watch for "CIRCUIT OVERLOAD IMMINENT": too many machines for the generators (game text).
- Later generators: wind turbines on Lubricant and the Spice-Powered Generator on Spice-Infused Fuel Cells (game text; output figures in the [bases chapter](../bases-and-building.md#power)).
- Taxes were removed in Chapter 3; power is the remaining upkeep (patch notes 1.3.0.0; 1.5 announcement).

## Backups

- The Base Reconstruction Tool stores up to three whole bases with their placeables and contents; snapshots are bound to your character and not lost on death (1.5 announcement).
- A backup fails if vehicles are inside, the console is not attached to a building piece, or pieces connect outside the claim (game text). Park vehicles outside first.
- Recycling a stored base returns 100% of construction materials and stored items to a Reserve inventory (game text).

## Access

- Permissions live in the console's Permissions tab: Owner, Co-owner, Associate, Guild, Public and custom roles; Base Builder access lets someone place and remove structures (game text).
- Each door or machine has an Access Level (game text). Lock storage behind a higher level than the front door.
- "Base gone? Vehicle missing? Check the Activity Log from the Communinet tab in the Social menu" (game text, loading tip).

## This server

Storms cannot damage buildings or placeables here: building and placeable sandstorm damage is 0 and `m_bMitigateAllSandstormDamage` is on, and "Base Decay" (`bAllowDynamicBuildingDamage`) is off (server config). An unpowered base therefore does not wear away from storms on this world, but its machines stop. Player damage to unshielded bases is at default (`PVPDamageStructures=1`) and the world's PvP partitions are not force-enabled (server config); security zones are on (server config).
