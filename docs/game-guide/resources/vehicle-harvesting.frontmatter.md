---json
{
  "schema": "dune-guide/v1",
  "title": "Gathering with vehicles",
  "description": "Which vehicles gather resources: the Buggy's cutteray for ore nodes, the Sandcrawler for spice sand, and ornithopters for hauling Deep Desert loot.",
  "kind": "system",
  "section": "resources",
  "tags": ["vehicle", "buggy", "sandcrawler", "harvester", "carrier", "ornithopter", "mining", "spice", "hauling"],
  "aliases": ["harvester", "spice harvester", "mining vehicle"],
  "related": ["resources/buggy-cutteray", "resources/spice-sand", "spice/sandcrawler-and-carrier", "resources/titanium-ore"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Gathering with vehicles

Two vehicles gather: the Buggy mines nodes with a turret-mounted [Buggy Cutteray](buggy-cutteray.frontmatter.md) into its storage module, and the Plastanium-only Sandcrawler harvests Spice Sand with a Vacuum (`SandcrawlerSpiceHeader_6`) plus a Centrifuge (`SandcrawlerSpiceContainer_6`) (game text; item data). The Sandcrawler does not take flour sand (wiki, cited in [vehicles.md](../vehicles.md)). Its details are in [spice/sandcrawler-and-carrier](../spice/sandcrawler-and-carrier.frontmatter.md).

| Need | Vehicle | Notes |
|---|---|---|
| Bulk ore, crystals, titanium | Buggy with Utility Rear, Buggy Cutteray and a storage module | Highest wiki yields; no Analysis Mode (game text; wiki) |
| Bulk spice sand | Sandcrawler | Stat "Sandcrawler Yield" (game text); 1.5 fixed the build and "Harvest Spice" journey steps (patch notes 1.5) |
| Moving a Sandcrawler or cargo crate | Carrier Ornithopter | Lifts Sandcrawlers and the Carrier Ornithopter Cargo Container (game text) |
| Hauling Deep Desert materials home | Scout or Assault Ornithopter with storage | Cargo in an ornithopter's storage modules travels between maps (see [world-and-maps.md](../world-and-maps.md)) |

Ground vehicles and harvesting on open sand draw sandworms; a caught vehicle is destroyed with its cargo (game text).
