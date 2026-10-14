---json
{
  "schema": "dune-guide/v1",
  "title": "The Deep Desert as endgame",
  "description": "What makes the Deep Desert the endgame map: weekly Coriolis wipe and reshuffle, PvE and PvP instances, fixed Shield Wall sites versus shifting content, titanium, stravidium and big spice, control points, grandfather worms, and temporary bases.",
  "kind": "region",
  "section": "endgame",
  "tags": ["deep desert", "coriolis", "weekly reset", "wipe", "pvp", "pve", "instance", "titanium", "stravidium", "control point", "grandfather worm", "endgame", "temporary base"],
  "aliases": ["DD", "DeepDesert_1", "Charting the Depths"],
  "region": "Deep Desert",
  "related": ["endgame/deep-desert-loot-and-schematics", "spice/deep-desert-spice", "spice/harvesting-worm-risk", "endgame/landsraad", "endgame/private-two-player-world"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# The Deep Desert

The Deep Desert, north of the Shield Wall, holds the richest resources (titanium, stravidium, medium and large spice fields), its own testing stations and wrecks, and is wiped and reshaped by the Coriolis storm each week on official worlds (game text; see the table in [../world-and-maps.md](../world-and-maps.md)). The weekly cycle is the endgame loop: scout, harvest and loot, carry it home before the storm.

## Weekly cycle

- On multiplayer servers, after a Coriolis storm "the Deep Desert map will be completely changed... All spice fields will be gone. Testing stations and shipwrecks buried, new ones revealed" (game text).
- Points of interest along rows A and B (the Shield Wall) are fixed and survive the storm; most of the rest changes weekly (wiki, https://awakening.wiki/Deep_Desert, 2026-09-29).
- Landsraad decrees last until shortly before the Deep Desert reset (wiki, https://awakening.wiki/Landsraad, 2026-10-08).
- Single-player since 1.5: the Deep Desert "never resets and buildings are never wiped", and the storm no longer instantly kills (patch notes 1.5.3.0, https://duneawakening.com/news/dune-awakening-console-release-patch-notes/).

## PvE and PvP

Since 1.3.20.0 every official world has at least one PvE and one PvP instance, chosen on entry from the Overland map; the PvP one is PvP everywhere except the Shield Wall rows A and B and pays 2.5x mining and spice harvesting (wiki; patch notes). PvP is not required for progression in 1.5 (community, boostroom 2026-09-29). Self-hosted worlds choose with the PvP setting; see [private-two-player-world](private-two-player-world.frontmatter.md).

## What to do there

| Activity | Notes | Source |
|---|---|---|
| Spice | Medium fields from row D, the single large field from row F; Sandcrawler plus Carrier Ornithopter | wiki; see [../spice/deep-desert-spice.frontmatter.md](../spice/deep-desert-spice.frontmatter.md) |
| Titanium and stravidium | Mk6 (Plastanium) materials; they do not spawn in Hagga Basin | community, method.gg (cited in world-and-maps) |
| Loot and schematics | Testing Stations 37, 93, 148, 185, 186, 217, plus Botany Resort, Spice Library and The Museum; ten named wrecks; random buried stations, forgotten caves, unrecovered shipwrecks | wiki; game text |
| Control Points | Landsraad territory objectives: "Gaining Control", "Contested", "Per minute while holding control point". The journey asks you to locate one. | game text; see [landsraad](landsraad.frontmatter.md) |
| Grandfather worms | Over the large field only; engulf the whole area | wiki; see [../spice/harvesting-worm-risk.frontmatter.md](../spice/harvesting-worm-risk.frontmatter.md) |
| House representatives | House Maros and House Wayku are listed on the Deep Desert page | wiki |
| Temporary bases | 50% building cost, 100% refund on demolish; base backup and recycling do not work there | game text; 1.5 announcement |

Funcom's defaults enable two control points per Landsraad cycle on dedicated servers (`m_ControlPointsPerCycle=2`, `m_bIsTerritoryControlEnabled=True`, server config). Where they spawn is not documented.

## Enemies

Atreides and Harkonnen troops and deserters, including Plastanium-tier compositions such as `NPCComp_Harkonnen_DeepDesert6` and a radiation variant (server config; game text). 1.5 says higher-tier enemies dash more (patch notes 1.5).

## Getting out

The Deep Desert can only be exited "from the Shield Wall to the south" (game text). Personal inventory and cargo carried in ornithopter storage travel with you (see [../world-and-maps.md](../world-and-maps.md)); a Sandcrawler cannot travel on the Overland map (wiki).
