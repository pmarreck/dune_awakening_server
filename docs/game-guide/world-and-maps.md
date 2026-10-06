# The world and its maps

Scope: the map structure of Arrakis, travel between maps, named locations and what they offer, PvP and security zones, environmental hazards, resources and enemies by region. Last researched: 2026-10-06, game 1.5.x (self-hosted server build 25689360; in-game text read from build 25610213).

Provenance tags: `(game text)` is the English string table extracted from build 25610213; `(verified on this server)` is this project's own map list and configuration docs; web sources carry their URL and, where the page showed one, its date. Pages dated before Update 1.5 (2026-09-17) are flagged "pre-1.5".

## Quick answers

| Question | Answer |
|---|---|
| Where's the nearest trading post? | Hagga Basin has four: Griffin's Reach (Hagga Basin South, the starter one), The Anvil (Vermillius Gap), Pinnacle Station (north-central, see the region note under Tradeposts) and The Crossroads (Mysa Tarill, farthest north) (game text; wiki, https://awakening.wiki/Tradeposts). All four are also respawn points (game text: `SPAWN_LOC_HaggaBasin_Tradepost_*`). Open the map and filter "Tradeposts". |
| How do I avoid sandworms? | Stay on rock. Cross open sand by the shortest line, don't linger, and keep vibration low (no sprinting, shields, suspensors or tools on the sand). The worm shows a warning breach before the kill. Get onto rock or climb high in an ornithopter when you see it. Avoid drumsand, which "will attract the worm" (game text). Details under Hazards. |
| What do I lose to a worm? | "Everything": backpack items cannot be recovered after a death to a sandworm or a Coriolis storm, and a vehicle you're using is destroyed (game text). On this server the admin can change this with `SandwormConsequences` (verified on this server, docs/operations.md). |
| What's in the Deep Desert? | An 81-sector grid (rows A to I, columns 1 to 9) north of the Shield Wall with the richest resources (titanium, stravidium, large spice fields), Imperial Testing Stations, shipwrecks and caves, 50% building cost, and a Coriolis storm that wipes and reshapes it (game text). On official servers it has PvE and PvP instances, with 2.5x yields in the PvP areas (patch notes 1.3.20.0). |
| Is there PvP in Hagga Basin? | Not on official servers since patch 1.3.20.0 (2026-04-28): "Hagga Basin is now fully PvE across the entire map, including the Shipwrecks" (patch notes). A self-hosted server can still choose "Limited" (Deep Desert plus "most shipwrecks in Hagga Basin") or "Full PvP" (game text, server settings). This server's PvP setting is not recorded in this repo: unverified. |
| How do I get to Arrakeen or Harko Village? | Pay an ornithopter pilot (taxi) at a tradepost, or fly your own ornithopter off the edge of Hagga Basin onto the Overland Map and pick the city (game text). Taxi cost was cut to 500 Solari to a social hub and 150 to a tradepost in 1.5 (patch notes 1.5.1.0 PTC). |
| Can I take my sandbike or buggy to another map? | No. Only flying vehicles travel between maps, and you can't travel with passengers or a harnessed vehicle (game text). Ground vehicles stay behind. |
| How much warning before a sandstorm? | On this server, about 40 seconds: a 10 s warning, then 30 s of buildup (verified on this server, docs/admin.md). Get indoors, into a cave, or into a stilltent. |
| When is the Coriolis storm? | On official servers, weekly on the Tuesday reset (times vary by region; community, https://game8.co/games/Dune-Awakening/archives/527339). On this server it is scheduled and announced 6 hours ahead with a 59-minute final stage (verified on this server, docs/admin.md). |
| How do I avoid sunstroke? | Stay in shadow. Sun fills a sunstroke bar; when full, Sunstroke raises dehydration (game text). |
| Where are the trainers? | Basic trainers are reached through tradeposts and fortresses; advanced ones are in the cities. See Trainers. |

## Map structure

Each region below is its own map server; you change maps through travel, not by walking (verified on this server, `data/maps.tsv`; game text). This server has 32 maps.

| Map (server name) | Player-facing name | What it is |
|---|---|---|
| Survival_1 | Hagga Basin | The persistent survival map and home map; "Region laid to waste by the war, partly sheltered by the Shield Wall" (game text). Always running on this server (verified on this server). |
| Overmap | Overland Map | The flight map between regions. It "represents the northern hemisphere of Arrakis"; movement costs fuel and time costs water (game text). |
| SH_Arrakeen | Arrakeen | Atreides capital, social hub, no combat (game text). |
| SH_HarkoVillage | Harko Village | "Harkonnen Center of Operations on Arrakis", social hub, no combat (game text). |
| DeepDesert_1 | The Deep Desert | Endgame open map; "Nothing survives the Coriolis Storm" (game text). |
| CB_Story_Hephaestus | The Wreck of the Hephaestus | Story map; "Burning remains of an Ixian freighter" (game text). |
| CB_Story_Ecolab_Carthag | Ruins of Old Carthag | Story map beneath the razed former Harkonnen capital (game text). |
| CB_Story_WaterFatManor | Water Shipper's Mansion | Story map; "High-security housing complex surrounded by dew fields, just outside Arrakeen" (game text). |
| Story_ProcesVerbal | (Chapter 2 story room) | Chapter 2 investigation map; player-facing name unverified. |
| DLC_Story_LostHarvest_EcolabA / EcolabB / ForgottenLab | Lost Harvest labs | Lost Harvest DLC labs; needs the DLC (verified on this server, docs/operations.md). See Story and dungeon maps. |
| Story_ArtOfKanly | Neo Carthag Arena | Chapter 3; "An illicit fighting arena located near the construction site of Neo Carthag" (game text). |
| CB_Dungeon_Hephaestus, CB_Dungeon_OldCarthag | Hephaestus and Old Carthag revisited | Chapter 3 dungeon versions (verified on this server, map paths `HephaestusRevisit`, `OldCarthagRevisit`). |
| Story_Faction_Outpost_Atre / _Hark | Arsunt Garrison | Faction story outposts, one per House (game text: both named "Arsunt Garrison"). |
| Story_HeighlinerDungeon | Fallen Light | "Secret lair of the smugglers, hidden in a fallen heighliner in the Deep Desert" (game text). |
| CB_Ecolab_Bronze_Green_* (5 maps) | Overland testing stations | Instanced Imperial Testing Stations reached from the Overland Map. Which number maps to which file is unverified. |
| CB_Overland_M_01, S_04, S_06, S_07, S_08 | Overland locations | Small instanced locations on the Overland Map; the file-to-name mapping is unverified. |
| CB_Story_BanditFortress01 | Probably The Broodworks | A bandit fortress map; The Broodworks is "A large, well-defended bandit stronghold located on the shieldwall" (game text). The match is unverified. |
| CB_Dungeon_ThePit | The Pit | Dungeon; its in-game name is still a placeholder ("PH_The Pit") in game text. |
| CB_Story_DestroyedZanovar | Arrakeen Spaceport | Chapter 4; game text names this map "Arrakeen Spaceport", "a way off of the planet Arrakis". |
| CB_Story_OrbitalMonitor | Sardaukar Orbital Bastion | Chapter 4 finale (game text). |

On this server every map except Hagga Basin starts on demand when the first player travels there and stops after 15 idle minutes by default. A first trip may take a little longer while the map server boots (verified on this server, docs/operations.md). Three small instanced rooms from Funcom's template are not served: a generic sietch room, the Paranoid's prayer room and the Glutton's dining room (verified on this server, docs/operations.md). The Hagga Basin entrances "The Paranoid's Contemplation Chamber" (O'odham) and "The Glutton's dining room" (Jabal Eifrit) (game text) may therefore not work on this server. That is untested.

### Overland Map destinations

Overland points of interest (game text, `OvermapHudPOI_*` and `Travel_MapName_*`): Hagga Basin, Arrakeen, Harko Village, Deep Desert, Wreck of the Hephaestus, Ruins of Old Carthag, Water Shipper's Mansion, Arrakeen Spaceport, Neo Carthag Arena, The Broodworks, Fallen Light, Ruins of Tsimpo ("A box-canyon village decimated during the war"), Wind Pass ("A windswept canyon village repurposed by the secretive Water Shippers"), The Old Quarry (Water Shipper quarry "on the outskirts of the Polar Sink"), Polar Sink, Wreck of the Tyche ("An irradiated shipwreck crashed inside the Shield Wall"), Smuggler's Run (a ground-vehicle course on a rock island), Blushing Cavern (bandit camps "atop a large cave of erythrite"), an abandoned former military outpost, Station 15, and five Imperial Testing Stations:

| Station | Theme (game text) |
|---|---|
| No. 136 | Fire: "fire-scorched earth" |
| No. 24 | Darkness: entrance "halfway hidden in the dark, unfinished construction" |
| No. 152 | Electricity: high Coriolis electromagnetic readings |
| No. 195 | Poison: vines and burnt elacca smell |
| No. 89 | Radiation: "High radiation readings" |

Polar Sink travel needs an ornithopter with a "polar-treated PSU" (game text; the string is still marked as a placeholder). Some Overland trips need "an active compatible Landsraad Mission" (game text). Free Trial accounts are limited to Hagga Basin (game text).

## Travel between maps

| Rule | Source |
|---|---|
| You need a flying vehicle, at least 50% fuel and at least 30% hydration to leave a map. | game text |
| Overland movement costs fuel; time spent on the Overland Map costs water. | game text |
| No passengers in your vehicle, no harnessed vehicle, and no travel while harnessing or deploying one. | game text |
| Ground vehicles can't use the Overland Map or leave a map's borders. | wiki, https://awakening.wiki/Ornithopter (2026-10-04) |
| In instanced locations "Your ornithopter will be inaccessible until you leave." | game text |
| A party member can invite you to leave in their vehicle. | game text |
| "Landing zones in destination are fully occupied" can block a trip. | game text |
| Taxi: tradepost thopter pilots fly to Arrakeen, Harko Village and other tradeposts for payment up front. | game text (journey "A Wider World") |
| Taxi prices: 500 Solari to a social hub, 150 to a tradepost. | patch notes 1.5.1.0 PTC, https://duneawakening.com/news/public-test-client-patch-1-5-1-0/ |
| The Deep Desert can only be exited "from the Shield Wall to the south". | game text |

Your personal inventory travels with you. Cargo carried in an ornithopter's storage modules also travels. Players commonly ferry Deep Desert loot home in a scout or assault ornithopter with storage, and the community figures are 500 and 1000 volume (community, pre-1.5, https://steamcommunity.com/app/1172710/discussions/0/595152363985064502/; capacities unverified for 1.5). A ground vehicle parked in Hagga Basin stays where you left it. Anything left in the Deep Desert is wiped by the Coriolis storm (game text). The Vehicle Backup Tool's recovery mode can restore a recently destroyed vehicle for Solari and maximum durability, but items in its inventory modules are lost (game text).

## Hagga Basin

About 8.1 by 8.1 km, roughly 65 km² (community, pre-1.5, https://game8.co/games/Dune-Awakening/archives/523470). Regions and their in-game subtitles (game text, `WORLD_REGION_NAMES_SURVIVAL1_*`):

| Region | Subtitle (controlling group) | Character, resources and notable places |
|---|---|---|
| Hagga Basin South | Scavenger Territory | Starting area. Copper ore, salvaged metal and plant fiber (community, pre-1.5). Griffin's Reach Tradepost, Wreck of the Alcyon, Imperial Testing Station No. 2, Chinara's Camp (planetologist trainer), Kaleff's Monument, Drugrunner's Rise, outposts such as Broken Stone Station, Sim's Jackpot, Threeway Outpost, Dewgap Gateway, Breaker Station, Hollow Arches, Keyhole Rock (game text). |
| Western / Eastern Vermillius Gap | Kirab Territory | "Iron-rich sands" (wiki, https://awakening.wiki/Hagga_Basin). The Anvil tradepost, Kirab Camp, the Ironworks mining rigs, Wreck of the Pallas, Wreck of the Actaeon, Testing Stations No. 197, 13 and 10, landmarks Mirzabah's Head, Table of the Gods and The Anomaly (game text). Reaching it from the south means a worm-exposed sand crossing; the game's own tip is "take the shortest path to safety" (game text). |
| Jabal Eifrit Al-gharb / Al-janub / Al-sharq | Slaver Territory | Rocky. Carbon ore (Al-janub) and mixed ores (community, pre-1.5). Hand of Khidr, Kant's Tower, Farhold, World's End, The Cells, Chains of Karak, Wreck of the Tisiphone, Testing Stations No. 76, 117 and 63, Devil's Eye Cavern (game text). |
| Hagga Rift | Contested Territory | A deep rift between Harkonnen and Atreides forces. Riftwatch (Harkonnen fortress), Pinnacle Station, seven CHOAM Mineral Extraction Facilities, Wreck of the Kytheria, The Weeping Chasm, The Red Maw, Testing Stations No. 23 and 29 (game text). Erythrite crystal lines the long tunnel that starts near Riftwatch and needs at least a Cutteray Mk2 (community, https://www.thegamer.com/dune-awakening-erythite-crystals-location-guide/). |
| Western / Eastern Shield Wall | Sandflies Territory | Mountains on the northern rim. Aluminum ore (community, pre-1.5). Helius Gate (Atreides fortress), Shield Wall Command, Ironwatch, the Comms outposts, Sietch Ta'lab, Sentinel City, Stoneheart Cave, Fangs of Maraqeb, Wreck of the Limos, Wreck of the Alecto, Testing Stations No. 142, 60 and 17 (game text). |
| Mysa Tarill | Maas Kharet Territory | The Crossroads Tradepost, Mysa Tarill, Ruined Landing Pad (game text). Basalt stone and diamond dust (community, pre-1.5). |
| The O'odham | Maas Kharet Territory | "Comparatively lush" (wiki). Agave seeds. Pyon villages (Stonestep, Rockwarren, Windsong, Mendek's Shithole), Kynes's Promise, The Beast's Claw (Harkonnen base), Testing Stations No. 163 and 71, The Paranoid's Contemplation Chamber (game text). |
| Sheol | No-man's Land | Irradiated southwest corner (wiki). Jasmium crystals form in irradiated pools inside rock outcrops (community, https://www.pcgamer.com/games/mmo/dune-awakening-jasmium-crystal-locations/). Edge of Acheron (Harkonnen fortress), Atreides and Harkonnen camps, Shaitan's Grotto, caves named Limbo, Lust, Greed, Wrath and Dis, Wrecks of the Ourea, Tartarus, Leto, Delphis and Euporia (game text). Bring radiation protection. |

Titanium ore and stravidium mass are Deep Desert resources and do not spawn in Hagga Basin (community, https://www.method.gg/dune-awakening/where-to-find-and-farm-stravidium-mass-and-titanium-ore-in-dune-awakening). Map filters for resources are Ores, Crystals, Foliage, Salvageable, Spice Field and Flour Sand (game text). Hagga Basin node locations move around at each Coriolis storm (wiki, https://awakening.wiki/Coriolis_Storms, 2026-09-05).

### Location types on the map

The map legend groups locations as Tradeposts, Outposts (enemy outposts), Camps, Caves, Shipwrecks, Imperial Testing Stations, Fortresses (Atreides or Harkonnen), Landmarks and Sietches (game text). Caves are good shelter from storms and sun. Imperial Testing Stations are Old Imperial facilities and the main source of Old Imperial components such as Advanced Servoks and Particle Capacitors; Hagga Basin has 13 numbered stations (wiki, https://awakening.wiki/Imperial_Testing_Stations, 2026-09-26). Shipwrecks are salvage sites.

### Tradeposts

All four offer a contract board, traders, house representatives, information on trainers, and ornithopter pilots. They also give "refuge during sandstorms" (wiki, https://awakening.wiki/Tradeposts, 2026-09-26; game text "Tradeposts are a good place to start looking for contracts or information about Basic Trainers").

| Tradepost | Region | Notes |
|---|---|---|
| Griffin's Reach | Hagga Basin South | First tradepost. Ghavouri (Trooper training lead), Myr Charki (wiki; game text for Ghavouri). |
| The Anvil | Eastern Vermillius Gap | Atreides and Harkonnen representatives, House Tseida representative, trader Tyg Rolsum, sandbike garage (wiki). |
| Pinnacle Station | Game text files it under Hagga Rift (`Survival_HaggaRift_PinnacleStation`); the community wiki places it in Jabal Eifrit Al-gharb | Arno (Swordmaster training lead) (game text). Tleilaxu trader (community, pre-1.5). |
| The Crossroads | Mysa Tarill | Farthest from the start; community guides say it stocks higher-end items (community, pre-1.5, https://game8.co/games/Dune-Awakening/archives/528207). |

### Trainers

| School | Basic training lead | Advanced trainer | Source |
|---|---|---|---|
| Trooper | Ghavouri, Griffin's Reach | Kara Valk, Arrakeen (Central Plaza Upper per wiki) | game text; wiki |
| Mentat | Samin Moro, Riftwatch | Zayn de Witte, Arrakeen | game text |
| Swordmaster | Arno, Pinnacle Station | Seron Varlin, Harko Village (Beast's Bend per wiki) | game text; wiki |
| Bene Gesserit | Sister Mesa, Helius Gate | Jocasta Cleo, Harko Village (The Baron's Eye per wiki) | game text; wiki |
| Planetologist | Derek Chinara, Chinara's Camp (Hagga Basin South) | | game text |

The game's map-marker keys file Kara Valk, Zayn de Witte, Seron Varlin and Jocasta Cleo under Hagga Basin regions, while the journey text sends you to the cities. Trust the journey text.

## Arrakeen and Harko Village

Both are social hubs under "KANLY - GUILD PEACE [NO COMBAT]" (game text).

**Arrakeen** is the "Battle-scarred capital of the Atreides, home for merchants and refugees alike" (game text). Districts: Central Plaza, The Warrens, CHOAM Exchange, Residency Approach, Imperial Consulate, The Salusan Bull tavern, Arrakeen Depot, Duncan's Dojo, Landsraad Services (game text). Services (wiki, https://awakening.wiki/Arrakeen, 2026-10-01): vehicle, weapon, scrap, water and Landsraad variant vendors, Shaffat's Clinic for recustomizing (name from game text), the Spacing Guild banker at the CHOAM Exchange, the Imperial tax agent at the Consulate, and Thufir Hawat (Atreides faction officer) at Residency Approach.

**Harko Village** is "Interim headquarters of the Harkonnens, and nexus of the Carthag slave trade" (game text). Districts: Spire Keep (taxi), New Court Way, The Baron's Eye, CHOAM Exchange, Imperial Consulate, Hannivar's tavern, Beast's Bend, Neo-Carthag Outskirts, Harko Terminus North and South, Spire Keep Terminus (game text). Services (wiki, https://awakening.wiki/Harko_Village, 2026-09-29): water, scrap, cosmetic and vehicle vendors, Landsraad vendors on upper New Court Way, banker at the CHOAM Exchange, Phrakk's Clinic for recustomizing, and ornithopter pilots at Spire Keep.

Since 1.5, "The Exchange now acts as a vendor with a large selection of items" (patch notes 1.5.1.0 PTC).

## The Deep Desert

| Topic | Detail | Source |
|---|---|---|
| Layout | Sector grid A1 to I9 (81 sectors). Rows A and B (the Shield Wall side) keep fixed points of interest; the rest changes each reset. | game text; wiki, https://awakening.wiki/Deep_Desert (2026-09-29) |
| PvE and PvP | Official worlds offer a PvE instance and a PvP instance, chosen on entry. In the PvP instance, PvP starts at the B row, outside the Shield Wall area, and PvP areas give 2.5x mining and harvesting yield. | patch notes 1.3.20.0, https://duneawakening.com/news/dune-awakening-1-3-20-0-patch-notes/ |
| Entering a PvP instance | "you will enter into a safe space on the Shield Wall, but as soon as you leave this area, you will be flagged for PvP." Dying in a PvP zone gives a respawn cooldown, or an immediate respawn at a start location. | game text |
| Weekly wipe | The Coriolis storm "will destroy everything in the Deep Desert and reshape it" and resets the fog of war. Get valuables out first. | game text |
| Building | Costs are 50% lower and demolishing refunds 100%. | game text |
| Resources | Titanium ore (rock outcrops, for example sector E9 near the wall), stravidium mass (denser farther from the wall), large spice fields. "Thermoelectric Cooler" parts come from the Deep Desert Shield Wall. | community, method.gg (URL in Sources); game text |
| Landmarks | Shield Wall caves (The Duke's Latrine, The Watchway, Hanuman's Grotto, The Sardaukar Promise and others), Imperial Testing Stations No. 185, 148, 37, 93, 186 and 217, ten wrecks (Hicetas, Eumenes, Hyperbatas, Archidamas III, Cycliadas, Dioedas, Xenophon, Proxenus, Orsippus, Stasanor), Execution Wall, plus random "Buried Testing Station", "Forgotten Cave" and "Unrecovered Shipwreck" markers. | game text |
| Enemies | Atreides and Harkonnen house troops and deserters (Landsraad kill targets). Grandfather worms appear only here. | game text; wiki, https://awakening.wiki/Sandworm |
| Landsraad modifier | One possible Landsraad effect drops all items, lootable by anyone, on defeat in Deep Desert PvP zones. | game text |

Whether this server separates PvE and PvP Deep Desert instances depends on its PvP mode, which this repo does not record: unverified.

## Security zones

The HUD shows the zone you're in (game text):

| Zone name | Meaning |
|---|---|
| KANLY - GUILD PEACE [NO COMBAT] | Towns and social hubs |
| KANLY - LIMITED WARFARE [PvE] | Normal PvE areas |
| KANLY - WAR OF ASSASSINS [PvP] | PvP areas |

A "Zone change in" countdown appears at a boundary (game text). Server-level PvP modes are No PvP, Limited (Deep Desert plus most Hagga Basin shipwrecks) and Full PvP (everywhere except settlements). Corpse looting by default is allowed for everyone only in PvP zones (game text). Official servers made all of Hagga Basin PvE in 1.3.20.0 (patch notes).

## Environmental hazards

### Sandworms

- Vibration attracts worms. Walking, ground vehicles, ornithopters near the sand, Holtzman shields and suspensors, cutterays and compactors, combat and thumpers all count (wiki, https://awakening.wiki/Sandworm, 2026-09-16).
- A threat meter goes from white through orange to red. At red the worm makes a warning breach, then there is a short grace period, then the kill if you are still on sand (wiki). The compass and map show a red "Sandworm Breach" marker (game text).
- Rock is safe. In an ornithopter, gain altitude, because low flight is still vulnerable (wiki). Crouch-walking makes less vibration than sprinting (community, https://www.thegamer.com/dune-awakening-traversal-tips-tricks/).
- The wiki gives 377.5 m as a figure for small Hagga Basin worms without saying what it measures (unverified). Deep Desert grandfather worms give only two breach steps before an engulfing attack (wiki).
- A thumper lures the worm away (game text map marker; community).
- Death by worm loses your whole backpack, and the vehicle is destroyed (game text). Worm riding does not exist (wiki).
- This server's admin can configure `SandwormConsequences` (All, Backpack, Default, None) and can pause worms server-wide (verified on this server, docs/operations.md and README).

### Sandstorms and Coriolis storms

- Sandstorms appear on the map as "Sandstorm" markers and are "dangerous, especially in the Deep Desert. Seek shelter" (game text). On this server they warn 10 s ahead and build up for 30 s, and they damage players, buildings, placeables and vehicles each tick (verified on this server, docs/admin.md). A stilltent lets you ride out a sandstorm in the open (game text).
- Coriolis storms "cover all of Arrakis" (game text). Communinet warns hours, then minutes ahead. Unshielded players get "seek shelter away from the Deep Desert" and "Seek shelter behind the shield wall". Base shields deactivate during the buildup (game text). In Hagga Basin the storm brings back fog of war over unsurveyed regions (game text) and moves resource nodes (wiki). On official servers it comes weekly on the Tuesday reset with 8 to 10 hours of buildup (community, https://game8.co/games/Dune-Awakening/archives/527339). On this server it is scheduled, warned 6 hours ahead with a 59-minute final stage, and harmless to players unless the admin enables `m_bCoriolisDoesDamage` (verified on this server, docs/admin.md). Whether the Deep Desert wipe still happens with damage off is unverified.

### Sun and heat

Sun exposure fills a sunstroke bar. Once it is full, Sunstroke raises the rate of hydration loss. "stick to the shadows" to avoid and remove it (game text). Hotter biomes drain hydration faster, and a better stillsuit counters that (game text). The skill attribute "Sun Tolerance" slows sunstroke buildup (game text).

### Sand hazards and spice blows

- Quicksand "can be fatal" and drumsand "will attract the worm"; both show on the map as hazard markers (game text). Scanners help spot them (game text). Western Vermillius Gap is known for quicksand (community, pre-1.5).
- Other map hazards are Fire, Poison, Radiation and Electricity (game text), common in testing stations and Sheol.
- Spice blows create spice fields. Harvest spice sand by hand or with a Static Compactor "before the Worm arrives" (game text). A spice field is a worm magnet, so plan an exit to rock.

## Enemy groups by area

| Area | Main hostiles | Source |
|---|---|---|
| Hagga Basin South | Scavengers (Thug, Cut-throat, Scrapper) | game text |
| Vermillius Gap | Kirab (Brute, Succor, bosses) | game text |
| Jabal Eifrit | Slavers (Trapper, Scorcher, Sawbones, Sniper) | game text |
| Hagga Rift | Harkonnen and Atreides forces, deserters | game text ("Contested Territory"); community |
| Shield Wall | Sandflies | game text |
| Mysa Tarill, The O'odham | Maas Kharet (Initiate, Fanatic, Oppressor, Priestess, Sniper) | game text |
| Sheol | No-man's land with House camps; enemies in radiation suits | game text; community, pre-1.5 |
| Testing stations | Varied: scavengers, deserters and others by contract | game text |
| Deep Desert | House troops, deserters, smugglers | game text |

## Story and dungeon maps

- **Wreck of the Hephaestus** and **Ruins of Old Carthag**: Chapter 1 and 2 story locations, revisited as dungeons in Chapter 3 (game text; verified on this server).
- **Water Shipper's Mansion**: story heist location near Arrakeen (game text).
- **Lost Harvest DLC**: starts with a distress call from the spice harvester Mithra. Reach the crash site "northwest of Griffin's Reach Tradepost" (Wreck of the Mithra, with Bridge and Engine entries), work for Keif Villari and Elara Tuek in Harko Village, and explore the forgotten labs. Completion unlocks the Treadwheel vehicle (game text). This server serves its three maps; players need the DLC (verified on this server).
- **Chapter 3**: Neo Carthag Arena (Art of Kanly), Arsunt Garrison faction outposts, Fallen Light (heighliner dungeon) (game text).
- **Chapter 4**: Arrakeen Spaceport (server map `CB_Story_DestroyedZanovar`) and the Sardaukar Orbital Bastion, from which "you can travel offworld" (game text).

## Sources

- Game text: `all-build25610213.tsv` string table (build 25610213), keys `NPCS_AND_WORLD/WORLD_MAP_*`, `WORLD_REGION_NAMES_*`, `UI/OvermapHudPOI_*`, `UI/Travel_*`, `UI/TravelFail_*`, `UI/SecurityZone_*`, `UI/ServerSetting_PvP*`, `PROGRESSION/Tutorial_*`, `PROGRESSION/JOURNEY_TRAINER_*`, `COMMUNINET/COMMUNINET_CORIOLIS*`.
- This server: `data/maps.tsv`, `docs/operations.md` ("Maps", "Gameplay settings"), `docs/admin.md` ("Storms").
- Patch notes 1.3.20.0 (2026-04-28): https://duneawakening.com/news/dune-awakening-1-3-20-0-patch-notes/
- Patch notes 1.5 console release (2026-09-17): https://duneawakening.com/news/dune-awakening-console-release-patch-notes/
- Public Test Client 1.5.1.0 (2026-08-13): https://duneawakening.com/news/public-test-client-patch-1-5-1-0/
- Public Test Client 1.5.15.0 (2026-09-30): https://duneawakening.com/news/public-test-client-patch-1-5-15-0/
- Wiki: https://awakening.wiki/Hagga_Basin (2026-09-26), https://awakening.wiki/Tradeposts (2026-09-26), https://awakening.wiki/Deep_Desert (2026-09-29), https://awakening.wiki/Arrakeen (2026-10-01), https://awakening.wiki/Harko_Village (2026-09-29), https://awakening.wiki/Sandworm (2026-09-16), https://awakening.wiki/Coriolis_Storms (2026-09-05), https://awakening.wiki/Imperial_Testing_Stations (2026-09-26), https://awakening.wiki/Ornithopter (2026-10-04)
- Community: https://game8.co/games/Dune-Awakening/archives/523470 (pre-1.5, 2025-06-30), https://game8.co/games/Dune-Awakening/archives/528207 (pre-1.5, 2025-07-02), https://game8.co/games/Dune-Awakening/archives/527339, https://boostroom.com/blog/dune-awakening-update-15-guide-new-endgame-progression-major-changes (2026-09-29), https://www.method.gg/dune-awakening/where-to-find-and-farm-stravidium-mass-and-titanium-ore-in-dune-awakening, https://www.thegamer.com/dune-awakening-erythite-crystals-location-guide/, https://www.pcgamer.com/games/mmo/dune-awakening-jasmium-crystal-locations/, https://www.thegamer.com/dune-awakening-traversal-tips-tricks/, https://steamcommunity.com/app/1172710/discussions/0/595152363985064502/ (pre-1.5, 2025-06-20)
