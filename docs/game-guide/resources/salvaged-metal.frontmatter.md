---json
{
  "schema": "dune-guide/v1",
  "title": "Salvaged Metal",
  "description": "Scrap from wreckage, picked up or cut with a cutteray; the first crafting metal for the improvised tools, darts and welding wire.",
  "kind": "resource",
  "section": "resources",
  "tags": ["salvaged metal", "scrap", "scrap metal", "salvage", "wreck", "early game", "tier 0", "welding wire"],
  "aliases": ["ScrapMetal", "metal salvage", "scrap"],
  "region": "Everywhere; wrecks and scavenger camps",
  "related": ["resources/cutteray", "resources/power-pack", "resources/fuel-cell", "resources/granite-stone"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Salvaged Metal

Salvaged Metal is "salvaged from wreckage left on Arrakis" and "used for crafting rudimentary metal items" (game text). "Small pieces can be picked up from the ground, while larger pieces of wreckage need to be mined with a Cutteray" (game text tutorial). It is the tier 0 material: "Salvage Products ... found scattered throughout the world" (game text).

| Fact | Value | Source |
|---|---|---|
| Item id | `ScrapMetal`, stacks to 500 | item data |
| Tool | Hands for small pieces; any cutteray for wreckage | game text |
| Best farming | Scavenger camps in Hagga Basin South, alongside fuel cells | community, https://deltiasgaming.com/?p=252484 (pre-1.5) |
| Vendor base price | 2 Solari; not dropped on death | wiki, https://awakening.wiki/Salvaged_Metal (edited 2026-10-05) |

Recipes that use it (wiki, same page): Improvised Cutteray (2), Improvised Power Pack (1), Improvised Blood Extractor (20), Small Blood Sack (5 + 25 Plant Fiber), Construction Tool (20), Respawn Beacon (20), Binoculars (15), Glowtube (15), Scrap Metal Knife (3), Improvised Maula Pistol (15), Light Darts x30 (5), Heavy Darts x15 (7), Incendiary Gel x15 (25 + 15 Fuel Cell + 75 mL), Solido Replicator (20), Welding Wire x100 (5).

Welding Wire, the basic vehicle repair consumable, is "crafted from salvaged metal parts" (game text). The keystone "Effective Salvaging" gives scrap nodes a chance of bonus components when mined in Analysis Mode (game text).

Not to be confused with the "Scrap Iron/Steel/Aluminum/Duraluminum/Plastanium" items, which are placeholder (`PH_`) strings for unreleased Polar Sink content (game text; not in item data), see [rare-resources](rare-resources.frontmatter.md).
