---json
{
  "schema": "dune-guide/v1",
  "title": "Sandworm risk while harvesting spice (and grandfather worms)",
  "description": "Why worms come to spice fields, how harvesting adds threat, the server's threat values, thumpers, and what is known about Deep Desert grandfather worms, including why they may never appear on a two-player server.",
  "kind": "system",
  "section": "spice",
  "tags": ["sandworm", "worm", "threat", "wormsign", "spice field", "harvesting", "grandfather worm", "giant worm", "thumper", "deep desert", "worm tooth", "safety"],
  "aliases": ["shai-hulud", "worm threat", "giant worm sequence", "GiantWorm", "WormTooth", "HarvestSpicePickupThreatUnit"],
  "related": ["spice/spice-fields", "spice/harvesting-by-hand-and-compactor", "spice/sandcrawler-and-carrier", "spice/deep-desert-spice", "endgame/deep-desert", "endgame/private-two-player-world"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Sandworm risk while harvesting

Every spice field is in worm territory, and both moving on sand and harvesting raise your threat. Harvest in short bursts, leave for rock or the air when the meter turns orange, and come back once it clears (wiki, https://awakening.wiki/Sandworm, 2026-09-16). General worm mechanics (meter colors, no decay on sand, draining off sand) are in [../world-and-maps.md](../world-and-maps.md) ("Sandworms").

## Threat from harvesting (server config)

Values from Funcom's `[/Script/DuneSandbox.SandwormSettings]` in the server's `DefaultGame.ini` (build 25789279). This server's `UserGame.ini` repeats the same harvesting and movement values unchanged (server config).

| Setting | Value | What it likely means |
|---|---|---|
| `HarvestSpicePickupThreatUnit` | 10 | threat per spice pickup |
| `HarvestSpiceCoalesceThreatUnit` | 10 | threat per compactor clump |
| `m_ThreatGeneratedPerResourceFieldHarvestedMap` | 0.5 for small, medium and large fields | threat per unit harvested from a field |
| Spice threat blob: size 5000, maximum 50,000, never decays, not high priority | | a harvested field keeps its own pool of threat |
| `m_SpiceBlobLifespan` | 420 | that pool lasts 420 s (7 minutes) |
| `WalkingThreatPerSec` / `RunningThreatPerSec` / `SuspendingThreatPerSec` / `ShieldingThreatPerSec` | 15 / 20 / 200 / 500 | movement and Holtzman tech on sand |

The "likely means" column is inferred from setting names, not tested. The inference that matters: harvesting builds threat on the field itself (the spice blob) as well as on you, so a field you have been working stays dangerous for several minutes after you leave it.

What attracts worms in general: running, driving ground or air vehicles, suspensors and shields, Cutterays and Static Compactors, combat, and Thumpers (wiki). The Compact Compactor uniques, Dampened Sandcrawler Treads and the Specialization traits Compactor Safety and Without Rhythm all reduce worm attention (game text).

## Thumpers

A Thumper draws the worm to itself; the Deep Desert journey uses one "to distract a worm away from the Sandcrawler" (game text). Server defaults make a worm "enraged" for 60 s after it eats 3 thumpers within 300 s (`m_NumberOfThumpersEatenForThumperEnrage=3`, `m_TimeToCountThumpersForThumperEnrage=300`, `m_TimeToStopThumperEnrage=60`, server config; effect of enrage unverified). A Unique thumper is named "Song of Shai-Hulud" (game text).

## Losing to a worm

- Default rule: everything carried is lost and the vehicle you were in is destroyed (game text). On this server `SandwormConsequences=Backpack`, so a worm death should cost only backpack contents, as with an ordinary death (server config; behavior of the Backpack value from the server settings text, not tested here).
- After a worm death you receive a Worm Tooth (`WormTooth`, server config `m_PostSandwormDeathItemsGranted`), which can be made into an Unfixed Crysknife (wiki). The journey "The Song of Shai-Hulud" starts from that death (game text).

## Grandfather worms (Deep Desert)

The giant "grandfather" worm only appears in the Deep Desert, only over the large crater spice field, and engulfs the whole area after a short breach warning (camera shake, a thunder-like sound); escape is by ornithopter, a carrier pickup, or an Advanced Suspensor Belt (wiki, https://awakening.wiki/Sandworm). Deep Desert grandfather worms give only two breach steps before the engulfing attack (wiki).

The wiki's summoning conditions are 2 to 4 players on the field, at least 1,000 m from a server border, at least 1,000 Spice Sand gathered, and a per-server cooldown of 1 to 2 hours, with a note that these rules are "somewhat fluid" (wiki). Funcom's server defaults (build 25789279) say:

| Setting | Value |
|---|---|
| `m_bGiantWormSystemEnabled` | True |
| `m_GiantWormResourceFieldTypes` | large spice field only |
| `m_GiantWormMinimumPlayersOnSpiceField` | 4 |
| `m_GiantWormMinimumSpiceAmountHarvested` | 50,000 (unit unknown) |
| `m_GiantWormSpawningCooldown` | 7,200 s (2 hours) |
| `m_GiantWormMinimumDistanceFromIgwBoundary` | 2,000 (engine units, probably 20 m) |
| `m_GiantWormSafezoneDetectionDistance` | 35,000 (probably 350 m) |

(server config). If the four-player minimum is enforced as written, a world with only two players will never trigger a grandfather worm; ordinary worms still come. This is an inference from the setting, not observed. Small worms can still breach inside a grandfather's territory, even during its cooldown (wiki).
