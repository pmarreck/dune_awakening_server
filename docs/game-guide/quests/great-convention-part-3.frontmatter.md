---json
{
  "schema": "dune-guide/v1",
  "title": "The Great Convention, Part III (Chapter 4 finale)",
  "description": "The final chapter of Book One (update 1.5): the Zanovar lead from Esmar Tuek, the spice bribe and spaceport, the off-world trip to Zanovar, the Sardaukar orbital prison, and the crash back to Arrakis.",
  "kind": "questline",
  "section": "quests",
  "tags": ["chapter 4", "great convention", "finale", "book one", "zanovar", "arrakeen spaceport", "esmar tuek", "staban tuek", "scytale", "stilgar", "orbital", "stealth", "main story"],
  "aliases": ["Dangerous Allies", "Prelude to a Journey", "The Tragedy of Zanovar", "Forty Fears", "A Fall from Heaven", "Cross My Palm With Spice", "The Water Wars", "JOURNEY_B1C4", "Great Convention Part 3"],
  "region": "Fallen Light, Deep Desert, Harko Village, Arrakeen Spaceport, off-world",
  "related": ["quests/great-convention-part-2", "quests/index"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# The Great Convention, Part III

Quick answer: the last chapter of Book One, added in update 1.5 (2026-09-17) so the whole story can be played start to finish (patch notes 1.5, https://duneawakening.com/news/announcement/the-new-dune-awakening-is-here/). Esmar Tuek sends you for a shigawire reel held by his son Staban at a besieged Smuggler base in the Deep Desert; the reel says "The truth lies buried on Zanovar". You pay Elara a spice bribe, fly off-world from the Arrakeen Spaceport, explore ruined Zanovar, wake prisoner on a Sardaukar orbital station, sneak out, and crash back onto Arrakis (game text, `JOURNEY_B1C4_*`; deck "The Great Convention — Part III", also titled "The Water Wars").

## Cards in order (wiki order; steps game text)

| # | Card | Steps and places |
|---|---|---|
| 1 | Dangerous Allies | Travel to a watersealed base and wait for Elara's call; talk to Esmar Tuek in Fallen Light; travel to the Smuggler base in the Deep Desert, infiltrate it and find Staban; exit the cave. |
| 2 | Prelude to a Journey | Contact a House Vernius representative in Hagga Basin (a placeholder string in this build); talk to Elara in Harko Village; complete the contract "Cross My Palm With Spice" (a spice melange bribe); meet the pilot at the Arrakeen Spaceport. |
| 3 | The Tragedy of Zanovar | Explore the ruins on Zanovar: cross plazas, climb ruined buildings, evade patrol ships, reach the amusement park and investigate the memorial. CHOAM mercenaries oppose you. |
| 4 | Forty Fears | Wake on the Sardaukar orbital station; Scytale frees you. Find the Sleeper while staying undetected (cell block, prison hangar, training room, maintenance corridor), search the infirmary, explore a memory sequence, wake the Sleeper, fight to the escape pods and defeat Sardaukar Commander Aramsham. |
| 5 | A Fall from Heaven | Aftermath: meet Stilgar at your crashed pod. |

## Sticking points

- The spice bribe is a delivery contract; have Spice Melange on hand before talking to Elara (game text; amount not in the strings read here, unverified).
- "Forty Fears" opens as a stealth section ("remain undetected!") (game text). If you leave mid-chapter the fallback is "Travel to the Arrakeen Spaceport to continue your journey" (game text, `JOURNEY_B1C4_FOURTYFEARS_1_ALTERNATESTEP`).
- On this server the Arrakeen Spaceport map is `CB_Story_DestroyedZanovar`, started on demand (verified on this server, see [world-and-maps.md](../world-and-maps.md)).
- Patch 1.5.15.0 (public test) added XP on completion for Chapter 3 and 4 journeys; live status unverified.

## After the story

The game shows a "Thank you for playing!" note after each chapter's story (game text, `DOCUMENT_JOURNEY_CH4_STORYCOMPLETED_*`). Funcom announced a separate standalone storyline with the free Polar Cap update for later in 2026 (patch notes 1.5).
