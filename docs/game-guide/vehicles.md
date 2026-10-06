# Vehicles

Scope: every player vehicle, its modules and tiers, assembly, fuel, repair and durability, the Vehicle Backup Tool, parking and losses. Last researched: 2026-10-06, game 1.5.x (strings from build 25610213; this server runs 25689360).

Provenance tags: `(game text)` is the build 25610213 string table; `(item data)` is `bin/dune-awakening items find`; web sources carry their URL. Anything dated before the 1.5 release (2026-09-17) is marked "pre-1.5".

## Quick answers

**How do I store my buggy?** You can't put it in the Vehicle Backup Tool. The tool's own description lists only "Sandbike, Scout Ornithopter, or Treadwheel" (game text). Park a buggy inside an enclosed garage in your own base, or disassemble it into modules with a Welding Torch and store those in base storage (game text, base-backup and character-transfer warnings both give this advice).

**How do I store a sandbike, scout ornithopter or treadwheel?** Equip the Vehicle Backup Tool, stand near the vehicle, empty its inventory, get everyone off, and use Store. Restore it later from the same tool. One tool holds several vehicles: on build 25689360 its screen read "vehicles backed up: 2/10" with two sandbikes stored (verified on this server, 2026-10-06). Older sources say one vehicle per player (wiki, https://awakening.wiki/Vehicles), which no longer matches. The failure message "Another vehicle is already stored" (game text) exists, but when it appears is unverified.

**What does "2/10" mean?** On the Vehicle Backup Tool it is the number of vehicles stored in it against its capacity of 10 (verified on this server, 2026-10-06: two stored sandbikes showed as "2/10"). Separately, the game caps how many vehicles you own, with the message "Vehicle limit reached {current}/{max}" (game text). Players report the cap as 10 per character (community, pre-1.5, https://steamcommunity.com/app/1172710/discussions/0/598529212470571632/). Disassembling or disowning a vehicle frees a slot (community, same thread; "Disown Vehicle" is a Vehicle Management option, game text).

**Why can't I repair past 50% (or any number below 100%)?** Each Welding Torch repair permanently lowers that module's maximum durability. The repair stops at the new maximum. The module screen shows "Current Durability" and "Maximum Durability" separately (game text). Better torches lose less; once a module is too worn, replace it with a freshly crafted one. Server admins can turn the loss off with the "Max Durability Decay" server setting (game text); a 1.5.15.0 fix made that setting actually apply to vehicle parts (patch notes 1.5.15.0, https://duneawakening.com/news/public-test-client-patch-1-5-15-0/).

**My vehicle was destroyed. Can I get it back?** Usually yes: Vehicle Backup Tool, Recovery mode, for Solari plus some maximum durability. Inventory contents are lost. Only vehicles that still had more than 15% durability show up, and you must be in a PvE area or inside your own land claim (game text). Details in "Recovery" below.

**I'm leaving this map. What happens to my parked vehicles?** The game warns: "Any vehicle left behind will be destroyed and can only be recovered using the Vehicle Backup Tool" (game text). Store a backup-capable vehicle first, or fly your ornithopter out with you.

**Where do I unlock vehicles?** Research menu, "Vehicles" category; each vehicle is a "Mk_ Assembly" research group, gated by material tier (game text). Craft parts at a Vehicles Fabricator or Advanced Vehicle Fabricator (game text), then weld them together.

**My vehicle got hurt while parked inside my base.** Two bugs of that kind were fixed: 1.5.03.0 "vehicles could receive environmental damage while sheltered in bases" (community summary of 1.5.3 notes, https://jeu.video/en/article/dune-awakening-patch-notes-hotfix-1-5-3-1) and 1.5.15.0 "safely stored vehicles" taking environmental damage (patch notes 1.5.15.0). If it still happens on build 25689360, it may be a new bug (unverified).

**Will a sandworm eat my vehicle?** Yes, on servers with "Sandworm Vehicle Destruction" enabled (game text server setting). If the worm catches you, "any vehicle you're using will be destroyed" (game text).

## Vehicle roster

Tier names follow material: Mk1 Copper, Mk2 Iron, Mk3 Steel, Mk4 Aluminum, Mk5 Duraluminum, Mk6 Plastanium (wiki, https://awakening.wiki/Sandbike). The research-menu subcategory text matches: Copper unlocks "CHOAM Sandbike and Vehicle Assembly Tool", Iron "Sandbike Boost Module", Steel "CHOAM Buggy and Buggy Boost Module", Aluminum "CHOAM Scout Ornithopter", Duraluminum "CHOAM Assault Ornithopter" (game text).

| Vehicle | Research groups (game text) | Seats | Backup Tool | Overland travel |
|---|---|---|---|---|
| Sandbike | Sandbike Mk1-Mk6 Assembly | 1-2 (Backseat module adds one) | Yes (game text) | No (wiki) |
| Treadwheel | Treadwheel Mk4-Mk6 Assembly | 1-2 (Passenger module) | Yes (game text) | No (wiki) |
| Buggy | Buggy Mk3-Mk6 Assembly | 3-4 (depends on rear hull) | No | No (unverified) |
| Scout Ornithopter | Scout Ornithopter Mk4-Mk6 Assembly | 1 | Yes (game text) | Yes (wiki) |
| Assault Ornithopter | Assault Ornithopter Mk5-Mk6 Assembly | 4 (pilot, co-pilot, 2 in cabin) | No | Yes (wiki) |
| Carrier Ornithopter | Carrier Ornithopter Mk6 Assembly | 6 (pilot plus five) | No | Yes (wiki) |
| Sandcrawler | Sandcrawler Mk6 Assembly | 2 | No | No; must be carried (wiki) |

Seat counts come from module descriptions (game text) and the wiki pages listed in Sources. The string table also contains Mk7-Mk9 names for some modules (for example "Buggy Chassis Mk8", "Sandbike PSU Mk9", "Scout Ornithopter Engine Mk7"), "Scrap" variants of every vehicle's parts, and a deprecated "Tank" set (game text). No research group exists for Mk7+ and the Tank parts are labeled "[DEPRECATED]", so treat them as unused or not obtainable through normal research (unverified). Treadwheel Mk1-Mk3 modules exist as items (`TreadwheelChassis_1` to `_3`, item data), but the research groups and the wiki start at Mk4 (wiki, https://awakening.wiki/Treadwheel); how Mk1-Mk3 treadwheel parts are obtained is unverified.

Sandbike: light, cheap, the first vehicle. The Backseat lets a passenger use ranged weapons and tools (game text). Unique parts include the Mohandis Sandbike Engine (more speed, more heat) (game text).

Treadwheel: a one-person groundcar added in the Lost Harvest update. It "trades top speed for stronger acceleration, a tighter turning radius, reduced worm attraction, and full-speed reverse" (wiki, https://awakening.wiki/Treadwheel). Uniques: Swift Treadwheel Engine, Steady Treadwheel Boost Module (game text).

Buggy: four treads, a front hull (driver plus passenger) and a choice of rear. The standard Rear has two passenger seats and one utility slot; the Utility Rear has a turret slot (game text). Turret options are the Buggy Cutteray (mining laser) and Buggy Rocket Launcher. The cutteray "does not allow analysis mode and requires an attached inventory module to hold mined resources" (game text). Buggy Shield Generators also exist (game text). 1.5.03.0 made the Lost & Found contract reward Buggy modules (wiki, https://awakening.wiki/1.5.03.0).

Scout Ornithopter: the solo flyer, used for scouting and overland travel. Uniques: Albatross Wing Module, Stormrider Boost Module, Dyvetz and Mohandis engines, Hawkeye Scanner, Heaven's Wrath Rocket Module (game text). 1.5.15.0 cut the gliding speed penalty with a rocket pod from 20% to 10% (patch notes 1.5.15.0).

Assault Ornithopter: armored multi-crew combat flyer. Uniques include the Hummingbird Wing Module, Steady Assault Boost Module and Adept/Regis High-payload Rocket Module (game text).

Carrier Ornithopter: Plastanium-only heavy lifter. It can lift Sandcrawlers "or other vehicles" (game text) and the Carrier Ornithopter Cargo Container (`ContainerVehicle`, item data), a placeable crate "with anchor points" (game text). Cargo inside anything it carries can be reached at CHOAM Exchange banker and market terminals in settlements (wiki, https://awakening.wiki/Carrier_Ornithopter). The Backup Tool refuses to store while "harnessing is active" (game text).

Sandcrawler: Plastanium-only spice harvester. It collects Spice Sand, not Flour Sand (wiki, https://awakening.wiki/Sandcrawler). It needs a Vacuum (header) plus a Centrifuge (container) to harvest; "A Spice Container is also required for the header to function" (game text). Uniques: Walker Sandcrawler Engine, Upgraded Regis Spice Container, and low-vibration dampened treads (game text; wiki).

## Assembly

Assembly always starts with the chassis. Every chassis description says it "is the starting point for assembling vehicles" and is placed with a Welding Torch (game text). Every other module is welded onto the chassis or onto a hull. The UI groups modules into classes: Chassis, Body, Cockpit Hull, PSU (Generator), Engine, Locomotion (Tread/Wings), Utility, Perk, Rear Hull, Mid Hull (game text). A missing required module shows as "Module Required" and a count such as "(3/4)" (game text). The UI also tells you to "Craft Vehicle Modules with Fabricators" (game text).

The Welding Torch "can also be used to assemble or disassemble vehicles" (game text). A vehicle that is still "Assembling" cannot be backed up or relocated (game text).

Rules from the module text (game text): all treads on one vehicle must be the same type, and all wings must be the same type. You can generally mix tiers across different module types (wiki, https://awakening.wiki/Vehicles).

| Vehicle | Required modules | Optional modules |
|---|---|---|
| Sandbike | Chassis, Hull, Engine, PSU, 3 Treads | Backseat, Booster, Inventory, Scanner (attach to hull) |
| Treadwheel | Chassis, Hull, Engine, PSU, 2 Treads | Boost, Inventory, Passenger, Scanner (attach to hull) |
| Buggy | Chassis, Hull (front), Rear or Utility Rear, Engine, PSU, 4 Treads | Booster, Storage, Shield Generator (on Rear); Cutteray or Rocket Launcher (turret slot) |
| Scout Ornithopter | Chassis, Cockpit, Hull (body), Engine, Generator, 4 Wings | Inventory/Storage, Thruster, Scanner (on cockpit), Rocket Launcher |
| Assault Ornithopter | Chassis, Cockpit, Cabin, Tail, Engine, Generator, 6 Wings | Storage, Thruster, Rocket Launcher |
| Carrier Ornithopter | Chassis, Main Hull, Engine, Generator, 2 Side Hulls, 2 Tail Hulls, 8 Wings | Thruster (one utility slot), Shield Generator, Harness |
| Sandcrawler | Chassis, Cabin, Engine, PSU, 2 Treads | Vacuum, Centrifuge (both needed to harvest) |

Sources for the table: tread and wing counts from game text ("Attach 3 of these to a Sandbike Chassis", "attach 4 of these to a Scout Ornithopter Chassis", "Attach 6 of these to an Assault Ornithopter Chassis", "Use a Welding Torch to attach 8 of these to a Carrier Ornithopter Chassis", 4 for buggy, 2 for sandcrawler, side and tail hulls "Attach two"). Required/optional split from the wiki vehicle pages (Sources).

What each module class does (game text short descriptions):
- Chassis: "Defines the fuel capacity of the vehicle." Some chassis variants are labeled "(Fuel Capacity)".
- PSU / Generator: "Defines power efficiency and controls temperature." Variants labeled "(Fuel-Efficient)" exist.
- Engine: ground vehicles, acceleration and speed; ornithopters, maximum speed.
- Treads: grip. Wings: lift and flying capability.
- Hull / Cabin / Cockpit: seats and utility slots, plus protection.
- Boost (ground) / Thruster (air): a triggered burst of acceleration and top speed with fixed duration and cooldown (game text).
- Scanner: lets you scan without dismounting (game text).
- Inventory / Storage: cargo space.

### Heat and boosts

Boosting builds heat. The HUD warns "Increased temperature" and then "Overheated" (game text). Uniques with "LESSHEAT" in their ids trade top speed for lower heat (game text). Keystones exist for "Superior Heat Dissipation" and "Vehicle Boost Heat Reduction" (game text). Exact heat numbers: unverified.

## Fuel

Vehicles burn Vehicle Fuel Cells, not the raw "Fuel Cell" resource. Raw Fuel Cells (`Oil`, item data) power base generators and are refined "at a Chemical Refinery into Vehicle Fuel Cells" (game text).

| Item (id) | Fuel | Recipe (wiki) |
|---|---|---|
| Small Vehicle Fuel Cell (`FuelCanister`) | 200 | 25 Fuel Cell, Small Chemical Refinery, 15 s; or 20 Fuel Cell, Medium Chemical Refinery, 10 s |
| Medium Sized Vehicle Fuel Cell (`FuelCanister_Medium`) | 400 | 45 Fuel Cell + 15 mL water, Small Chemical Refinery, 20 s; or 40 + 15 mL, Medium, 15 s |
| Large Vehicle Fuel Cell (`FuelCanister_Large`) | 800 | 80 Fuel Cell + 30 mL water, Medium Chemical Refinery, 15 s |

Ids from item data; amounts and recipes from the wiki (https://awakening.wiki/Small_Vehicle_Fuel_Cell, https://awakening.wiki/Medium_Sized_Vehicle_Fuel_Cell, https://awakening.wiki/Large_Vehicle_Fuel_Cell), which says 200 fills a Sandbike Chassis Mk1 twice and 800 fills a Scout Ornithopter Chassis Mk6 twice. A game8 page gives a different medium recipe (10 cells per batch) (community, pre-1.5, https://game8.co/games/Dune-Awakening/archives/528441); treat recipe batch sizes as unverified and check your refinery.

To refuel, carry the vehicle fuel cell and interact with the vehicle (community, pre-1.5). On success the game shows "Refueled. New Status: {NewPercentage} %" (game text). 1.5.3 fixed radial-menu actions failing, including refueling a moving vehicle (community summary of 1.5.3, https://jeu.video/en/article/dune-awakening-patch-notes-hotfix-1-5-3-1). HUD warnings run "Low fuel", "Running on fumes", "Out of fuel" (game text).

Fuel-saving skills: "Fuel Efficient Driver" (ground) and "Fuel Efficient Pilot" (ornithopters), plus the keystone "Superior Fuel Efficiency" (game text). The server's "Fuel Efficiency" setting only affects fuel-powered base placeables, not vehicles (game text). Players report that parked vehicles outside a base lose fuel over time (community, pre-1.5, https://steamcommunity.com/app/1172710/discussions/0/595153695607375938/).

## Repair and durability

Tools and materials (names: game text; ids: item data):

| Tool | Id | Repair Quality (wiki) |
|---|---|---|
| Welding Torch Mk1 | `RepairTool` | 76.0% |
| Welding Torch Mk3 | `RepairTool3` | 83.0% |
| Welding Torch Mk5 | `RepairTool5` | 90.0% |

Repairs consume welding wire: Welding Wire (`WeldingMaterial`), Iron Welding Wire, Steel Welding Wire (`WeldingMaterial3`), Aluminum Welding Wire, Duraluminum Welding Wire (game text; ids item data). The Steel wire "reduces the rate of durability loss from repairs" and the Duraluminum wire "greatly reduces" it (game text). Out of wire, the crosshair says "Out of Welding Material" (game text). A "House Welding Torch" also exists in the strings (game text); how it is obtained is unverified.

Max-durability loss: the wiki gives the formula "Max Durability Decay = Repaired Amount × (1 - Repair Quality) × (1 - Vehicle Repair Perk)". Fully repairing a broken module loses 10% of max with Mk5 and 24% with Mk1 (wiki, https://awakening.wiki/Welding_Torch). The "Vehicle Repair" skill reduces this (game text); the wiki puts the full perk at 35%. The "Repair Master" keystone reduces repair loss on all items (game text).

Restoring lost maximum durability: no in-game way is confirmed. A Repair Station rejects some items with "This item must be repaired with a welding torch" (game text), which suggests vehicle modules can't go there. A GameRant guide claims removed parts can be repaired at a Repair Station (community, pre-1.5, https://gamerant.com/how-fix-repair-equipment-weapons-armor-gear-vehicles-dune-awakening/). The two disagree; unverified. The dependable fix is to craft a new module and swap it in.

Wear sources (community, pre-1.5, https://steamcommunity.com/app/1172710/discussions/0/595153695607375938/): driving wears treads, engine and PSU; firing weapons and using thrusters wears those modules; sandstorms damage every module; enemy fire damages what it hits. HUD warnings: "{ModuleClass} module about to break!" and "{ModuleClass} module broken!", "Critical health", "Wrecked" (game text). A wrecked vehicle cannot be repaired ("Vehicle is wrecked") (game text).

## Vehicle Backup Tool

Item id `VehicleBackupTool` (item data). Its description: "Use it to store and restore your Sandbike, Scout Ornithopter, or Treadwheel. Can also be used to recover destroyed vehicles for a cost" (game text). The older short description still says only "Sandbike or Scout Ornithopter" (game text); the long one is current.

Getting it: research "Vehicle Backup Tool" (journey task "Research the Vehicle Backup Tool", game text), then fabricate. Recipe sources disagree: the wiki lists 6 Copper Ingot + 2 Particle Capacitor at a Fabricator (wiki, https://awakening.wiki/Vehicle_Backup_Tool); game8 lists 12 Copper Ingot + 7 Advanced Servoks (community, pre-1.5, https://game8.co/games/Dune-Awakening/archives/528213). Check the research screen. Both agree it is a Copper-tier, early item.

Modes (game text tab names):

| Mode | What it does |
|---|---|
| Backup (Store / Restore) | Store one owned Sandbike, Scout Ornithopter or Treadwheel; restore it later where there is room |
| Recovery | Rebuild a recently destroyed vehicle of any type for Solari plus max durability |
| Relocation | Move an owned vehicle on the current map to your position, for a cost; lists "Owned vehicles in your current map location" |
| Auto-Transfer | Holds vehicles auto-backed-up from closed-server character migrations |

Store failure messages (game text):
- "No ownership on vehicle"
- "Vehicle inventory not empty"
- "Another vehicle is already stored"
- "Vehicle is out of range"
- "Vehicle is occupied"
- "Cannot back up vehicle while harnessing is active"
- "Cannot back up vehicle while it is being assembled"
- "No vehicle to store", "Vehicle cannot be stored"

Restore failures: "No vehicle to restore", "Not possible to place vehicle" (need open space) (game text). Clan members need the "Vehicle Backup" permission (game text). The progression card advises carrying the tool with a spare vehicle stored (game text journey "A Backup Plan").

### Recovery

From the game text: Recovery "fully restore[s] vehicles that have been recently destroyed at the cost of Solari and Maximum Durability"; "Items stored in the vehicle's Inventory modules will not be recovered"; it works only "in PvE zones or inside of your Landclaim if you are within a PvP enabled zone" (fail message: "Must be in a PvE area or inside your own landclaim"); the list shows "Destroyed vehicles with more than 15% durability"; a vehicle whose chassis had "critically low maximum durability" when destroyed is "permanently lost", logged in the Communinet Event Log as "...got destroyed and cannot be recovered due to being too damaged." The list shows a countdown as "{Hours}h {Minutes}m" and a "Recovery Cost" with a "Max Durability" line.

Numbers, with conflicts:
- Max-durability cost: 15% per recovery (wiki; community, pre-1.5, https://mein-mmo.de/en/dune-awakening-update-1-2-10-0-patch-notes,1530846/).
- Time window: 72 hours at launch in 1.2.10.0 (patch notes 1.2.10.0, pre-1.5, https://duneawakening.com/news/new-update-now-live-with-vehicle-recovery-system-and-more/). The wiki now says 30 days and only the latest 5 vehicles. The in-game timer is authoritative.
- Coriolis storm exception: vehicles destroyed by a Coriolis storm are recoverable from 5% durability (wiki); unverified.
- Solari cost per vehicle: a web summary reported Scout Ornithopter 2,500, Assault Ornithopter 3,000, Buggy 3,000, Sandcrawler 4,000, Carrier 5,000, but no primary source confirmed it; unverified. Sandbike and Treadwheel costs unknown. The keystone "Vehicle Recovery Cost Reduction" lowers it (game text).
- Only vehicles lost after the 1.2.10.0 patch were ever eligible (patch notes 1.2.10.0).

### Relocation

Relocation moves a vehicle that is on the current map, useful for vehicles stuck in terrain or left far away. Its cost appears as "Relocation Cost" (game text); the wiki says it matches the recovery cost. "Items in vehicle storage will not be relocated!" (game text); the wiki says the contents drop on the ground at the relocation site. Fails if someone is using the vehicle or it is still being assembled (game text).

## Parking, decay and storms

The tutorial is explicit (game text): an abandoned, unsheltered vehicle takes sandstorm damage and is eventually destroyed; "Vehicles parked outside your land claim will gradually decay over time, even if they are sheltered. For long-term parking, keeping them within your base is the best option."

The Vehicle Management console ("Manage Vehicle") shows status OK, Sheltered with a shelter percentage ("{state} - Shelter: {percentage}%"), Unsheltered, Critical, Disabled, Assembling or Wrecked (game text). Aim for Sheltered inside your own claim.

Practical parking (community, pre-1.5, Steam threads in Sources): build an enclosed garage inside your base with a Garage Door (several faction styles exist, game text). Rock overhangs shelter you but players report they don't stop vehicle decay outside a claim. One player reported a single sandstorm taking about 45% durability (community, pre-1.5); unverified.

Storm-related settings and perks (game text): the "Rider in the Storm" keystone reduces sandstorm damage to vehicles; admins can turn sandstorms off ("Sandstorms" setting); "Base Decay" covers bases, not vehicles. In the Deep Desert, Coriolis storms wipe the map; since 1.5.03.0 the Coriolis storm no longer instantly kills players (wiki, https://awakening.wiki/1.5.03.0). Vehicles left in the Deep Desert through a Coriolis storm should be assumed lost and recovered via the tool (unverified for 1.5).

Leaving a map: "Any vehicle left behind will be destroyed and can only be recovered using the Vehicle Backup Tool" (game text). You cannot return home or visit friends while in a vehicle (game text). Before a character transfer or base backup, store one vehicle in the tool and disassemble the rest into modules in base storage (game text).

## Sandworms

Open sand builds a vibration meter; when it turns red the worm is close (game text). Vehicles let you cross faster, but a caught vehicle is destroyed along with your items (game text), and it shows up in Recovery if eligible. An active personal shield on sand attracts worms much faster (game text). Drumsand attracts the worm and quicksand can kill (game text). The Treadwheel has reduced worm attraction (wiki) and Sandcrawler dampened treads lower vibration (game text), but "the sandworm will always come regardless" (game text). Admins control this with "Sandworms" and "Sandworm Vehicle Destruction" (game text). Exact vibration per vehicle: unverified.

## Research and crafting stations

- Research: Research menu, "Vehicles" category (game text). Assembly groups are listed in the roster table. Module upgrades and uniques come from the same tree or from loot/schematics; Plastanium modules need parts such as power regulators and hydraulic pistons "found in the Deep Desert, obtained from Landsraad rewards, or crafted in an Advanced Survival Fabricator" (game text).
- Crafting: "Vehicles Fabricator" for early parts and "Advanced Vehicle Fabricator" for "advanced vehicles like the Buggy or Ornithopter"; it must be near a Sub-Fief Console and powered (game text).
- Ids follow `<Vehicle><Module>_<tier>`, for example `SandbikeChassis_1`, `BuggyChassis_3`, `OrnithopterLightChassis_4` (scout), `OrnithopterMediumChassis_5` (assault), `OrnithopterTransportChassis_6` (carrier), `SandcrawlerChassis_6`, `TreadwheelChassis_4` (item data). Ids with a `D_` prefix (for example `D_SandcrawlerChassis_7`) correspond to the unused Mk7/scrap names (item data; purpose unverified).

## Vehicle-related skills and keystones (game text)

Vehicle Repair, Fuel Efficient Driver, Fuel Efficient Pilot, Vehicle Mining, Vehicle Scanning (skills); Superior Heat Dissipation, Vehicle Recovery Cost Reduction, Rider in the Storm, Vehicle Boost Heat Reduction, Expert Maneuvering (less damage while piloting), Superior Fuel Efficiency, Vehicle Mining Heat Reduction, Vehicular Mining Mastery, Vehicle Speed Bonus, Repair Master (keystones). Which skill tree holds each: unverified.

## Open questions

- Is build 25689360 the live 1.5.15.0? It adds the BattlEye launch choice that the 1.5.15.0 notes describe, so the 1.5.15.0 vehicle fixes are probably in it (unverified).
- Current recovery window (72 h vs 30 days) and per-vehicle Solari costs.
- Whether any station restores maximum durability on vehicle modules.

## Sources

- https://duneawakening.com/news/public-test-client-patch-1-5-15-0/ (2026-09-30)
- https://awakening.wiki/1.5.03.0 (1.5.03.0, 2026-09-17)
- https://jeu.video/en/article/dune-awakening-patch-notes-hotfix-1-5-3-1
- https://duneawakening.com/news/new-update-now-live-with-vehicle-recovery-system-and-more/ (1.2.10.0, 2025-10-07, pre-1.5)
- https://mein-mmo.de/en/dune-awakening-update-1-2-10-0-patch-notes,1530846/ (pre-1.5)
- https://awakening.wiki/Vehicle_Backup_Tool
- https://awakening.wiki/Vehicles
- https://awakening.wiki/Sandbike
- https://awakening.wiki/Treadwheel
- https://awakening.wiki/Buggy
- https://awakening.wiki/Scout_Ornithopter
- https://awakening.wiki/Assault_Ornithopter
- https://awakening.wiki/Carrier_Ornithopter
- https://awakening.wiki/Sandcrawler
- https://awakening.wiki/Welding_Torch
- https://awakening.wiki/Small_Vehicle_Fuel_Cell
- https://awakening.wiki/Medium_Sized_Vehicle_Fuel_Cell
- https://awakening.wiki/Large_Vehicle_Fuel_Cell
- https://game8.co/games/Dune-Awakening/archives/528213 (pre-1.5)
- https://game8.co/games/Dune-Awakening/archives/528441 (pre-1.5)
- https://gamerant.com/how-fix-repair-equipment-weapons-armor-gear-vehicles-dune-awakening/ (pre-1.5)
- https://steamcommunity.com/app/1172710/discussions/0/598529212470571632/ (2025-06, pre-1.5)
- https://steamcommunity.com/app/1172710/discussions/0/595153695607375938/ (2025-07, pre-1.5)
