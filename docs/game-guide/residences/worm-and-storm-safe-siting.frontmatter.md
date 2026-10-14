---json
{
  "schema": "dune-guide/v1",
  "title": "Worm-safe and storm-safe base siting",
  "description": "How to place a base so sandworms and sandstorms don't cost you: rock not sand, short sand crossings to the tradepost, power for the shield, sheltered parking, and this server's storm settings.",
  "kind": "tip",
  "section": "residences",
  "tags": ["sandworm", "worm", "sandstorm", "storm", "safe", "base location", "shield", "shelter", "garage", "rock"],
  "aliases": ["worm safe base", "storm proof base", "where are worms"],
  "region": "Hagga Basin",
  "related": ["residences/base-sites-by-region", "residences/base-layout-tips", "zones/travel-and-fast-travel"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Worm-safe and storm-safe base siting

Quick answer: build on rock and keep the base powered. Rock is safe from worms (wiki, Sandworm), and you cannot build on open sand anyway ("Cannot build in desert", game text). What actually gets eaten is you and your vehicle on the commute, so pick a rock outcrop with the shortest possible sand crossing to the places you visit. Storms hurt unpowered bases and unsheltered vehicles, so keep the generator fueled and park inside.

## Worms

- Rock is safe; open sand builds threat, and on sand the threat does not decay while you stand still (server config `ThreatDecreasingValuePerSec=0`; see [../world-and-maps.md](../world-and-maps.md)). Each rock island along your route resets the meter: off the sand it drains at 10 per second after 5 seconds (server config).
- Vehicles on sand count as vibration (wiki, Sandworm). A base whose only exit is a long sand run is a base where you will lose bikes.
- Death by worm loses the backpack and destroys the vehicle by default; this server's admin can change `SandwormConsequences` (verified on this server, docs/operations.md).
- Thumpers lure the worm away (game text); the Deep Desert journey uses one to protect a Sandcrawler (game text).

## Storms

- A powered console projects a shield that protects "from enemies" and reduces "sandstorm damage" (game text). When fuel runs out the shield drops and storms wear the base down (Funcom help center, via the bases chapter). The console warns when power is running out (game text).
- On this server, sandstorms warn about 10 seconds ahead, build for 30 seconds and deal 5 (small) or 7 (large) damage per tick to players, buildings, placeables and vehicles (verified on this server, docs/admin.md). Coriolis storms here are announced 6 hours ahead and do no damage unless enabled (verified on this server).
- Vehicles: an unsheltered vehicle takes sandstorm damage, and vehicles parked outside your claim decay over time even if sheltered (game text). Park in a garage inside the claim.
- Pieces disconnected from the main structure can decay (Funcom help center); keep outbuildings attached.
- Plastone is "used in sandstorm-resistant construction" (game text). A 2025 Deep Desert guide says granite bases there need constant repair and recommends Plastone via the faction Stronghold sets (community, pre-1.5, https://www.method.gg/dune-awakening/building-in-the-deep-desert-in-dune-awakening-a-full-guide).

## Placement checklist

1. On rock, away from quicksand and drumsand ("will attract the worm", game text).
2. Short sand hop to your nearest tradepost or route north.
3. Console in a sheltered spot, as the tutorial says ("Move your Sub-fief Console to a sheltered location", game text), placed high enough to leave headroom.
4. Room for a garage inside the claim, and for windtraps and turbines in the open.
