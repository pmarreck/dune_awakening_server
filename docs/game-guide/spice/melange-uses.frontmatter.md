---json
{
  "schema": "dune-guide/v1",
  "title": "What Spice Melange is used for",
  "description": "Every known sink for melange in 1.5: Specialization Traits, skill respecs, Mk6 crafting recipes, Landsraad and story deliveries, spiced consumables, and trade.",
  "kind": "item",
  "section": "spice",
  "tags": ["melange", "spice melange", "uses", "traits", "specialization", "respec", "crafting", "mk6", "landsraad", "what to do with spice"],
  "aliases": ["MelangeSpice", "spice"],
  "related": ["spice/refining-melange", "spice/selling-spice", "spice/prescience-and-addiction", "endgame/specializations", "endgame/gear-grades-and-augments", "endgame/landsraad"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Uses of melange

Spice Melange (`MelangeSpice`, stack 500, item data) is "Nothing is worth more" (game text). In 1.5 its main sinks are Specialization Traits, Plastanium-tier crafting and respecs; 1.5 removed it from the build cost of six stations, so a new base needs much less (patch notes 1.5).

| Use | Detail | Source |
|---|---|---|
| Specialization Traits | Traits "become available to purchase with Spice Melange" as each track levels. The wiki sums the primary traits of one track to 750 melange through level 100, 3,750 for all five tracks; cost rises with level. | game text; wiki, https://awakening.wiki/Specializations (2026-10-03) |
| Skill respec | "You can reattribute skill points by paying {amount} Spice Melange from your inventory." Cost steps 0, 5, 10, 20, 50 for consecutive respecs and drops one step every 6 hours. | game text; patch notes 1.3.0.0 (see [../progression-and-skills.md](../progression-and-skills.md)) |
| Crafting | Ingredient in 193 recipes, mostly Mk6 items at the advanced fabricators: for example Buggy Chassis Mk6 55, Buggy Booster Mk6 81, Impure and Filter Extractor Mk6 83 each, The Baron's Bloodbag 94; armor pieces about 41 to 85. Pre-1.5 figures; 1.5 cut Plastanium-tier costs 10 to 25%. | wiki, https://awakening.wiki/Spice_Melange (fetched 2026-10-13); patch notes 1.5 |
| Station build costs | No longer needed for the Advanced Garment, Survival, Vehicle and Weapons Fabricators, the Medium Chemical Refinery or the Augmentation Station. | patch notes 1.5 |
| Landsraad | Mission type "Deliver Spice Melange", plus deliveries of each spice-infused metal dust. | game text |
| Story and contracts | A contract asks you to "Acquire {number} Spice Melange" and deliver it; in Chapter 4 you gather "a suitable bribe of spice melange" for a pilot to Zanovar. | game text |
| Prescience | Spiced food and drink raise "the amount of spice in your blood". Their recipes are not documented here (unverified whether they cost melange). | game text |
| Trade | Vendor base price 6,500 Solari (wiki); sells better to players. | see [selling-spice](selling-spice.frontmatter.md) |

## Carrying it

Melange is dropped on death, unlike ingots and healkits (wiki). On this server death drops only the backpack (`DropEquipmentOnDeath=Backpack`, server config), and melange in the backpack counts. Bank it or store it before risky trips.
