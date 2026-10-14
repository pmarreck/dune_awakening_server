---json
{
  "schema": "dune-guide/v1",
  "title": "The Landsraad endgame: terms, Houses, missions, control points, decrees and faction rank",
  "description": "How the weekly Landsraad competition works in 1.5 with the server's actual timings: 25 Houses, missions and their cooldowns, Mnemonic Recollections, House reward tiers, control points, decrees, faction ranks 1 to 20, and what changes on a dedicated server without simulated rivals.",
  "kind": "system",
  "section": "endgame",
  "tags": ["landsraad", "landsraad missions", "decree", "house", "control point", "faction rank", "house scrip", "mnemonic recollection", "guild", "vote", "atreides", "harkonnen", "weekly", "term"],
  "aliases": ["Sysselraad", "Landsraad contracts", "faction standing", "Atreides Envoy", "Harkonnen Enforcer", "LandsraadSettings"],
  "related": ["endgame/specializations", "endgame/challenge-testing-stations", "endgame/deep-desert", "endgame/private-two-player-world", "spice/melange-uses"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# The Landsraad endgame

The Landsraad is a weekly faction competition over 25 Great Houses. Guild members aligned with Atreides or Harkonnen run repeatable missions in five categories; mission progress secures Houses for your faction, the winning faction's guild leaders vote on a server-wide decree, and every mission also pays Solari, XP, Specialization XP, faction standing and (with Mnemonic Recollections) House Scrip (game text; wiki, https://awakening.wiki/Landsraad, 2026-10-08). Access needs a faction-aligned guild and faction-journey progress (game text). Basics are in [../progression-and-skills.md](../progression-and-skills.md) and [../economy-social-versions.md](../economy-social-versions.md); this entry adds the numbers.

## Timings on a dedicated server (server config)

From Funcom's `[/Script/DuneSandbox.LandsraadSettings]` `DedicatedServerData` (build 25789279), which this server does not override:

| Setting | Value | Meaning |
|---|---|---|
| `m_LandsraadCycleDurationInSeconds` | 604,800 | one term per week |
| `m_LandsraadVotingPeriodDurationInSec` | 118,500 | voting lasts about 33 hours |
| `m_TaskGoalAmount` | 70,000 | contribution needed to win a House (wiki agrees) |
| `m_LandsraadContractsPerVotingBlock` / `m_LandsraadContractsMaxActiveAmount` | 3 / 3 | three missions offered per bloc; at most three active |
| `m_LandsraadContractsRepeatCooldownSeconds` | 57,600 | a mission repeats after 16 hours |
| `m_LandsraadContractsAbandonCooldownSeconds` | 3,600 | 1 hour after abandoning |
| `m_LandsraadContractsDailyBonusPerDay` / `...Max` | 5 / 35 | 5 Mnemonic Recollections a day, banked up to 35 (game text: "for up to 7 days") |
| `m_ControlPointsPerCycle` | 2 | control points per term |
| `m_NumberOfDecreesToNominate`, reroll cost, max rerolls | 3, 1,000 Solari, 5 | decree ballot |

Single-player uses a different block: a 10-hour cycle with 5-minute voting, simulated rival guilds and no daily bonus cap (server config `ListenServerData`; game text). The dedicated block has no simulation entries, so on a self-hosted world only real guilds compete (inference from the config; see [private-two-player-world](private-two-player-world.frontmatter.md)).

## Houses and winning

- 25 Houses in five blocs of five, one bloc per Specialization category; each bloc offers three missions at a time, completable for any revealed House in that bloc (wiki).
- A faction wins the vote by securing five Houses in a row (horizontal, vertical or diagonal) or by having more Houses than the other faction when voting starts (game text; wiki).
- House rewards: five tiers at 700, 3,500, 7,000, 10,500 and 14,000 personal contribution, randomly rotated, accumulating across terms and claimable from the House Representative at any time (wiki).
- Control points show "Gaining Control", "Contested", "Controlled", and pay contribution "Per minute while holding control point" (game text). A House task can make a point "Uncaptureable" until revealed (game text).

## Decrees (wiki; several also game text)

Import Rights (opens a Tool, Armor, Weapon or Vehicle vendor and one extra Mk6 blueprint a week), CHOAM Production Contract (-25% refining and crafting cost incl. water, tier 4+ materials), CHOAM Refining Contract (-75% refining time and repair cost), In Honor of the Fallen (+33% ranged or melee damage), Scholarly Collaboration (+50% XP, not Specialization XP), The Right of Salvage (everything drops on defeat in the Deep Desert). Spice tax +/-50% decrees exist in game text.

## Faction ranks

Ranks 1 to 5 come from faction contracts, 6 to 19 from Landsraad missions, rank 20 from a special mission (patch notes 1.3.0.0; wiki, https://awakening.wiki/Faction_Rank, 2026-09-20). A Recollection-boosted mission gives 75 standing; the daily cap is 375 (five boosted missions) (wiki). The wiki's table puts rank 19 at 11,974 total standing, 133 boosted missions and about 27 days, with rank 20 at 12,474 (wiki). Faction rank also caps the challenge testing station difficulty you can attempt (game text). Patch 1.5.3.0 fixed players stuck at rank 4 after finishing all faction journeys (patch notes).

1.5.3.0 disabled the "Convergence" and "Sample Recovery" missions (patch notes, https://duneawakening.com/news/dune-awakening-console-release-patch-notes/).
