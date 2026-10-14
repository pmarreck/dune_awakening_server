---json
{
  "schema": "dune-guide/v1",
  "title": "Buggy Cutteray",
  "description": "The Buggy's turret-mounted mining laser (Mk3 to Mk6 and Focused variants): the highest mining yields in the game, but no Analysis Mode and it needs a storage module.",
  "kind": "item",
  "section": "resources",
  "tags": ["buggy", "buggy cutteray", "vehicle mining", "mining", "yield", "focused buggy cutteray", "vehicle"],
  "aliases": ["BuggyMining_3", "BuggyMining_4", "BuggyMining_5", "BuggyMining_6", "vehicle cutteray", "mining laser"],
  "related": ["resources/cutteray", "resources/titanium-ore", "resources/aluminum-ore"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Buggy Cutteray

The Buggy's Utility Rear can carry a Buggy Cutteray in its turret slot. It "does not allow analysis mode and requires an attached inventory module to hold mined resources" (game text). The wiki calls buggy cutterays "generally always the most efficient way to harvest resource nodes" and says their constant "Poor efficiency" label is a visual bug (wiki, https://awakening.wiki/Cutteray, edited 2026-08-29).

| Tool (id) | Wiki yield row, Cu/Fe/C/Al/Jas/Ti (unit not stated) |
|---|---|
| Buggy Cutteray Mk3 (`BuggyMining_3`) | 195 / 135 / 112 |
| Buggy Cutteray Mk4 (`BuggyMining_4`) | 255 / 195 / 168 / 90 |
| Buggy Cutteray Mk5 (`BuggyMining_5`) | 315 / 255 / 243 / 135 / 214 |
| Buggy Cutteray Mk6 (`BuggyMining_6`) | 375 / 315 / 318 / 195 / 280 / 90 |
| Focused Buggy Cutteray Mk3 to Mk6 | Mk6: 468 / 393 / 398 / 243 / 318 / 116 |

Ids from item data (`D_BuggyMining_7`, "Mk7", is an unused item). The buggy laser's tier lags the handheld by one: a Buggy Mk3 lists no aluminum yield and a Buggy Mk5 no titanium (wiki; inference from the empty cells).

Buggy Cutteray Mk3 recipe: 30 Steel Ingot + 25 Particle Capacitor + 17 Cobalt Paste + 23 Holtzman Actuator + 200 mL water, Vehicle Fabricator, 20 s. It uses 21.48 power per second and builds 6.67 heat per second; attach it with a Welding Torch (wiki, https://awakening.wiki/Buggy_Cutteray_Mk3, edited 2026-10-05). Keystones "Vehicle Mining Heat Reduction" and "Vehicular Mining Mastery" (range) and the stats "Vehicle Cutteray Yield" and "Vehicle Mining Efficiency" improve it (game text).

Mining from a vehicle on sand still draws worms; see [vehicles.md](../vehicles.md).
