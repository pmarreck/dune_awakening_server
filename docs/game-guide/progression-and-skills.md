# Progression and skills

Scope: character level and XP, skill points, Intel and research, the five skill trees and their trainers, respec, Specializations, factions and the Landsraad, contracts and the story Journey. Last researched: 2026-10-06, game 1.5.x (server build 25689360; game text read from build 25610213).

Provenance tags: `(game text)` means the English string table extracted from build 25610213; `(verified on this server)` means measured on the self-hosted world this repository runs; web sources carry their URL, with dates where the page showed one.

## Quick answers

| Question | Short answer |
|---|---|
| What is the level cap? | 200. The game's curve table sets `MaxLevel` 200 (verified on this server, `data/levels.tsv`). Total XP to reach 200 is 344,440 under the reading in `docs/admin.md` (verified on this server). |
| How do I earn XP? | "XP is earned via combat, resource-gathering, and exploration" (game text). Story content also pays XP: the server setting "Mission Experience" covers "journeys, missions and contracts", including Landsraad mission rewards (game text). |
| What do I get per level? | One skill point per level from level 2 up, and Intel up to level 125 (verified on this server, `data/levels.tsv`). The level-up toast reads "Skill Points: {n} - Intel Points: {n}" (game text). |
| How do I unlock the Swordmaster tree? | Talk to Arno at Pinnacle Station and complete "SWORDMASTER: BASICS: Checking the Post" (game text). The tree's later levels and capstones come from Seron Varlin, the advanced trainer, in Harko Village (game text). |
| How do I unlock any other tree? | Each tree opens at its basic trainer; see [Trainers](#trainers). Your starting class's tree is open from the start (community, https://www.pcgamer.com/games/mmo/dune-awakening-best-class-mentor-homeworld-caste/). |
| Which classes can I start as? | Bene Gesserit, Mentat, Swordmaster or Trooper. Planetologist is not a starting choice (game text, character creation "Mentor" screen; wiki, https://awakening.wiki/Planetologist). |
| How do I get more Intel? | Level up (stops paying at 125), and loot Intel at enemy outposts ("find hidden Intel inside enemy Outposts marked on your map", game text) and in Deep Desert Testing Stations, which refresh weekly (wiki, https://awakening.wiki/Intel). |
| What does "Intel Point Limit Reached" mean? | You are at the Intel cap. The wiki says the cap equals the Intel needed for every researchable schematic and rises when new schematics are added (wiki, https://awakening.wiki/Intel). Whether it counts held or lifetime Intel is unverified. |
| Can I respec? | Yes. Skills menu, "Skills Reattribution". It costs Spice Melange from your inventory, requires a watersealed base (game text) or a social hub (patch notes 1.3.0.0), and is blocked while abilities are active or on cooldown (game text). |
| Can I change my starting class? | Reported as no, but every tree can be learned later, so the choice only decides your head start (community, https://www.pcgamer.com/games/survival-crafting/dune-awakening-how-to-respec/). |
| Atreides or Harkonnen? | Pick at The Anvil through the faction journey. You can defect once, and that switch is permanent (wiki, https://awakening.wiki/Faction). |
| What are Specializations? | Five tracks (Crafting, Gathering, Exploration, Combat, Sabotage) leveled by Landsraad missions; their Traits are bought with Spice Melange (game text). One Combat trait grants extra skill points (game text). |

## Levels and XP

The level curve is the game's `SkillXPPerLevel` curve table, copied into `data/levels.tsv` (verified on this server). Per-level XP rises from 40 (level 1) to 600 by level 7, stays at 600 through level 100, is 650 from 101 to 127, then climbs steeply to 13,126 for level 200 (verified on this server). Cumulative totals (verified on this server, reading in `docs/admin.md`):

| Level | 10 | 20 | 50 | 100 | 125 | 150 | 200 |
|---|---|---|---|---|---|---|---|
| Total XP | 4,190 | 10,190 | 28,190 | 58,190 | 74,440 | 93,099 | 344,440 |

The level 125 total is computed from the same table: 58,190 plus 25 levels at 650. About 73% of all XP to level 200 lies between levels 150 and 200.

XP sources and categories. The game's XP award uses the categories Combat, Crafting, Gathering, Exploration and Sabotage (verified on this server, `docs/admin.md`). Server settings scale XP: "Global Experience", "Combat Experience" (killing enemies), "Harvesting Experience" and "Mission Experience" (journeys, missions, contracts, Landsraad rewards) (game text). This server's global multiplier was 1.5 when measured on 2026-09-30 (verified on this server); check the current server settings before quoting it to a player. Patch 1.5.15.0 (public test, 2026-09-30) made the Chapter 3 and 4 journeys award XP on completion, which they had not before (patch notes 1.5.15.0, https://duneawakening.com/news/public-test-client-patch-1-5-15-0/); whether that has reached the live build is unverified.

## Skill points

- Levels: `SkillPointsRewarded` is 0 at level 1 and 1 per level from 2 to 200, so 199 points from leveling (verified on this server; three characters' point totals matched this reading).
- Specialization: the Trait "Skill Points" reads "Gain an additional skill point" (game text). A community calculator lists it in the Combat track at several levels, for example +3 at level 1 and +5 at level 100 (community, https://www.method.gg/dune-awakening/specialization-calculator/list). Exact totals unverified.
- Cost: each skill shows "{n} Skill Points" and "Level {current}/{max}", so many skills take several ranks (game text). The wiki gives full-tree costs of 132 points for Bene Gesserit, 120 for Mentat and 136 for Planetologist (wiki, pages linked under each tree below). With about 199 points you cannot max every tree.
- Skill kinds: "Abilities are actions that require activation while Techniques provide powerful bonuses under specific conditions. Both Abilities and Techniques must be equipped in the Skills Loadout... Passives, once trained, provide bonuses that are always in effect" (game text). You can equip up to 3 Abilities (game text, "Equip and use up to 3 powerful Abilities").
- Prescience skills: several passives say "Requires Prescience" and work only while the character is spice-prescient (game text). Prescience comes from consuming spice or standing in spice fields, followed by a withdrawal phase and rising tolerance (game text).

## Intel and the Research menu

What Intel buys. "Intel is used to research Schematics from the Research menu. Research Schematics to unlock specific Recipes for Fabrication" (game text). The Research menu also "shows the location of necessary components" (game text). Intel can also buy Imperial Permits (crafting charges) for some items: "use {numintel} Intel to acquire {numcharges} Imperial Permit(s) for {itemname}" (game text). Research is tiered: entries show "Requires Intel Spent: {current}/{required}" (game text). The wiki gives tier gates from 19 Intel spent (Copper) to 1,200 (Plastanium) and five categories, Water Discipline, Combat, Construction, Exploration and Vehicles (wiki, https://awakening.wiki/Intel). Some schematics also need a Journey step (wiki, same page).

Intel from levels (verified on this server, `IntelPointsRewarded`):

| Levels | Intel per level | Subtotal |
|---|---|---|
| 1 | 4 | 4 |
| 2-3 | 2 | 4 |
| 4-15 | 3 | 36 |
| 16-30 | 5 | 75 |
| 31-50 | 10 | 200 |
| 51-69 | 20 | 380 |
| 70-85 | 30 | 480 |
| 86-125 | 40 | 1,600 |
| 126-200 | 0 | 0 |

Total from levels: 2,779 Intel, matching the figure players report (community, https://steamcommunity.com/app/1172710/discussions/0/596286289747116752/, 2025 thread).

Intel from the world. Enemy outposts hold Intel pickups ("Enemy outposts contain valuable Loot and Intel", game text), and the map marks them with an "Intel" marker (game text). Deep Desert Testing Stations hold Intel that refreshes weekly (wiki, https://awakening.wiki/Intel). The server setting "Intel Points" scales pickup Intel only; at 0, "Intel Points can only be gained from leveling up" (game text).

The cap. Pickups show "Intel Point Limit Reached" when you are at the cap (game text). The wiki describes the cap as the total Intel needed for all available schematics, raised automatically when new schematics ship (wiki, https://awakening.wiki/Intel). Patch 1.1.20.0 fixed a bug where capped players could not interact with Intel pickups at all (wiki, https://awakening.wiki/1.1.20.0; older than 1.5). The exact 1.5 cap number is unverified. Whether spending Intel frees room under the cap, or the cap counts lifetime Intel, is unverified.

## Starting class

Character creation offers four mentors (game text):

| Mentor | Skill focus (game text) | Starting ability (game text description) |
|---|---|---|
| Bene Gesserit | Physical Mastery & Manipulation | Compel: "Use The Voice to force someone towards your position from afar" |
| Mentat | Recon & Strategy | The Sentinel: "a suspensor buoyed dart projector that uses motion detection" |
| Swordmaster | Close Quarter Aggression | Knee Charge: "Propel yourself forward into battle with a terrific knee charge" |
| Trooper | Offense & Demolition | Shigawire Claw: "Shoot a barb that attaches to a surface, then rapidly pulls you towards that position" |

The screen notes "(You can access additional skills later)" (game text). The mentor grants that first ability and opens that tree; other trees need their trainers (community, https://www.pcgamer.com/games/mmo/dune-awakening-best-class-mentor-homeworld-caste/).

## Trainers

Each tree has three unlock stages. Contract rewards read "Unlocks {School} Skill Tree", "Unlocks Level 2 {School} Skills", "Unlocks Level 3 {School} Skills" and "Unlocks a {School} Capstone Skill" (three capstones per school) (game text). Locked skills say where to go: "Unlock Tree at the basic {School} Trainer", "Unlock Upgrade at the advanced {School} Trainer", "Unlock Skill at the advanced {School} Trainer" (game text). The Journey card for all of this is "Learning the Skills" (game text).

| School | Basic trainer | First contract | Advanced trainer | Where (Journey text) | Final advanced contract |
|---|---|---|---|---|---|
| Bene Gesserit | Sister Mesa, Helius Gate | "BENE GESSERIT: BASICS: The Missing Pieces" | Jocasta Cleo | Harko Village | "The Rogue Bene Gesserit" |
| Swordmaster | Arno, Pinnacle Station | "SWORDMASTER: BASICS: Checking the Post" | Seron Varlin | Harko Village | "The Last Stand of Seron Varlin" |
| Trooper | Ghavouri, Griffin's Reach Tradepost | "TROOPER: BASICS: Proving Grounds" | Kara Valk | Arrakeen | "The Cleansing of Kara Valk" |
| Mentat | Samin Moro, Riftwatch | "MENTAT: BASICS: First Blood" | Zayn de Witte | Arrakeen | "Untwisted Questions" |
| Planetologist | Derek Chinara, his camp | "PLANETOLOGIST: Basics: Minimic Film Recovery" | Derek Chinara (same NPC) | his camp | "The Final Piece" |

All names, locations and contract titles above are game text (Journey "Rigor of the Trooper", "Discipline of the Mentat", "Prowess of the Swordmaster", "Mysteries of the Bene Gesserit", "Knowledge of the Planetologist"). The basic trainers were also confirmed on this server (verified on this server).

Correction to an earlier project note. The regions previously recorded for the advanced trainers (Jocasta Cleo at Shield Wall, Seron Varlin at Jabal Eifrit, Kara Valk at Hagga Basin South, Zayn de Witte at Hagga Rift) are where some of their contracts send you, not where the trainers stand. Kara Valk's first contract sends you to a slaver camp in Jabal Eifrit; Zayn's contracts involve deserters in the Hagga Rift and end "Deliver the Minimic Film to Zayn in Arrakeen" (game text). The trainers themselves are in Harko Village (Bene Gesserit, Swordmaster) and Arrakeen (Trooper, Mentat) (game text, Journey steps). Community guides agree (community, https://www.gamesradar.com/games/survival/dune-awakening-trainers-locations-swordmaster-trooper-mentat-bene-gesserit-planetologist/ search summary). Finer placement from the wiki: Jocasta Cleo in a Harko Village back alley near the Atreides vendor; Zayn de Witte in Arrakeen's lower bar; Kara Valk in Arrakeen's central plaza, later the Salusan Bull bar (wiki, pages under each tree; unverified on this server).

Planetologist details. Derek Chinara's camp sits "above Imperial Testing Station No. 2" (game text) in "the rocky clefts above the Blight" (game text). Its chain is the longest, nine contracts from Basics to "The Final Piece" (game text). A community guide places the later Planetologist stage at Imperial Testing Station No. 197 (community, search summary of https://www.pcgamer.com/games/mmo/dune-awakening-trainer-locations/); unverified.

Admin shortcut on this server: an operator can open a school's tree without its quests with `&unlock <school>` or `character unlock-tree`, which sets the `Skills.Key.<School>1` module (verified on this server, `docs/admin.md`). Levels 2 and 3 of a tree are the `...2` and `...3` keys.

## The five trees

Skill names below are exact game text. Subtree placement comes from the community wiki (pages edited 2026-09-22 to 2026-10-01); the game text itself does not say which tree a skill belongs to.

### Bene Gesserit (wiki, https://awakening.wiki/Bene_Gesserit; 132 points)

- Weirding Way: Weirding Step, Bindu Sprint, Prana-Bindu Strikes (abilities); Manipulate Instability (technique); Blade Damage, Short Blade Damage (passives); Bindu Dodge (prescience passive).
- The Voice: Compel, Stop, Ignore (abilities); Rapid Register (technique, Voice registers faster); Voice Training (passive, lower Voice cooldowns); Screech (prescience passive, staggers around your Voice target).
- Body Control: Litany Against Fear (ability, armor and poise for you and allies); Prana-Bindu Stability, Metabolize Poison, Trauma Recovery (techniques); Vitality, Self-Healing, Poison Tolerance, Sun Tolerance, Recovery (passives).
- Voice abilities "require a short period for you to 'register' your opponent before they can be used" (game text).

### Mentat (wiki, https://awakening.wiki/Mentat; 120 points)

- Mental Calculus: The Sentinel (ability); Exploit Weakness, Marksman (techniques); Ranged Damage, Rifle Damage, Pistol Damage, Tailoring, Garment Keeper (passives); Shield Overcharge (prescience passive).
- Assassination: Hunter-Seeker, Stunner, Poison Mine, Poison Capsule (abilities); Poison Tooth (technique); Assassin's Shot, Headshot Damage (passives).
- Tactician: Shield Wall, Solido Decoy, Gravity Mine, Anti-gravity Mine, Source of Power (abilities); Iron Will (technique, resists the Voice).

### Swordmaster (wiki, https://awakening.wiki/Swordmaster)

- The Blade: Eye of the Storm, Foil, Retaliate (abilities); Dance of Blades (technique); Long Blade Damage, Blade Damage (passives); Precise Parry (prescience passive).
- The Will: Deflection (ability); Thrive on Danger, Reckless Lunge (techniques); Solid Stance, Confidence, Bleed Tolerance (passives).
- The Way: Knee Charge, Crippling Strike, Inspiration (abilities); Disciplined Breathing (technique); General Conditioning, Desert Conditioning, Optimized Hydration, Field Medicine (passives); Prescient Strike (prescience passive: after a Swordmaster ability your next strike hits twice).

### Trooper (wiki, https://awakening.wiki/Trooper)

- Gunnery: Energy Capsule (ability); Heavy Weapon Agility, Center of Mass (techniques); Ranged Damage, Heavy Weapon Damage, Scattergun Damage, Disruptor Damage, Gunsmith, Field Maintenance (passives).
- Suspensor Training: Suspensor Blast, Collapse Grenade, Gravity Field, Anti-gravity Field (abilities); Death from Above, Suspensor Dash (techniques); Suspensor Efficiency (passive).
- Tactical Tech: Shigawire Claw, Explosive Grenade, Assault Seeker, Attractor Field (abilities); Battle Hardened (technique, lower Trooper cooldowns); Reflexive Reload (prescience passive).

### Planetologist (wiki, https://awakening.wiki/Planetologist; 136 points)

Mostly gathering and travel passives, the tree to take for a crafter or harvester.

- Scientist: Cutteray Mining, Dew Gathering, Deep Analysis, Compaction, Rerouting, Overcharge (passives); Conservation of Energy (technique, lower tool power drain).
- Explorer: Suspensor Pad (ability); Cartographer (makes sinkcharts from surveyed areas), Mountaineer, Scanner Mastery, Stillsuit Seals, Spice Surveyor (passives).
- Mechanic: Vehicle Repair, Fuel Efficient Driver, Fuel Efficient Pilot, Vehicle Mining, Vehicle Scanning, Sandcrawler Yield (passives); Heat Management (prescience passive).

### Names in the game text not placed above

The 1.5 string table also contains skills the wiki pages do not list: capstone-style entries Weak-Point Focus, Spice Infused Poisons, Feedback Routines, Overdrive, Spice Medicine and Spiced Death; abilities such as Battlefield Calculation, Enemy Analysis, Weapons Projection, Healer-Seeker, Trophy Seeker, Possfeign, Expunge and Anigolah; and techniques such as The Rook, The Tower, Squadron Alpha, Squadron Omega, Triage, Toxic Trait and Incubator (game text). Some are probably the advanced trainers' capstones (Overdrive, for example, buffs Hunter-Seekers, Sentinels, Trophy Seekers and Solido-Decoys, which points to Mentat; game text); others may be unused. Their tree placement is unverified.

## Respec

Open the Skills menu and choose reattribution ("Skills Reattribution", "Would you like to reattribute your skill points?") (game text). Conditions (game text):

- "You need to be inside a watersealed base to reattribute your skill points."
- "You will need {amount} Spice Melange in your inventory."
- "You are unable to reattribute skills while abilities are active or cooling down."
- A cooldown timer exists ("Time left till cooldown is up").

Patch 1.3.0.0 (public test notes, 2025-12-19) set the rule: social hubs also count, the cost runs 0, 5, 10, 20, then 50 Spice Melange for consecutive respecs, and it steps down one level every 6 hours, so a respec every 6 hours or more is free (patch notes 1.3.0.0, https://duneawakening.com/news/public-test-client-patch-1-3-0-0/). The free respec every 48 hours described in mid-2025 guides is outdated. When Funcom reworks a tree, everyone gets a free "global respec": "Global respec occurred. Your skill points have been refunded" (game text). Patch 1.3.0.0 reset all trees this way (patch notes 1.3.0.0).

## Specializations

Specializations sit in a tab of the Skills menu (game text). There are five tracks, Crafting, Gathering, Exploration, Combat and Sabotage; "Gain Specialization XP by completing Landsraad Missions of each category" (game text). Leveling a track gives automatic per-level bonuses, and unlocks Traits that "enhance your character permanently" and are bought with Spice Melange in any order (game text). The menu unlocks "by advancing through the faction journey" (game text); the Chapter 3 journey has you buy the "Ranged Augmentation Limit" Trait (game text).

Notable Traits (names game text): Skill Points, Pack Mule ("Increases inventory size by 1 row"), Max Health Increase, Max Stamina Increase, Melee / Ranged / Garment Augmentation Limit (gear augment slots, "Expand Augment Limit in the Crafting Specialization menu"), Landsraad Contributor, Greasing Palms (Landsraad bribe cost), Tax Evasion, Without Rhythm (sandworm threat), and helm cosmetic variants per track. A community calculator gives a maximum of level 100 per track and Trait costs from 2 to 40 Spice Melange (community, https://www.method.gg/dune-awakening/specialization-calculator/list); unverified in game. The server setting "Specialization Experience" multiplies it (game text).

## Factions

Joining. The faction journey starts at The Anvil, where Atreides and Harkonnen recruiters test you; joining also opens the Landsraad (wiki, https://awakening.wiki/Faction, edited 2026-09-20).

Ranks. Rank titles are the same for both houses up to 5, then diverge (game text):

| Rank | Atreides | Harkonnen |
|---|---|---|
| 0 | Outsider | Outsider |
| 1 | Mercenary | Mercenary |
| 2 | Recruit | Recruit |
| 3 | Contractor | Contractor |
| 4 | Agent | Agent |
| 5 | House Operator | House Operator |
| 20 | Envoy | Enforcer |
| 30 | Peacekeeper | Executor |

Ranks 1 to 5 come from faction contracts; ranks 6 to 19 from Landsraad missions; rank 20 needs an Overland Map outpost mission (patch notes 1.3.0.0). The rank 20 story contracts are "Honorable Death" (Atreides) and "Revenge Most Toxic"/"Rabban's Revenge" (Harkonnen) (game text). The 1.5 launch post describes "twenty ranks from outsider to Atreides Envoy or Harkonnen Enforcer" (patch notes 1.5, https://duneawakening.com/news/announcement/the-new-dune-awakening-is-here/). The rank 30 titles exist in the game text but no source describes reaching them; treat rank 30 as unreleased or unverified. The wiki caps Landsraad standing gains at 375 per day past rank 5 (wiki, https://awakening.wiki/Faction). Faction vendors check rank ("Requires Reputation Level {Level}", game text); opposing-faction cosmetics can be bought from settlement NPCs at double price (wiki, same page).

Defecting. You can switch once, permanently, by speaking to the other house's Mentat (Thufir Hawat or Piter de Vries) and completing a betrayal contract; it resets Landsraad progress (wiki, https://awakening.wiki/Faction; contract names game text). Several faction journeys block it: "While this Journey is active, you cannot defect from your faction" (game text).

## Landsraad

On a multiplayer server the council "convenes weekly to pass a server-wide Decree that stays in effect until the next voting session" (game text). In single-player a cycle is ten hours of play, with voting in its last fifteen minutes (game text). A faction wins the council by "completing a row of House requirements horizontally, vertically, or diagonally, or by having the most House requirements met by the start of a voting session" (game text). Each Great House's requirements are met through repeatable Landsraad missions (combat, crafting, gathering, exploration, sabotage, plus dungeons and time trials) (game text; patch notes 1.3.0.0). House rewards go to every contributor, but only guild leaders of the winning faction get voting power and can vote on the decree (game text).

Mission rewards. Each mission pays standard rewards plus a "Recollection Reward" if you spend a Mnemonic Recollection: "You gain 5 Mnemonic Recollections per day", and unused ones accumulate "for up to 7 days" (game text). Example decrees include a spice tax change, weapon damage increase, crafting cost decrease, a CHOAM Refining Contract and an XP bonus decree for the winning house (game text).

## Contracts

The contract menu groups contracts as Regular, Chained, Exploration, Trainer, Atreides and Harkonnen (game text). Trainer contracts unlock skill trees (see [Trainers](#trainers)); Atreides and Harkonnen contracts raise faction standing up to rank 5 (patch notes 1.3.0.0). Contracts pay XP scaled by the "Mission Experience" server setting (game text).

## The Journey (story), spoiler-light

The Journey menu holds decks of cards; each card is a story step (game text).

- Opening: "A New Beginning" and "Find the Fremen". You start shipwrecked after the fall of the Proteus, under a deal with the Bene Gesserit to "Find the Fremen" (game text).
- The Fremen thread: "The Test of Aql", a series of Trials of Aql (First through Seventh), and "The Footsteps of the Fremen" (game text). These are spice-vision trials spread across the map (community, https://www.pcgamer.com/games/mmo/dune-awakening-trial-of-aql-locations/).
- Side decks: Survival, Exploration, "Learning the Skills" (trainers), and "The War of Assassins" with "Join a House", "Factions" and "Climb the ranks" (game text).
- Main story chapters: "The Great Convention" in three parts. Part I is Chapter 2, Part II is in Chapter 3 and Part III in Chapter 4 (game text keys `CH2`, `B1C3`, `B1C4`; the chapter mapping is inferred from those key names). Update 1.5 added Part III, "the final Chapter", so Book One can now be played start to finish in one run (patch notes 1.5, https://duneawakening.com/news/announcement/the-new-dune-awakening-is-here/). Four older boss missions (Echoes of the Past, The Glutton, The Paranoid, The Jackal) became instanced levels (same source).
- Lost Harvest (paid DLC, released with Chapter 2 in September 2025): a standalone story about the crashed Miner's Guild harvester Mithra, plus the Treadwheel vehicle and cosmetics (community, https://alcasthq.com/dune-awakening-dlc-the-lost-harvest/; older source). In game its cards are "The Fall of the Mithra", "Villari's Prize", "Digging Deeper" and "Secrets of the Past"; it starts from a distress call northwest of Griffin's Reach Tradepost (game text).

## Open questions

- The exact Intel cap in 1.5, and whether unspent Intel counts toward it.
- Total skill points per tree for Swordmaster and Trooper, and which tree owns each unplaced name in the game text.
- Whether faction rank 30 is reachable.
- Whether 1.5.15.0's journey-XP change is in the live build 25689360.

## Sources

- Game text: `strings/all-build25610213.tsv` (assets ST_Localization_Progression, ST_Localization_Abilities, ST_Localization_UI, ST_Localization_Lore_Pickups_Contracts), extracted from build 25610213.
- This repository: `data/levels.tsv` (curve table `SkillXPPerLevel`), `docs/admin.md` (XP and levels, skill-tree unlock).
- Patch notes: https://duneawakening.com/news/announcement/the-new-dune-awakening-is-here/ (2026-09-17); https://duneawakening.com/news/dune-awakening-console-release-patch-notes/ (2026-09-17); https://duneawakening.com/news/public-test-client-patch-1-5-15-0/ (2026-09-30); https://duneawakening.com/news/public-test-client-patch-1-3-0-0/ (2025-12-19, older).
- Wiki: https://awakening.wiki/Skill_Tree, https://awakening.wiki/Bene_Gesserit, https://awakening.wiki/Mentat, https://awakening.wiki/Swordmaster, https://awakening.wiki/Trooper, https://awakening.wiki/Planetologist, https://awakening.wiki/Intel, https://awakening.wiki/Faction, https://awakening.wiki/1.1.20.0.
- Community: https://www.pcgamer.com/games/mmo/dune-awakening-best-class-mentor-homeworld-caste/, https://www.pcgamer.com/games/survival-crafting/dune-awakening-how-to-respec/ (2025, outdated respec rules), https://www.pcgamer.com/games/mmo/dune-awakening-trainer-locations/, https://www.pcgamer.com/games/mmo/dune-awakening-trial-of-aql-locations/, https://www.gamesradar.com/games/survival/dune-awakening-trainers-locations-swordmaster-trooper-mentat-bene-gesserit-planetologist/, https://www.method.gg/dune-awakening/specialization-calculator/list, https://steamcommunity.com/app/1172710/discussions/0/596286289747116752/ (2025), https://alcasthq.com/dune-awakening-dlc-the-lost-harvest/ (2025).
