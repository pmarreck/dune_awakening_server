---json
{
  "schema": "dune-guide/v1",
  "title": "The tainted spice investigation (faction story, Chapter 2 era)",
  "description": "The faction storyline after joining a house: the Kytheria wreck, Sandflies intelligence, the poisoned spice plot, the hunt for Skorda, and recovering tainted spice from the Sheol, with Atreides and Harkonnen variants.",
  "kind": "questline",
  "section": "quests",
  "tags": ["faction", "atreides", "harkonnen", "kytheria", "skorda", "tainted spice", "poisoned spice", "sandflies", "red scorpion", "andrea ganan", "simone von konig", "thufir hawat", "piter de vries", "sheol", "delphis", "euporia"],
  "aliases": ["The Kytheria Wreck", "Deadly Intelligence", "Poisoned Spice", "Hunting Skorda", "The Doomed Delphis", "Euporia Fallen", "Track Down Skorda", "Investigate the Sandflies", "Interrogate Tripp Yates", "The Trail of the Red Scorpion", "Secrets of the Stone Sentinel", "The War Profiteer", "The Coup", "The Tainted Spice", "Skorda's Last Stand"],
  "region": "Hagga Rift, Shield Wall, Arrakeen or Harko Village, Mysa Tarill, O'odham, Sheol",
  "related": ["quests/faction-join-a-house", "quests/faction-chapter-3", "quests/index"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# The tainted spice investigation

Quick answer: after your loyalty test, your recruiter sends you after the Atreides deserter Captain Tighe Skorda. The trail leads to the wreck of the Kytheria in the Hagga Rift, where the crew died of a strange "bad spice". You move up to a handler (Andrea Ganan at Helius Gate for Atreides, Simone Von Konig at Riftwatch for Harkonnen), chase the spice through the Sandflies, foil a poisoning plot, enter the service of your house's Master of Assassins (Thufir Hawat in Arrakeen or Piter de Vries in Harko Village), hunt Skorda down, and recover a container of tainted spice from a wreck in the Sheol (game text, faction journey cards and `JOURNEY_TASK_TITLE_*`).

## Cards in order

Order from the wiki's Journeys page (https://awakening.wiki/Journeys, edited 2026-10-04). The assignment of task strings to cards is inferred from their names; the contract names are game text.

| # | Card | Contracts and steps |
|---|---|---|
| 1 | The Kytheria Wreck | "FACTIONS: ASSET RECRUITMENT: Track Down Skorda": talk to Katrina Chloros in the Hagga Rift, find the wreck of the Kytheria and its bow, reach the lower level, investigate the storage room, report. Then deliver your report to Andrea Ganan at Helius Gate (Atreides) or report to Simone Von Konig at Riftwatch (Harkonnen). |
| 2 | Deadly Intelligence | "FACTIONS: CONTRACTUAL OBLIGATIONS" contracts: "Investigate the Sandflies" (a Sandfly-occupied testing station and training camp), "Interrogate Tripp Yates", "The Trail of the Red Scorpion" (Imperial Testing Station No. 142), "Secrets of the Stone Sentinel" (a Sandflies base; track down the container). You end holding a canister of the spice. |
| 3 | Poisoned Spice | Analyze the sample ("Secrets of the Sample"). Atreides: "The War Profiteer", talk to Ambrose Lucifera in Arrakeen and decide what to do with a poisoned bottle; then talk to Thufir Hawat in Arrakeen. Harkonnen: "A Secret Delivery" to Piter de Vries' contact, then choose "Poison Piter de Vries or betray Simone Von Konig" (contract "The Coup"); then talk to Piter de Vries in Harko Village. |
| 4 | Hunting Skorda | "FACTIONS: AGENT MASTERY" contracts: "A New Cultist" (Arrakeen), "The Hunt for Skorda" (Mysa Tarill), "Skorda's Last Stand" (optional: catch up with a hunting party northwest of Mysa Tarill; find Skorda). |
| 5 | The Doomed Delphis (Atreides) / Euporia Fallen (Harkonnen) | "FACTIONS: AGENT MASTERY: The Tainted Spice": recover a container from the named wreck in the Sheol; then pledge to your house. |

Atreides rank 4 contract keys include "On the Tainted Trail", "A New Cultist", "A Center of Learning" and "The Hunt for Skorda" (game text, `CONTRACT_FACTION_ATREIDES_RANK4_*`), which suggests this arc overlaps ranks 3 to 5 (inference).

## Sticking points

- Every card in this arc says "While this Journey is active, you cannot defect from your faction" (game text).
- The final card sends you into the Sheol's radiation; build the Radiation Suit first (see [Regional journeys](regional-journeys.frontmatter.md), Shield Wall and Sheol decks).
- Card 3 has a real choice; the Harkonnen branch text notes you were meant to take the fall and instead enter de Vries' service (game text). Which consequences differ beyond dialogue is unverified.

Next: [Faction Chapter 3 journeys](faction-chapter-3.frontmatter.md).
