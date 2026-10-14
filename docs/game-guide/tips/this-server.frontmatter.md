---json
{
  "schema": "dune-guide/v1",
  "title": "What is different on this server",
  "description": "The private world's gameplay settings that change everyday advice for a new player: stamina, storms, death, inventory, crafting, mining, chat commands and the timeout break.",
  "kind": "tip",
  "section": "tips",
  "tags": ["this server", "private server", "self-hosted", "settings", "server rules", "timeout", "chat commands", "&help", "&water", "difficulty"],
  "aliases": ["server settings", "house rules", "how is this server different"],
  "related": ["tips/water-discipline", "tips/sandstorms", "tips/death-and-recovery", "tips/keybinds-and-ui"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# What is different on this server

**Quick answer.** This is a self-hosted (Experimental) world with friendlier settings than official servers: stamina drains slower, storms are weaker and never hurt buildings, you only drop your backpack on death (worm deaths included), inventory volume is ten times larger, crafting is instant and half price, and mining yields triple. Everything else (thirst, heat, worms) is at default. Values below are from the server's settings files as of 2026-10-13 (server config); the operator can change them.

| Area | Setting | This server | Default |
|---|---|---|---|
| Stamina | `PlayerStaminaDrain` | 0.8 (20% slower drain, verified on this server) | 1 |
| Thirst, heat | `ThirstMultiplier`, `HeatBuildupRate` | 1, 1 | 1, 1 |
| Water extraction | `WaterExtractionRate` | 0.5 (faster) | 1 |
| Death drop | `DropEquipmentOnDeath` | Backpack | Default |
| Worm death | `SandwormConsequences` | Backpack | Default |
| Inventory volume | `InventoryVolumeMultiplier` | 10 (slots stay at 35, verified on this server) | 1 |
| Crafting | `CraftingCost`, `CraftingTimeMultiplier` | 0.5, 0 (instant) | 1, 1 |
| Mining output | `Dune.GlobalMiningOutputMultiplier`, vehicle mining | 3, 3 | 1, 1 |
| Durability | `ItemDurabilityDrainMultiplier`; max-durability loss on repair | 0.25; off | 1; on |
| XP | `GlobalXpMultiplier` | 1.5 (verified on this server) | 1 |
| Combat | damage to enemies, damage from enemies, own shield mitigation | 1.2, 0.8, 2 | 1, 1, 1 |
| Sandstorms | warning, player damage, vehicle damage, building damage | 90 s warning; 4 / 5.5; 1 / 1.4; 0 | 10 s; 5 / 7; 5 / 7; 5 / 7 |
| Base decay | `bAllowDynamicBuildingDamage` | off | unverified |
| Base move cooldown | `BaseBackupToolTimeRestriction` | 16 hours | 7 days (game text) |
| Coriolis | damage | off; warned 6 h ahead (verified on this server) | weekly wipe of the Deep Desert on official worlds |

## Practical consequences

- Bases do not wear down from storms here, but machines still need power (server config; game text).
- Worms are as dangerous as anywhere; only the loss on death is softer (server config).
- Water still drains in the Escape menu because the world never pauses (verified on this server). For a real break, the operator (or a player granted it) can turn on the world "timeout" with `&timeout on`, which switches off all damage, sandworms, sandstorms and Coriolis storms until `&timeout off` (verified on this server for the settings; whether it also stops thirst and heat is not yet verified in game; `docs/admin.md`).
- Chat commands: trusted players can type `&help` in any chat channel to list the `&` commands they may use, such as `&where`, `&water` (fill your water containers) and `&fuel` (five large vehicle fuel cells) (`docs/admin.md`). Access is set per player by the operator.

## Joining

Find the world under the Experimental tab of the server browser and enter the join password from the host; your client build must match the server's (`docs/game-guide/economy-social-versions.md`). A Steam client launched without BattlEye can join this world (verified on this server). A character used here becomes an Experimental character and cannot move back to official Standard or Custom servers (game text).
