---json
{
  "schema": "dune-guide/v1",
  "title": "Base building and economy at endgame",
  "description": "What a finished late-game base needs (advanced fabricators, large refineries, power, storage, augmentation station), the 1.5 protections for bases and vehicles, and how money works once you are maxed.",
  "kind": "tip",
  "section": "endgame",
  "tags": ["base", "endgame base", "large spice refinery", "advanced fabricator", "augmentation station", "spice generator", "power", "base backup", "vehicle recovery", "solari", "money", "economy"],
  "aliases": ["late game base", "main base", "Base Reconstruction Tool", "Vehicle Backup Tool"],
  "related": ["spice/refining-melange", "spice/spice-infused-materials", "spice/selling-spice", "endgame/gear-grades-and-augments", "endgame/whats-new-in-1-5"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Base and economy endgame

A late-game home base exists to turn Deep Desert hauls into Mk6 gear: Large Spice and Ore Refineries, a Medium Chemical Refinery (stravidium fiber, spice fuel), the four Advanced Fabricators, the Augmentation Station, enough power and storage, and a garage for the Sandcrawler and Carrier Ornithopter (game text; station roles in [../bases-and-building.md](../bases-and-building.md) and [../survival-combat-crafting.md](../survival-combat-crafting.md)). 1.5 made this cheaper by removing melange from six station build costs (patch notes 1.5).

## Checklist

| Need | Why | Source |
|---|---|---|
| Large Spice Refinery | Twice the melange per sand of the small one, half the water per melange | wiki; see [../spice/refining-melange.frontmatter.md](../spice/refining-melange.frontmatter.md) |
| Large Ore Refinery | Plastanium Ingot from 4 Titanium Ore (vs 6 in the medium) plus Stravidium Fiber and water | wiki (in the crafting chapter) |
| Medium Chemical Refinery | Stravidium Fiber; Spice-infused Fuel Cells from residue | game text |
| Advanced Weapons, Garment, Survival, Vehicle Fabricators | Mk6 and Unique items; the Survival one also processes Offworld Regis Compound | game text |
| Augmentation Station | Attach augments to Plastanium Uniques | game text |
| Spice-Powered Generator | Burns Spice-infused Fuel Cells, 1,000 power per generator, 1.5 h per cell | game text; wiki |
| Water | Refining and crafting use a lot; this server halves water extraction (`WaterExtractionRate=0.5`) | game text; server config |

## Protection tools (1.5)

- Base Reconstruction Tool keeps up to three base snapshots; bases outside the Deep Desert can be recycled for a full refund into a Reserve inventory (community, boostroom 2026-09-29; game text).
- Vehicle Backup Tool can recover destroyed vehicles for 30 days at a Solari and max-durability cost (1.5 announcement; game text). The Sandcrawler cannot be stored in it (wiki).
- Base taxation is gone and the death durability penalty fell from 5% to 2% (community, boostroom; 1.5 announcement).
- Solido Replicators are capped: 20 in inventory, 10 per base storage, 20 in the bank, 10 per vehicle (patch notes 1.5.3.0).

## Money

Late-game Solari come from Landsraad missions, high-value loot, and selling melange, Mk6 parts and schematics to players (see [../economy-social-versions.md](../economy-social-versions.md) and [../spice/selling-spice.frontmatter.md](../spice/selling-spice.frontmatter.md)). Solari sinks at this stage include vehicle recovery, decree rerolls (1,000 each, up to 5 per term; server config) and Landsraad bribes (Sabotage trait "Greasing Palms" lowers them; game text).
