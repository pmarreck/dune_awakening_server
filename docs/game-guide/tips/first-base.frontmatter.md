---json
{
  "schema": "dune-guide/v1",
  "title": "Your first base: where and what to build",
  "description": "Where to put a starter base, the minimum shelter and power to build first, and the order of the first machines.",
  "kind": "tip",
  "section": "tips",
  "tags": ["base", "first base", "starter base", "shelter", "sub-fief console", "generator", "power", "where to build", "base location"],
  "aliases": ["starter base", "what to build first", "base location"],
  "related": ["tips/base-safety", "tips/first-hours", "tips/sandstorms", "tips/water-discipline"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Your first base: where and what to build

**Quick answer.** Build small, on rock, inside Hagga Basin South, close to copper, salvage and a tradepost. The journey's own first base is 4 foundations, 7 walls, a door and 4 roofs, with the Sub-Fief Console moved inside, plus a Small Storage Container and a Fuel-Powered Generator fed with Fuel Cells (game text). You will move it north later, so do not over-invest.

## Where

- Rock, not sand: the game refuses "Cannot build in desert" and "Cannot build on quicksand" (game text), and anything on open sand draws worms (Funcom help center, see [bases chapter](../bases-and-building.md)).
- Hagga Basin South: a backed-up base can be placed again there with no cooldown; elsewhere a placed backup triggers a 7-day cooldown (game text; patch notes 1.5.1.0 set the South cooldown to 0). On this server the operator set `BaseBackupToolTimeRestriction` to 16 hours (server config), so the out-of-South cooldown here is shorter than the official 7 days, if that setting is honored (unverified in game).
- The journey itself later sends you to back up the base, cross into the Vermillius Gap, build an Advanced Sub-Fief Console there and abandon the South base (game text). Guides advise keeping the first base to roughly 2x2 or 3x3 for that reason (community, https://deltiasgaming.com/?p=252609, pre-1.5).
- Place the console thoughtfully: its claim is a box, and the plain console's ceiling is only about 13.8 m above it (verified on this server).

## What, in order

1. Shelter: foundations, walls, a door and a roof, then move the console inside ("Move your Sub-fief Console to a sheltered location", game text). Sheltered areas protect you from sandstorms and your shelter status shows above the hydration bar (game text).
2. Power: a Fuel-Powered Generator. Put Fuel Cells into base storage first, then process them in the generator (game text). Fuel Cells come from scavenger camps (game text).
3. Storage: a Small Storage Container; storage is linked to the base so stations can draw from it (game text).
4. Water: a Blood Purifier, then a Windtrap and cistern when researched (game text).
5. Production: Small Ore Refinery, Fabricator, Small Chemical Refinery (game text, journey order). Fabricators need power and a Sub-Fief Console nearby (game text).
6. A Respawn Beacon near or in the base (game text: "Place a Respawn Beacon. On death, you can respawn at these locations").

## Server notes

On this server storms do no damage to buildings or placeables, `m_bMitigateAllSandstormDamage` is on and "Base Decay" (`bAllowDynamicBuildingDamage`) is off (server config). Power is still needed to run machines and the base shield (game text). Building costs are default (`BuildingCostMultiplier=1`) and crafting costs are halved (`CraftingCost=0.5`) with instant crafting (`CraftingTimeMultiplier=0`) (server config, see [settings table](../economy-social-versions.md#this-servers-adjustable-settings)).
