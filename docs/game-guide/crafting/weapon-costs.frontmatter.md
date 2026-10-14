---json
{
  "schema": "dune-guide/v1",
  "title": "Weapon costs by tier",
  "description": "Material cost of representative weapons at every tier (sword, Disruptor M11, Karpov 38) plus ammunition, rockets and missiles.",
  "kind": "recipe",
  "section": "crafting",
  "tags": ["weapon cost", "weapon recipe", "sword", "disruptor", "karpov", "ammo", "darts", "rocket", "missile", "standard", "artisan", "house", "adept", "regis"],
  "aliases": ["weapon recipes", "gun recipes"],
  "related": ["crafting/weapons-fabricator", "crafting/advanced-weapons-fabricator", "crafting/mechanical-parts", "crafting/gun-parts", "crafting/blade-parts", "crafting/worked-example-adept-disruptor-mk5"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Weapon costs by tier

Quick answer: guns take ingots + Mechanical Parts + Gun Parts (+ Silicone from Mk2, a Light Caliber Compressor from Mk4); blades take ingots + Plasteel Microflora Fiber + Blade Parts + Plant Fiber (+ Carbide Scraps from Mk4). Mk6 (Regis) swaps the loot parts for Plasteel Composite parts and adds Spice Melange (wiki recipe data). Numbers are wiki recipe data from before 1.5; Mk4-Mk6 costs may be 10 to 25% lower in 1.5, and this server halves fabrication costs (`CraftingCost=0.5`, server config). See [index](index.frontmatter.md).

## Disruptor M11 (light dart SMG)

| Tier | Station | Recipe |
|---|---|---|
| Standard (Mk2) | Fabricator or Weapons Fabricator | 8 Iron, 5 Mechanical Parts, 4 Silicone, 7 Gun Parts |
| Artisan (Mk3) | Weapons Fabricator | 9 Steel, 8 Mechanical Parts, 7 Silicone, 11 Gun Parts, 70 mL |
| House (Mk4) | Weapons Fabricator | 18 Aluminum, 11 Mechanical Parts, 17 Silicone, 17 Gun Parts, 4 Light Caliber Compressor, 170 mL |
| Adept (Mk5) | Weapons Fabricator | 25 Duraluminum, 14 Mechanical Parts, 33 Silicone, 23 Gun Parts, 5 Light Caliber Compressor, 340 mL |
| Regis (Mk6) | Advanced Weapons Fabricator | 30 Plastanium, 18 Mechanical Parts, 34 Silicone, 12 Plasteel Composite Gun Parts, 8 Light Caliber Compressor, 25 Melange, 530 mL |

## Karpov 38 (rifle)

| Tier | Recipe |
|---|---|
| Mk1 | 8 Copper, 2 Mechanical Parts |
| Standard | 9 Iron, 4 Mechanical Parts, 3 Silicone, 9 Gun Parts |
| Artisan | 10 Steel, 6 Mechanical Parts, 5 Silicone, 14 Gun Parts, 70 mL |
| House | 20 Aluminum, 9 Mechanical Parts, 13 Silicone, 22 Gun Parts, 4 Light Caliber Compressor, 170 mL |
| Adept | 30 Duraluminum, 11 Mechanical Parts, 26 Silicone, 29 Gun Parts, 5 Light Caliber Compressor, 340 mL |
| Regis | 32 Plastanium, 14 Mechanical Parts, 27 Silicone, 14 Plasteel Composite Gun Parts, 8 Light Caliber Compressor, 25 Melange, 530 mL |

## Sword

| Tier | Recipe |
|---|---|
| Standard | 10 Iron, 4 Plasteel Microflora Fiber, 3 Plant Fiber, 6 Blade Parts |
| Artisan | 6 Steel, 12 Plasteel Microflora Fiber, 3 Plant Fiber, 9 Blade Parts, 60 mL |
| House | 12 Aluminum, 25 Plasteel Microflora Fiber, 3 Plant Fiber, 15 Blade Parts, 3 Carbide Scraps, 140 mL |
| Adept | 15 Duraluminum, 12 Plasteel Microflora Fiber, 3 Plant Fiber, 19 Blade Parts, 4 Carbide Scraps, 280 mL |
| Regis | 30 Plastanium, 15 Plasteel Microflora Fiber, 3 Plant Fiber, 10 Plasteel Composite Blade Parts, 7 Carbide Scraps, 20 Melange, 440 mL |

Mk1 knives: Kindjal 4 Copper + 3 Plasteel Microflora Fiber + 3 Plant Fiber; Scrap Metal Knife from Salvaged Metal (wiki).

## Ammunition and explosives

| Output | Recipe | Station |
|---|---|---|
| 30 Light Darts | 5 Salvaged Metal, 3 s | Fabricator, Weapons Fabricator |
| 15 Heavy Darts | 7 Salvaged Metal, 3 s | Fabricator, Weapons Fabricator |
| 10 Rocket | 1 Duraluminum Ingot, 10 Fuel Cell, 50 mL | Weapons Fabricator |
| 10 Missile | 2 Duraluminum Ingot, 15 Fuel Cell, 75 mL | Advanced Weapons Fabricator |

Sources: https://awakening.wiki/Weapons_Fabricator, https://awakening.wiki/Advanced_Weapons_Fabricator, https://awakening.wiki/Fabricator. Research: Standard 5 Intel, Artisan 10, House 20, Adept 30, Regis 40 per weapon (https://awakening.wiki/Research).
