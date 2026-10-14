---json
{
  "schema": "dune-guide/v1",
  "title": "Surviving sandstorms and Coriolis storms",
  "description": "What to do when a sandstorm warning appears, where to shelter, how much warning you get on this server, and what the weekly Coriolis storm means.",
  "kind": "tip",
  "section": "tips",
  "tags": ["sandstorm", "storm", "shelter", "stilltent", "cave", "coriolis", "warning", "storm damage", "sheltered"],
  "aliases": ["storm coming", "how long is the storm warning", "Coriolis storm"],
  "related": ["tips/base-safety", "tips/vehicle-safety", "tips/heat-and-shade", "tips/safe-travel"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Surviving sandstorms and Coriolis storms

**Quick answer.** When a sandstorm warning appears, get indoors, into a cave or tradepost, or into a stilltent; your shelter status shows above the hydration bar (game text). On this server you get about two minutes between the warning and full strength (server config). Bring your vehicle under a roof too.

## Sandstorms

- Sandstorms show on the map as "Sandstorm" markers; they "are dangerous, especially in the Deep Desert. Seek shelter" (game text).
- Shelter options: your base, caves, tradeposts ("refuge during sandstorms", wiki), and a stilltent, which shelters you in the open and retains some lost moisture (game text).
- After a storm, use a scanner to find buried treasure and uncover it with a Static Compactor (game text).
- The keystone "Rider in the Storm" reduces sandstorm damage to vehicles (game text).

## This server's storms

| Setting | Value | Funcom default |
|---|---|---|
| Warning before buildup | 90 s (`m_WarningBuildupTimeInSeconds`) | 10 s |
| Buildup to full strength | 30 s | 30 s |
| Damage to players per tick, small / large | 4 / 5.5 | 5 / 7 |
| Damage to vehicles per tick, small / large | 1 / 1.4 | 5 / 7 |
| Damage to buildings and placeables | 0 | 5 / 7 |

All values are from this server's `UserGame.ini`, section `[/Script/DuneSandbox.SandStormConfig]` (server config). Whether the client's warning display follows the longer warning was not yet verified (`docs/admin.md`). Some older notes in this guide quote the default 40 seconds; the current setting is the one above.

## Coriolis storms

- Coriolis storms cover all of Arrakis; in the Deep Desert they destroy everything and reshape the map (game text). Get valuables out of the Deep Desert first.
- In Hagga Basin they bring back fog of war over unsurveyed regions and move resource nodes (game text; wiki).
- On this server the Coriolis storm is scheduled, warned 6 hours ahead with a 59-minute final stage, and harmless to players unless the operator enables `m_bCoriolisDoesDamage` (verified on this server, `docs/admin.md`).
