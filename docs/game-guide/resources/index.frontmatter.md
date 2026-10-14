---json
{
  "schema": "dune-guide/v1",
  "title": "Resources: index",
  "description": "Overview of every raw resource, refined intermediate and gathering tool: where each is found, what tool gathers it, and what it is used for.",
  "kind": "index",
  "section": "resources",
  "tags": ["resources", "index", "materials", "ore", "where to find", "gathering", "tools", "refining", "table"],
  "aliases": ["resource list", "materials list"],
  "related": ["resources/rare-resources", "resources/cutteray", "resources/water", "spice/index"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Resources

One entry per raw resource, per important refined intermediate, and per gathering tool. Locations follow the game's own progression tutorial (game text); details and sources are in each entry. The refining overview table also lives in [survival-combat-crafting.md](../survival-combat-crafting.md). Spice is covered in the [spice section](../spice/index.frontmatter.md).

## Raw resources

| Resource (id) | Where | Tool | Used for |
|---|---|---|---|
| [Water](water.frontmatter.md) (`WaterItem`) | Dew at dawn, blood, corpses, windtraps | Dew Reaper, Blood Extractor, base buildings | Drinking, nearly every refinery and fabricator recipe |
| [Plant Fiber](plant-fiber.frontmatter.md) (`PlantFiber`) | Any solid ground | Hands | Healkits, blood sacks, armor |
| [Granite Stone](granite-stone.frontmatter.md) (`Stone`) | Almost everywhere | Any cutteray, loose rocks | Basic building |
| [Salvaged Metal](salvaged-metal.frontmatter.md) (`ScrapMetal`) | Wreckage, scavenger camps | Hands or any cutteray | Improvised tools, darts, welding wire |
| [Copper Ore](copper-ore.frontmatter.md) (`AzuriteOre`) | Hagga Basin South and beyond | Improvised Cutteray+ | Copper Ingot |
| [Iron Ore](iron-ore.frontmatter.md) (`MagnetiteOre`) | Vermillius Gap | Cutteray Mk1+ | Iron Ingot, Steel |
| [Carbon Ore](carbon-ore.frontmatter.md) (`DolomiteRock`) | Jabal Eifrit | Cutteray Mk2+ | Steel Ingot |
| [Erythrite Crystal](erythrite-crystal.frontmatter.md) (`ErythriteCrystal`) | Hagga Rift | Cutteray Mk2+ | Cobalt Paste |
| [Aluminum Ore](aluminum-ore.frontmatter.md) (`BauxiteOre`) | Shield Wall; Deep Desert | Cutteray Mk3+ | Aluminum Ingot, Duraluminum |
| [Basalt Stone](basalt-stone.frontmatter.md) (`Basalt`) | Mysa Tarill, Shield Wall | Cutteray Mk3+ | Plastone |
| [Jasmium Crystal](jasmium-crystal.frontmatter.md) (`JasmiumCrystal`) | Sheol radioactive pools | Cutteray Mk4+ | Duraluminum Ingot |
| [Titanium Ore](titanium-ore.frontmatter.md) (`T6ResourceA`) | Deep Desert only | Cutteray Mk5+ | Plastanium Ingot |
| [Stravidium Mass](stravidium-mass.frontmatter.md) (`T6ResourceB`) | Deep Desert only | Cutteray Mk5+ | Stravidium Fiber, Plastanium |
| [Flour Sand](flour-sand.frontmatter.md) (`FlourSand`) | Open sand, mainly Vermillius Gap | Hands, Static Compactor | Silicone Block |
| [Spice Sand](spice-sand.frontmatter.md) (`SpiceSand`) | Spice fields after blows | Hands, Static Compactor, Sandcrawler | Spice Melange |
| [Agave Seeds](agave-seeds.frontmatter.md) (`SaguaroResourceRaw`) | The O'odham | Hands | Iodine Pills |
| [Fuel Cell](fuel-cell.frontmatter.md) (`Oil`) | Scavenger camps, wrecks, loot | Pick up, break boxes | Base generator, vehicle fuel, spice fuel |

## Refined intermediates

| Product | Made from | Station |
|---|---|---|
| [Copper Ingot](copper-ingot.frontmatter.md) | Copper Ore | Any Ore Refinery |
| [Iron Ingot](iron-ingot.frontmatter.md) | Iron Ore + water | Any Ore Refinery |
| [Steel Ingot](steel-ingot.frontmatter.md) | Iron Ingot + Carbon Ore + water | Any Ore Refinery |
| [Aluminum Ingot](aluminum-ingot.frontmatter.md) | Aluminum Ore + water | Medium or Large Ore Refinery |
| [Duraluminum Ingot](duraluminum-ingot.frontmatter.md) | Aluminum Ingot + Jasmium + water | Medium or Large Ore Refinery |
| [Stravidium Fiber](stravidium-fiber.frontmatter.md) | Stravidium Mass + water | Medium Chemical Refinery |
| [Plastanium Ingot](plastanium-ingot.frontmatter.md) | Titanium Ore + Stravidium Fiber + water | Medium or Large Ore Refinery |
| [Silicone Block](silicone-block.frontmatter.md) | Flour Sand + water | Chemical Refinery |
| [Cobalt Paste](cobalt-paste.frontmatter.md) | Erythrite + water | Chemical Refinery |
| [Plastone](plastone.frontmatter.md) | Basalt Stone + Silicone Block + water | Ore Refinery |
| [Vehicle Fuel Cells](vehicle-fuel-cells.frontmatter.md) | Fuel Cells (+ water) | Chemical Refinery |
| [Spice-infused Fuel Cell](spice-infused-fuel-cell.frontmatter.md) | Fuel Cells + Spice Residue + Irradiated Slag + water | Medium Chemical Refinery |

## Tools

[Cutteray](cutteray.frontmatter.md) (handheld mining, Improvised to Mk6 and uniques), [Buggy Cutteray](buggy-cutteray.frontmatter.md), [Power Pack](power-pack.frontmatter.md), [Static Compactor](static-compactor.frontmatter.md), [Scanners and Survey Probes](scanners.frontmatter.md), [Blood Extractor](blood-extractor.frontmatter.md), [Dew Reaper](dew-reaper.frontmatter.md), [Gathering with vehicles](vehicle-harvesting.frontmatter.md).

## Cutteray tier needed

| Mineral tier (game text) | Minerals | Cutteray |
|---|---|---|
| 1 | Copper, granite, salvaged metal | Improvised |
| 2 | Iron | Mk1 |
| 3 | Carbon, erythrite | Mk2 |
| 4 | Basalt, aluminum | Mk3 |
| 5 | Jasmium | Mk4 |
| 6 | Titanium, stravidium | Mk5 |

Scarce and loot-only materials: [rare-resources](rare-resources.frontmatter.md).

Notes for this server: Hagga Basin resource nodes move at each Coriolis storm (wiki, https://awakening.wiki/Coriolis_Storms). Whether this server's Deep Desert has PvP areas with 2.5x yields is not recorded (see [world-and-maps.md](../world-and-maps.md)). No server resource multipliers were checked for this section (unverified).
