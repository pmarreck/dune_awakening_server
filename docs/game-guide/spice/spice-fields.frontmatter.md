---json
{
  "schema": "dune-guide/v1",
  "title": "Spice fields (small, medium, large)",
  "description": "What a spice field is, the three sizes, where each spawns, how many can exist at once on each map, and roughly how much Spice Sand each holds.",
  "kind": "resource",
  "section": "spice",
  "tags": ["spice field", "spice bed", "spice sand", "small spice field", "medium spice field", "large spice field", "hagga basin", "deep desert", "where to find spice"],
  "aliases": ["spice beds", "spice patch", "SpiceSand", "BP_SpiceField_Small", "BP_SpiceField_Medium", "DA_FieldType_Spice_Large"],
  "related": ["spice/spice-blows", "spice/harvesting-by-hand-and-compactor", "spice/sandcrawler-and-carrier", "spice/deep-desert-spice", "spice/harvesting-worm-risk"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Spice fields

Spice fields are patches of Spice Sand on open sand, created by spice blows. Hagga Basin only gets small fields; medium fields appear from Deep Desert row D northward and the single large field from row F northward (wiki, https://awakening.wiki/Spice_Fields, edited 2026-09-19). They are violet when fresh and turn rust-brown as the melange oxidizes (game text).

## Sizes

| Size | Where | Full harvest without yield bonuses | At most active at once (server config) |
|---|---|---|---|
| Small | Hagga Basin open sand (Eastern and Western Vermillius Gap, Mysa Tarill, Sheol); Deep Desert everywhere except rows A and I (wiki) | 500 Spice Sand (wiki) | Hagga Basin 5; Deep Desert 60 |
| Medium | Deep Desert, row D and north (wiki) | 15,000 Spice Sand (wiki) | Deep Desert 12 |
| Large | Deep Desert, row F and north, in a crater that stays visible when inactive; several possible sites, one active at a time (wiki) | 250,000 Spice Sand (wiki) | Deep Desert 1 |

The per-map caps come from Funcom's `[/Script/DuneSandbox.SpiceHarvestingSystem]` defaults in the server's `DefaultGame.ini` (build 25789279): `Survival_1` (Hagga Basin) allows 5 small fields primed and 5 active and lists no medium or large entry; `DeepDesert_1` allows 60 small, 12 medium and 1 large (server config). That agrees with the wiki's claim that Hagga Basin has small fields only. A primed field is presumably one waiting to blow (inferred from the setting names). The same section sets `m_bPlayerMustWitnessBloom=False`, so fields form whether or not anyone is nearby (server config; meaning inferred from the name).

Yield figures disagree between sources. A KeenGamer guide gives about 500 for small, 5,000 to 10,000+ for medium and 15,000 to 20,000+ for large (community, https://www.keengamer.com/articles/guides/dune-awakening-deep-desert-spice-harvesting-guide-pvp-pve/, date unknown, probably pre-1.5). Treat the wiki numbers as the better source but unverified on this server. This server multiplies gathering output by 3 (`Dune.GlobalMiningOutputMultiplier=3.0` and the vehicle equivalent, server config); whether that applies to spice pickup has not been checked in game.

## Finding them

- The map has a "Spice Field" resource filter and marker (game text). Fields are visible from far away because of the blow's purple cloud (game text).
- The Planetologist passive Spice Surveyor lets you "recognize the density of a spice bed from surveys", which is "of most use in the Deep Desert" (game text).
- Contract item "Spice Field Records" hints at nearby fields (game text).
- In the Deep Desert the Coriolis storm removes all fields: "All spice fields will be gone" (game text).

## Notes

- Standing in a field exposes you to spice and pushes you toward Prescience (game text); see [prescience-and-addiction](prescience-and-addiction.frontmatter.md).
- Fields only form where sandworms patrol (wiki), so every field is worm territory. See [harvesting-worm-risk](harvesting-worm-risk.frontmatter.md).
