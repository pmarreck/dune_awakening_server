---json
{
  "schema": "dune-guide/v1",
  "title": "Cutteray (mining tool)",
  "description": "The handheld mining laser: every tier from Improvised to Mk6 and the uniques, what each can mine, recipes, power use and relative yields.",
  "kind": "item",
  "section": "resources",
  "tags": ["cutteray", "mining", "mining laser", "tool", "analysis mode", "yield", "mk1", "mk2", "mk3", "mk4", "mk5", "mk6", "unique"],
  "aliases": ["cutter ray", "mining tool", "MiningTool_1h_Standard", "MiningTool_1h_Heavy", "MiningTool_1h_Light", "MiningTool_2h_Standard", "MiningTool_2h_Heavy", "MiningTool_2h_Light", "MiningTool_2h_Advanced", "Industrial Cutteray Mk4"],
  "related": ["resources/power-pack", "resources/buggy-cutteray", "resources/copper-ore", "resources/titanium-ore", "resources/index"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Cutteray

The cutteray mines ore and salvage and cuts some doors; it "require[s] a working Power Pack" (game text). Analysis Mode "displays hidden structural weaknesses that can be traced with the Cutteray laser to yield greater resource amounts" (game text). Each tier unlocks one more mineral tier, so the tool you carry decides what you can gather.

## Tiers

| Tool (id) | New minerals (game text) | Recipe (wiki, per-tool page, edited 2026-10-05) | Power use (wiki) |
|---|---|---|---|
| Improvised Cutteray (`MiningTool_1h_Standard`) | Copper, granite, salvaged metal, doors | 2 Salvaged Metal; Personal Fabricator or better | 18 |
| Cutteray Mk1 (`MiningTool_1h_Heavy`) | Iron | 6 Copper Ingot + 4 EMF Generator; Fabricator | 27 |
| Cutteray Mk2 (`MiningTool_1h_Light`) | Carbon, erythrite | 10 Iron Ingot + 7 EMF Generator; Fabricator | 36 |
| Cutteray Mk3 (`MiningTool_2h_Standard`) | Aluminum, basalt | 15 Steel Ingot + 10 EMF Generator + 10 Cobalt Paste + 5 Ray Amplifier + 90 mL; Survival Fabricator | 54 |
| Industrial Cutteray Mk4 (`MiningTool_2h_Heavy`) | Jasmium | 25 Aluminum Ingot + 14 EMF Generator + 12 Cobalt Paste + 7 Ray Amplifier + 225 mL; Survival Fabricator | 74.9 |
| Cutteray Mk5 (`MiningTool_2h_Light`) | Titanium, stravidium | 40 Duraluminum Ingot + 18 EMF Generator + 16 Cobalt Paste + 10 Ray Amplifier + 7 Thermoelectric Cooler + 450 mL; Survival Fabricator | 113.9 |
| Cutteray Mk6 (`MiningTool_2h_Advanced`) | "virtually anything", better yields | 50 Plastanium Ingot + 30 EMF Generator + 30 Cobalt Paste + 6 Thermo-Responsive Ray Amplifier + 9 Thermoelectric Cooler + 27 Spice Melange + 700 mL; Advanced Survival Fabricator | 153.7 |

Ids from item data. The mineral tiers match the game's info cards: tier 1 copper/granite/salvage, 2 iron, 3 carbon and erythrite, 4 basalt and aluminum, 5 jasmium, 6 titanium and stravidium (game text). Mk3 and up are two-handed (item ids `2h`). EMF Generators come from Fremen caves; better ones from caves in harder regions (game text); Ray Amplifiers are "used extensively to mine large parts of the Hagga Rift" (game text); Thermoelectric Coolers come from the Deep Desert Shield Wall (game text).

## Relative yields

The wiki gives a "Mining Yield" number per mineral group (no unit; higher is better):

| Tool | Cu/granite/salvage | Iron | Carbon/erythrite | Al/basalt | Jasmium | Ti/stravidium |
|---|---|---|---|---|---|---|
| Improvised | 40 | | | | | |
| Mk1 | 48 | 36 | | | | |
| Mk2 | 72 | 48 | 45 | | | |
| Mk3 | 104 | 72 | 60 | 36 | | |
| Mk4 | 136 | 104 | 90 | 48 | 72 | |
| Mk5 | 168 | 136 | 130 | 72 | 114 | 36 |
| Mk6 | 200 | 168 | 170 | 104 | 149 | 48 |

(wiki, per-tool pages edited 2026-10-05; the overview https://awakening.wiki/Cutteray, edited 2026-08-29, shows 56 for Mk1 iron.) A higher tier also mines lower minerals faster, so upgrading pays off even for copper.

## Uniques

| Unique (id) | Tier and bonus (game text) | Wiki yield row, Cu/Fe/C/Al/Jas/Ti |
|---|---|---|
| Sim's Cutter (`MiningTool_1h_Unique_01`) | Tuned for granite, copper and salvage; "only basic Iron yields" | 63 / 48 |
| Olef's Quickcutter (`MiningTool_1h_Unique_02`) | Extra iron | 93 / 63 / 56 |
| Callie's Breaker (`MiningTool_2h_Unique_01`) | Extra carbon and erythrite | 162 / 93 / 79 / 48 |
| Sandflies Carver (`MiningTool_2h_Unique_02`) | Lasts longer, extra aluminum | 170 / 130 / 112 / 63 / 93 |
| Tarl Cutteray (`MiningTool_2h_Unique_03`) | "Tuned for better yields" | 210 / 170 / 130 / 93 / 152 / 48 |
| Kynes's Cutteray (`MiningTool_2h_Unique_04`) | "Tuned for better yields" | 250 / 210 / 212 / 130 / 187 / 63 |

Game text also has "Miner's Delight" (+20% iron, +10% aluminum) and "Cutter of Al'Gha'Hir" (+20% erythrite, +10% jasmium), but neither is in this build's item list (item data), so they are probably cut or unreleased (inference). Schematics for the uniques exist as separate items (item data).

## Skills that raise mining yield

Stats "Hand-held Cutteray Yield", "Analysis Mode Yield", "Bonus Yield Chance (Mineral)" and "Jackpot Yield Chance"; keystones "Effective Mining" (extra resources not normally in a node, in Analysis Mode), "Effective Salvaging" (bonus components from scrap nodes) and "Yield Jackpot" (game text). The UI rates each node "Great / Good / Poor efficiency" for the tool in hand (game text).
