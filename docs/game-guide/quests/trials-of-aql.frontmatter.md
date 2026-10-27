---json
{
  "schema": "dune-guide/v1",
  "title": "The Test of Aql (Trials of Aql, Find the Fremen)",
  "description": "The seven Fremen spice-vision trials: how a trial starts, where each altar is, what each one asks and teaches (stillsuit, static compactor, prescience, thumper, stilltent), and the riddles that point to the next.",
  "kind": "questline",
  "section": "quests",
  "tags": ["trial of aql", "aql", "fremen", "vision", "spice vision", "ibn qirtaiba", "sadus", "altar", "find the fremen", "riddle", "stillsuit", "static compactor", "prescience", "thumper", "stilltent", "main story"],
  "aliases": ["Trials of Aql", "Test of Aql", "Find the Fremen", "Aql altar", "Ibn qirtaiba", "First Trial of Aql", "Seventh Trial of Aql", "JOURNEY_CARD_TITLE_TESTOFAQL"],
  "region": "Hagga Basin South, Vermillius Gap, Hagga Rift, Jabal Eifrit",
  "related": ["quests/footsteps-of-the-fremen", "quests/a-new-beginning", "quests/regional-journeys", "quests/index"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-26",
  "confidence": "medium"
}
---

# The Test of Aql

Quick answer: the "Find the Fremen" deck is a chain of seven Fremen trials. Each starts at a stone altar in a cave: you interact with the altar, breathe in spice, and wake inside a vision where a Fremen voice (Sadus) opens with the invocation "Ibn qirtaiba" and sets the test. Finish it and you wake with new knowledge and a carved riddle that marks the next altar on your map. The first is in Hagga Basin South and the eighth stop is the abandoned sietch (game text; community, https://www.method.gg/dune-awakening/dune-awakening-trials-of-aql-locations-and-rewards, 2025, pre-1.5).

## How a trial works

- Discovery. The first trial comes as a dream: "In my stupor I have marked the symbol of a purple eye on my map" (game text, `JOURNEY_CARD_DESCRIPTION_FIRSTTEST`). The step reads "Follow your inner sight to the first trial" (game text).
- Each later trial is pointed to by a wall carving at the previous altar, which becomes a map note ("Second Aql Altar" ... "Seventh Aql Altar", "The Sietch") with a riddle (game text, `JOURNEY_MAP_Altar*`). Journey steps then ask you to survey a region to locate it, for example "Survey the Eastern Vermillius Gap to locate the next trial", followed by "Enter the ancient cave" and "Interact with the altar, then complete the ... trial" (game text).
- The vision speaker is named Sadus in the subtitles; his lines open with "Ibn qirtaiba" and include "Do you understand, wali?" (game text, dialogue strings). The same words later come back in a Noctua message, "Ibn Qirtaiba, Zantara. We are coming." (game text, Chapter 3 card "Call of the Night").
- The third and sixth altars are destroyed by the Sardaukar; there is no vision, only a shigawire recording left by a wandering scholar ("Listen to the shigawire recording at the destroyed altar") (game text).

## The trials

| Trial | Where (game text) | Community location detail | What it asks / teaches |
|---|---|---|---|
| First | Hagga Basin South ("Complete the First Trial of Aql in Hagga Basin South") | A cave the map marks with a purple eye; guides name it Mihna Cavern (community, keengamer and method.gg, 2025) | Stealth: move while the giant eyes are not looking (community). You wake knowing how to make a stillsuit (game text). |
| Second | Eastern Vermillius Gap. Riddle: "Para-southeast of the great hammer of Mirzabah ... the shattered teeth of the gods ... a cavity revealed." | East of the Wreck of the Actaeon per method.gg, north of Aren's Post per keengamer; check the map | Clear fire, poison and sand with a Static Compactor (community). You wake knowing "the making of a Fremen static compaction tool" (game text). |
| Third | Western Vermillius Gap. Riddle: "Para-west of the great hammer of Mirzabah ... a table of stone for God's feast ... seek the cave of the purple eye." | Southwest of the Wreck of the Pallas (community) | Destroyed altar; listen to the recording. No trial (game text). |
| Fourth | Eastern Vermillius Gap. Riddle: "The iron hammer that beats the dead who cannot enter paradise. The head of the hammer awaits." | In a large rock formation west of the Anvil Tradepost (community) | Combat against Sardaukar shades. You wake able to "see beyond this moment", the prescience ability; method.gg adds a third ability slot (game text; community). |
| Fifth | Hagga Rift. Riddle: "Where the earth has sundered ... across the bridges of stone ... where the monoliths lean ... always para-east." | Northeastern Hagga Rift (community) | Platforming, then using a Thumper; method.gg lists the Thumper schematic as the reward (community). |
| Sixth | Jabal Eifrit Al-Sharq. Riddle: "Follow your para-compass to the north and east ... amidst the jinn's towering spires ... seek eyes among the stones." | Devil's Eye Cavern, northeast corner (community); poison mines nearby | Destroyed altar; listen to the recording (game text). |
| Seventh | Hagga Rift. Riddle: "Red teeth ... gaping maw ... down, down in the depths ... hunger hidden from storm and worm." | The Red Maw, entered from the rift's lower levels; strong enemies (community) | Cross a storm by moving between stilltents; Stilltent schematic (community). |

Then "The Footsteps of the Fremen" sends you to the sietch: see [Footsteps of the Fremen](footsteps-of-the-fremen.frontmatter.md).

Conflict to note: the Jabal Eifrit regional card "Calling the Worm" lists "Complete the Fourth Trial of Aql" as the step that unlocks the Thumper (game text, `JOURNEY_JE_MIDGAME_TASK_TITLE_UNLOCKTHUMPER`), while method.gg ties the Thumper to the fifth trial. Unverified which is current.

## Prerequisites and pacing

- The second-trial card says to follow the path "when I am strong enough", and its first step is "Build a vehicle for long distance travel", then "Reach the Vermillius Gap" (game text). In practice you finish [A New Beginning](a-new-beginning.frontmatter.md) through the sandbike before trial two.
- Trials four through seven sit in Vermillius Gap, Hagga Rift and Jabal Eifrit, the mid-game regions; travel at night and stay off open sand (community, deltiasgaming/sportskeeda search summaries, 2025).
- Rewards are knowledge (schematics or abilities); none of the cards lists Solari (game text).

## Trouble on this server

- On 2026-10-13 a player got stuck on a "Connecting..." screen at the end of one of the trial visions while the operator's "timeout" mode had damage disabled (observed on this server, cause unconfirmed). The vision appears to be a scripted sequence that hands you back to the open world when it ends (inference, unverified), so if this recurs, note which trial, whether damage was disabled, and whether relogging clears it. No public report of the same symptom was found (web search, 2026-10-13).
- It recurred on 2026-10-26 with damage on, in the first trial ("Ibn qirtaiba" vision): the vision ended and the client disconnected while the server still held the player in its challenge room; after several such drops he relogged and the server logged "First trial completed!" eight seconds after he was back in the world (verified on this server, server log). If the vision ends in a disconnect, log back in: the trial counts.
- The Fremen Deathstill, Stilltent and other Fremen recipes reward finishing the whole chain; see the sietch entry.
