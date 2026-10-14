---json
{
  "schema": "dune-guide/v1",
  "title": "Healkits and combat consumables",
  "description": "Healing in a fight: Healkit tiers, ids and stack size, what they cleanse, healing skills, and other combat consumables (Iodine Pill, Toxin-Absorption Pills, spice).",
  "kind": "item",
  "section": "combat",
  "tags": ["healkit", "heal", "healing", "medkit", "bandage", "consumable", "iodine pill", "antidote", "poison", "cleanse"],
  "aliases": ["medkit", "health pack", "HealthPack_Channeled"],
  "related": ["combat/damage-types-and-status-effects", "combat/grenades-and-gadgets", "combat/downed-state-and-second-wind", "combat/pve-boss-tactics"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Healkits and combat consumables

Quick answer: Healkits "heal wounds and cleanse ongoing effects" (poison, bleed, burn). Use one from the radial wheel, hotbar or inventory (game text). There are four tiers, each stacking to 20 (item data).

## Healkits (names game text, ids and stacks item data)

| Name | Id | Stack |
|---|---|---|
| Healkit | `HealthPack_Channeled` | 20 |
| Healkit Mk2 | `HealthPack_Channeled_2` | 20 |
| Healkit Mk4 | `HealthPack_Channeled_3` | 20 |
| Healkit Mk6 | `HealthPack_Channeled_4` | 20 |

The ids say "Channeled", which suggests a short use time (inference). Early Healkits are crafted from Plant Fiber in the crafting menu (game text). Heal amounts per tier are not in game text (unverified). The Crafting specialization can double consumable crafts ("Batch Crafting Chance") (game text).

## Healing skills (game text)

Field Medicine passive (more instant healing from healkits), Self-Healing, Vitality, Recovery and Trauma Recovery (Bene Gesserit), Thrive on Danger (Swordmaster, faster regen at low health), Healing Capsule, Healer-Seeker, Healing Exploiter, Triage, Overgrowth (over-heal), Resilient Aid, Spice Medicine (tree placement of the last group unverified). Prescience raises passive healing (game text).

## Other combat consumables

| Item (id) | Effect |
|---|---|
| Iodine Pill (`AntiRadiationPill`, stack 20) | Against radiation; recommended for pushing Testing Station 89 (game text; wiki, https://awakening.wiki/Testing_Station_89). |
| Experimental Toxin-Absorption Pills (`Consumable_Buff_PoisonStackIncrease`) | Poison absorption at half speed; needs twice the stacks to poison you. Top drop (19.2%) of Testing Station 195 (game text; wiki, https://awakening.wiki/Testing_Station_195). |
| Spice food and drink | Build toward Prescience; see [prescience](prescience-in-combat.frontmatter.md). |
| Blood sacks | Drinking blood hydrates but lowers max health (game text). |

There is no bandage item in 1.5; old Medical Kit and Medical Stim items are marked "OLDDONOTUSE" (game text). An "HP Boost" consumable name exists without a description (game text; unverified).
