# Bases and building

Scope: land claims, consoles, building sets, utilities (power, water, storage, crafting stations), upkeep and decay, moving and storing bases, permissions and where you may build. Last researched: 2026-10-06, game 1.5.x.

Provenance tags: `(game text)` is the English string table from server build 25610213; `(item data)` is this project's `items find`; `(verified on this server)` comes from this project's admin notes; web sources are named with their URL. Wiki pages that say "added in v1.1.0" describe launch-era stats that may have been rebalanced since; treat their numbers as approximate.

## Quick answers

| Question | Short answer |
|---|---|
| How do I start a base? | Craft a Construction Tool, then place a Sub-Fief Console with it. The tool "can only be used on land claimed using a Sub-fief console" (game text). Without a console you get "Place a Sub-fief Console first" (game text). |
| Why can't I build taller? | Every claim is a box with a ceiling. The plain Sub-Fief Console reaches only about 13.8 m above the console and cannot be extended (verified on this server). Build an Advanced Sub-Fief Console and raise it with Vertical Staking Units, up to about 130 m above its origin at level 6 (verified on this server). The failure message is "Exceeds maximum building height" (game text), and at the top of the advanced console it is "Maximum height reached" (game text). |
| Why can't I make my claim bigger? | "Only Advanced Sub-fief Consoles can be extended" (game text). Use Staking Units (horizontal) and Vertical Staking Units on an advanced console. |
| How many bases can I have? | Three claims, of which at most two can be the small Sub-Fief Console (official blog, 2025; wiki). Self-hosted and single-player worlds can change this with the "Maximum Sub-fief Amount" setting (game text; 1.5 announcement). |
| Do I still pay base taxes? | No. Taxation was disabled in Chapter 3 (patch 1.3.0.0, 2026-02-03) and overdue taxes were forgiven (patch notes). Tax strings still exist in the game text but the system is off. |
| What keeps my base alive? | Power. A powered console projects a shield; without it sandstorms slowly wear the base down (game text; Funcom help center). |
| How do I build a garage? | Every major building set has a Garage Door piece (game text), and Large Garage Doors were added to the CHOAM Facility, Atreides and Harkonnen sets in Chapter 3 (patch notes 1.3.0.0). A vehicle is safe when it is parked inside your claim and shows as sheltered; see "Garages and vehicle shelter". |
| How do I move my base? | Use the Base Reconstruction Tool to back the base up, then place it elsewhere. It stores up to three bases (1.5 announcement). In Hagga Basin South there is no re-placement cooldown; elsewhere a placed backup gets a 7-day cooldown (game text; patch notes 1.5.1.0). |
| How do I copy a design? | The Solido Replicator stores a blueprint of a base and places it as a projection that you then fill with the Construction Tool (game text). |
| How do I get my materials back from an old base? | Back it up, then recycle it from the Base Reconstruction Tool: 100% of construction materials and stored items go to a "Reserve" inventory reachable from any Sub-Fief Console or storage container (game text; patch 1.3.15.0). Not available for Deep Desert bases (1.5 announcement). |
| How do I let a friend build? | Add them in the Sub-Fief Console's permissions list and give them a role with Base Builder access (game text). |
| Can I build on sand? | No: "Cannot build in desert" and "Cannot build on quicksand" (game text). Anything resting on open sand also risks sandworms (Funcom help center). |
| Can I build in the Deep Desert? | Yes, at half cost with a full refund on demolish (game text), but the weekly Coriolis storm wipes it on official worlds and the PvP instance allows raids (official blog; 1.5 announcement). |

## Land claims

### The two consoles

