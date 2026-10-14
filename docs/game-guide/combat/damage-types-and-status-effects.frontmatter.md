---json
{
  "schema": "dune-guide/v1",
  "title": "Damage types and status effects",
  "description": "Every damage type, the matching armor mitigation stats, and how bleed, poison, burn and radiation build up and are cleared.",
  "kind": "system",
  "section": "combat",
  "tags": ["damage type", "blade", "dart", "concussive", "energy", "fire", "poison", "bleed", "burn", "radiation", "mitigation", "status effect", "debuff"],
  "aliases": ["status effects", "DoT", "damage over time", "resistances"],
  "related": ["combat/shields-and-the-slow-blade", "combat/light-armor", "combat/heavy-armor", "combat/augments", "combat/healkits-and-combat-consumables"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Damage types and status effects

Quick answer: weapons deal blade, light dart, heavy dart, disruptor dart, concussive, energy or fire damage; poison, bleed, burn and radiation build up as stacks and then hurt you over time. Armor has a separate mitigation value for each, and Healkits cleanse ongoing effects (game text).

## Damage types (game text, `DamageType_*`)

Blade, Light Dart, Heavy Dart, Disruptor Dart, Heavy Disruptor Dart, Concussive, Energy, Electricity, Fire, Poison, Bleed, Radiation Buildup, Sandstorm, Coriolis, Quicksand, Pure. Frostbite also exists but cold content is placeholder text in this build.

## Armor mitigation stats (game text, item stats)

Armor Value, Blade, Dart, Light Dart, Heavy Dart, Concussive, Energy, Explosive, Fire, Poison, Radiation, Sandstorm (levels 1 to 3), Coriolis. Heavy Darts "can pierce certain types of armor" (game text). Garment augments trade one resistance for another; see [augments](augments.frontmatter.md).

## Status effects

| Effect | How it works (game text) | Counters |
|---|---|---|
| Poison | Stacks build ("In danger of becoming poisoned"), then damage over time. Passes through shields. | Healkit; Poison Tolerance, Metabolize Poison; prescience gives poison tolerance; Experimental Toxin-Absorption Pills double the stacks needed to poison you; Static Compactor clears poison clouds. |
| Bleed | Stacks ("In danger of bleeding"), then damage over time. | Healkit; Bleed Tolerance. |
| Burn | Stacks ("In danger of catching on fire"), then damage over time. | Healkit; fire mitigation; Static Compactor clears fire. |
| Radiation | Stacks; status reads "In danger of instant death". | Radiation Suit, Iodine Pill, radiation augments. |
| Stun | "Prevents action" (Stunner, Weirding Step, Collapse Grenade). | Dash once it ends; Iron Will against Voice. |
| Slow / crippled | Crippling Strike, Gravity Field, Suspensor Blast reduce movement. | |

- Weapon cards list "Poison Damage Over Time" and "Fire Damage Over Time" (game text).
- Spitdart Poison is its own debuff, from JABAL Spitdart rifles (game text).
- 1.5.15.0 (test client, 2026-09-30) clears negative status effects when you go down (patch notes 1.5.15.0, https://duneawakening.com/news/public-test-client-patch-1-5-15-0/); whether that is live on this server's build is unverified.
- Poison builds that weaponize stacks: Clotting Chemicals, Nerve Agents, Incubator, Toxic Trait, Corpse Cloud, Spice Infused Poisons, Expunge (game text). Several of these names are not placed in a tree by any source; see [mentat-build](mentat-build.frontmatter.md).
