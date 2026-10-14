---json
{
  "schema": "dune-guide/v1",
  "title": "Join a House (faction recruitment, ranks 0 to 5)",
  "description": "How to start the Atreides or Harkonnen faction questline at The Anvil: the recruiter contracts, The Missing Spy, the Test of Loyalty or Test of Treachery, and the contracts that raise you to House Operator (rank 5).",
  "kind": "questline",
  "section": "quests",
  "tags": ["faction", "atreides", "harkonnen", "join a house", "the anvil", "anton tolliver", "maxim kazmir", "recruiter", "rank", "war of assassins", "faction standing", "landsraad", "climb the ranks"],
  "aliases": ["The War of Assassins", "Join a House", "A Test of Loyalty", "A Test of Treachery", "Climb the ranks", "Recruits Wanted!", "Do you have what it takes?", "The Missing Spy", "Test of Resourcefulness", "Test of Acquisition"],
  "region": "The Anvil Tradepost, Eastern Vermillius Gap",
  "related": ["quests/faction-tainted-spice", "quests/faction-chapter-3", "quests/contracts", "quests/index"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Join a House

Quick answer: go to The Anvil Tradepost in the Eastern Vermillius Gap and talk to a recruiter, Lieutenant Anton Tolliver (Atreides) or Levenbrech Maxim Kazmir (Harkonnen). Do the contract "The Missing Spy" for either, prove yourself, pick a side and pledge allegiance. Then your house's loyalty test sets you against the other recruiter, and recruiter contracts carry you through ranks 1 to 5 (game text; wiki, https://awakening.wiki/Faction, edited 2026-10-14).

## Getting there

Recruiting notices on contract boards read "NOTE: VEHICLE NEEDED IF CROSSING FROM THE SOUTH" and point to Tolliver or Kazmir at the Anvil (game text, contracts "Recruits Wanted!" and "Do you have what it takes?"). In practice that means after the sandbike in [A New Beginning](a-new-beginning.frontmatter.md).

## Steps (game text; the grouping into cards follows the wiki's Journeys page)

Join a House:
1. Talk to a recruiter for House Atreides or House Harkonnen at the Anvil Tradepost; strike a deal; get a contract from one of them.
2. Complete "FACTIONS: JOINING RANKS: The Missing Spy": locate the spy's nest, search it, report back, deliver the report to one of the recruiters.
3. Prove yourself to at least one recruiter; choose a side; pledge allegiance to your House.

A Test of Loyalty (Atreides) or A Test of Treachery (Harkonnen). While this journey is active you cannot defect (game text):
- Atreides: contract "Test of Loyalty". Find records of Kazmir's Semuta dealings, locate the Kirab semuta den, deliver the Semuta Trade Logs to Tolliver, neutralize Kazmir, return to Tolliver.
- Harkonnen: contract "Test of Treachery". Find the forged documents at a Kirab hideout in a testing station, deliver the Counterfeit Document to Kazmir, blackmail Tolliver, return to Kazmir.

Climb the ranks: "Complete Contracts for Anton Tolliver or Maxim Kazmir". The recruiter contracts include (game text):

| Atreides (Tolliver) | Harkonnen (Kazmir) | What |
|---|---|---|
| Test of Resourcefulness | Test of Acquisition | Atreides: Holtzman Shields and Artisan Kindjals at 50% durability or better (the condition line also names Steel Ingots). Harkonnen: fifty steel bars. |
| Test of Prowess | Test of Might | Kill ten slavers in Jabal Eifrit / clear a bribed slaver post there; both warn of heavy resistance |
| Test of Cunning | Test of Ruthlessness | Covertly interrogate a target (Lanov / Gloos Bohannon) and report |
| Deep Extraction | (Harkonnen key 4) | Erythrite crystals from the Hagga Rift mining galleries |
| The Price of Betrayal, Recovered Honor | Seeking Guidance | Later errands: an ID tag from a Hagga Rift battlefield; an Atreides missile guidance component |

Further recruiter contracts send you after Hagga Rift deserters and their blood samples and to Testing Station 29 (game text, `CONTRACTS_ATREIDES_FACTION7/8`, `CONTRACTS_HARKONNEN_FACTION7/8`). Which contract grants which rank is not in the strings; the wiki says only that "relevant Contracts" earn Faction Standing up to rank 5.

## Standing needed (wiki, same page)

| Rank | Title | Total standing |
|---|---|---|
| 1 | Mercenary | 99 |
| 2 | Recruit | 249 |
| 3 | Contractor | 499 |
| 4 | Agent | 999 |
| 5 | House Operator | 1999 |

Past rank 5, ranks 6 to 19 come from Landsraad missions (about 27 days at the 375-per-day cap) and rank 20 from a special mission (wiki). See [Faction Chapter 3 journeys](faction-chapter-3.frontmatter.md) and [progression-and-skills.md](../progression-and-skills.md#factions).

## Sticking points

- Joining also opens the Landsraad (wiki).
- You can defect once, permanently, through the other house's Mentat and a betrayal contract ("Betray the Atreides", "A Betrayal Within a Betrayal", "A Spy Among Spies"); it resets Landsraad progress, and several faction journeys block it while active (game text; wiki).

Next in the faction story: [The tainted spice investigation](faction-tainted-spice.frontmatter.md).
