---json
{
  "schema": "dune-guide/v1",
  "title": "Vehicle Fuel Cells",
  "description": "Small, Medium and Large Vehicle Fuel Cells refined from raw Fuel Cells in a Chemical Refinery; the only fuel vehicles burn.",
  "kind": "resource",
  "section": "resources",
  "tags": ["vehicle fuel cell", "fuel", "refuel", "chemical refinery", "sandbike", "ornithopter"],
  "aliases": ["FuelCanister", "FuelCanister_Medium", "FuelCanister_Large", "Small Vehicle Fuel Cell", "Medium Sized Vehicle Fuel Cell", "Large Vehicle Fuel Cell"],
  "related": ["resources/fuel-cell", "resources/spice-infused-fuel-cell"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Vehicle Fuel Cells

Vehicle Fuel Cells are "refined from Fuel Cells at a Chemical Refinery. Used to power vehicles" (game text). The full table, fuel amounts and refueling are in [vehicles.md](../vehicles.md) ("Fuel").

| Item (id) | Fuel | Recipe (wiki, https://awakening.wiki/Fuel_Cell, edited 2026-10-05) |
|---|---|---|
| Small Vehicle Fuel Cell (`FuelCanister`) | 200 | 25 Fuel Cell, Small Chemical Refinery, 15 s; or 20, Medium, 10 s |
| Medium Sized Vehicle Fuel Cell (`FuelCanister_Medium`) | 400 | 40 Fuel Cell + 15 mL, Medium Chemical Refinery, 15 s |
| Large Vehicle Fuel Cell (`FuelCanister_Large`) | 800 | 80 Fuel Cell + 30 mL, Medium Chemical Refinery, 15 s |

Ids from item data; fuel amounts from the wiki, as cited in [vehicles.md](../vehicles.md). Per raw cell, the Medium refinery's Small cell (10 fuel per cell) and the Large cell (10 per cell) are equal; the Small refinery's Small cell gives 8 (arithmetic). This server's admin has a `&fuel` command that gives five Large Vehicle Fuel Cells (see the project's admin docs).
