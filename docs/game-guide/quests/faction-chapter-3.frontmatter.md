---json
{
  "schema": "dune-guide/v1",
  "title": "Faction Chapter 3 journeys (Landsraad, augmentation, rank 20)",
  "description": "The post-rank-5 faction path added in Chapter 3: the audience with Duke Leto or Beast Rabban, the first Landsraad mission and Specialization trait, crafting an augmentation, climbing to rank 19, the rank 20 operations, and the Greater Arrakis dungeon cards.",
  "kind": "questline",
  "section": "quests",
  "tags": ["faction", "chapter 3", "landsraad", "rank 19", "rank 20", "augmentation", "regis", "specialization", "mnemonic recollection", "duke leto", "rabban", "dungeon", "overland map", "greater arrakis", "endgame"],
  "aliases": ["Called to Duty", "The Art of Making Friends", "Of Politics and Recollection", "Mnemonic Devices", "Honorable Death", "Revenge Most Toxic", "The Last Beacon", "Rabban's Revenge", "Raider of the Broken Lands", "Exponential Growth", "Terminal Profits", "Choosing a Side", "Claiming the Sands"],
  "region": "Arrakeen or Harko Village, overland map dungeons, Deep Desert",
  "related": ["quests/faction-tainted-spice", "quests/faction-join-a-house", "quests/great-convention-part-2", "quests/contracts", "quests/index"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Faction Chapter 3 journeys

Quick answer: once the tainted spice arc is done, your house leader summons you (Duke Leto at the Arrakeen Residence, or "Beast" Glossu Rabban in the Spire at Harko Village). He orders you to win favor with the Landsraad. That means three things: run your first Landsraad mission and buy the "Ranged Augmentation Limit" trait, craft your first weapon augmentation, then grind Landsraad missions to rank 19. At rank 20 the leader gives you a final operation: "The Last Beacon" for Atreides, "Rabban's Revenge" for Harkonnen (game text, `JOURNEY_B1C3_FACTION_*`, `_LANDSRAADMISSION_*`, `_AUGMENTATION_*`).

These journeys came with Chapter 3 (update 1.3, 2026-02-03), which raised the faction rank cap to 20 and rebuilt the Landsraad (wiki, https://www.awakening.wiki/Chapter_3).

## Cards in order (wiki order; steps game text)

| # | Card | Steps |
|---|---|---|
| 1 | Called to Duty | Go to your base or a settlement; talk to Thufir (to meet Duke Leto) or Piter (to meet Beast Rabban). |
| 2 | Of Politics and Recollection | Accept a Landsraad mission from the Landsraad > Missions menu, complete it, claim the reward there, buy the "Ranged Augmentation Limit" Trait in Skills > Specialization, talk to Thufir Hawat or Piter de Vries. |
| 3 | Mnemonic Devices | Loot an augmentation schematic; go to the Landsraad crafting vendor and buy an Offworld Regis Compound; fabricate a Regis Component in the Advanced Survival Fabricator; fabricate a ranged-weapon augmentation in the Advanced Weapons Fabricator; research and build an Augmentation Station; upgrade an item; talk to your Mentat. |
| 4 | The Art of Making Friends | Talk to the head of your house; report to your handler; complete the two journeys above; "Complete Landsraad Missions to reach rank 19". |
| 5 | Honorable Death / Revenge Most Toxic | Talk to Duke Leto in Arrakeen or Beast Rabban in Harko Village; complete "FACTIONS: OPERATIONAL DEPLOYMENT: The Last Beacon" or "... Rabban's Revenge". |

Rank 20 requires a special mission rather than more standing grinding (wiki, https://awakening.wiki/Faction, edited 2026-10-14; patch notes 1.3.0.0 per [progression-and-skills.md](../progression-and-skills.md#factions)).

## Greater Arrakis side cards (game text, `JOURNEY_B1C3_DUNGEON`, `_SCALINGUP`, `JOURNEY_1400_*`)

- Raider of the Broken Lands: attune to any dungeon after entering it from the Overland map, defeat its last challenger, acquire an augmentation schematic from a dungeon, recycle one.
- Exponential Growth: complete any overland dungeon at difficulty 20 or higher, then 30 or higher.
- Terminal Profits: complete any Landsraad missions in Wind Pass; defeat the last challenger of the Old Quarry and complete it on difficulty 15 or higher.

The 1.5 update added six Imperial Testing Station dungeons, five of them repeatable from the overland map, scaling with party size and difficulty, and the source of Plastanium-tier blueprints and augmentation schematics (patch notes 1.5, https://duneawakening.com/news/announcement/the-new-dune-awakening-is-here/, 2026-09-17).

## Older Landsraad cards

The Deep Desert Landsraad cards "Choosing a Side" (locate a House Representative, take a task for a Great House) and "Claiming the Sands" (take over a Deep Desert Control Point, collect a Landsraad reward) are still in the string table (game text, `JOURNEY_LANDSRAAD_PART1/2`). Whether they still appear after the Chapter 3 Landsraad rebuild is unverified.

## Sticking points

- Standing past rank 5 is capped per day: Landsraad missions boosted with a Mnemonic Recollection give 75 standing each, 375 a day, so rank 19 takes about 27 days of play (wiki, same page). You gain 5 Recollections per day and they keep for up to 7 days (game text).
- Completing or abandoning a Landsraad mission starts a 16-hour cooldown before it can be shared again (game text, `Landsraad_ShareContractAction_ErrorInCooldown`).
- These journeys also block defection while active (game text).
