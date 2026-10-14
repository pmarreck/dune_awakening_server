---json
{
  "schema": "dune-guide/v1",
  "title": "Staking Unit",
  "description": "Item that extends a land claim: recipe (15 Steel + 15,000 Solari), research, limits and what each one adds.",
  "kind": "recipe",
  "section": "crafting",
  "tags": ["staking unit", "vertical staking unit", "land claim", "expand base", "sub-fief", "solari"],
  "aliases": ["StakingUnit", "StakingUnitVertical", "Staking Unit Set"],
  "related": ["crafting/survival-fabricator", "crafting/base-building-costs", "crafting/steel-ingot"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Staking Unit

Quick answer: 15 Steel Ingot + 15,000 Solari at a Survival Fabricator, 20 s (wiki, https://awakening.wiki/Staking_Unit, edited 2026-10-05, data unchanged from pre-1.5). Research the "Staking Unit Set" (Staking Unit and Vertical Staking Unit) at the Steel tier for 10 Intel; it is "Crafted in a Survival Fabricator and built with the Construction Tool" (game text; wiki research list). Ids `StakingUnit` (stack 10) and `StakingUnitVertical` (item data).

- Limits (wiki, same page): at most 5 Staking Units per claim; each horizontal unit adds roughly a 5x5 block for the full claim height and 15 power draw, and raises build caps by 500 building pieces, 8 production, 6 light, 15 storage, 70 decoration, 7 door and 2 projection placeables (caps 5,000 / 80 / 60 / 150 / 700 / 70 / 20). Vertical units adjust height and count toward caps without power draw.
- The Solari cost is part of the recipe, so this server's `CraftingCost=0.5` would presumably halve it as well (server config; unverified in game).
- A 2025 guide gave the same recipe (bases chapter). Base vendor price 25,000 (wiki item data).
