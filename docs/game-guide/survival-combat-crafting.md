# Survival, combat and crafting

Scope: staying alive on Arrakis (water, heat, stamina, health, spice, death), fighting (shields, weapons, armor, augments, enemies) and making things (gathering, refining, stations, schematics, durability, repair). Last researched: 2026-10-06, game 1.5.x (newest self-hosted server build 25689360). Game text was extracted from build 25610213.

Provenance tags: `(game text)` is the game's own English strings; `(item data)` is the server's item tables via `dune-awakening items find`; `(verified on this server)` was observed on this self-hosted world; patch notes, wiki and community sources carry their URL. Wiki recipe and capacity numbers come from awakening.wiki, a community wiki that mirrors game data; a few pages say "added 1.1.0" and may not reflect 1.5 cost changes, so treat costs as approximate.

## Quick answers

| Question | Short answer |
|---|---|
| How do I get water fast? | Early: drink from Dew Flowers (only up to one third of the hydration bar) and loot blood with the Improvised Blood Extractor into a Small Blood Sack, then drink it (costs max health) or put it in a Blood Purifier at your base (game text). Wear a stillsuit and drink its catchpockets. Later: Windtraps and cisterns at your base. Details in [Water](#water-and-hydration). |
| What happens to my stuff when I die? | Backpack items drop at your death location in a loot container marked on the map; equipped gear stays on you but loses durability. A sandworm (and on standard servers the Coriolis storm) takes everything (game text). The server removes the container once emptied or when it expires (verified on this server). See [Death](#death-and-what-you-drop). |
| How long does my death drop last? | Not stated in game text. Community reports say roughly 10 to 15 minutes, and dying again before you reach it loses the older drop (community, unverified). |
| How do I make steel? | Small Ore Refinery: 1 Iron Ingot + 4 Carbon Ore + 50 mL water makes 1 Steel Ingot; Medium uses 3 Carbon Ore, Large 2 (wiki). Carbon Ore needs a Cutteray Mk2 or better. |
| How do I make duraluminum? | Medium Ore Refinery: 1 Aluminum Ingot + 4 Jasmium Crystal + 500 mL water; Large uses 3 Jasmium (wiki). Aluminum Ingot itself is 7 Aluminum Ore + 200 mL (Medium) or 4 (Large). |
| How do I make plastanium? | Titanium Ore + 1 Stravidium Fiber + 1250 mL water in a Medium (6 ore) or Large (4 ore) Ore Refinery; Stravidium Fiber comes from 3 Stravidium Mass in a Medium Chemical Refinery (wiki). |
| How do I make melange? | Spice Sand + water in a Spice Refinery: 100 sand + 750 mL gives 1 melange + 5 residue in 180 s (wiki). Bigger refineries are more efficient. |
| How do I hurt a shielded enemy? | Stagger it (3-hit light combo or a parry), then use a heavy / slow blade attack; or use poison, fire, or concentrated fire to break the shield; disruptors are best at that (game text). |
| Why am I losing water so fast? | Sunstroke (the bar fills in direct sun and speeds dehydration), hot biomes, or a poor stillsuit (game text). Stand in shade. |
| How do I heal? | Healkits (Healkit, Mk2, Mk4, Mk6), crafted from Plant Fiber early on (game text). |
| How do I repair gear? | Repair Station at your base (research it in the Construction tab); vehicles use a Welding Torch. Each repair lowers maximum durability (game text). |

## Water and hydration

### The hydration bar

- Above one third hydration you get a bonus to maximum stamina, larger above two thirds. Below one third the bonus goes away; at zero you are **Dehydrated** and lose health until you drink (game text, tutorial "Water Discipline"). One guide puts the top bonus at up to 1.5x the stamina bar (community, https://game8.co/games/Dune-Awakening/archives/528206, dated June 2025, pre-1.5).
- Status lines: "You feel parched / thirsty / hydrated / refreshed / sated" (game text).
- Hold the drink key to drink; "Consume Water" is the action on containers (game text).
- A tradepost "Cup of Water" refills 100 mL of hydration when bought (game text).
- Time on the Overland Map costs water; movement there costs fuel (game text).
- Downed (DBNO) revive can fail with "Insufficient Water to Revive" (game text), so carry water when playing in a group.
- Server knob: "Dehydration Speed" (`ThirstMultiplier`) scales thirst (game text). This chapter does not know this server's value.

### Sources of water

| Source | How it works |
|---|---|
| Dew Flowers (hand) | Drink directly; caps at one third of your hydration, and too much causes nausea ("Dew limit reached") (game text). |
| Dew Reaper / Dew Scythe | Reaps dew from plants into a container; "most useful at dawn" (game text). Tiers seen in game text: Dew Reaper Mk2, Mk4, Mk6, Collapsible Dew Reaper Mk4 to Mk6, Dew Scythe Mk4, Mk6, plus uniques. Reaper Gloves (unique) raise yield (game text). |
| Blood | Improvised Blood Extractor (then Blood Extractor Mk2, Mk4, Mk6, and the unique Filter and Impure extractors) fills a blood sack from a corpse (game text). Drinking blood hydrates but "max health will suffer" (game text). Community figure: yield per body from about 1,000 mL (Improvised) to about 6,000 mL (Mk6) (community, https://www.mmojugg.com/news/dune-awakening-water-mechanic-stillsuit-introduction.html, unverified). |
| Blood Purifier / Improved Blood Purifier | Base machine (needs power) that turns deposited blood into drinkable water (game text). |
| Deathstill (Fremen / Advanced Fremen) | Base machine (needs power) that extracts water from a corpse you carry to it; shows extraction time and yield; needs free water storage (game text). |
| Stillsuit catchpockets | Stillsuits fill catchpockets while worn; drink from them to restore hydration (game text). |
| Windtrap / Large Windtrap | Base machine that collects water over time; needs a Filter; routes to cisterns or production (game text). |
| Cisterns | Water Cistern, Medium, Large, and Small/Medium Insulated Cistern store water; uninsulated storage shows an evaporation rate (game text). |

### Water containers

| Item (id) | Capacity | Notes |
|---|---|---|
| Literjon (`Literjon`) | 1,000 mL | Copper-tier; Fabricator or Survival Fabricator, 14 Copper Ingot + 2 Micro-Sandwich Fabric (wiki, https://awakening.wiki/Literjon). |
| Literjon Mk2 to Mk5 | unverified | Exist in item data; capacities not checked. |
| Literjon Mk6 | 20,000 mL | Volume 25 (community, https://duneawakening.wiki.fextralife.com/Literjon+Mk6 and https://dune.gaming.tools/items/literjon_t6). |
| Decaliterjon (`Decajon`) | 10,000 mL | Large and hard to carry (game text); capacity (community, game8 above). |
| Hajra Literjon Mk1 / Mk2 / Mk5 / Mk6 (Unique) | 1,500 / 1,750 / 2,500 / 3,000 mL | Lightweight (Mk6 is volume 2) (wiki, https://awakening.wiki/Hajra_Literjon_Mk5; community, https://dune.gaming.tools/items/highcapacityliterjon_06). Mk5 schematic drops at the Wreck of the Delphis and Wreck of the Euporia (wiki). |
| Dewpack (`D_Dewpack`) | unverified | Small water container (game text); the id's `D_` prefix suggests it is deprecated (item data). |

Item data gives each of Literjon, Decaliterjon and the blood sacks a stack size of 1 (`items find` shows the give floor of 10).

### Blood sacks

| Sack (id) | Capacity (wiki, https://awakening.wiki/Blood_Sacks) |
|---|---|
| Small Blood Sack (`Bloodsack_01`) | 3,000 mL |
| Medium Blood Sack | 9,000 mL |
| Large Blood Sack (`Bloodsack_03`) | 15,000 mL |
| Massive Blood Sack | 24,000 mL |
| Unique: Scipio's, Glutton's, Sinner's, Maas Kharet, The Baron's Bloodbag | 13,000 / 16,000 / 19,000 / 22,000 / 30,000 mL |

The 1.5 patch added Micro-Sandwich Fabric to the Massive Blood Sack and Baron's Bloodbag recipes (patch notes 1.5, https://duneawakening.com/news/dune-awakening-console-release-patch-notes/).

### Stillsuits

A stillsuit "mitigates hydration loss" and collects water in tube-accessed catchpockets (game text). Stillsuit tops cover both chest and leg slots (patch notes 1.5). Stats shown on items include Catchpocket Size, Heat Protection, Dehydration Capture and Armor Value (game text).

| Tier | Material | Sets (wiki, https://awakening.wiki/Stillsuits) |
|---|---|---|
| 1 | Copper | Scavenger, Hollower |
| 2 | Iron | Kirab, Menol's |
| 3 | Steel | Slaver, Kel's |
| 4 | Aluminum | Native, Shadrath's, Maraqeb, Shadow Hood |
| 5 | Duraluminum | Mercenary, Saturnine, Batigh, Shaded Hood |
| 6 | Plastanium | CHOAM, Imperial, Villari's, Pardot's Hood, Shaddam's Bladder |

Community database figures: catchpocket 500 on the tops listed; heat protection 0.3 (tier 1), 0.9 (tier 4), 1.2 (tier 5), 1.5 (tier 6) (community, https://dune.gaming.tools/items/stillsuit_choam_04_top and siblings; version not stated). The hoods (Shadow, Shaded, Pardot's) are uniques that "reduce the harm caused by direct sunlight" (game text). Hotter biomes drain hydration faster, and the game says to answer that with better stillsuits; the HUD shows "Heat Level" against your "Heat Protection" (game text).

## Heat and sun exposure

- Direct sun fills the **sunstroke** bar; once full, **Sunstroke** raises your dehydration rate. Stay in shadow to avoid and clear it (game text, tutorials "Sunstroke" and "Shadowplay").
- The status shows "Overheated" (game text). The skill "Sun Tolerance" slows sunstroke buildup (game text).
- Separate from sunstroke, biome heat tiers raise water loss; Heat Protection on stillsuits counters it (game text).
- "Travel by night" is the game's own advice (game text, loading tip).
- Server knobs: "Heat Buildup Speed" (0 disables) and "Cold Buildup" for night, shade and cold regions (game text). Cold, cryo and polar-cap strings are placeholders (`PH_`) in this build, so that content is not live (game text).
- Sandstorms: shelter (shown above the hydration bar) protects you (game text). Radiation zones need a Radiation Suit or Iodine Pill (game text).

## Stamina and climbing

- Climbing drains stamina; stamina recharges unless you sprint (game text). Hold forward against a surface to attach (game text).
- Dashing, attacking and blocking cost stamina; items show Dash, Attack, Block and Climbing stamina costs (game text). Light armor reduces dash cost; heavy armor does not (community, https://www.method.gg/dune-awakening/dune-awakening-best-armor-tier-list).
- A successful parry restores stamina: 10 for daggers, swords and dual blades in the 1.5 release notes (patch notes 1.5); the 1.5.1.0 test-client notes said 25 (patch notes PTC 1.5.1.0, https://duneawakening.com/news/public-test-client-patch-1-5-1-0/), so the live value is the release figure, 10.
- Hydration above one third raises maximum stamina; skills "Optimized Hydration" and "Desert Conditioning" affect hydrated and dehydrated stamina (game text).
- On this server, `PlayerStaminaDrain` (default 1.0) is set to 0.8, so stamina drains 20% slower than default (verified on this server).

## Health and healing

- Healkits "heal wounds and cleanse ongoing effects" (game text). Names: Healkit, Healkit Mk2, Healkit Mk4, Healkit Mk6 (game text). Early Healkits are crafted from Plant Fiber, which grows all over Arrakis (game text). Stack size 20 (wiki, https://awakening.wiki/Healkit). Use from the radial wheel, hotbar or inventory. There is no separate "bandage" item in 1.5 game text; older heal-over-time and stim items are marked "OLDDONOTUSE" (game text).
- Prescience (spice) increases passive healing (game text). Healing amounts per kit are not in game text (unverified).
- **Downed (DBNO)**: you can be revived, self-revive ("Try To Keep Going"), or "Surrender to the Desert" (game text). 1.5 extended invulnerability frames entering and leaving the downed state (patch notes 1.5).
- **Second Wind**: taking 40 health damage during Second Wind returns all stamina and frees you from the state (patch notes 1.5).
- A Spice Dream (story event) leaves you protected from harm for a short time after you wake (game text).

## Spice

- Spice Melange is refined from Spice Sand; it is "Addictive. Withdrawal leads to death." (game text). Item id `MelangeSpice`, stacks to 500; Spice Sand `SpiceSand` stacks to 2,500; Spice Residue stacks to 1,000 (item data).
- Eating or drinking spice items (Melange Spiced Beer, Wine, Food, Coffee, Liquor) or standing in spice fields builds toward the **Prescient** state (game text).
- Prescient: unlocks a third ability slot, reduces cooldowns, increases all damage and passive healing, gives poison tolerance and shows enemy info (game text). You cannot consume spice while Prescient.
- Afterwards comes **Withdrawal**, when you cannot consume spice, and your **Tolerance** rises, making Prescience harder to reach again; tolerance decays over time or you can push through with more spice (game text). The Status UI shows Spice Addiction Level (game text).
- Spice-infused gear: Unique items use **Spice-infused Copper / Iron / Steel / Aluminum / Duraluminum / Plastanium Dust** as a component, found in secure containers (game text). Spice-infused Fuel Cells power the spice generator (game text).
- Melange is used heavily in advanced fabricator recipes (wiki, https://awakening.wiki/Spice_Melange). 1.5 removed melange from the building cost of the Advanced fabricators, Medium Chemical Refinery and Augmentation Station (patch notes 1.5).

## Death and what you drop

- On death, backpack items drop where you died and can be recovered there; killed by a Sandworm (and, on standard servers, the Coriolis storm), you lose everything (game text). Sandworm death destroys the vehicle you were in (game text).
- The drop is a loot container that the server removes when emptied or when it expires (verified on this server). The map shows a "Death Location" marker (game text). Expiry time is not in game text; community reports say about 10 to 15 minutes and that a second death loses the earlier drop (community, https://steamcommunity.com/app/1172710/discussions/0/595152277706164115/, unverified).
- Durability: items lose durability on defeat (game text, "Durability Loss on Defeat" stat). 1.5 lowered the death penalty from 5% to 2% and halved equipment drain (Funcom announcement, https://duneawakening.com/news/announcement/the-new-dune-awakening-is-here/).
- Respawn: Respawn Beacons (one active at a time), home or authorized base, or vehicle respawn (game text). Respawning in a different world location loses all items on the character (game text). The menu "Respawn" option warns of item and durability loss (game text). PvP zones may impose a respawn cooldown (game text).
- Server knobs (game text): "Dropped on Death" (Everything / Backpack only / Default, which drops "some backpack content ... excluding critical items" / Nothing; not applied to sandworm deaths); "Lost On Sandworm Death" (Everything / Backpack only / Nothing); "Looting Player Corpses" (Everyone / Default, PvP zones only / Private). This chapter does not know this server's values.
- Wiki item pages list a "Dropped on death" flag per item: for example Duraluminum Ingot No, Spice Melange Yes, Healkit No (wiki).
- Vehicles: destroyed vehicles can be restored for Solari and some maximum durability with the Vehicle Backup Tool's Recovery mode (inventory modules are not recovered); up to 30 days (game text; announcement above).

## Combat

### Shields and the slow blade

- A Holtzman Shield must be toggled on; it blocks projectiles, drains power per deflection, and can short-circuit when overwhelmed. Firing a ranged weapon drops it briefly; it reactivates on its own (game text).
- Poison, fire and slow attacks pass through shields (game text). Fast melee can stagger but not damage a shielded target (game text).
- Against shields: stagger the target, then a heavy (slow blade) attack; or poison or fire; or concentrated fire to disable it; disruptors are best at breaking shields (game text).
- An active shield on open sand draws sandworms from hundreds of meters (game text). Suspensor belts use Holtzman fields and also anger worms (game text).
- 1.5: heavy melee attacks now do the same damage as shield-penetrating attacks; PvP shield damage reduced 33% (patch notes 1.5).

### Melee

- Light attacks are fast; three in a row stagger (game text). Heavy attacks are slow, break block and stagger (game text).
- Block; time it to the enemy's swing to parry, which staggers them and restores stamina. 1.5 widened the parry window from 0.25 to 0.33 s for swords, daggers and dual blades (patch notes 1.5). Dash out of a stagger (game text); 1.5 lets you dash through characters.
- Categories: Short Blades (daggers, slip-tips), Long Blades (swords, rapiers), Dual Blades (game text). 1.5 added Dual Blades and the Pyrocket and reworked the Rapier into a parrying weapon (announcement above).

### Ranged weapons and ammo

| Ammo (id) | Used by |
|---|---|
| Light Darts (`Ammo`, stack 1,000) | Pistols (Maula), rifles, scatterguns, disruptors (community, https://game8.co/games/Dune-Awakening/archives/528662) |
| Heavy Darts (`HeavyAmmo`, stack 1,000) | Some rifles and heavy weapons; pierce some armor (community, https://dune.gaming.tools/items/heavyammo) |
| Weapon-specific | Lasgun (energy), flamethrower, rocket and missile launchers (community, https://duneawakening.wiki.fextralife.com/Weapons) |

Item ids and stack sizes are item data. Named weapons in game text include Karpov 38 rifle (`HarkAr2`, verified on this server), Maula pistol, GRDA 44 and Drillshot FK7 scatterguns, Disruptor M11, JABAL Spitdart, Flamethrower, Lasgun, Vulcan GAU-92, Missile Launcher, Pyrocket. Lasguns are "slow to fire ... extremely powerful", and CHOAM lasguns have a shield-detection override (game text).

### Damage types

Blade, Concussive, Energy, Fire, Heavy Dart, Light Dart, Poison, Radiation buildup (game text). Armor shows a mitigation for each: Blade, Concussive, Dart, Light Dart, Heavy Dart, Energy, Explosive, Fire, Poison, Radiation, Sandstorm (Lv.1 to 3), Coriolis (game text).

### Armor classes

Game text has two armor categories, **Light Armor** and **Heavy Armor**, plus stillsuits (worn as armor and water gear) and social clothing. No "medium armor" category exists in 1.5 game text. Light armor trades armor for dash-stamina reduction and blade mitigation; heavy armor has higher armor and dart mitigation (community, https://www.method.gg/dune-awakening/dune-awakening-best-armor-tier-list). Each school (Bene Gesserit, Mentat, Planetologist, Swordmaster, Trooper) has its own armor set (announcement above). Materials follow the metal tiers: copper, iron, steel, aluminum, duraluminum, plastanium (game text).

### Augments and item grades

- Only Plastanium-tier (tier 6) Unique items can be augmented, at an Augmentation Station. Augments cannot be removed and reduce the item's maximum durability; the item needs enough durability to accept one (game text).
- Augment schematics come from overland dungeons after faction training; slot limits rise with "Augmentation Limit" traits (Garment, Melee, Ranged) in the Crafting specialization (game text). Recycling unwanted augment schematics gives Augmentation Schematic Patterns (game text).
- Plastanium Unique items and augments come in Grades 1 to 5; higher grades have better stats (game text). 1.5 made augment stat rolls a bell curve (better average, same maximum odds) and moved grade drops by dungeon difficulty: Grade 3 stops after difficulty 20, Grade 4 drops less from 27 (patch notes 1.5).

### Enemies and bosses

- Enemies scale by material tier (copper through plastanium); higher tiers dash more (patch notes 1.5). Types named in notes: rushers, assault, heavies, marksmen (patch notes 1.5). Factions include scavengers, Kirab, Sandflies, slavers, Maas Kharet cultists, Sardaukar (game text).
- 1.5 changes: assault enemies 15% less health, plastanium-tier melee about 20% less damage, low-tier rushers no lunge, suspensor grenade removed from most NPCs (patch notes 1.5).
- Dungeons: Imperial Testing Stations on the Overland map, including No. 89 (radiation), No. 136 (fire), No. 195 (poison), with difficulty scaling; 1.5 moved the old difficulty 20 scaling to 30 and reduced boss bonus health for 3 and 4 player groups (game text; patch notes 1.5). Bosses named by guides: Masano the Burned (136), Lieutenant Aman (89), Burrbridge (195), Doctor Jalanta (The Old Quarry) (community, https://www.method.gg/dune-awakening/testing-stations).
- Sandworms come to vibration on open sand and cannot be outrun; watch the vibration bar and stick to rock. Quicksand can kill; drumsand attracts the worm (game text).

## Gathering

| Tool | What it does |
|---|---|
| Cutteray | Mines ore and salvage, and cuts some doors. Analysis Mode shows weak lines; tracing them gives more yield. Needs a working Power Pack (game text). |
| Power Pack | Improvised, then Mk1 to Mk6, plus uniques (Accelerator, Purifier); recharges when you stop (game text). |
| Static Compactor | Harvests Flour Sand and Spice Sand, uncovers buried treasure after storms, and clears fire and poison clouds (game text). Variants: Static Compactor, Compact Compactor Mk3 to Mk6, Industrial, Omni (game text). |
| Scanners | Hand scanner reveals components, vehicles, bases and people; Handheld Resource Scanner, Handheld Life Scanner Mk3, Long Range Scanner (game text). Survey Probes reveal map areas (game text). |
| Dew Reaper / Blood Extractor | Water, see above. |

Cutteray tiers and what they can mine (wiki, https://awakening.wiki/Cutteray, edited 2026-08-29):

| Cutteray | Adds |
|---|---|
| Mk1 | Copper, Granite, Salvaged Metal, Iron |
| Mk2 | Carbon, Erythrite |
| Mk3 | Basalt, Aluminum |
| Mk4 | Jasmium |
| Mk5 | Titanium, Stravidium |
| Mk6 | all ores, at higher yields |

Uniques follow the same ladder (Sim's Cutter, Olef's Quickcutter, Callie's Breaker, Sandflies Carver, Tarl Cutteray, Kynes's Cutteray). Buggy-mounted Cutterays start at Mk3 (wiki).

Other raw materials: Plant Fiber (healkits), Salvaged Metal (small pieces picked up, wrecks need a Cutteray), Flour Sand (white dust clouds on open sand), Spice Sand (spice fields and blows; stay clear of an imminent blow), Fuel Cells from scavenger camps (game text).

## Resources and refining

Item ids (item data): Iron Ore `MagnetiteOre`, Copper Ore `AzuriteOre`, Aluminum Ore `BauxiteOre`, Carbon Ore `DolomiteRock`, Basalt Stone `Basalt`, Titanium Ore `T6ResourceA`, Stravidium Mass `T6ResourceB`, Stravidium Fiber `T6RefinedResourceB`, Jasmium Crystal `JasmiumCrystal`, Erythrite Crystal `ErythriteCrystal`, Copper Ingot `CopperBar`, Iron Ingot `IronBar`, Steel Ingot `SteelBar`, Aluminum Ingot `AluminiumBar`, Duraluminum Ingot `DuraluminumRod`, Plastanium Ingot `T6RefinedResourceA`, Silicone Block `Silicone`, Cobalt Paste `CobaltBar`, Flour Sand `FlourSand` (stack 1,000), Plant Fiber `PlantFiber`, Salvaged Metal `ScrapMetal`, Fuel Cell `Oil`, Water `WaterItem`. Ores and ingots stack to 500.

Recipes (wiki pages for each item on awakening.wiki; one ingot out unless noted):

| Output | Small refinery | Medium refinery | Large refinery |
|---|---|---|---|
| Copper Ingot | 4 Copper Ore, 5 s | 3 ore, 4 s | 2 ore, 3 s |
| Iron Ingot | 5 Iron Ore + 25 mL, 10 s | 4 ore, 7 s | 3 ore, 5 s |
| Steel Ingot | 1 Iron Ingot + 4 Carbon Ore + 50 mL, 5 s | 3 Carbon, 4 s | 2 Carbon, 3 s |
| Aluminum Ingot | not possible | 7 Aluminum Ore + 200 mL, 30 s | 4 ore, 20 s |
| Duraluminum Ingot | not possible | 1 Aluminum Ingot + 4 Jasmium + 500 mL, 5 s | 3 Jasmium, 4 s |
| Plastanium Ingot | not possible | 6 Titanium Ore + 1 Stravidium Fiber + 1,250 mL, 30 s | 4 Titanium, 20 s |
| Silicone Block (chemical) | 5 Flour Sand + 50 mL, 15 s | 3 Flour Sand, 10 s | n/a |
| Cobalt Paste (chemical) | 3 Erythrite + 75 mL, 15 s | 2 Erythrite, 10 s | n/a |
| Stravidium Fiber (chemical) | n/a | 3 Stravidium Mass + 100 mL, 10 s | n/a |
| Spice Melange (spice) | 100 Spice Sand + 750 mL: 1 melange + 5 residue, 180 s | 750 sand + 7,000 mL: 10 + 75 residue, 450 s | 10,000 sand + 75,000 mL: 200 + 1,000 residue, 2,700 s |

Game text agrees on the station roles: Small Ore Refinery does copper, carbon and iron and makes steel from iron and carbon; the Medium Ore Refinery makes aluminum and duraluminum ingots "from raw Aluminum and Jasmium ore"; the Small Chemical Refinery makes cobalt, silicone and fuel cell packs; refineries "require significant amounts of water" (game text). 1.5 reduced component costs 10 to 25% for aluminum through plastanium tiers (patch notes 1.5), so wiki numbers tagged 1.1.0 may be stale. A Landsraad decree, "CHOAM Refining Contract", cuts repair costs and refining times by 75% while active (game text).

## Crafting stations and tiers

Personal crafting (menu) makes basics; fabricators need power and a Sub-Fief Console nearby; constructing uses the Construction Tool (game text). Completed fabricator orders go to the fabricator's storage (game text).

| Station | Role (game text) |
|---|---|
| Fabricator, Portable Fabricator, Construction Fabricator | Basic items |
| Survival / Weapons / Garment / Vehicles Fabricator | Tiered specialist fabricators |
| Advanced Survival / Weapons / Garment / Vehicle Fabricator | Advanced tiers (survival, exploration, mining; weapons; stillsuits and armor; buggies and ornithopters) |
| Small / Medium / Large Ore Refinery | Ingots |
| Small / Medium Chemical Refinery | Silicone, cobalt, fuel, stravidium fiber |
| Spice / Medium / Large Spice Refinery | Melange |
| Blood Purifier, Improved Blood Purifier, Fremen and Advanced Fremen Deathstill | Water |
| Repair Station, Recycler, Augmentation Station | Upkeep, salvage, augments |
| Fuel-Powered Generator, spice generator, wind turbines | Base power |

Material tiers run copper (1), iron (2), steel (3), aluminum (4), duraluminum (5), plastanium (6) (game text: item descriptions and the stillsuit tiers).

## Schematics, Imperial Permits and unique items

- Designs are researched with **Intel** in the Research menu; Intel comes from leveling and from enemy outposts (game text).
- **Unique** items need **Imperial Permits**, one per craft. Using a found Schematic adds permits for that item (sometimes double), and permits can also be bought with Intel (game text). Researching a schematic requires being watersealed at a base, city or tradepost (game text).
- Specialized components for an item share its color and map marker: green markers (shipwrecks) for weapon and armor parts, blue (testing stations) for vehicle and tech parts, orange (moisture-sealed caves) for hydration and gathering gear (game text).

## Quality, durability and repair

- Items lose durability with use and on defeat; broken items cannot be used (game text). Vehicle module condition reads Pristine, Perfect, Excellent, Good, Bad, Critical, Wrecked (game text).
- **Repair Station** (base, powered) restores durability using materials and the item's schematic; "Each time an item is repaired its maximum durability decreases" and an item can end "Broken beyond repair" (game text). Some items must be repaired with a welding torch; vehicles are repaired with a Welding Torch and welding wire (game text).
- **Recycler** breaks items into a portion of their materials, more for better-condition items (game text).
- Skills: Garment Keeper, Field Maintenance, Gunsmith reduce durability loss (game text).
- Server knob: "Durability Wear Speed" (0 disables durability) (game text).

## Sources

- Game strings, build 25610213 (`ST_Localization_*` tables: Progression tutorials, UI, Items, Buildings, Abilities).
- Item data: `bin/dune-awakening items find`, this repository; `docs/admin.md`.
- Funcom, Update 1.5 / console release patch notes, 2026-09-17: https://duneawakening.com/news/dune-awakening-console-release-patch-notes/
- Funcom, "The new Dune: Awakening is here" (1.5 overview): https://duneawakening.com/news/announcement/the-new-dune-awakening-is-here/
- Funcom, Public Test Client patch 1.5.1.0, 2026-08-13: https://duneawakening.com/news/public-test-client-patch-1-5-1-0/
- awakening.wiki: Literjon, Hajra Literjon Mk5, Blood Sacks, Stillsuits, Healkit, Cutteray, Copper / Iron / Steel / Aluminum / Duraluminum / Plastanium Ingot, Stravidium Fiber, Silicone Block, Cobalt Paste, Spice Melange (pages at https://awakening.wiki/<Page_Name>, fetched 2026-10-06).
- dune.gaming.tools item database (stillsuit stats, Literjon Mk6, Hajra Literjon Mk6, Heavy Darts), fetched via search, version not stated.
- Fextralife wiki: https://duneawakening.wiki.fextralife.com/Literjon+Mk6 and /Weapons.
- game8 hydration guide (June 2025, pre-1.5): https://game8.co/games/Dune-Awakening/archives/528206 ; light darts: https://game8.co/games/Dune-Awakening/archives/528662
- method.gg armor tier list and testing stations: https://www.method.gg/dune-awakening/dune-awakening-best-armor-tier-list , https://www.method.gg/dune-awakening/testing-stations
- MMOJUGG water guide (blood extractor yields, unverified): https://www.mmojugg.com/news/dune-awakening-water-mechanic-stillsuit-introduction.html
- Steam discussion on death backpacks: https://steamcommunity.com/app/1172710/discussions/0/595152277706164115/
