---json
{
  "schema": "dune-guide/v1",
  "title": "Refining Spice Sand into Spice Melange",
  "description": "The three Spice Refineries, their sand-water-melange ratios and speeds, which is most efficient, bonus-yield skills and decrees, and how refining behaves on this server.",
  "kind": "station",
  "section": "spice",
  "tags": ["spice refinery", "refine spice", "melange", "spice sand", "spice residue", "small spice refinery", "medium spice refinery", "large spice refinery", "ratio", "water", "refining"],
  "aliases": ["SmallSpiceRefinery", "MediumSpiceRefinery_Patent", "LargeSpiceRefinery_Patent", "MelangeSpice", "SpiceResidue", "RefinedSpiceRecipe", "MediumSpice_Recipe", "T6_LargeSpice_Recipe"],
  "related": ["spice/melange-uses", "spice/spice-infused-materials", "spice/spice-fields", "endgame/landsraad"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Refining melange

Put Spice Sand and water into a powered Spice Refinery; it returns Spice Melange plus Spice Residue (game text; wiki). The Large Spice Refinery is "more efficient than other spice refineries" (game text): it gets twice the melange per sand of the small one and uses half the water per melange.

## Ratios

Recipes from the wiki (https://awakening.wiki/Spice_Melange, fetched 2026-10-13, page says "added in 1.1.0"; 1.5 cut many other costs, so recheck in game):

| Refinery (item id) | Input | Output | Time | Melange per 1,000 sand | Water per melange |
|---|---|---|---|---|---|
| Small Spice Refinery (`SmallSpiceRefinery`) | 100 sand + 750 mL | 1 melange + 5 residue | 180 s | 10 | 750 mL |
| Medium Spice Refinery (`MediumSpiceRefinery_Patent`) | 750 sand + 7,000 mL | 10 melange + 75 residue | 450 s | 13.3 | 700 mL |
| Large Spice Refinery (`LargeSpiceRefinery_Patent`) | 10,000 sand + 75,000 mL | 200 melange + 1,000 residue | 2,700 s | 20 | 375 mL |

The last two columns are arithmetic on the wiki figures. All refineries need base power (game text). Item ids are item data.

## Bonus yield

- Funcom's server defaults give the spice recipes a crafting-output multiplier keyed to a "SpiceRefining" bonus level and a bonus chance: the small recipe (`RefinedSpiceRecipe`) doubles at bonus levels 1 to 3, and the medium and large recipes multiply by 1.15, 1.45 and 1.75 at levels 1, 2 and 3 (`m_CraftingOutputMultiplierPerRecipeList`, server config). How a player reaches each level is not documented; the matching skill stat is "Bonus Yield Chance (Spice Refining)" (game text).
- The Specialization trait "Superior Spice Yield" gives "a chance to get extra resources from refining orders in the Spice Refineries" (game text). A general "Refining Yield" keystone also exists (game text).
- Landsraad decrees: "CHOAM Refining Contract" cuts refining times and repair costs by 75%; "CHOAM Production Contract" cuts refining and crafting costs, water included, by 25%, but not for base materials below tier 4 (wiki, https://awakening.wiki/Landsraad, 2026-10-08; refining contract also game text).

## On this server

- `CraftingTimeMultiplier=0` (server config), which this project's operations notes list as instant crafting and refining. Expect refinery orders to finish immediately; the real limit is sand and water.
- `CraftingCost=0.5` and `WaterExtractionRate=0.5` (server config). Whether the cost multiplier halves refinery inputs is unverified.

## Tips

- Melange stacks to 500, Spice Sand to 2,500, Spice Residue to 1,000 (item data).
- Keep residue: it becomes Spice-infused Fuel Cells for the spice generator (see [spice-infused-materials](spice-infused-materials.frontmatter.md)).
- Patch 1.5.3.5 fixed water problems in fabricators and refineries (patch notes, summarized in [../economy-social-versions.md](../economy-social-versions.md)).
