---json
{
  "schema": "dune-guide/v1",
  "title": "Missile launchers",
  "description": "Infantry missile launchers: the homing Adept and Regis versions, The Ancient Way, missile ammo, shield interaction and augments.",
  "kind": "weapon",
  "section": "combat",
  "tags": ["missile launcher", "rocket launcher", "rocket", "missile", "homing", "explosive", "heavy weapon", "ancient way"],
  "aliases": ["rocket launcher", "RPG", "The Ancient Way"],
  "related": ["combat/ranged-weapons-and-ammo", "combat/trooper-gunner-build", "combat/shields-and-the-slow-blade", "combat/unique-weapons"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Missile launchers

Quick answer: infantry missile launchers fire Missiles (`InfantryRocketAmmo`, up to 250 per give); the base launcher shoots straight, the Adept and Regis versions fire homing missiles (game text; item data). Shields only partly mitigate rockets (wiki, https://awakening.wiki/Holtzman_Shield).

## Lines (names game text, ids item data)

| Name (id) | Notes |
|---|---|
| Missile Launcher (`D_RocketLauncher`) | "A launcher that shoots missiles." |
| Adept Missile Launcher (`RocketLauncher_3`) | Homing rockets. |
| Regis Missile Launcher (`RocketLauncher_2`) | Homing missiles. |
| The Ancient Way (`RocketLauncher_Unique_Homing_06`) | Unique with tracking missiles; drops in Testing Stations 136 and 195 (wiki, https://awakening.wiki/Testing_Station_136). 1.5.15.0 test notes raise its delay between shots when augmented for multiple rockets from 0.71 s to 1.6 s (patch notes 1.5.15.0, https://duneawakening.com/news/public-test-client-patch-1-5-15-0/; not confirmed live). |

Vehicle rocket pods use a separate "Rocket" ammo (game text).

## Augments (game text)

Missile Launcher Fragmenter (bigger area, faster reload, less shield damage), Disruptive Coating (more shield damage, slower reload), Quickloader, Heavy Payload (more damage, less shield damage and area), Obliterator (more shield damage and recoil control, less accuracy).

Heavy Weapon Damage and Heavy Weapon Agility (Trooper) apply (game text).
