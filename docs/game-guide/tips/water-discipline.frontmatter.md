---json
{
  "schema": "dune-guide/v1",
  "title": "Water discipline",
  "description": "How to keep hydrated in practice: the one-third and two-thirds thresholds, which water sources to use at each stage, and habits that stop you running dry.",
  "kind": "tip",
  "section": "tips",
  "tags": ["water", "hydration", "thirst", "dehydrated", "dew", "blood", "stillsuit", "literjon", "catchpockets", "water discipline", "drink"],
  "aliases": ["how to get water", "running out of water", "dehydration"],
  "related": ["tips/heat-and-shade", "tips/first-hours", "tips/this-server", "tips/safe-travel"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Water discipline

**Quick answer.** Keep hydration above one third (it adds maximum stamina, more above two thirds; at zero you lose health), carry a full container, drink stillsuit catchpockets before anything else, stay in shade by day and refill from blood, dew and base water (game text). The game's own summary: "Wear a stillsuit. Travel by night. Harvest dew from plants. Take blood from the fallen" (game text, loading tip).

## The thresholds

Above one third hydration you get a maximum-stamina bonus, larger above two thirds; below one third the bonus disappears; at zero you are Dehydrated and lose health until you drink (game text, tutorial "Water Discipline"). Leaving a map by air also needs at least 30% hydration (game text).

## Sources by stage

| Stage | Source | Notes |
|---|---|---|
| First minutes | Dew Flowers by hand | Only up to one third of the bar; more causes nausea (game text). |
| First hour | Blood | Improvised Blood Extractor into a Small Blood Sack. Drinking raw blood hydrates but costs maximum health; a Blood Purifier at base turns it into clean water (game text). |
| Always | Stillsuit catchpockets | Collect water while worn; drink them to restore hydration (game text). There is a separate "Drink Catchpockets" input (game text). |
| Base | Blood Purifier, Windtrap, cisterns | Purifier and windtrap need power; a windtrap needs a Filter; uninsulated storage evaporates (game text). |
| Travel | Literjon, Decaliterjon, Hajra Literjon | 1,000 mL for the basic Literjon; the Hajra Literjon schematic is sold at Griffin's Reach in the opening journey (wiki; game text). |
| Town | "Cup of Water" | Refills 100 mL when bought at a tradepost (game text). |

Details and capacities are in [Water and hydration](../survival-combat-crafting.md#water-and-hydration).

## Habits

- Fill every container before leaving base, and never ride out below two thirds.
- Use a Dew Reaper at dawn: the game says it is "most useful at dawn" (game text).
- Carry a blood extractor on every trip; every fight is a water refill (game text).
- In a group carry spare water: a downed teammate's revive can fail with "Insufficient Water to Revive" (game text).
- The world does not pause in the Escape menu, so water keeps draining while you sit in menus (verified on this server, `docs/admin.md`).
- On the Overland Map time costs water (game text), so fill up before a long flight.

## This server

`ThirstMultiplier` is 1 (default) and `WaterExtractionRate` is 0.5, which per Funcom's setting comment makes extraction faster than default (server config). Players the operator has granted the `water` permission can type `&water` to fill every water container they carry (server config, `docs/admin.md`).