| | Sub-Fief Console | Advanced Sub-Fief Console |
|---|---|---|
| Item id | `Totem_Small_Patent` (item data); placed as `Totem_Small_Placeable` (verified on this server) | `Totem_Patent`, in-game name "Advanced Sub-Fief" (item data); placed as `Totem_Placeable` |
| Claim width | 30.6 m (verified on this server) | 53.8 m at level 1, plus staking-unit sections (verified on this server). The wiki describes it as 10×10 foundations (wiki, https://awakening.wiki/Advanced_Sub-Fief_Console). |
| Vertical range | 12.8 m below to 17.92 m above the claim origin, about 13.8 m above the console itself (verified on this server) | Level 1: 23.04 m below, 28.16 m above. Each level adds 15.36 m below and 20.48 m above; level 6 (max) is 99.84 m below and 130.56 m above (verified on this server) |
| Extendable | No (game text) | Yes, "further expanded with staking units" (game text) |
| Power draw | 15 (wiki, https://awakening.wiki/Sub-Fief_Console) | 15 (wiki) |
| Health | 1250 (wiki) | 2500 (wiki) |
| Unlock | Starting kit ("Basic Construction Kit", game text) | "Advanced Construction Kit" in the research tree (game text name). One guide puts it at 2 Intel under Construction (community, https://www.method.gg/dune-awakening/all-building-sets-in-dune-awakening-how-to-unlock-them, 2025, possibly outdated). |

The game's in-world description says the plain console "claims a piece of land to build on" and can "generate a shield that will protect a base from damage when powered by a generator placed nearby" (game text). There is also a "Survival Sub-Fief Console" string (game text, `TOTEMTEMPORARY_PLACEABLE`); where it appears in play is unverified.

### Placing the console

- The console is the base's control center: permissions, storage and power distribution are managed there, and you can change its elevation and rotation while placing it (game text).
- Its height matters. The claim box is measured from the claim origin, so placing the console low on a slope gives you less room above it (verified on this server, inferred from the claim data).
- Claims cannot overlap other bases, NPC sites, Imperial Testing Stations or trading posts (official blog, https://duneawakening.com/news/building-in-dune-awakening-claim-your-piece-of-arrakis/, 2025).
- Since 1.5.15 (on the Public Test Client, 2026-09-30) placing a console over part of an existing base shows how many pieces fall outside the claim (patch notes 1.5.15.0, https://duneawakening.com/news/public-test-client-patch-1-5-15-0/). Whether that build is live on this server is unverified.
- Since Chapter 3 you can pick up the console from anywhere inside the claim by holding a button in the Move mode (patch notes 1.3.0.0, https://duneawakening.com/news/dune-awakening-chapter-3-patch-notes/).
- The tutorial suggests moving the console to a sheltered spot (game text: "Move your Sub-fief Console to a sheltered location"). Enclosing it is also Funcom's advice (Funcom help center).

### Staking units (extensions)

- Two items: Staking Unit (`StakingUnit`) and Vertical Staking Unit (`StakingUnitVertical`) (item data). The research entry is the "Staking Unit Set", "crafted in a Survival Fabricator and built with the Construction Tool" (game text).
- A horizontal unit stakes another section of land onto the existing claim; you must place it inside your claim (game text: "Place inside your landclaim"). A vertical unit raises the whole claim by one level (game text: "Extend Sub-fief with vertical staking unit"; verified on this server for the per-level heights).
- Vertical levels stop at 6, so five vertical units on top of level 1 (verified on this server). Horizontal limits are disputed: one source says 5 horizontal and 5 vertical (community, https://www.thegamer.com/dune-awakening-bases-sub-feifs-how-many-can-you-have-guide/), another reports 8 combined (community, https://gamerant.com/dune-awakening-how-expand-base-increase-max-size/, 2025). Treat both as unverified. Server owners can change the cap with "Fief Expansion Limit" (game text).
- Recipe reported in 2025: 15 Steel Ingots and 15,000 Solari, after researching the set for 10 Intel; placing one starts a 4-minute timer (community, gamerant URL above; possibly outdated).

### How many bases

- Three claims per player, at most two of them small consoles (official blog 2025; wiki, https://awakening.wiki/Sub-Fief_Console). The failure messages are "Maximum number of Sub-fief Consoles reached" and "Maximum number of Sub-fief Consoles reached in this map" (game text), so there is also a per-map cap; its value is unverified.
- Self-hosted and single-player worlds can change "Maximum Sub-fief Amount" and "Building Size Limit" (piece count per category per fief) (game text; 1.5 announcement, https://duneawakening.com/news/announcement/the-new-dune-awakening-is-here/). Per-category limits show up as "Reached building limit for this category" (game text).
- A skill placeholder "Increased Subfief limit" exists in the text but is marked placeholder ("PH_") (game text); treat it as unused.

### Abandoning a base

Hover the base marker on the map and use the remote-destroy prompt; only the owner can do this (game text). Owners and co-owners can also demolish the console in person (Funcom help center, https://funcom.helpshift.com/hc/en/4-dune-awakening/faq/71-lost-base-and-how-to-keep-it-safe/). Consider recycling first, since that returns everything.

## Building pieces, placeables and the Construction Tool

- The Construction Tool has five modes: Build, Piece Picker, Repair, Move and Demolish (game text). Its menu switches between Placeables, Decorations and Building Sets, and a Favorites tab holds up to 20 entries (game text).
- Building pieces are the structural kit of a set (foundations, walls, floors, roofs, stairs, doors). Placeables are functional or decorative objects (generators, fabricators, refineries, storage, furniture), most described as "Place close to a Sub-Fief Console with the Construction Tool" (game text).
- Projections (holograms) are only visible with the Construction Tool equipped, and any player on your team can see and fill them (game text).
- Stability: pieces need support. Messages include "Insufficient stability", "Not enough support", "No Valid Stable Connection" and "Foundation beneath terrain surface" (game text). A piece that loses support is destroyed and logged as "destroyed due to a lack of structural stability" (game text). Servers can switch stability off with "Building Stability" (game text).
- Other common refusals: "Uneven ground", "Cannot be placed at this angle", "Placement blocked by Character", "Buildable not unlocked", "Remove objects on top first", "Move further inside land claim" (game text).
- Since 1.5.15 placeables can no longer be put above the building height limit, and their info card states their shelter requirement (patch notes 1.5.15.0).
- Swatches (colors) apply to placeables and buildings; Atreides and Harkonnen swatches come at faction rank 10 (patch notes 1.3.0.0). Placeables and containers can be renamed (1.5 announcement).

## Building sets

| Set (in-game name) | How you get it | Notes |
|---|---|---|
| Starting set / CHOAM Shelter Set | Available from the start ("Starting Set Patent", "CHOAM Shelter Set", game text) | Basic CHOAM pieces (official blog 2025). |
| CHOAM Facility Set | Research: Advanced Construction Kit (community, method.gg 2025) | Gained Large Garage Doors in Chapter 3 (patch notes 1.3.0.0). |
| Atreides Building Set | Faction vendor; a 2025 guide lists faction level 2 and 80,000 Solari, double that from the opposing faction's vendor (community, method.gg 2025) | Faction systems were reworked in Chapter 3, so the rank and price may be outdated. |
| Harkonnen Building Set | Same pattern as Atreides (community, method.gg 2025) | Same caveat. |
| Faction furniture and light sets (Atreides, Harkonnen, CHOAM) | Vendors; 2025 guide lists faction levels 2 to 5 (community, method.gg 2025) | Possibly outdated. |
| Smuggler Building Set and Smuggler Placeables Set | Raiders of the Broken Lands DLC (Chapter 3) (community, https://www.techpowerup.com/345935/dune-awakening-chapter-3-dlc-now-available) | Reported 74 pieces and 17 decorations; its Garage Door was mislabeled "Wide Door" until 1.5.15 (patch notes 1.5.15.0). |
| Water Shipper Building Set and Water Shipper Placeable Set | The Water Wars DLC, added in 1.4.0.0 (wiki, https://awakening.wiki/Water_Shipper_Building_Set) | 52 pieces; most cost Granite Stone, the garage door 30 (wiki). Players report the foundation is permeable to sand (community, Steam discussion title). |
| Sardaukar building set and Sardaukar Decoration Set | Filmic Archive DLC, released 2026-09-22 (Funcom on X; patch notes 1.5) | 73 pieces and 17 decorations; 1.5 added mirrored versions of asymmetric pieces and a missing Corner Column (patch notes, https://duneawakening.com/news/dune-awakening-console-release-patch-notes/). The set's own name string is still a placeholder in build 25610213 (game text). |
| Landing Pad Building Set | Unverified. Its key carries the MTX (store/reward) prefix (game text) and the wiki lists a vendor price of 2500 (wiki, via search snippet) | Pieces: Floor, Floor Corner, Wall Support, Triangle Wall Support (game text). |
| Observer Building Set | Twitch drop rewards in 2025 (community, method.gg); its Hatch and Door are now sold by decor vendors (patch notes 1.3.0.0) | |
| Sentinel, Desert Mechanic, Jail sets | Event, DLC or vendor rewards (game text names; community) | Desert Mechanic decorations were added to the structure vendor in 1.1.20.0 (community search result). |
| Pentashields (horizontal and vertical) | Research "Pentashield Set" (game text) | Passable only with a matching Wristband Key (game text). |

"Duneman" appears in the game text only for armor, a sandbike scanner and a Garage Door piece (`DUNEMAN_GARAGE_DOOR_PLACEABLE`); no Duneman building-set patent exists in build 25610213 (game text). Ask before assuming the player means a full set.

## Garages and vehicle shelter

- Garage Door pieces exist for the Water Shipper, Duneman, Harkonnen, CHOAM, Atreides, Smuggler and Sardaukar styles (game text). Large Garage Doors were added to CHOAM Facility, Atreides and Harkonnen in Chapter 3 (patch notes 1.3.0.0).
- An unsheltered vehicle takes sandstorm damage, and vehicles parked outside your claim decay over time "even if they are sheltered"; the game recommends keeping them inside your base (game text). The vehicle console shows "Unsheltered" / "At Risk" (game text).
- Co-owned vehicles no longer decay inside a friendly claim (patch notes 1.3.0.0). 1.5 and 1.5.15 fixed cases where sheltered vehicles still took environmental damage (patch notes 1.5; 1.5.15.0).
- Ornithopters: players roof over a landing pad so the thopter counts as sheltered (community search result; unverified mechanics).
- The Vehicle Backup Tool can store a vehicle, recover a recently destroyed one for Solari and durability, and relocate one on the same map; recovery works only in PvE areas or inside your own claim (game text; patch notes 1.3.0.0; 1.5 announcement says recovery for up to 30 days).

## Power

Most base machines need power from the base's circuit; the console overview shows Power Generated, Power Usage and states "CIRCUIT STABLE", "CIRCUIT OVERLOAD IMMINENT" and "CIRCUIT OVERLOADED" (game text). Bases have up to five named circuits (game text: "Circuit 1" to "Circuit 5").

| Generator | Fuel | Output | Notes |
|---|---|---|---|
| Fuel-Powered Generator | Fuel Cells, added to base storage first (game text) | 75 (wiki, https://awakening.wiki/Fuel-Powered_Generator) | |
| Wind Turbine Omnidirectional | Lubricant (game text); 1 hour per unit (wiki) | 150 (wiki, https://awakening.wiki/Wind_Turbine_Omnidirectional) | One guide says 75 (community, thegamer); the wiki figure is used here. |
| Windturbine Directional | Lubricant (game text); 1.5 hours per unit (wiki) | 350 (wiki, https://awakening.wiki/Wind_Turbine_Directional) | Needs an unsheltered spot (wiki). |
| Spice Generator ("Spice-Powered Generator") | Spice-Infused Fuel Cells (game text); 1.5 hours per cell (wiki) | 1000 (wiki, https://awakening.wiki/Spice-Powered_Generator) | |

There are no solar generators in build 25610213: no solar placeable string exists (game text). Server owners can stretch fuel with "Fuel Efficiency" (game text). 1.5.15 fixed offline simulation burning more fuel than intended (patch notes 1.5.15.0).

The console warns "Your base … is running out of power in {TimeLeft} and risks being destroyed!" (game text).

## Water

Water moves through the base's water circuit, not pipes; there are no pipe pieces in the game text. Cisterns store water that "can be utilized in the operation of multiple base production units" (game text).

| Placeable | What it does | Data |
|---|---|---|
| Windtrap | Collects water over time; needs a Filter (game text) and an unsheltered spot | 0.75 water per tick, 75 power, filters last 3 h or 8 h (wiki, https://awakening.wiki/Windtrap; units unclear) |
| Large Windtrap | Collects "a lot of water" (game text) | 1.75 per tick, 135 power, 500 internal storage (wiki, https://awakening.wiki/Large_Windtrap) |
| Blood Purifier / Improved Blood Purifier | Turns blood from a Blood Sack into water; needs power (game text) | |
| Fremen Deathstill / Advanced Fremen Deathstill | Extracts water from a corpse; needs power (game text) | |
| Water Cistern, Medium, Large; Small and Medium Insulated Water Cisterns | Storage. Plain cisterns are "Fragile"; insulated ones are sturdier (game text) | Large Water Cistern holds 100,000 (wiki, https://awakening.wiki/Large_Water_Cistern) |

Water circuits show an "Evaporation Rate" (game text). "Dew collectors" are not base placeables; dew is gathered by hand with a Dew Reaper into a literjon (game text). 1.5.15 fixed offline water generation being too high or too low (patch notes 1.5.15.0).

## Storage

Chest, Small Storage Container, Medium Storage Container and Storage Container are linked to the base by "storage circuits", so crafting stations can draw from them (game text). The Medium Storage Container's volume rose from 3500 to 4000 in 1.5 (patch notes 1.5). The wiki lists the Storage Container at 45 slots and 1750 volume (wiki, https://awakening.wiki/Storage_Container; launch-era figure).

## Crafting stations

| Station | Role (game text) |
|---|---|
| Fabricator | General crafting; needs power. Crafts the Base Reconstruction Tool (wiki). |
| Survival, Weapons, Garment (Wearables), Vehicle Fabricators and their Advanced versions | Specialized gear; need power. Since 1.5 the four advanced fabricators no longer cost Spice Melange to build (patch notes 1.5). |
| Small Ore Refinery | Copper, Carbon, Iron into refined resources; Steel from Iron and Carbon. |
| Medium Ore Refinery | Aluminum and Duraluminum ingots. |
| Large Ore Refinery | High-end ingots with better yields. |
| Small Chemical Refinery | Cobalt Ingots, Silicone Blocks, Fuel Cell Packs; needs power. |
| Medium Chemical Refinery | Better efficiency; no Spice Melange build cost since 1.5 (patch notes 1.5). |
| Small, Medium and Large Spice Refineries | Spice Sand into Spice Melange; the large one is the most efficient. |
| Recycler | Breaks items down for part of their materials, based on condition. |
| Repair Station | Restores durability, lowering maximum durability each time. |
| Modding Station, Augmentation Station | Item attachments; augmentations on Plastanium-tier uniques. |

## Upkeep, taxes and decay

- Taxes: disabled since patch 1.3.0.0 (2026-02-03), including the console UI, the city NPC dialogue and the journey; overdue amounts were forgiven (patch notes, https://duneawakening.com/news/dune-awakening-chapter-3-patch-notes/). The 1.5 announcement repeats "base upkeep taxation removed entirely" and adds that "Bases still need power to resist weather damage." The old tax strings (Imperial Tax Representatives in Harko Village and Arrakeen, shields disabled by defaulted taxes) remain in the game text but describe a retired system.
- Power is the remaining upkeep. When fuel runs out the generator stops and the shield drops; sandstorms then gradually damage walls and components (Funcom help center). The event log records shield state and why it went down (game text). A large sandstorm or polar storm can also knock a shield down (game text: "A large sandstorm disabled the shield on your base").
- Shielded bases take reduced sandstorm damage: the shield protects "from enemies" and reduces "sandstorm damage" (game text).
- How long an unpowered base lasts is unverified; Steam players report weeks to months depending on location and wall material (community, https://steamcommunity.com/app/1172710/discussions/0/595153917110836786/).
- Pieces cut off from the main structure can decay (Funcom help center).

### Sandstorm damage on this server

Damage per tick defaults to 5 for small and 7 for large sandstorms, separately for players, buildings, placeables and vehicles, with about 40 seconds between the warning and full strength (verified on this server). Coriolis storms here are warned 6 hours ahead and do no damage unless the owner enables it (verified on this server). Server owners can turn off environmental building damage entirely ("Base Decay", `bAllowDynamicBuildingDamage`) or make buildings ignore sandstorms (`m_bMitigateAllSandstormDamage`) (game text; this project's operations notes). On official Deep Desert instances, Coriolis storms wipe structures weekly (official blog 2025).

## Moving, storing and copying bases

### Base Reconstruction Tool (`BaseBackupTool`, item data)

- Stores whole bases with their placeables and stored items; "allows the owner of a sub-fief to remove and restore structures" (game text). Up to three snapshots, bound to your character and not lost on death, and they travel with you to another world (1.5 announcement).
- Crafted from the Iron tier of research at a Fabricator or Survival Fabricator (wiki, https://awakening.wiki/Base_Reconstruction_Tool).
- Cooldown: placing a backed-up base "triggers a cooldown of 7 days", but bases in Hagga Basin South move freely (game text). 1.5 set the Hagga Basin South cooldown to 0 (patch notes 1.5.1.0). Server owners set it with "Base Reconstruction Cooldown" in hours (game text).
- Restore only in the base's original map ("Structure can only be restored in the origin map", game text). "Snap to origin" puts it back where it was (game text), and the origin now has a map marker (patch notes 1.3.0.0).
- Backups fail when: vehicles are inside the structure, the console is not attached to a building piece, building pieces connect to pieces outside the claim, the region does not allow backups, or (formerly) taxes were unpaid (game text). Loose placeables not connected to the building are left behind after a warning (game text). The wiki says assembled vehicles drop to the ground; the game text says vehicles inside block the backup, so park them outside first.
- The wiki states Advanced Sub-Fief Consoles cannot be placed in Hagga Basin South (wiki); not confirmed in game text.
- Recycling a stored base sends all construction materials and stored items to the Reserve, reachable from any Sub-Fief Console or storage container; you must empty the Reserve before recycling another, and you confirm by typing "recycle" (game text). Not available for Deep Desert bases (1.5 announcement).

### Solido Replicator (`BuildingBlueprint_CopyDevice`, item data)

"Point this tool at an existing base to store a blueprint copy. Use again to place a projection of the saved base in a different location", then build it with the Construction Tool (game text). The tool is consumed when the blueprint is placed (game text: "Solido Replicator consumed"). Blueprints can be traded (official blog 2025). Since 1.5 there are hard caps on stored blueprints: 20 in your inventory, 10 per base storage, 20 in the bank, 10 per owned vehicle; excess ones drop (patch notes 1.5). All pieces must land on your own claim (game text).

## Permissions and sharing

- Managed in the Sub-Fief Console's Permissions tab. Levels are Owner, Co-owner, Associate, Guild and Public, and you can create custom roles (game text). Owners add or remove associates and co-owners; co-owners can add or remove associates (game text).
- Access roles stack: Base Helper (fill projections, repair), Base Facilitator (move placeables, assign circuits, make Solido blueprints), Base Builder (place projections, build or remove structures, edit circuits; needs access level 4) (game text). Separate permissions cover moving or demolishing the console, respawning and placing deployables (game text).
- Each door or machine has an Access Level; a player can use it only if their permission meets or exceeds it (game text).
- Bases can be shared by access code: "Player … wants to share a base access code with you" (game text).
- A "Guild" permission level exists alongside "Public" (game text). How it is granted to guild members, and whether guilds can own bases, is unverified.

## Where you can and cannot build

- Not on open sand or quicksand (game text). Anything on sand attracts sandworms (Funcom help center).
- Not in blocked regions: "Can't build in this region" and "{BuildableName} cannot be placed in {RegionName}" (game text). Claims avoid NPC sites, testing stations and trading posts (official blog 2025). Server owners can lift these with "Area Building Restrictions", at the cost of no shelter inside caves or enemy bases and possible content bugs (game text).
- Hagga Basin is fully PvE on official worlds since 1.3.20, shipwrecks included (1.5 announcement; community, https://massivelyop.com/2026/04/29/dune-awakening-has-officially-split-the-deep-desert-into-pve-and-pvp-instances-with-this-weeks-patch/). Private servers can set it fully PvP or PvE (1.5 announcement).
- Deep Desert: building costs 50% less and demolishing refunds 100% (game text). Coriolis storms "will destroy everything in the Deep Desert" (game text). Official worlds run a PvE and a PvP instance; the PvP one allows raids on bases whose shields are down (1.5 announcement; community, massivelyop). Base backups do not work there by default (wiki; game text "Base Backup is not possible in this region"). In single-player the Deep Desert never resets (patch notes 1.5).
- Player damage to unshielded bases is a server setting, "Player Damage to Player Bases" (game text).

## Sources

- Game text, build 25610213: `ST_Localization_Buildings`, `ST_Localization_UI`, `ST_Localization_Progression`, `ST_Localization_Communinet`, `ST_Localization_Items`.
- Item data: `bin/dune-awakening items find` (StakingUnit, StakingUnitVertical, BaseBackupTool, BuildingBlueprint_CopyDevice, BasicBuildingTool, Totem_Patent, Totem_Small_Patent).
- This project: `docs/admin.md` ("Building height", "Storms"), `docs/operations.md` ("Gameplay settings").
- Patch notes 1.5 console release, 2026-09-17: https://duneawakening.com/news/dune-awakening-console-release-patch-notes/
- Patch notes 1.5.1.0 (PTC): https://duneawakening.com/news/public-test-client-patch-1-5-1-0/
- Patch notes 1.5.15.0 (PTC, 2026-09-30): https://duneawakening.com/news/public-test-client-patch-1-5-15-0/
- 1.5 announcement: https://duneawakening.com/news/announcement/the-new-dune-awakening-is-here/
- Chapter 3 patch notes (1.3.0.0 and hotfixes): https://duneawakening.com/news/dune-awakening-chapter-3-patch-notes/
- Base recycling, 1.3.15.0: https://mmohuts.com/news/dune-awakening-adds-base-recycling-in-patch-1-3-15-0-as-pve-pvp-split-heads-to-testing
- Official building blog (2025, older): https://duneawakening.com/news/building-in-dune-awakening-claim-your-piece-of-arrakis/
- Funcom help center, lost bases: https://funcom.helpshift.com/hc/en/4-dune-awakening/faq/71-lost-base-and-how-to-keep-it-safe/
- awakening.wiki pages: Sub-Fief_Console, Advanced_Sub-Fief_Console, Base_Reconstruction_Tool, Fuel-Powered_Generator, Wind_Turbine_Omnidirectional, Wind_Turbine_Directional, Spice-Powered_Generator, Windtrap, Large_Windtrap, Large_Water_Cistern, Storage_Container, Water_Shipper_Building_Set
- Community (2025, possibly outdated): https://www.method.gg/dune-awakening/all-building-sets-in-dune-awakening-how-to-unlock-them, https://gamerant.com/dune-awakening-how-expand-base-increase-max-size/, https://www.thegamer.com/dune-awakening-bases-sub-feifs-how-many-can-you-have-guide/
- Community (2026): https://massivelyop.com/2026/04/29/dune-awakening-has-officially-split-the-deep-desert-into-pve-and-pvp-instances-with-this-weeks-patch/, https://www.techpowerup.com/345935/dune-awakening-chapter-3-dlc-now-available
