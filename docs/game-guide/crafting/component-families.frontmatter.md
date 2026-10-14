---json
{
  "schema": "dune-guide/v1",
  "title": "Component families: what looted parts are for",
  "description": "The looted crafting components that cannot be fabricated, grouped by where they drop (Fremen caves, Old Imperial testing stations, Great House shipwrecks, enemies, regions, Deep Desert) and what they go into.",
  "kind": "system",
  "section": "crafting",
  "tags": ["components", "loot", "fremen", "old imperial", "great house", "shipwreck", "testing station", "cave", "where to find", "primary source"],
  "aliases": ["component sources", "crafting components", "Primary Source"],
  "related": ["crafting/advanced-servoks", "crafting/particle-capacitor", "crafting/emf-generator", "crafting/micro-sandwich-fabric", "crafting/mechanical-parts", "crafting/plasteel-microflora-fiber", "crafting/regional-loot-components", "crafting/plastanium-tier-components"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Component families

Quick answer: besides refined metals, most recipes need looted components that you cannot fabricate. The game color-codes them by origin: green map markers (shipwrecks) for weapon and armor parts, blue (testing stations) for vehicle and tech parts, orange (moisture-sealed caves) for hydration and gathering gear (game text, survival chapter). The Research menu card shows each component's "Primary Source" (game text).

| Family (origin) | Item (id) | Goes into (game text and wiki) |
|---|---|---|
| Fremen (caves) | [EMF Generator](emf-generator.frontmatter.md) (`FremenComponent1`) | Cutterays, dew and blood tools |
| Fremen (caves) | [Micro-sandwich Fabric](micro-sandwich-fabric.frontmatter.md) (`FremenComponent2`) | Stillsuits, blood sacks, literjons, tents |
| Old Imperial (testing stations) | [Advanced Servoks](advanced-servoks.frontmatter.md) (`OldImperialComponent1`) | Vehicle chassis, hulls, treads; welding torches |
| Old Imperial (testing stations) | [Particle Capacitor](particle-capacitor.frontmatter.md) (`OldImperialComponent2`) | Holtzman tech, boosters, engines, PSUs, power packs |
| Great House (shipwrecks) | [Plasteel Microflora Fiber](plasteel-microflora-fiber.frontmatter.md) (`GreatHouseComponent1`) | Armor, blades |
| Great House (shipwrecks) | [Mechanical Parts](mechanical-parts.frontmatter.md) (`GreatHouseComponent2`) | Firearms |
| Enemies by role | [Gun Parts](gun-parts.frontmatter.md), [Blade Parts](blade-parts.frontmatter.md), [Armor Plating](armor-plating.frontmatter.md), Range Finder | Guns, blades, heavy armor and hulls |
| Old machinery | [Complex Machinery](complex-machinery.frontmatter.md) (`T2MachineComponent`) | Stations, vehicle engines |
| Suspensor caches | [Holtzman Actuator](holtzman-actuator.frontmatter.md) (`T1ExplorationComponent`) | Boosters, belts, shields |
| Regions (Mk3-Mk5) | [regional-loot-components](regional-loot-components.frontmatter.md) | Mk3+ tools, weapons, armor, vehicles |
| Great House bases | [Military Power Regulator](military-power-regulator.frontmatter.md), [Hydraulic Piston](hydraulic-piston.frontmatter.md) | Vehicle PSUs and engines, Advanced Weapons Fabricator |
| Secure containers | [Spice-infused dusts](spice-infused-dust.frontmatter.md) | Unique items |
| Deep Desert | [Plasteel Plate](plasteel-plate.frontmatter.md) and [plastanium-tier components](plastanium-tier-components.frontmatter.md) | Mk6 items |

## One item per family since the regional variants were retired

Game text lists six regional grades for each Fremen, Old Imperial and Great House component (for example Servoks, Enhanced, Efficient, Optimized and Advanced Servoks, from the Vermilius Gap through the Jabal Eifrit and Hagga Rift, the Shield Wall and O'odham, the Sheol, to the Deep Desert). Item data marks every graded variant except one per family as deprecated (`D_OldImperialComponent3` and up), and the wiki's station recipes use only `FremenComponent1`/`2`, `OldImperialComponent1`/`2` and `GreatHouseComponent1`/`2` (item data; wiki recipe data, counted 2026-10-13). The same holds for enemy parts: recipes use only the base Gun Parts (`T1AssaultComponent`), Blade Parts (`T1RusherComponent`) and Armor Plating (`T2HeavyComponent`), even though game text names tiered versions (Enhanced, Lightweight, Precision, Advanced Gun Parts and so on). Mk6 recipes instead use Plasteel Composite parts made in the Advanced Survival Fabricator. The region texts in the old descriptions still hint where the components are most common.

Old graded components still in an inventory are presumably dead stock; whether the Recycler accepts them is unverified.
