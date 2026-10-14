---json
{
  "schema": "dune-guide/v1",
  "title": "Death and getting your stuff back",
  "description": "What you lose when you die, how to recover your backpack, how Respawn Beacons work, and how to limit losses before risky trips.",
  "kind": "tip",
  "section": "tips",
  "tags": ["death", "die", "respawn", "respawn beacon", "death drop", "corpse run", "lost items", "downed", "revive", "sandworm death"],
  "aliases": ["I died", "where is my stuff", "death location", "corpse run", "Surrender to the Desert"],
  "related": ["tips/worm-avoidance", "tips/vehicle-safety", "tips/inventory-and-volume", "tips/this-server"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Death and getting your stuff back

**Quick answer.** Backpack items drop where you died in a container marked "Death Location" on the map; equipped gear stays on you but loses durability (game text). A sandworm death (and on standard servers a Coriolis storm death) loses everything (game text). Respawn at your Respawn Beacon, base or a tradepost, then go straight back for the drop.

## Before a risky trip

- Place a Respawn Beacon near where you are going. It costs 20 Salvaged Metal (wiki, https://awakening.wiki/Respawn_Beacon); only one is active at a time and placing a new one replaces the old (game text).
- Leave valuables in base storage. Only what you carry can drop.
- Keep durability up: items lose durability "with use and when you are defeated", and broken items cannot be used (game text).

## When you go down

- Downed is not dead: a teammate can revive you, you can try to self-revive ("Try To Keep Going"), or give up ("Surrender to the Desert") (game text). A revive needs water ("Insufficient Water to Revive", game text).
- Respawn choices are Respawn Beacons, your home or an authorized base, tradeposts, or vehicle respawn points (game text). Respawning in a different world location loses all items on the character (game text), so on another map, recover before you travel.

## Recovering the drop

- The drop is a loot container that the server removes when emptied or when it expires (verified on this server). Its lifetime is not in game text; community reports say about 10 to 15 minutes and that dying again loses the older drop (community, unverified). Go straight back.
- In PvP zones other players may loot it; in PvE areas only you can (game text: corpse looting defaults to PvP zones only; this server keeps `PlayerDeathLootRule=DependsOnSecurityZone`, server config).

## Worm deaths

Killed by a sandworm, "All items in your inventory have been lost and are not recoverable" and any vehicle you were using is destroyed (game text). The wiki says the Vehicle Backup Tool and quest items survive, and that your first worm death sends you through a spice vision and back with a sandbike (wiki, https://awakening.wiki/Sandworm; unverified in game). A destroyed vehicle can usually be bought back in the Vehicle Backup Tool's Recovery mode (game text).

## This server

`DropEquipmentOnDeath=Backpack` (only backpack contents drop) and `SandwormConsequences=Backpack` (a worm takes your backpack contents) (server config). Durability wear is a quarter of default (`ItemDurabilityDrainMultiplier=0.25`) and repairs do not lower maximum durability (`bEnableItemMaxDurabilityLoss=False`) (server config).
