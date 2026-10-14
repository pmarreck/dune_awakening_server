---json
{
  "schema": "dune-guide/v1",
  "title": "Mk6 gear, Uniques, item Grades and Augmentations",
  "description": "The top gear tier (Plastanium, Mk6), what Unique means, Grades 1 to 5 on Unique Mk6 items and augments, how the Augmentation Station works, augment slots from Specialization traits, and 1.5's bell-curve rolls.",
  "kind": "system",
  "section": "endgame",
  "tags": ["mk6", "plastanium", "unique", "grade", "item grade", "augment", "augmentation", "augmentation station", "augment slot", "best gear", "endgame gear", "schematic patterns"],
  "aliases": ["T6", "tier 6", "Augment Station", "Modding Station", "Augmentation Schematic Patterns", "graded gear"],
  "related": ["endgame/challenge-testing-stations", "endgame/specializations", "endgame/deep-desert-loot-and-schematics", "spice/spice-infused-materials"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Mk6 gear, Grades and Augmentations

Plastanium (Mk6, "tier 6") is the top material tier (wiki; see [../vehicles.md](../vehicles.md)). At the top end, "Plastanium Tier Unique items and Augmentations can be found in Grades from 1-5. A higher Grade will result in improved statistics" (game text). Only Plastanium-tier Unique items can be augmented (game text).

## Uniques

Unique items are named variants with special properties, crafted from schematics that drop in the world; their recipes use spice-infused metal dust of the matching tier (game text; see [../spice/spice-infused-materials.frontmatter.md](../spice/spice-infused-materials.frontmatter.md)). Sources are in [deep-desert-loot-and-schematics](deep-desert-loot-and-schematics.frontmatter.md).

## Grades

- Grades 1 to 5 apply to Plastanium Unique weapons and armor and to augmentations; ungraded versions also exist (game text).
- Graded gear and augments drop from the challenge testing stations; the grade mix depends on the difficulty level (patch notes 1.5.3.0; see [challenge-testing-stations](challenge-testing-stations.frontmatter.md)).
- The Exchange filters by "GRADE" and weapon schematics on the Exchange have a grade selector (game text; patch notes 1.5.3.0).
- The Landsraad crafting vendor sells "specialized components required to craft high quality items and augmentations" for House Scrip (game text). One is the Offworld Regis Compound (`LandsraadComponent`, stack 500, item data), "used to fabricate high quality gear and augmentations", which must first be processed ("adapted to local environments") in an Advanced Survival Fabricator (game text). The Chapter 3 augmentation journey has you buy one (game text).

## Augmentation Station

- Augments "improve the base statistics of weapons and garments via the Augmentation Station" (game text).
- Applying one is permanent: "The augmentation cannot be removed once attached", and it reduces the item's maximum durability (game text). This server has `bEnableItemMaxDurabilityLoss=False` (server config); the server setting text says the toggle governs max-durability loss on repair or augment, so augmenting may not cost max durability here (inferred, unverified in game).
- Slots are limited; buy "Ranged / Melee / Garment Augmentation Limit" traits in the Crafting specialization to add slots (game text). The wiki places Ranged Augmentation Limit at Crafting level 1 and Melee at level 3 (wiki, https://awakening.wiki/Specializations, 2026-10-03).
- Augmentation Schematics come from Overland dungeons after faction training; recycle unwanted ones into Augmentation Schematic Patterns, which are needed to craft other augmentations (game text).
- 1.5 changed augment stat rolls to "more of a bell curve than an exponential curve": good rolls are more common, the chance of the maximum roll is unchanged (patch notes 1.5.3.0).
- 1.5 removed Spice Melange from the Augmentation Station's build cost (patch notes 1.5).
