---json
{
  "schema": "dune-guide/v1",
  "title": "Selling spice: vendors, the Exchange and spice taxes",
  "description": "Where melange is worth the most, why NPC buyback is poor, the CHOAM spice tax decrees, and what selling looks like on a small private world.",
  "kind": "tip",
  "section": "spice",
  "tags": ["sell spice", "sell melange", "solari", "exchange", "market", "vendor", "price", "spice tax", "choam", "money"],
  "aliases": ["spice price", "melange price", "Landsraad_Name_SpiceTaxIncrease", "Landsraad_Name_SpiceTaxDecrease"],
  "related": ["spice/melange-uses", "endgame/base-and-economy-endgame", "endgame/private-two-player-world"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "low"
}
---

# Selling spice

Melange's listed vendor base price is 6,500 Solari (wiki, https://awakening.wiki/Spice_Melange, fetched 2026-10-13), but NPC vendors buy back far below their selling price; a 2025 report had a vendor selling melange at 120,000 and buying it at 650 (community, pre-1.5, cited in [../economy-social-versions.md](../economy-social-versions.md)). Sell to players through the Exchange when there are buyers, and otherwise spend it on Traits and crafting.

## Notes

- The small refinery's own description says melange "can be sold or used in further crafting" (game text).
- Landsraad decrees can raise or cut "spice taxes" by 50% for a term: "CHOAM Spice Tax Increased" and "CHOAM Spice Tax Decreased" (game text). What the tax applies to in 1.5 is not stated in the game text or the sources found (unverified); base taxation itself was removed in 1.5 (community, https://boostroom.com/blog/dune-awakening-update-15-guide-new-endgame-progression-major-changes, 2026-09-29).
- In single-player 1.5 "the Exchange acting as a vendor" replaces player trading (1.5 announcement, https://duneawakening.com/news/announcement/the-new-dune-awakening-is-here/). A self-hosted world runs as a dedicated server, so its Exchange is presumably the normal player market (inference, not checked in game); with two players there is little to sell to. See [../endgame/private-two-player-world.frontmatter.md](../endgame/private-two-player-world.frontmatter.md).
- Deep Desert PvP instances pay 2.5x mining and harvesting yield on official worlds (patch notes 1.3.20.0). This server keeps the multiplier at 2.5 (`SecurityZones.PvpResourceMultiplier=2.5`, server config) and does not force PvP everywhere (`m_bShouldForceEnablePvpOnAllPartitions=False`, server config).
