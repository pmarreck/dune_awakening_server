---json
{
  "schema": "dune-guide/v1",
  "title": "Inventory slots and volume",
  "description": "How backpack slots and volume limit what you carry, how to raise them, and habits for keeping space free on trips.",
  "kind": "tip",
  "section": "tips",
  "tags": ["inventory", "backpack", "volume", "slots", "carry capacity", "storage", "full inventory", "pack mule", "stack size"],
  "aliases": ["inventory full", "how to carry more", "backpack volume capacity"],
  "related": ["tips/death-and-recovery", "tips/this-server", "tips/daily-and-weekly-routines"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Inventory slots and volume

**Quick answer.** Your backpack has two limits, a number of slots and a "Backpack Volume Capacity" (game text). Each item has a volume (for example 1.0 for a Respawn Beacon, 0.1 for a Survey Probe; wiki). Free space by dumping ore and loot into base storage, using vehicle inventory modules, and refining raw ore into ingots.

## Ways to carry more

| Method | Effect | Source |
|---|---|---|
| Pack Mule Trait | "Increases inventory size by 1 row" | game text (Specializations) |
| Backpack Volume Capacity research | A Research-menu stat named "Backpack Volume Capacity" exists | game text; which entry grants it is unverified |
| Vehicle inventory modules | Sandbike and treadwheel inventory modules, buggy storage, ornithopter storage | game text; see [vehicles chapter](../vehicles.md) |
| Refining | Ores and ingots both stack to 500, and several ores make one ingot, so refined metal takes fewer slots | item data; wiki recipes |

## Habits

- Empty your bag at base before every trip; what you carry is what you can lose (game text: backpack items drop on death).
- Water containers, blood sacks and Literjons stack to 1 each (item data), so each one takes a whole slot.
- Contract rewards that do not fit can be claimed later: the prompt reads "Claim Reward in Journey Menu" (game text).
- Base storage containers are linked to the base, so fabricators and refineries draw from them directly (game text); you do not need to carry inputs to the machine.
- Vehicle Inventory full shows "Vehicle Inventory is full" (game text).

## This server

`InventoryVolumeMultiplier` is 10, so volume capacity is ten times default and visibly larger; the slot count (35 in the main backpack) cannot be raised by any server setting (verified on this server). Here slots, not volume, are the usual limit.
