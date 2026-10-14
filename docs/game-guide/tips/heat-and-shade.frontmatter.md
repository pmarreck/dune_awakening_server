---json
{
  "schema": "dune-guide/v1",
  "title": "Heat, sunstroke and using shade",
  "description": "How sunstroke and biome heat drain water, and the practical habits (shade, night travel, caves, stillsuits) that counter them.",
  "kind": "tip",
  "section": "tips",
  "tags": ["heat", "sun", "sunstroke", "overheated", "shade", "shadow", "night", "biome heat", "heat protection", "caves"],
  "aliases": ["heatstroke", "sun damage", "how to stop sunstroke", "shadowplay"],
  "related": ["tips/water-discipline", "tips/safe-travel", "tips/stamina-and-climbing"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Heat, sunstroke and using shade

**Quick answer.** Direct sun fills a sunstroke bar; once it is full, Sunstroke raises your dehydration rate. Step into shadow to avoid it and clear it (game text, tutorials "Sunstroke" and "Shadowplay"). Separately, hotter regions drain water faster no matter what; a stillsuit with better Heat Protection is the answer there (game text, tutorial "Biome Heat").

## Two different heat problems

| Problem | Cause | Fix |
|---|---|---|
| Sunstroke | Time in direct sunlight by day | Shadow: rock overhangs, cliff sides, buildings, caves. Travel at night (game text). |
| Biome heat | Being in a hot region; the HUD compares "Heat Level" to your "Heat Protection" | Higher-tier stillsuits; tier 1 suits have the lowest heat protection (game text; community database figures in [Stillsuits](../survival-combat-crafting.md#stillsuits)). |

## Habits

- Route along cliff faces and through caves rather than across sunlit flats; caves also shelter you from sandstorms (game text; community, https://www.thegamer.com/dune-awakening-traversal-tips-tricks/, pre-1.5).
- Do gathering and base chores at midday, long trips at night: "Travel by night" is the game's own advice (game text, loading tip).
- The Bene Gesserit "Sun Tolerance" passive slows sunstroke buildup (game text).
- The unique hoods (Shadow, Shaded, Pardot's) "reduce the harm caused by direct sunlight" (game text).
- A stilltent shelters from the heat of day and mild sandstorms and lets you drink back retained moisture (game text: "retain some lost moisture while sheltering from the elements"; wiki, https://awakening.wiki/Stilltent).

## This server

`HeatBuildupRate` is 1, the default (server config). Night, shade and cold-region "Cold Buildup" strings exist, but cold content is still placeholder text in this build (game text).
