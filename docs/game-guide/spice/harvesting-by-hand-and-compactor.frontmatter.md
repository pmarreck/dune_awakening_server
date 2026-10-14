---json
{
  "schema": "dune-guide/v1",
  "title": "Harvesting spice by hand and with a Static Compactor",
  "description": "The two on-foot ways to collect Spice Sand, the compactor variants and their trade-offs, the Spice Mask, and the skills and traits that raise yield.",
  "kind": "tip",
  "section": "spice",
  "tags": ["harvest spice", "spice sand", "static compactor", "compactor", "industrial static compactor", "omni static compactor", "compact compactor", "spice mask", "gathering", "power pack"],
  "aliases": ["ChoamCom1", "ChoamCom2", "StaticCompactor_CR", "StaticCompactorTier6", "StaticCompactor_Unique_Compact_03", "StaticCompactor_Unique_Compact_06", "Combat_Light_SpiceMask", "compacter"],
  "related": ["spice/spice-fields", "spice/harvesting-worm-risk", "spice/sandcrawler-and-carrier", "spice/prescience-and-addiction", "endgame/specializations"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Harvesting by hand and with a Static Compactor

Spice Sand "can be harvested by hand or with a Static Compactor at Spice Blow sites before the Worm arrives" (game text). Hand gathering needs no tool but is the slowest and yields the least before the worm comes; a compactor packs sand into clumps you then pick up (wiki, https://awakening.wiki/Spice_Fields, 2026-09-19).

## Static Compactor family

All compactors are "point and shoot" tools that compact flour sand or spice sand "into a clump that can be picked up" and drain a Power Pack on each use (game text). They also clear fire and poison clouds and uncover buried treasure after storms (game text; see the survival chapter).

| Item | Id (item data) | Notes |
|---|---|---|
| Static Compactor | `ChoamCom1`, `StaticCompactor_CR` | Base tool. Vendor price 6,100 Solari; crafted from 10 Iron Ingots + 7 EMF Generators in 15 s; power use 41 per use; gather rate "Low" (wiki, https://awakening.wiki/Static_Compactor, 2026-10-05) |
| Industrial Static Compactor | `ChoamCom2` | "Industrial tool for compacting sand and spice" (game text); stats unverified |
| Omni Static Compactor | `StaticCompactorTier6` | Plastanium tier; its text mentions only spice fields (game text); stats unverified |
| Compact Compactor Mk3 to Mk6 | `StaticCompactor_Unique_Compact_03` to `_06` | Unique; "draws less power and reduces worm attention" (game text) |

Higher-tier compactors add compaction area or reduce worm threat (wiki). No source gives per-tier numbers.

## Spice Mask

The Spice Mask (`Combat_Light_SpiceMask`) "filters out spice" so Dunemen can work fields without "adverse addictive effects" (game text). The Hagga Basin late-game journey "The Spice Must Flow" has you research, fabricate and equip one, then harvest with a compactor while wearing it (game text). Wear it if you do not want field exposure to push you toward Prescience. A cosmetic "Choam Spice Mask" variant exists (item data).

## Yield bonuses

- Planetologist passive "Compaction" improves compactor yield (game text).
- Specialization, Gathering track: per-level +0.5% Static Compactor Yield up to +50% at level 100; traits "Superior Compactor Range" (recurring) and "Compactor Safety" (less sandworm threat from compactor use) (wiki, https://awakening.wiki/Specializations, 2026-10-03; names and effects game text).
- This server triples gathering output (`Dune.GlobalMiningOutputMultiplier=3.0`, server config). Whether it covers spice pickup is not verified in game.

## Technique

- Compactor clumps are separate pickups; harvest a batch, collect, and leave when the threat meter turns orange. Retreat to rock or take off in an ornithopter until the meter clears, then return (wiki, https://awakening.wiki/Sandworm, 2026-09-16).
- Both picking up spice and compacting it add worm threat (`HarvestSpicePickupThreatUnit=10`, `HarvestSpiceCoalesceThreatUnit=10`, server config). See [harvesting-worm-risk](harvesting-worm-risk.frontmatter.md).
