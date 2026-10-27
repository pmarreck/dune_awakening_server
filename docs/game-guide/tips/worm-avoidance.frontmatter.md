---json
{
  "schema": "dune-guide/v1",
  "title": "Avoiding sandworms",
  "description": "How the sandworm threat meter fills and drains, which actions are loud or quiet (with the server's own per-second numbers), and a practical crossing technique.",
  "kind": "tip",
  "section": "tips",
  "tags": ["sandworm", "worm", "shai-hulud", "vibration", "threat", "wormsign", "open sand", "crossing", "shield", "suspensor", "drumsand", "thumper", "crouch", "sprint"],
  "aliases": ["how not to get eaten", "worm threat meter", "vibration bar", "wormsign"],
  "related": ["tips/crossing-the-vermillius-gap", "tips/vehicle-safety", "tips/death-and-recovery", "tips/common-newbie-mistakes"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Avoiding sandworms

**Quick answer.** On open sand a vibration bar fills; when it turns red the worm is close and you must get onto rock (game text). The meter never drains while you stand on sand, only once you are off it or airborne (server config). So plan crossings as short hops from rock to rock, never switch on a shield or suspensor on sand, keep off drumsand, and do not stop to loot or mine in the open.

## How threat builds and drains

Values are Funcom's defaults in the server's `DefaultGame.ini`, section `[/Script/DuneSandbox.SandwormSettings]`, build 25789279, and this server's `UserGame.ini` repeats the same numbers (server config). The meaning of each number is inferred from its setting name.

| Activity on sand | Threat per second |
|---|---|
| Walking without rhythm (`WWoR`) | 5 |
| Walking | 15 |
| Crouching | 15 |
| Running or sprinting | 20 |
| Dashing or hyper-sprinting | 90 |
| Suspensor (`Suspending`) | 200 |
| Standing on drumsand (red spots on the map, verified on this server) | 200 |
| Personal shield active | 500 |
| Vehicle shield active | 50 |

- Crouch-walking builds threat at the same rate as walking (15), so crouching does not help; plain running costs only a third more than walking (server config). An older community tip says crouching is quieter than sprinting (community, https://www.thegamer.com/dune-awakening-traversal-tips-tricks/, pre-1.5); that is true only against sprinting.
- Dashes, suspensor use and hyper-sprints are listed as uncapped threat sources (`m_TagsAffectingUncappedThreat`) (server config).
- Picking up harvested spice or flour sand adds threat (`HarvestSpicePickupThreatUnit=10`, `HarvestFlourSandPickupThreatUnit=10`) (server config).
- Character and vehicle threat does not decay on sand (`ThreatDecreasingValuePerSec=0`, `ThreatBlobCanDecayMap` false for characters and vehicles). Off the sand it drains at 10 per second after a 5-second wait; airborne it drains at 100 per second (server config). See [Sandworms](../world-and-maps.md#sandworms).
- "The closer a worm is, the more sensitive it is to vibrations" (game text).
- Walking without rhythm is a real movement state with a third of the walking rate, but how to enter it is not documented; the slow-walk toggle is the likeliest candidate (unverified; see the world chapter). Specializations include a Trait called "Without Rhythm" that affects sandworm threat (game text).

## The breach sequence

At red the worm makes a warning breach, then a short grace period, then the fatal attack if you are still on sand (wiki, https://awakening.wiki/Sandworm, edited 2026-09-16). The compass and map show a red "Sandworm Breach" marker (game text). After several failed pursuits a worm can surface directly under you (wiki, same page).

## Practical technique

1. Before stepping off rock, pick the next rock island with binoculars or the map and run straight for it: "take the shortest path to safety" (game text).
2. Run or walk; never dash, suspend or shield on sand.
3. On rock, wait a few seconds for the meter to clear before the next hop (drain starts after 5 s, server config).
4. If the worm warns while you are mid-crossing, run for the nearest rock, not forward; in an ornithopter, climb, because low flight is still vulnerable (wiki).
5. A thumper placed on open sand summons any nearby worm, "attracting and distracting" it (game text, item description and loading tip). Placing one away from where you work is the intended use; how far it pulls a worm is unverified.

## Consequence

Killed by a worm you lose everything carried, and a vehicle you are using is destroyed (game text). The wiki says the Vehicle Backup Tool and quest items survive a worm death (wiki, https://awakening.wiki/Sandworm). On this server `SandwormConsequences` is `Backpack`, so a worm death takes your backpack contents rather than everything (server config); whether equipped gear survives was not tested in game.
