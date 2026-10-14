---json
{
  "schema": "dune-guide/v1",
  "title": "Stamina in combat",
  "description": "What drains stamina in a fight, how to get it back (parries, hydration, skills, uniques), and the server stamina setting.",
  "kind": "system",
  "section": "combat",
  "tags": ["stamina", "stamina cost", "parry", "dash", "block", "hydration", "disciplined breathing", "second wind"],
  "aliases": ["stamina management"],
  "related": ["combat/blocking-and-parrying", "combat/dashing-and-dodging", "combat/downed-state-and-second-wind", "combat/specialization-combat-traits"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Stamina in combat

Quick answer: attacking, blocking, dashing and most abilities spend stamina; parries, hydration and several skills give it back. Dashing out of a stagger also costs stamina, so keep a reserve (game text).

## What costs stamina

- Melee attacks and blocks (per-weapon "Attack Stamina Cost" and "Block Stamina Cost"), dashes ("Dash Stamina Cost" on armor), sprinting, climbing (game text).
- Abilities: in 1.5 most active abilities cost 15 stamina (Crippling Strike, Compel, Stop, Weirding Step, Stunner, Ignore); Deflection drains 2.5 per second plus a per-deflection cost (patch notes 1.5, https://duneawakening.com/news/dune-awakening-console-release-patch-notes/).
- Iron Will (Mentat) blocks lesser Voice effects at the cost of stamina (game text).
- Being hit by Nerve Agents poisons lowers stamina regeneration (game text).

## Getting it back

| Source | Effect |
|---|---|
| Parry | Restores stamina; 10 per parry with swords, daggers and dual blades in 1.5 (patch notes 1.5). |
| Hydration | Above one third hydration, max stamina rises; more above two thirds (game text). Optimized Hydration adds to this (game text). |
| Disciplined Breathing (Swordmaster technique) | Faster stamina recovery (game text). A guide gives up to +20% regeneration (community, https://banrado.de/en/dune-awakening-best-builds, 2026-10-11). |
| General Conditioning, Max Stamina Increase trait | Higher max stamina (game text). The Combat specialization adds +55 max stamina by level 95 (wiki, https://awakening.wiki/Specialization). |
| Thrive on Danger | At low health, all stamina costs drop (game text). |
| Fast Deflection | Deflecting darts replenishes stamina (game text). |
| Second Wind | Taking 40 health damage during Second Wind returns all stamina (patch notes 1.5). |
| Recovery Assistance | Bonus stamina when you recover from downed (game text). |
| Planned Recurrence (Mentat) | Stamina when a nearby deployable expires (game text). |
| Spark-Knife and pulse swords | Small stamina boost on hit (knives) or on parry (swords) (game text). |
| Aramsham's Caress | Its balance "allows the wielder to expend very little energy with each swing" (game text). |

Server knob: "Stamina Drain" (`PlayerStaminaDrain`) scales stamina spent on dodging, blocking and other stamina actions; higher drains faster (game text). This server uses 0.8 (verified on this server).
