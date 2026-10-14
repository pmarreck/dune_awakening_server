---json
{
  "schema": "dune-guide/v1",
  "title": "Specializations (endgame character progression)",
  "description": "The five Specialization tracks leveled by Landsraad missions: per-level passive bonuses, Traits bought with Spice Melange, notable traits per track, total costs, and which traits matter most.",
  "kind": "system",
  "section": "endgame",
  "tags": ["specialization", "specializations", "traits", "crafting", "gathering", "exploration", "combat", "sabotage", "landsraad", "melange", "augment limit", "pack mule", "skill points"],
  "aliases": ["spec", "specs", "Specialization menu", "keystones", "Without Rhythm", "Pack Mule", "Ghost Data"],
  "related": ["endgame/landsraad", "endgame/gear-grades-and-augments", "spice/melange-uses", "spice/harvesting-by-hand-and-compactor"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Specializations

Specializations are the endgame's long progression: five tracks (Crafting, Gathering, Exploration, Combat, Sabotage) gain XP only from Landsraad missions of the matching category, each level gives a small automatic bonus, and levels unlock Traits you buy with Spice Melange (game text). The menu sits in the Skills tab and opens through the faction journey (game text). Basics and trait names are also in [../progression-and-skills.md](../progression-and-skills.md).

## Scale and cost (wiki, https://awakening.wiki/Specializations, 2026-10-03)

- 100 levels per track, 100 traits per track split into primary and secondary.
- About 44,182 Specialization XP per track to reach level 100, about 220,910 for all five.
- Buying every primary trait in a track costs 750 Spice Melange; all five tracks 3,750. Trait cost rises with level. A community calculator gives individual trait costs from 2 to 40 melange (community, method.gg, cited in the progression chapter).

## Per-level bonuses (wiki)

| Track | Per level | At level 100 |
|---|---|---|
| Crafting | +1% crafted item durability | +100% |
| Gathering | +0.5% mining yield and +0.5% Static Compactor yield | +50% each |
| Exploration | +1% backpack volume | the wiki's intro and table disagree (+59% vs +100%) |
| Combat | +1% damage, +0.5% damage mitigation | +100% / +50% |
| Sabotage | +0.5% damage to staggered targets | +50% in the table, +29.5% in the intro |

## Notable traits

| Track | Traits | Source |
|---|---|---|
| Crafting | Ranged Augmentation Limit (level 1), Melee Augmentation Limit (3), Garment Augmentation Limit, Repair Master (5), Recycling Yield, Augment Fabrication Mastery, Superior Spice/Ore/Chemical Yield (bonus refining output), Ghost Data (100: +15% chance to duplicate a schematic) | wiki; names and refining effect game text |
| Gathering | Effective Salvaging (1), Pickup Yields (15), Effective Mining and Yield Jackpot (recurring), Superior Compactor Range (recurring), Compactor Safety (less worm threat from the compactor) | wiki; game text |
| Exploration | Pack Mule (1 and 100; game text: "Increases inventory size by 1 row"), Rider in the Storm (less sandstorm damage), Superior Fuel Efficiency (recurring), Without Rhythm ("Reduced worm threat from moving across the sand") | wiki; game text. Without Rhythm's track is unverified. |
| Combat | Skill Points (+1 to +5 each, recurring), Max Health Increase, Max Stamina Increase | wiki; game text |
| Sabotage | Head Hunter (1 and 100, +5% headshot damage), Soft Step (2), Explosive (8), Loosen the Purse Strings (more House Scrip), Greasing Palms (cheaper Landsraad bribes), Landsraad Contributor | wiki; game text |

Each track also has a cosmetic helm variant at level 75 (wiki).

## Priorities (advice, not data)

For a small group without PvP, the Augmentation Limit traits unlock augment slots and are the gate to the top of gear progression; Pack Mule and the gathering yield traits pay off immediately; Without Rhythm and Compactor Safety make spice runs safer. Combat's Skill Points traits add skill points on top of those from leveling (game text: "Gain an additional skill point"); whether any other source exists is unverified.

## On this server

`LandsraadSpecializationXpMultiplier=1` (server config), the default. The admin can raise it (0 to 10) to speed Specializations for a two-player world; see [private-two-player-world](private-two-player-world.frontmatter.md).
