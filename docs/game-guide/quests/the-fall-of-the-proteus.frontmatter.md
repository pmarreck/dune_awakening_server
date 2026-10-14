---json
{
  "schema": "dune-guide/v1",
  "title": "The Fall of the Proteus (opening)",
  "description": "The tutorial opening: the prison ship crash, escaping the Sardaukar lockdown with Zantara, and the ornithopter flight into the storm that drops you in Hagga Basin South.",
  "kind": "questline",
  "section": "quests",
  "tags": ["opening", "tutorial", "crash", "proteus", "zantara", "escape", "start", "new character", "story", "journey"],
  "aliases": ["Escape", "Planetfall", "JOURNEY_DECK_TITLE_PLANETFALL", "prison ship crash", "intro"],
  "region": "Tutorial (instanced) then Hagga Basin South",
  "related": ["quests/a-new-beginning", "quests/trials-of-aql", "quests/index"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# The Fall of the Proteus (opening)

Quick answer: every character starts as a prisoner on the transport Proteus, bound for slave labor in Neo-Carthag, who struck a deal with the Bene Gesserit to "Find the Fremen" in exchange for freedom. The ship is shot down; a man named Zantara pulls you from the wreck, you fight to the ship's bridge to lure down a Sardaukar ornithopter, and the two of you escape in it into a sandstorm. You come to in Hagga Basin South, where the "A New Beginning" deck takes over (game text).

## Steps

The Journey deck is "The Fall of the Proteus" with a single card, "Escape" (game text, `JOURNEY_DECK_TITLE_PLANETFALL`, `JOURNEY_CARD_TITLE_ESCAPE`). Its steps, from the game's task strings:

1. Talk to Zantara (game text, `JOURNEY_TASK_TITLE_TALKTOZANTARA`).
2. Escape the Enclosure (game text).
3. Reach the bridge and activate the captain's emergency transmitter to lure a Sardaukar Bakkar down (game text, card completion and dialogue: "slip back onto the Proteus and locate the command module").
4. Zantara kills the officer and you both flee in the stolen ornithopter, straight into a storm (game text).

The ordering of steps 1 and 2 is inferred from the card text; the task strings carry no order.

The deck text frames the whole game: the Reverend Mother's command "Find the Fremen. Wake the Sleeper." (game text, `JOURNEY_DECK_DESCRIPTION_PLANETFALL`).

## Practical notes

- The character-creation "Mentor" choice (Bene Gesserit, Mentat, Swordmaster or Trooper) decides your first ability and opens that school's tree; the others come from trainers. See [progression-and-skills.md](../progression-and-skills.md#trainers) and the trainer entries in this section.
- After the crash, Zantara guides you over the communinet while he nurses an injured leg (game text, "Getting Equipped" card). The next deck is [A New Beginning](a-new-beginning.frontmatter.md).
