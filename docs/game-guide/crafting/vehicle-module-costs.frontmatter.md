---json
{
  "schema": "dune-guide/v1",
  "title": "Vehicle costs by tier (whole vehicles and key modules)",
  "description": "Total materials for the required modules of every vehicle at every tier (sandbike Mk1-Mk6, buggy Mk3-Mk6, scout, assault and carrier ornithopters, sandcrawler), plus chassis costs.",
  "kind": "recipe",
  "section": "crafting",
  "tags": ["vehicle cost", "vehicle recipe", "sandbike", "buggy", "ornithopter", "scout ornithopter", "assault ornithopter", "carrier", "sandcrawler", "modules", "how much"],
  "aliases": ["vehicle recipes", "thopter cost", "buggy cost"],
  "related": ["crafting/vehicle-fabricator", "crafting/advanced-vehicle-fabricator", "crafting/worked-example-buggy-mk4", "crafting/advanced-servoks", "crafting/particle-capacitor"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Vehicle costs by tier

Quick answer: a whole vehicle is its required modules welded to a chassis. Totals below add up the required modules only (no booster, storage, turret, scanner or seat), computed from wiki recipe data. Numbers are wiki recipe data from before 1.5; Mk4-Mk6 costs may be 10 to 25% lower in 1.5, and this server halves fabrication costs (`CraftingCost=0.5`, server config). See [index](index.frontmatter.md). Required-module lists are from the vehicles chapter (game text). Each module also needs research: the "Mk_ Assembly" group teaches the set ([research-and-intel](research-and-intel.frontmatter.md)).

| Vehicle | Station | Total materials for required modules (computed) |
|---|---|---|
| Sandbike Mk1 | Fabricator / Vehicle Fab | 43 Copper, 13 Advanced Servoks, 6 Particle Capacitor |
| Sandbike Mk2 | Fabricator / Vehicle Fab | 75 Iron, 28 Servoks, 7 Armor Plating, 13 Particle Capacitor |
| Sandbike Mk3 | Vehicle Fab | 88 Steel, 39 Servoks, 56 Cobalt, 13 Armor Plating, 28 Particle Capacitor, 10 Complex Machinery, 675 mL |
| Sandbike Mk4 | Vehicle Fab | 166 Aluminum, 53 Servoks, 90 Cobalt, 7 Carbide Scraps, 21 Armor Plating, 7 Diamondine Dust, 27 Particle Capacitor, 15 Complex Machinery, 1,686 mL |
| Sandbike Mk5 | Vehicle Fab | 228 Duraluminum, 67 Servoks, 124 Cobalt, 10 Carbide, 34 Armor Plating, 10 Diamondine, 34 Particle Capacitor, 21 Complex Machinery, 7 Hydraulic Piston, 7 Military Power Regulator, 3,385 mL |
| Sandbike Mk6 | Advanced Vehicle Fab | 260 Plastanium, 259 Melange, 93 Servoks, 225 Cobalt, 15 Carbide, 30 Plasteel Composite Armor Plating, 15 Diamondine, 45 Particle Capacitor, 30 Complex Machinery, 9 Tri-Forged Hydraulic Piston, 9 Overclocked Power Regulator, 5,100 mL |
| Buggy Mk3 | Vehicle Fab | 150 Steel, 90 Servoks, 81 Cobalt, 13 Armor Plating, 50 Particle Capacitor, 10 Complex Machinery, 855 mL |
| Buggy Mk4 | Vehicle Fab | 271 Aluminum, 72 Servoks, 110 Cobalt, 7 Carbide, 42 Armor Plating, 14 Diamondine, 31 Particle Capacitor, 15 Complex Machinery, 3,060 mL |
| Buggy Mk5 | Vehicle Fab | 358 Duraluminum, 88 Servoks, 149 Cobalt, 10 Carbide, 68 Armor Plating, 20 Diamondine, 44 Particle Capacitor, 21 Complex Machinery, 7 Hydraulic Piston, 7 Military Power Regulator, 4,070 mL |
| Buggy Mk6 | Advanced Vehicle Fab | 435 Plastanium, 329 Melange, 126 Servoks, 273 Cobalt, 15 Carbide, 60 Plasteel Composite Armor Plating, 30 Diamondine, 54 Particle Capacitor, 30 Complex Machinery, 9 Tri-Forged Piston, 9 Overclocked Regulator, 6,250 mL |
| Scout Ornithopter Mk4 | Vehicle Fab | 241 Aluminum, 46 Servoks, 82 Cobalt, 7 Carbide, 22 Armor Plating, 14 Diamondine, 22 Particle Capacitor, 8 Complex Machinery, 8 Industrial Pump, 3,056 mL |
| Scout Ornithopter Mk5 | Vehicle Fab | 350 Duraluminum, 98 Servoks, 149 Cobalt, 10 Carbide, 68 Armor Plating, 20 Diamondine, 34 Particle Capacitor, 21 Complex Machinery, 7 Hydraulic Piston, 7 Military Power Regulator, 12 Industrial Pump, 4,070 mL |
| Scout Ornithopter Mk6 | Advanced Vehicle Fab | 420 Plastanium, 329 Melange, 131 Servoks, 273 Cobalt, 15 Carbide, 60 Plasteel Composite Armor Plating, 30 Diamondine, 54 Particle Capacitor, 30 Complex Machinery, 9 Tri-Forged Piston, 9 Overclocked Regulator, 16 Industrial Pump, 6,250 mL |
| Assault Ornithopter Mk5 | Vehicle Fab | 430 Duraluminum, 110 Servoks, 174 Cobalt, 10 Carbide, 68 Armor Plating, 20 Diamondine, 44 Particle Capacitor, 21 Complex Machinery, 7 Hydraulic Piston, 7 Military Power Regulator, 12 Industrial Pump, 4,875 mL |
| Assault Ornithopter Mk6 | Advanced Vehicle Fab | 505 Plastanium, 382 Melange, 156 Servoks, 318 Cobalt, 15 Carbide, 90 Plasteel Composite Armor Plating, 45 Diamondine, 54 Particle Capacitor, 30 Complex Machinery, 9 Tri-Forged Piston, 9 Overclocked Regulator, 18 Industrial Pump, 7,800 mL |
| Carrier Ornithopter Mk6 | Advanced Vehicle Fab | 769 Plastanium, 498 Melange, 256 Servoks, 408 Cobalt, 15 Carbide, 144 Plasteel Composite Armor Plating, 75 Diamondine, 54 Particle Capacitor, 30 Complex Machinery, 9 Tri-Forged Piston, 9 Overclocked Regulator, 16 Industrial Pump, 10,400 mL |
| Sandcrawler Mk6 (no vacuum or centrifuge) | Advanced Vehicle Fab | 243 Plastanium, 245 Melange, 84 Servoks, 186 Cobalt, 15 Carbide, 45 Armor Plating, 54 Particle Capacitor, 30 Complex Machinery, 9 Tri-Forged Piston, 9 Overclocked Regulator, 4,700 mL |

The sandcrawler needs both the Vacuum and Centrifuge to harvest (vehicles chapter); the Vacuum Mk6 alone is 60 Plastanium, 36 Servoks, 45 Cobalt, 54 Melange, 9 Advanced Machinery, 1,050 mL (wiki). Treadwheel module recipes are not on the wiki's fabricator pages (unverified how they are made; vehicles chapter notes their research is journey-gated).

## Module patterns

- Chassis, hulls and treads: ingots + Advanced Servoks + Cobalt (from Mk3); from Mk4 chassis add Carbide Scraps, hulls add Armor Plating + Diamondine Dust. Chassis by tier: Sandbike Mk1 12 Copper + 5 Servoks, Mk2 20 Iron + 8, Mk3 25 Steel + 12 + 11 Cobalt, Mk4 45 Aluminum + 16 + 18 + 7 Carbide, Mk5 60 Duraluminum + 20 + 25 + 10, Mk6 70 Plastanium + 27 + 45 + 15 + 54 Melange.
- Engines: ingots + Particle Capacitor + Complex Machinery (+ Hydraulic Piston from Mk5, Tri-Forged from Mk6). PSUs and generators: ingots + Particle Capacitor (+ Military Power Regulator from Mk5). Boosters: Particle Capacitor + Holtzman Actuator. Ornithopter wings: Industrial Pump.
- Optional modules cost about as much as a hull: Buggy Booster Mk4 60 Aluminum + 40 Particle Capacitor + 30 Cobalt + 31 Holtzman Actuator; Buggy Cutteray Mk4 70 Aluminum + 30 Particle Capacitor + 27 Cobalt + 15 Ray Amplifier (wiki).
- Welding: Welding Torch Mk1 6 Copper; Mk3 12 Steel + 8 Servoks + 8 Cobalt; Mk5 32 Duraluminum + 14 Servoks + 16 Cobalt. Welding Wire 100 per 5 Salvaged Metal (Steel / Duraluminum wire per 5 ingots) (wiki).

Sources: https://awakening.wiki/Vehicle_Fabricator, https://awakening.wiki/Advanced_Vehicle_Fabricator, https://awakening.wiki/Fabricator, https://awakening.wiki/Survival_Fabricator.
