---json
{
  "schema": "dune-guide/v1",
  "title": "Blood Purifier",
  "description": "Base machine that turns blood from blood sacks into drinkable water; cost, power, capacity.",
  "kind": "station",
  "section": "crafting",
  "tags": ["blood purifier", "water", "blood", "blood sack", "purify", "station"],
  "aliases": ["BloodWaterExtractor_Placeable", "BloodWaterExtraction_Patent", "fluid purifier"],
  "related": ["crafting/improved-blood-purifier", "crafting/fremen-deathstill", "crafting/station-progression"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Blood Purifier

Quick answer: costs 70 Salvaged Metal, draws 10 power and holds 1,000 mL of water you can drink from directly; deposit blood from a Blood Sack ("Deposit All Blood") and it filters it into water (wiki, https://awakening.wiki/Blood_Purifier, pre-1.5 data; game text).

- Research: "Blood Purifier", Water Discipline, Salvage tier, 1 Intel, after the journey "Water From Blood" (wiki, https://awakening.wiki/Research). The early journey asks you to build one, deposit blood and drink from it (game text).
- Health 1,250 (wiki). Its UI shows Processing Capacity, Blood Filtration Rate and Water Extraction Efficiency (game text).
- This server sets `WaterExtractionRate=0.5` (server config). The in-game setting text says it "controls how quickly water is produced from machines like deathstills or windtraps" and "Higher = machines produce water faster" (game text), but the comment beside the key in the server's settings file says "Higher = extraction takes longer" (server config file comment). The two disagree, so whether 0.5 speeds up or slows down water machines here is unverified, as is whether it covers blood purifiers.
