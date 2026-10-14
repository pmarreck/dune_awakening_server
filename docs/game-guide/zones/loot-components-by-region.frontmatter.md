---json
{
  "schema": "dune-guide/v1",
  "title": "Crafting components by region",
  "description": "Where each tier of looted crafting component comes from (caves, testing stations, wrecks, enemy types) region by region, from the game's own item descriptions, with item ids.",
  "kind": "system",
  "section": "zones",
  "tags": ["components", "loot", "farming", "where to find", "servoks", "emf generator", "micro-sandwich fabric", "particle capacitor", "mechanical parts", "plasteel", "armor plating", "gun parts", "blade parts", "tiers"],
  "aliases": ["component tiers", "where do I farm", "OldImperialComponent", "FremenComponent", "GreatHouseComponent"],
  "region": "Hagga Basin, Deep Desert",
  "related": ["zones/imperial-testing-stations", "zones/shipwrecks", "zones/caves-and-trials-of-aql", "zones/merchant-directory"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Crafting components by region

Quick answer: components come in three families tied to a kind of place, and each region drops its own tier. Fremen components (EMF Generator, Micro-sandwich Fabric) are in caves; Old Imperial ones (Servoks, Particle Capacitor) in Imperial Testing Stations; Great House ones (Plasteel Microflora Fiber, Mechanical Parts) in shipwrecks. Enemy-type parts (armor plating, gun parts, blade parts) drop from Heavy, Assault/Marksman and Rusher enemies of the region. All of this is stated in the items' own descriptions (game text, build 25610213).

## Family tiers by region (game text names; ids from item data where checked)

| Tier region | Caves (Fremen) | Testing stations (Old Imperial) | Wrecks (Great House) |
|---|---|---|---|
| Starter (no region named) | EMF Generator (`FremenComponent1`), Micro-sandwich Fabric (`FremenComponent2`) | Advanced Servoks (`OldImperialComponent1`), Particle Capacitor (`OldImperialComponent2`) | Plasteel Microflora Fiber (`GreatHouseComponent1`), Mechanical Parts (`GreatHouseComponent2`) |
| Vermillius Gap | EMF Generator, Micro-sandwich Fabric | Servoks (`D_OldImperialComponent3`), Particle Capacitor | Plasteel Microflora Fiber, Mechanical Parts |
| Jabal Eifrit and Hagga Rift | Enhanced EMF Generator, Enhanced Micro-sandwich Fabric | Enhanced Servoks (`D_OldImperialComponent5`), Enhanced Particle Capacitor | Enhanced Plasteel Microflora Fiber, Enhanced Mechanical Parts |
| Shield Wall and The O'odham | Efficient EMF Generator, Efficient Micro-sandwich Fabric | Efficient Servoks (`D_OldImperialComponent7`), Efficient Particle Capacitor | Efficient Plasteel Microflora Fiber, Efficient Mechanical Parts |
| Sheol | Overtuned EMF Generator, Durable Micro-sandwich Fabric | Optimized Servoks (`D_OldImperialComponent9`), Charged Particle Capacitor | Braided Plasteel Microflora Fiber, Precision Mechanical Parts |
| Deep Desert | Advanced EMF Generator (`D_FremenComponent11`), Advanced Micro-sandwich Fabric | Advanced Servoks, Advanced Particle Capacitor (`D_OldImperialComponent12`) | Advanced Plasteel Microflora Fiber, Advanced Mechanical Parts |

Several regional tiers share a display name with the starter item (for example two different "EMF Generator" and "Advanced Servoks" items). The vendors' lists on the wiki do not say which tier they sell; the starter tier is the likely one (inference).

## Enemy-type parts (game text)

| Region | Heavy enemies | Assault and Marksman | Rusher (and weapon lockers) |
|---|---|---|---|
| Starter / Vermillius Gap | Armor Plating | Gun Parts | Blade Parts ("in the Vermilius Gap") |
| Jabal Eifrit and Hagga Rift | Thick Armor Plating | Enhanced Gun Parts | Serrated Blade Parts |
| Shield Wall and The O'odham | Fortified Armor Plating | Lightweight Gun Parts | Sharpened Blade Parts |
| Sheol | Reinforced Armor Plating | Precision Gun Parts | Keen Blade Parts |
| Deep Desert | Advanced Armor Plating | Advanced Gun Parts | Advanced Blade Parts |

Only some descriptions name the region; the Gun Parts and Blade Parts tiers above Vermillius Gap say only "found in loot", so their region columns follow the tier naming (inference).

## Place-specific components (game text; ids item data)

| Component | Where |
|---|---|
| Calibrated Servok (`T3MiningGalleryComponent1`), Ray Amplifier (`T3MiningGalleryComponent2`) | Heavy mining equipment "used extensively in Jabal Eifrit"; the map's CHOAM Mineral Extraction Facilities in the Hagga Rift are the "mining gallery" sites (inference from ids) |
| Complex Machinery | "found in many older fabricators and refineries" |
| Insulated Fabric (`T4PyonVillageComponent`) | The O'odham pyon villages |
| Diamondine Dust (`T4MysaTarilComponent1`), Carbide Scraps | The Maas Kharet's "most sacred site" (Mysa Tarill by the id) |
| Dart-grooved Barrel | "High-up bases in Shield Wall" |
| High-tensile Springs | Sheol |
| Irradiated Slag (`T5RadiatedCoreComponent`) | "Radiated Core in the Sheol" |
| Thermoelectric Cooler (`T5DeepDesertShieldWallComponent`) | Deep Desert Shield Wall |
| Station 15 Component | Station 15 (Overland Map) |
| Plastanium-tier parts (Holtzman Actuator, Range Finder T6, Irradiated Core, Industrial Pump and others) | Deep Desert, Landsraad rewards, or an Advanced Survival Fabricator |
| Erythrite Crystal | Hagga Rift deposits only |
| Flour Sand | Open-sand drifts, "predominantly in the Vermillius Gap" |
| Fuel Cell | "Found throughout the world" |
