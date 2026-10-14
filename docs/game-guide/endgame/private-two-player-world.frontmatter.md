---json
{
  "schema": "dune-guide/v1",
  "title": "Endgame on this private two-player world",
  "description": "How this self-hosted server's settings change the endgame for two players: faster harvesting and instant refining, softer death and durability, a Landsraad with no simulated rivals, no grandfather worms likely, a quiet Exchange, and settings worth changing.",
  "kind": "tip",
  "section": "endgame",
  "tags": ["private server", "self-hosted", "two players", "duo", "server settings", "landsraad", "pvp", "grandfather worm", "harvest multiplier", "crafting time", "coriolis", "this server"],
  "aliases": ["our server", "self-hosted endgame", "UserServerCustomSettings", "UserEngine.ini", "UserGame.ini"],
  "related": ["endgame/landsraad", "endgame/deep-desert", "spice/harvesting-worm-risk", "spice/refining-melange", "spice/selling-spice", "endgame/specializations"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Endgame on this private two-player world

This server is generous with resources and forgiving on death, has no third party to trade or compete with, and runs Funcom's multiplayer rules rather than single-player ones. Settings below were read from the server's `UserSettings` files on 2026-10-13 (server config); recheck before quoting, since the admin can change them. Operations notes: [../../operations.md](../../operations.md) ("Gameplay settings").

## Settings that matter for endgame (server config)

| Setting | Value | Effect for endgame |
|---|---|---|
| `Dune.GlobalMiningOutputMultiplier`, `Dune.GlobalVehicleMiningOutputMultiplier` | 3.0 | Three times ore (and probably spice) per harvest; spice not checked in game |
| `SecurityZones.PvpResourceMultiplier` | 2.5 | Extra yield in PvP zones, as on official worlds |
| `CraftingTimeMultiplier` | 0 | Instant crafting and refining (per the operations notes) |
| `CraftingCost` | 0.5 | Cheaper recipes; effect on refinery inputs unverified |
| `WaterExtractionRate` | 0.5 | Half water from windtraps and similar; water is the refining bottleneck |
| `InventoryVolumeMultiplier` | 10 | Ten times inventory volume; hauling is rarely the limit |
| `ItemDurabilityDrainMultiplier`, `bEnableItemMaxDurabilityLoss` | 0.25, False | Slow wear, no max-durability loss on repair (and possibly on augmenting) |
| `DropEquipmentOnDeath`, `SandwormConsequences` | Backpack, Backpack | Equipped gear should stay on you on death, including worm deaths (not tested here) |
| `GlobalXpMultiplier` | 1.5 | Faster character XP |
| `LandsraadContributionMultiplier`, `LandsraadSpecializationXpMultiplier`, `LandsraadFactionStandingMultiplier` | 1, 1, 1 | Landsraad progression at official speed |
| `PlayerDamageToNPC`, `NPCDamageToPlayer`, `PlayerShieldDamageAbsorptionMultiplier` | 1.2, 0.8, 2.0 | Combat tilted toward players; helps duo testing-station runs |
| `Vehicle.SandwormInvulnerabilitySecondsOnExit` / `...OnServerRestart` | 900 / 7,200 | Parked vehicles are protected from worms for 15 minutes after you leave them and 2 hours after a restart |
| Coriolis (`m_bCoriolisDoesDamage`) | False (default) | The storm is announced 6 hours ahead and does not hurt players |

## How the endgame differs here

- Landsraad: the dedicated-server Landsraad block has no simulated guilds (those exist only for single-player), so only real guilds compete (inference from the server config; see [landsraad](landsraad.frontmatter.md)). If both players are in one guild of one faction and the other faction scores nothing, holding more Houses at voting time should win the term; not yet observed. Missions still need a faction-aligned guild, and faction rank still gates testing-station difficulty (game text).
- Grandfather worms: Funcom's default needs at least 4 players on the large spice field (`m_GiantWormMinimumPlayersOnSpiceField=4`), so two players will probably never see one (inference; see [../spice/harvesting-worm-risk.frontmatter.md](../spice/harvesting-worm-risk.frontmatter.md)). Ordinary worms are on.
- Deep Desert wipe: the world runs multiplayer Coriolis rules, so expect the Deep Desert to reset after a storm, unlike single-player. Whether a harmless storm still wipes structures and reshapes the map here has not been observed (unverified). Treat Deep Desert bases as temporary.
- PvP: this server does not force PvP everywhere (`m_bShouldForceEnablePvpOnAllPartitions=False`) and keeps security zones on; which PvP mode it uses is not recorded in this repo (unverified; see [../world-and-maps.md](../world-and-maps.md)). PvP-only loot in Deep Desert tables may be out of reach without a PvP instance (inference).
- Trading: with two players the Exchange is not a market; melange is worth more spent on Traits and crafting than sold to NPC vendors.
- Dungeons: challenge testing stations scale enemy count to party size (game text), so a duo is a supported group.

## Settings to consider (admin choices, not recommendations from Funcom)

- Raise `LandsraadSpecializationXpMultiplier` or `LandsraadFactionStandingMultiplier` (0 to 10) if Specializations or faction rank feel slow with two people; rank caps dungeon difficulty.
- Lower `m_GiantWormMinimumPlayersOnSpiceField` in `UserGame.ini` under `[/Script/DuneSandbox.SandwormSettings]` if you want to see a grandfather worm (untested; the key is from the defaults file).
