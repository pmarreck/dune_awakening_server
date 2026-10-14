---json
{
  "schema": "dune-guide/v1",
  "title": "Spice-infused metal dusts, Spice Residue and spice fuel",
  "description": "The spice-infused Copper-to-Plastanium dusts that Unique gear needs, where they come from, the Landsraad deliveries that ask for them, and how Spice Residue becomes fuel for the spice generator.",
  "kind": "resource",
  "section": "spice",
  "tags": ["spice-infused", "spice infused dust", "unique", "unique component", "spice residue", "spice-infused fuel cell", "spice generator", "secure container", "landsraad delivery"],
  "aliases": ["T1UniqueComponent", "T2UniqueComponent", "T3UniqueComponent", "T4UniqueComponent", "T5UniqueComponent", "T6UniqueComponent", "SpiceResidue", "SpicedFuelCell", "Spice-infused Copper Dust", "Spice-infused Plastanium Dust"],
  "related": ["spice/refining-melange", "endgame/gear-grades-and-augments", "endgame/landsraad"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Spice-infused materials

"Truly Unique items often rely on spice-infused metal to enhance their qualities," and these metals are "locked away in their most secure containers" (game text). They are looted, not refined from melange: no recipe in the game text makes them (game text; absence of a recipe is not proof).

## Dusts

| Dust | Id (item data) | Stack |
|---|---|---|
| Spice-infused Copper Dust | `T1UniqueComponent` | 500 |
| Spice-infused Iron Dust | `T2UniqueComponent` | 500 |
| Spice-infused Steel Dust | `T3UniqueComponent` | 500 |
| Spice-infused Aluminum Dust | `T4UniqueComponent` | 500 |
| Spice-infused Duraluminum Dust | `T5UniqueComponent` | 500 |
| Spice-infused Plastanium Dust | `T6UniqueComponent` | 500 |

Each tier's Unique schematics use the matching dust (game text, see [../survival-combat-crafting.md](../survival-combat-crafting.md)). Landsraad missions ask for "Deliver Spice Infused {Copper ... Plastanium} Dust" (game text), so hoarded dust has a second use.

## Spice Residue and spice fuel

- Every spice refining order also returns Spice Residue (stack 1,000, `SpiceResidue`, item data): 5 per small order, 75 per medium, 1,000 per large (wiki).
- Spice-infused Fuel Cell (`SpicedFuelCell`, stack 500, item data) is "made from fuel cells and spice residue" in a Medium Chemical Refinery (game text).
- It powers the Spice-Powered Generator, "a spice fuel-powered generator that provides power to a base by processing Spice-Infused Fuel Cells" (game text); 1.5 hours per cell and 1,000 power per generator (wiki, see [../bases-and-building.md](../bases-and-building.md)).
