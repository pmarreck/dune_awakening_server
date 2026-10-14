---json
{
  "schema": "dune-guide/v1",
  "title": "Base building costs",
  "description": "What land claims, consoles and building pieces cost: Sub-Fief Consoles, CHOAM Shelter and Facility pieces, Plastone, and Deep Desert discounts.",
  "kind": "recipe",
  "section": "crafting",
  "tags": ["base building cost", "building pieces", "foundation", "wall", "granite", "sub-fief console", "choam shelter", "choam facility", "plastone", "deep desert"],
  "aliases": ["building costs", "construction costs"],
  "related": ["crafting/staking-unit", "crafting/plastone", "crafting/station-progression"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Base building costs

Quick answer: the consoles and the basic building sets are cheap. A Sub-Fief Console costs 25 Salvaged Metal and an Advanced Sub-Fief Console 40 (wiki, https://awakening.wiki/Sub-Fief_Console, https://awakening.wiki/Advanced_Sub-Fief_Console). CHOAM Shelter pieces cost Granite Stone: 12 per foundation and 8 per wall, floor, roof or stair (wiki, https://awakening.wiki/CHOAM_Shelter_Set). The Construction Tool is 20 Salvaged Metal at a Fabricator (wiki).

| Set | Foundation | Wall / floor / roof / stairs | Door |
|---|---|---|---|
| CHOAM Shelter (Basic Construction Kit) | 12 Granite | 8 Granite | 13 (wide door 24) |
| CHOAM Facility (Advanced Construction Kit) | 15 Granite | 10 Granite | 17 (door frame) |

Source: rendered wiki set pages, fetched 2026-10-13 (version not stated; possibly pre-1.5). Granite Stone is `Stone` in item data ("A common building material", game text). Plastone is the "sandstorm-resistant" building material (game text); which sets use it is unverified here; see [plastone](plastone.frontmatter.md).

- In the Deep Desert building costs 50% less and demolishing refunds 100% (game text; bases chapter).
- This server's `BuildingCostMultiplier=1` leaves building costs at default (server config).
- Other sets (Water Shipper, Smuggler, Pentashields) and land-claim rules are in the bases chapter.
