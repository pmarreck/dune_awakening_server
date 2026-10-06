# Economy, social play and versions

Scope: money (Solari, the Exchange, vendors, contracts, spice, the Landsraad), guilds, parties, chat, PvP zones, server types and transfers, BattlEye, this server's adjustable settings, DLC, and the version history. Last researched: 2026-10-06, game 1.5.x (server build 25689360).

Provenance labels: `(game text)` is the English string table extracted from build 25610213; `(game config)` is Funcom's shipped `DuneSandbox/Config/DefaultGame.ini` in this server's 1.5 image; `(settings file)` is Funcom's shipped `UserServerCustomSettings.ini` with its own comments; `(verified on this server)` was observed on the self-hosted world this project runs. Web sources carry their URL. Anything marked "unverified" has not been confirmed.

## Quick answers

| Question | Answer |
|---|---|
| How do I invite a friend to my party? | Press **P** (social menu), find the player in the friend list or search by Funcom ID, select them and choose **Invite to Party**. Or look at a nearby player, interact, and pick **Invite to Party** from the inspect menu. They get "Do you want to join the party of {name}?" and accept. Both of you must be on the same server (game text; key P from game data). Full steps under [Parties](#parties-groups). |
| How big can a party be? | Disputed: 4 per a 2025 Steam thread, 5 per several 2025 guides. Not found in the game config. Unverified for 1.5. |
| How do I whisper someone? | Social menu (P) → select the player → **Private Message**. Whispers appear in the **Private** chat tab (game text). |
| How do I make money fast? | Early: contracts and story quests (bounties pay well; a story bounty pays 1,000,000 Solari). Mid/late: loot routes of high-value points of interest, selling crafted goods (vehicle parts, T6 items) and Spice Melange to players on the Exchange rather than to NPC vendors, and Landsraad missions (Solari plus House Scrip). See [Earning Solari](#earning-solari). |
| What changed in the latest patch? | Hotfix 1.5.3.6 (2026-10-06): Steam players may launch **without BattlEye** for single-player and for private/self-hosted servers that do not require it; stability fixes; autosave recovery fix; ornithopter spawn-position fix (patch notes). On this server a client launched without BattlEye joins fine (verified on this server). |
| Can I bring my official-server character here? | Official and private characters can transfer to a self-hosted ("Experimental") server, but the character is then marked Experimental and can never go back to Standard or Custom servers (game text; patch notes). Consider a fresh character. |
| How do I create a guild? | Guild tab (key **O**) → **Create Guild**, name and description, confirm; costs **1,000 Solari** (game config; wiki). |
| Where is the Exchange? | CHOAM Exchange terminals in the settlements, Arrakeen and Harko Village (wiki, game text). |
| Is there PvP? | Official servers since 1.3.20.0: Hagga Basin is fully PvE; the Deep Desert has separate PvE and PvP instances (patch notes). On a self-hosted server the host chooses (setting "Player Versus Player": No PvP / Limited / Full). |
| Does my server have to match my client version? | Yes, exactly. A mismatched client sees "Outdated Client" (M52) or the server is missing from the list (project research notes). |

## Earning Solari

Solari ("Solaris" in many UI strings) are the Imperial currency used "for trade at certain locations or with others you meet in the world" (game text). The item id is `SolarisCoin`, stack size 50,000 (game config, read in this project's admin notes). Solari exist in two places: carried in your inventory and deposited in your **bank** (Deposit/Withdraw Solaris at a banker; game text). The Exchange pays and charges from banked Solari ("Insufficient Banked Solaris"; game text).

| Source | Notes | Provenance |
|---|---|---|
| Contracts | Job boards at tradeposts (Griffin's Reach, The Anvil, Pinnacle Station, Crossroads), fortresses (Helius Gate, Riftwatch) and settlements. Rewards go straight to the backpack, or are claimable later from Journey → Contracts if it is full. Many end by calling the issuer over the Communinet. | wiki, https://awakening.wiki/Contracts (edited 2026-10-04); game text |
| Contract Solari tiers | The config maps reward tags to amounts: tier 1 1,500 / 2,000 / 3,000 (small/medium/large), tier 2 3,000 / 4,500 / 5,500, tier 3 4,500 / 6,500 / 8,500, tier 4 5,500 / 8,500 / 11,500, tier 5 7,000 / 11,000 / 14,500, tier 6 from 8,500 / 13,000. Which content uses which tag is not mapped here. | game config (`m_SolarisAmountToTagMapping`) |
| Bounties | Kill-count contracts such as "Bounty: Deserters" and "Kirab Bounty". The story contract "Zantara's Head" (from Count Fenring's associate in Harko Village) promises one million Solaris. | game text |
| Landsraad missions | Repeatable; pay Solari Credits, character XP and Landsraad contribution, plus bonus rewards (specialization XP, faction standing, House Scrip) while you have Mnemonic Recollections. | patch notes, https://duneawakening.com/news/dune-awakening-chapter-3-patch-notes/ |
| Selling to NPC vendors | Vendors buy back far below their own sell price (2025 report: Spice Melange sold by a vendor for 120,000, bought back for 650). | community, https://steamcommunity.com/app/1172710/discussions/0/595152778808005604/ (2025-06-24, pre-1.5) |
| Selling to players (Exchange) | The usual way to realise value for spice, rare schematics, vehicle parts and high-tier gear. | game text; community guides |
| Loot routes | 2025 guides describe ornithopter loops of high-value points of interest (Pinnacle Station, comms arrays, testing stations) with schematic chests worth 2,000 to 4,000 Solaris each. | community, https://gamerant.com/how-to-make-solaris-money-fast-in-dune-awakening/ (2025-06-13, pre-1.5; loot tables have changed since) |
| Player trades | Direct player-to-player trade window (request, both sides mark READY) with a **Transfer Solaris** option. | game text |

On a self-hosted server an admin can also hand out Solari (this project's `&give solari N` / `character give`), verified on this server.

### Spending Solari

| Sink | Cost | Provenance |
|---|---|---|
| Guild creation | 1,000 | game config (`m_GuildCreationCost=1000`); wiki |
| Taxi (ornithopter pilot) | 500 to a social hub, 150 to a tradepost (since 1.5); pilots accept inventory or bank Solari (since Chapter 3) | patch notes |
| Exchange sell orders | 20 Solari per day of listing plus 2% of the price; the listing fee is lost if you cancel | game config (`SellOrderDailySolarisFee=20`, `SellOrderPricePercentageFee=2`); game text |
| Landsraad decree reroll | 1,000 per reroll, up to 5 per term | game config |
| Character recustomization | 5,000 (currency not stated in the config) | game config (`CharacterRecustomizerSubsystem m_CostAmount=5000`) |
| Vendors | weapons, tools, consumables, schematics | game text |
| Imperial tax | **Removed.** Chapter 3 disabled taxation (UI, NPC dialogue and journey). The 1.5 config still ships `m_bTaxationEnabled=False`. | patch notes, Chapter 3; game config |

## The Exchange (player market)

The CHOAM Exchange is the player market; a loading tip says to visit it "to buy rare items, and to trade with other players on multiplayer servers" (game text). Exchange names in the UI are Arrakis, Harko Village and Windsack (game text); the wiki confirms terminals with Spacing Guild bankers in Arrakeen and Harko Village (wiki, https://awakening.wiki/Exchange, edited 2026-10-06). You must be at a terminal ("No exchange terminal within range"; game text).

How it works (all game text unless noted):

- **Tabs:** Buy, Sell, My Orders (Active / Completed). Items can be filtered by category and by grade.
- **Selling:** pick an item from the backpack or vehicle storage, set price per unit and quantity, choose a duration of **1, 3, 7 or 14 days**. The dialog shows listing price, exchange fees and total profit.
- **After a sale:** "Claim your Solaris in the Exchange, 'My Orders' section"; claimed Solari go to the bank account.
- **Buying:** pay from banked Solari; collect bought items from My Orders, to the backpack or "Send to vehicle".
- **Expired or cancelled:** claim or relist from My Orders. Cancelling forfeits the listing fee.
- **Limits:** "No free slots in exchange" means you have hit your listing cap. A 2025 player report puts it at 12 to 15 slots (community, link above; unverified for 1.5). Some items cannot be listed ("Item can not be listed for sale"); the config has an exclude tag for that (game config).
- **Single-player (1.5):** "The Exchange now acts as a vendor with a large selection of items" (patch notes).
- **Character transfers:** exchange listings are deleted when you transfer; de-list what you want to keep first (game text).

Whether a self-hosted server's Exchange is populated by players only, or also behaves as a vendor as in single-player, is unverified.

## Vendors and tradeposts

Tradeposts are "the lone lights of civilization in the desert", where you meet trainers, take contracts, contact factions and trade (game text). Settlements (Arrakeen, Harko Village) hold the Exchange, bankers and more vendors. The **Landsraad crafting vendor** takes **House Scrip**, earned from Landsraad missions with Mnemonic Recollections; it sells specialized components for high-quality items and augments, and its stock is limited and restocks weekly (game text). Landsraad decrees can also open temporary Weapon, Armor, Tool and Vehicle vendors (game text). PTC 1.5.15.0 limits the tool vendor's Mk5 power packs to 5 per refresh (patch notes, https://duneawakening.com/news/public-test-client-patch-1-5-15-0/, PTC only as of 2026-09-30).

## Spice economics

Spice Melange is refined from spice sand harvested in spice fields and blows; blows are visible from far off and destroy anything nearby when they erupt (game text). Uses and value drivers:

- Crafting: 1.5 removed Spice Melange from six advanced fabricator/refinery recipes (patch notes, 1.5), which lowers demand from base builders.
- Specializations: traits are unlocked with Spice Melange (patch notes, Chapter 3); a skill respec asks for an amount of Spice Melange in your inventory (game text).
- Landsraad tasks "Deliver Spice Melange" and spice-infused dusts (game text).
- Deep Desert PvP instances give 2.5x yield from mining and harvesting (patch notes, 1.3.20.0, https://duneawakening.com/news/dune-awakening-1-3-20-0-patch-notes/).
- Landsraad decrees can raise or cut CHOAM spice taxes by 50% (game text).
- Price: players sell it on the Exchange; NPC buyback is a tiny fraction of the vendor price (community, 2025, pre-1.5). No current 1.5 price data was found; prices vary by server.

## The Landsraad and guild-level systems

- **Access:** Landsraad missions need both a faction-aligned guild and progress in the faction journey (game text). A guild aligns with Atreides or Harkonnen; members aligned with the opposite house are removed (game text; wiki, https://awakening.wiki/Guilds).
- **Missions:** repeatable, they count toward your faction's effort to win a Great House's vote. XP goes to Skills > Specialization (Crafting, Gathering, Exploration, Combat, Sabotage). Claim rewards from the Mission Report (game text). Missions can be shared with party members (patch notes, Chapter 3).
- **Mnemonic Recollections:** 5 per day; the in-game tip says unused ones accumulate for up to 7 days, and the Chapter 3 notes say up to 35 charges (the same cap: 5 × 7). Without one you get only the standard rewards (game text; patch notes).
- **Terms and decrees:** the winning faction's guild leaders with voting power vote on a decree (game text). Decrees seen in the game text include +50% XP, -25% crafting cost, -50% refining time, +33% melee or ranged damage, vendor access, spice tax ±50%, and full item drop on PvP death in the Deep Desert. Config: 3 decrees nominated per term, rerolls enabled at 1,000 each, at most 5 per term, top-5 guild highscore list (game config).
- **Single-player and simulated guilds:** in 1.5 the Landsraad simulates rival guilds so it progresses without other players (patch notes); the simulated guild names are in the game text.
- **Double Landsraad Loot Weekend** events exist (game text).

## Guilds

| Item | Value | Provenance |
|---|---|---|
| Open | Guild tab (key **O**) or the Social menu | game data (input mapping, read in this project's admin notes); game text loading tip |
| Cost | 1,000 Solari | game config; wiki |
| Max members | 32 | game config (`m_MaxGuildMembersAllowed=32`) |
| Pending invites | at most 10 outstanding | game config |
| `m_MaxGuildsAllowed=3` | present in config; meaning (per player? per account?) is unclear | game config; unverified |
| Ranks | Leader (Admin), Officer, Member | game config; game text |
| Inviting | Guild menu → INVITE PLAYER (type the name), or inspect a player → Invite to Guild. They see "Do you want to join {player}'s guild {guild}?" | game text |
| Leaving | A leader cannot leave; promote someone (which demotes you) or disband | game text |
| Rename | Leader can rename the guild in PTC 1.5.15.0 | patch notes (PTC only) |
| Effects | Members are friendly to each other in PvP and see each other on the map | community, https://gamerant.com/how-to-play-with-friends-in-dune-awakening/ (2025) |
| Transfers | Transferring a character removes it from its guild | game text |

Guild permissions on buildings and vehicles: base and vehicle access has a "Guild" permission level, and an "Add Players" permission; bases can also share access codes over the Communinet (game text, game config). Exact per-rank permissions were not found.

## Parties (groups)

How to invite (game text for every label; keys from game data):

1. Open the **Social** menu (**P**). Tabs: Friend List, Friend Invites, Party, Party Invites.
2. Find the player: Steam friends appear automatically (community, https://game8.co/games/Dune-Awakening/archives/523562); others by **Search Player** → "Insert Funcom ID" (name#number).
3. Select them and choose **Invite to Party** ("Send Invite"). Alternatively, look at a player in the world, interact to open their inspect panel, and choose **Invite to Party**.
4. They get "Party invite -- {name} sent you a party invite" and the prompt "Do you want to join the party of {name}?"; accepting shows "{name} joined the party".

Rules and errors (game text): you can only interact with players on the same server; the invite fails if they are already in a party, the party is full, an invite is pending, or the invite times out. Players in character creation or the opening tutorial cannot accept. "Leave Party" is a bindable action; if the leader leaves, leadership passes ("Leader changed to {name}"). Party members in another map, ground vehicle or air vehicle are shown with their own markers.

**Visit friend:** from the social menu you can visit a friend on another server of the same world, after a countdown, but not from inside a vehicle and not before finishing the new-player experience (game text).

**Party size:** a 2025 Steam thread reports 4, with two leftover UI slots from a cut larger size (community, https://steamcommunity.com/app/1172710/discussions/0/563626586778120597/, 2025-06-13); other 2025 sources say 5 (community, https://steamcommunity.com/app/1172710/discussions/0/595152944226166390/, 2025-06-27; https://gamerant.com/how-to-play-with-friends-in-dune-awakening/). The config holds no size key. Unverified; test in game.

## Chat and whispers

Channels (game text): **All** (feed), **Proximity**, **Map**, **Party**, **Guild**, **Faction**, **Private** (whispers), plus an Error tab. Open chat with **Enter** (game data). Errors confirm you must be in a party, guild or faction to use those channels. Private messages: social menu → player → **Private Message** (game text); a whisper shows as "To [name]:" in purple in the Private and All tabs (verified on this server). Free-trial characters cannot whisper (game text). Voice chat: hold **V** for proximity voice (community, game8 link above). Ping with the middle mouse button (same source). An automatic toxicity filter can mute you (game text). The game has a "short command" error string, but no list of slash commands was found; treat `/w`-style commands as unverified.

On this server, trusted players can also use `&` chat commands (the project's GM bridge, e.g. `&help`) typed in any channel (project admin notes).

## PvP, PvE and security zones

Zone labels (game text): **KANLY - GUILD PEACE [NO COMBAT]** (towns and social hubs), **KANLY - LIMITED WARFARE [PvE]**, **KANLY - WAR OF ASSASSINS [PvP]**. A PvP death offers a respawn cooldown there or an immediate respawn at a start location (game text).

Official servers:

- Since 1.3.20.0 (2026-04-28): "Hagga Basin is now fully PvE across the entire map, including the Shipwrecks"; every official world has at least one PvE and one PvP Deep Desert instance, labelled when you enter from the Overland map; the PvP instance has 2.5x resource yield (patch notes).
- In the Deep Desert PvP instance "Players may attack each other anywhere in the desert beyond the midway point" (game text).
- Death drops: backpack items drop where you die; a sandworm or Coriolis storm death loses everything (game text).

Self-hosted and private servers choose with the **Player Versus Player** setting: No PvP; Limited (PvP only in the Deep Desert and around most Hagga Basin shipwrecks, the pre-1.3.20 rules); Full PvP (everywhere except settlements) (game text). Corpse looting follows **PlayerDeathLootRule** (below).

## Server types and transfers

The server browser tabs (game text): **OFFICIAL / Standard**, **Custom**, **Private**, **Experimental**, plus Friends and Recent, and a "Rent A Private Server" button.

| Type | What it is | Character rule |
|---|---|---|
| Official (Standard) | Funcom-run worlds of numbered "Sietch" servers | can transfer outward to private/self-hosted |
| Private / Custom | Rented servers with altered settings | "will not be able to return to Standard Servers" (game text); private characters move between private servers (patch notes) |
| Experimental (self-hosted) | Worlds people run themselves with Funcom's server software, PC only; live since 2026-05-19 | character becomes **Experimental** and cannot transfer to Standard or Custom servers (game text); self-hosted characters can move between self-hosted servers (project research notes) |
| Single-player (1.5) | Local world with presets | characters stay single-player (patch notes) |

Transfer mechanics (game text): use **Transfer Character** in the in-game menu; your character must be in Hagga Basin. You keep only your backpack and bank (Solari and items); the old character and its Exchange listings are deleted; bases and vehicles left behind are abandoned after a while, so back them up first with the Base Reconstruction Tool and Vehicle Backup Tool (not the Solido Replicator). You leave your guild and lose progress toward the next Landsraad reward. Transfers may cost a **Transfer Token**, which regenerate over time; transfers off closed worlds are free. You type "transfer" to confirm.

History: character transfers arrived in 1.2.40.0 (2026-01-20); 133 official servers closed on 2026-05-26 with forced migrations, bases and vehicles auto-backed up (wiki, https://awakening.wiki/Developer_Updates; https://duneawakening.com/game-updates/).

### Joining this server

This is a self-hosted (Experimental) world: find it under the **Experimental** tab and enter the join password the host gives you (this server uses one). Your client and the server must be on the same build; after a Steam client update, wait for the host to update the server (project research notes; operations notes).

## BattlEye

- Hotfix 1.5.3.1 (2026-09-19) added a launch-without-BattlEye option and disabled it again in the same hotfix (patch notes).
- PTC 1.5.15.0 (2026-09-30) and then live hotfix 1.5.3.6 (2026-10-06) made it optional: Steam players can launch "without the BattlEye anti-cheat software installed or enabled for the single-player mode, or private and self-hosted servers that do not require it"; "BattleEye is still required to play on multiplayer servers with BattleEye enabled" (patch notes, https://duneawakening.com/news/dune-awakening-console-release-patch-notes/).
- The Steam launcher now asks whether to start with BattlEye. This server's image ships `BattlEye.Enabled=false`, and a client launched without BattlEye joins this world (verified on this server, build 25689360).
- On a server that requires it, a client without BattlEye sees "You cannot play on this server without BattlEye. Please restart the game client with BattlEye enabled." (game text).
- 1.5 also removed the Funcom Launcher from the Steam PC version (patch notes).

## This server's adjustable settings

Self-hosted gameplay settings live in `UserServerCustomSettings.ini` (section `[/Script/DuneSandbox.UserServerCustomSettings]`), added in hotfix 1.5.3.1. It needs `DifficultyLevel=Custom`; 1.5.3.4 fixed servers ignoring the file because that line was missing (patch notes). Changes apply at the next map-server start (project operations notes). Ranges below are Funcom's own comments in the shipped file (settings file); the UI names and meanings are the in-game settings text (game text). "This server" is the current value on this world.

| Key | In-game name | Range | This server |
|---|---|---|---|
| `GlobalXpMultiplier` | Global Experience | 0 to 10 | 1.5 |
| `CombatXp` | Combat Experience | 0 to 10 | 1 |
| `GatheringXp` | Harvesting Experience | 0 to 10 | 1 |
| `MissionXp` | Mission Experience (story, contracts, Landsraad) | 0 to 10 | 1 |
| `IntelPointsGainMultiplier` | Intel Points (0 = only from leveling) | 0 to 10 | 1 |
| `GatheringAmount` | Mining Efficiency (commented out; use `Dune.GlobalMiningOutputMultiplier` / `Dune.GlobalVehicleMiningOutputMultiplier` in UserEngine.ini) | 0.1 to 10 | default |
| `CraftingCost` | Crafting Cost (0 = free) | 0 to 10 | 0.5 |
| `CraftingTimeMultiplier` | Crafting Speed (0 = instant crafting and refining) | 0 to 5 | 0 |
| `WaterExtractionRate` | (higher = extraction takes longer) | 0.1 to 10 | 0.5 |
| `LootRespawnSpeed` | Loot Respawn Speed (higher = slower) | 0.1 to 10 | 1 |
| `ResourceRespawnSpeed` | Resource Respawn Speed (higher = faster) | 0.1 to 10 | 1 |
| `BuildingCostMultiplier` | Building Cost (0 = free) | 0 to 10 | 1 |
| `FuelBurnTimeMultiplier` | Fuel Efficiency | 0 to 10 | 1 |
| `InventoryVolumeMultiplier` | (higher = carry more) | 0.1 to 10 | 10 |
| `PlayerStaminaDrain` | (higher = stamina drains faster) | 0.1 to 10 | 0.8 |
| `ItemDurabilityDrainMultiplier` | Durability Wear Speed (0 = no wear) | 0 to 10 | 0.25 |
| `bEnableItemMaxDurabilityLoss` | max durability loss on repair | True/False | False |
| `PlayerDamageToPlayer` | Player Damage To Other Players | 0.1 to 10 | 1 |
| `PlayerDamageToNPC` | Player Damage To Enemies | 0.1 to 10 | 1.2 |
| `PlayerDamageToVehicle` | Player Damage To Vehicles | 0.1 to 10 | 1 |
| `NPCHealth` | Enemy Health | 0.1 to 10 | 1 |
| `NPCDamageToPlayer` | Enemy Damage To Players | 0.1 to 10 | 0.8 |
| `NPCDamageToNPC` | Enemy Damage to Other Enemies | 0.1 to 10 | 1 |
| `NPCRespawnMultiplier` | Enemy Respawn Speed | 0.1 to 10 | 1 |
| `PVPDamageStructures` | Player Damage to Player Bases (unshielded) | 0 to 10 | 1 |
| `PlayerShieldDamageAbsorptionMultiplier` | Player Shield Damage Mitigation | 0.1 to 10 | 2 |
| `NPCShieldDamageAbsorptionMultiplier` | Enemy Shield Damage Mitigation | 0.1 to 10 | 1 |
| `HeatBuildupRate` | Heat Buildup Speed (0 = off) | 0 to 10 | 1 |
| `ThirstMultiplier` | Dehydration Speed (0 = off) | 0 to 10 | 1 |
| `DropEquipmentOnDeath` | Dropped on Death | All, Backpack, Default, None | Backpack |
| `SandwormConsequences` | Lost On Sandworm Death | All, Backpack, Default, None | Backpack |
| `PlayerDeathLootRule` | Looting Player Corpses | DependsOnSecurityZone, NeverAllowOtherPlayers, AlwaysAllowOtherPlayers | DependsOnSecurityZone |
| `bAllowDynamicBuildingDamage` | Base Decay (environmental damage) | True/False | False |
| `bAllowSandstorms` / `bAllowSandworms` | Sandstorms / Sandworms (commented out; use `Sandstorm.Enabled`, `m_bCoriolisAutoSpawnEnabled`, `sandworm.dune.Enabled` in UserEngine.ini) | True/False | default |
| `bIsBuildingRestrictionsEnabled` | Area Building Restrictions | True/False | True |
| `LandsraadContributionMultiplier` | Landsraad contribution | 0 to 10 | 1 |
| `LandsraadSpecializationXpMultiplier` | specialization XP from the Landsraad | 0 to 10 | 1 |
| `LandsraadFactionStandingMultiplier` | faction standing | 0 to 10 | 1 |
| `FiefdomLimit` | Maximum Sub-fief Amount (commented out, default 3) | 0 to 10 | default |
| `BuildingPieceLimitMultiplier` | Building Size Limit | 0.1 to 10 | 1 |
| `bBuildingInfiniteStability` | Building Stability | True/False | False |
| `BaseBackupToolTimeRestriction` | Base Reconstruction Cooldown (hours) | hours | 16 |

Verified effects on this server: `GlobalXpMultiplier=1.5` multiplied awarded XP (4,150 sent became 6,225); `InventoryVolumeMultiplier=10` made inventory space visibly larger; the slot count (35 in the main backpack) cannot be raised by any setting (project admin and readiness notes, verified on this server). The in-game settings text also lists PvP mode, Difficulty Preset (Relaxed / Survival / Challenging / Custom), Fief Expansion Limit and Cold Buildup Speed, which have no key in the shipped file; their ini names are unverified. The text warns that some settings apply only after a world restart and that raising building or fief limits can make the game unstable (game text).

## DLC and cosmetics

| Content | Released | Price (USD) | Type | Provenance |
|---|---|---|---|---|
| The Lost Harvest | 2025-09-09 | 12.99 | story + Treadwheel vehicle + cosmetics | community, https://deep-desert.com/dune-awakening-dlc-guide/; Wikipedia |
| Raiders of the Broken Lands | 2026-02-03 | 9.99 | building pieces and cosmetics | community, same guide |
| The Water Wars | 2026-05-19 | 9.99 | building pieces and cosmetics | community, same guide; patch notes 1.4 |
| Season Pass | n/a | 24.99 | the three above | community, same guide |
| Filmic Archive | 2026-09-22 | 9.99 | film-inspired armors and stillsuits, 73 Sardaukar building pieces, decorations, weapons, emotes; 1.5.3.5 added 11 mirrored pieces and a corner column | patch notes |
| 1.5 login reward | Sep 17 to Oct 22, 2026 window | free | 6-piece decorative set (banner, two chairs, two tables, carpet) | patch notes |

The client also has a **Store** tab, a **Battle Pass** ("Chronicle", with a premium tier and purchasable level unlocks) and a "Purchase CHOAM Credit" currency store (game text). Whether these are active in 1.5 is unverified. DLC content is cosmetic or building/story content; no DLC was found that sells gameplay currency.

## Version timeline

| Date | Version | Highlights | Provenance |
|---|---|---|---|
| 2025-06-05 | early access | head start for advance purchasers | Wikipedia |
| 2025-06-10 | 1.0, Chapter 1 | PC launch; 140,000+ Steam peak, 1 million sold in two weeks | Wikipedia; https://duneawakening.com/game-updates/ |
| 2025-06-26 to 08-13 | 1.1.0.5 to 1.1.20.0 | Deep Desert balance and PvE areas, smarter sandworms, new Deep Desert islands, building fixes | https://duneawakening.com/game-updates/ |
| 2025-09-09 | Chapter 2 (1.2) | story continues, character recustomization, Lost Harvest DLC | game-updates page; Wikipedia |
| 2025-10-29 | 1.2.11.0 | direct vehicle-to-bank transfer | game-updates page |
| 2026-01-20 | 1.2.40.0 | character transfers | game-updates page |
| 2026-02-03 | Chapter 3 (1.3.0.0) | Landsraad rebuilt around repeatable missions, specializations, augments, taxation removed, Raiders DLC | patch notes, Chapter 3 (the wiki's developer-updates page dates it January 2026; official notes say Feb 3) |
| 2026-03-25 | 1.3.10.0 | Ruins of Tsimpo | game-updates page |
| 2026-04-28 | 1.3.20.0 | PvP optional: Hagga Basin fully PvE, PvE and PvP Deep Desert instances (one tracker lists Apr 14; the official notes say Apr 28) | patch notes |
| 2026-05-19 | 1.4.0.0 | Wind Pass and Old Quarry Testing Station, Water Wars DLC; self-hosted servers go live | patch notes; https://duneawakening.com/news/self-hosted-servers-now-live/ |
| 2026-05-26 | n/a | 133 official servers closed, characters migrated | wiki, Developer_Updates |
| 2026-06-24 | 1.4.10.0 | five new Landsraad missions; hotfixes 1.4.10.1 to .5 through Aug 12 | patch notes; https://patched.gg/games/dune-awakening |
| 2026-08-13 | PTC 1.5.1.0 | single-player and character-centric menus on the test client | patch notes |
| 2026-09-17 | **1.5 (1.5.3.0)** on PC | single-player mode with presets; story conclusion; character-centric menu and portability rules; Filmic Archive DLC; combat rebalance (parry window 0.25 s to 0.33 s, ability levels); economy (Spice Melange removed from six recipes, aluminum/duraluminum/plastanium costs cut 10 to 25%, taxis 500/150, medium storage 4,000); Funcom Launcher removed on Steam; private and self-hosted settings via .ini | patch notes |
| 2026-09-19 | 1.5.3.1 | `UserServerCustomSettings.ini` for self-hosted servers; BattlEye option added and pulled; login decorative set | patch notes |
| 2026-09-21 | 1.5.3.2 | server recommendations, Assault Ornithopter cockpit fix | patch notes |
| 2026-09-22 | 1.5.3.3 + console launch | PS5 and Xbox release; progression-loss fixes | patch notes; Wikipedia |
| 2026-09-24 | 1.5.3.4 | stability (7X3 errors), custom settings file fix (`DifficultyLevel=Custom`), stuck characters after cross-realm transfers on private servers, base marker offset after restart | patch notes; project research notes |
| 2026-09-30 | 1.5.3.5 | Filmic Archive mirrored Sardaukar pieces, garment customization, fabricator/refinery water fixes, Exchange order status fix. Same day: server build 25610213 and PTC 1.5.15.0 (guild rename, tool-vendor limit, BattlEye optional) | patch notes; project operations notes (build time) |
| 2026-10-06 | **1.5.3.6** | BattlEye optional on Steam for single-player and for private/self-hosted servers that do not require it; stability; autosave recovery fix; ornithopter spawn-position fix in Hagga Basin and the Deep Desert. Self-host build 25689360 after about 30 minutes of downtime | patch notes; https://x.com/DuneAwakening/status/2107126596503003503; verified on this server |

Self-host server builds seen: 25351779 (Sep 17), 25396338 (reported Sep 21), 25486303 (Sep 23), 25610213 (Sep 30), 25689360 (Oct 6) (project research and operations notes). Pairing each build with a hotfix number is inference; Funcom does not publish the mapping.

## Sources

- Game text: `strings/all-build25610213.tsv` (extracted from build 25610213), keys under `UI/ServerSetting_*`, `UI/Exchange_*`, `UI/SocialMenu_*`, `UI/Party*`, `UI/Guild*`, `UI/TextChat_*`, `UI/Landsraad_*`, `UI/CharacterTransfer*`, `UI/CustomServers_*`, `UI/ServerBrowser_*`, `UI/SecurityZone_*`, `UI/ErrorPopup_BattlEye_*`, `PROGRESSION/Tutorial_*`, `LORE_PICKUPS_AND_CONTRACTS/*`.
- Game config: `DuneSandbox/Config/DefaultGame.ini` and `DefaultEngine.ini` in this server's 1.5 image (sections `GuildSettings`, `DuneExchangeSettings`, `TaxationSettings`, `CharacterRecustomizerSubsystem`, Landsraad `DedicatedServerData`, `m_SolarisAmountToTagMapping`; `BattlEye.Enabled=false`).
- Settings file: Funcom's `UserServerCustomSettings.ini` as copied into this server's operator config.
- Project notes: `docs/research/version-1.5-compatibility.md`, `docs/admin.md`, `docs/operations.md`, `docs/readiness.md`.
- Patch notes: https://duneawakening.com/news/dune-awakening-console-release-patch-notes/ (1.5 and hotfixes 1.5.3.1 to 1.5.3.6); https://duneawakening.com/news/public-test-client-patch-1-5-15-0/; https://duneawakening.com/news/dune-awakening-chapter-3-patch-notes/; https://duneawakening.com/news/dune-awakening-1-3-20-0-patch-notes/; https://duneawakening.com/news/self-hosted-servers-now-live/; https://duneawakening.com/game-updates/; https://duneawakening.com/news/category/patch-notes/; https://x.com/DuneAwakening/status/2107126596503003503.
- Wiki: https://awakening.wiki/Guilds, https://awakening.wiki/Exchange, https://awakening.wiki/Contracts, https://awakening.wiki/Developer_Updates; https://en.wikipedia.org/wiki/Dune:_Awakening.
- Community: https://steamcommunity.com/app/1172710/discussions/0/563626586778120597/, https://steamcommunity.com/app/1172710/discussions/0/595152944226166390/, https://steamcommunity.com/app/1172710/discussions/0/595152778808005604/, https://gamerant.com/how-to-play-with-friends-in-dune-awakening/, https://gamerant.com/how-to-make-solaris-money-fast-in-dune-awakening/, https://game8.co/games/Dune-Awakening/archives/523562, https://deep-desert.com/dune-awakening-dlc-guide/, https://patched.gg/games/dune-awakening.
