# Live-world control surfaces (research, 2026-09-25)

Question: what could a `dune-world admin` CLI do against the running 1.5 server (broadcast, kick, teleport, give items, "spawn a sandworm near a player")? Read-only research: binary strings of `DuneSandboxServer-Linux-Shipping` (build 2124138), shipped configs, the Director binary, read-only Director GETs, `pg_proc` metadata, the vendored DASH docs and web sources. Nothing was sent or changed. **V** = verified, **I** = inferred.

## Unreal console, RCON, stdin

- **V** No RCON, remote-console or stdin-console strings in the binary (ASCII or UTF-16). Our launch feeds stdin from `/dev/null` anyway.
- **V** `ServerExec` exists as a client-to-server cheat RPC: it needs a logged-in admin client.
- **V** In-game admin exists: `ADunePlayerControllerBase::AdminLogin`, `m_AdminPasswords`, `m_bRequiresAdminPassword`, `EDunePrivileges::{User,PowerTester,GM,Admin}`, `PrintAllowedCommands`. The shipped `Config/DedicatedServerGame.ini` `[AdminSetting.Global]` allow-list includes AddItemToInventory, SpawnVehicle, TeleportTo/ToExact/ToPlayer/ToMap/ToSandworm, TravelTo, Fly/Ghost/Walk, Destroy{Totem,Placeable,EntireBuilding}, PrintPos. No worm spawn.
- **I** Which ini section carries `m_AdminPasswords` is unconfirmed.
- **V** Funcom describes admin commands for self-hosted servers as planned ([Massively OP Q&A](https://massivelyop.com/2026/05/21/dune-awakening-answers-questions-about-about-upcoming-features-for-self-hosted-servers/)).

## Server-command subsystem (the main lever; not enabled on our server)

- **V** `UDuneServerCommandSubsystem` strings: "Now running ServerCommand '%s' with parameters '%s'", "Invalid Auth Token", "Invalid Sender ID, we only accept server commands from 'fls'", broadcast and shutdown payload types.
- **V** (vendored DASH `docs/player-runtime-actions.md`, derived from Red-Blink's work) Enabled by `server.NotificationSystem.Enabled=true` plus `[FuncomLiveServices] ServerCommandsAuthToken=<token>`. Envelope: `{"Version":2,"AuthToken":…,"MessageContent":"{\"ServerCommand\":\"KickPlayer\",\"PlayerId\":\"<FLS id or *>\",…}"}` published on the game broker to exchange `heartbeats`, routing key `notifications`, app_id `fls_backend`, user_id `fls`.
- **V** Our server log has no "Initialized DuneServerCommandSubsystem" line: it is off.
- **I** Reported working (third party, not re-tested): KickPlayer (`*` = everyone), TeleportTo, SpawnVehicleAt, UpdateAllWaterFillables, SkillsSetUnspentSkillPoints, CleanPlayerInventory, ResetProgression. Other `UDuneCheatManager` functions are probably callable the same way; KickPlayer is not in the GM allow-list, so this path likely bypasses it.
- **V** Worm and weather cheats in the binary: `SandwormTargetPlayer <name>` (redirects an existing nearby worm; fails with "Can't find Worm close to player"), `GiantWormForceSpawnSequence` (needs a nearby spice field), `SpawnSandStorm`, `SpawnSandStormPath`, `SpawnSandStormAngle`, `SpawnCoriolis`, `SandwormSetSpawnProtection`, `SandwormPrintLocations`, `SetTimeOfDaySpeed`, `PrintNumPlayers`.
- Risk: the auth token is a superuser credential on the broker; destructive commands have no undo; DASH warns never to send `BroadcastType=ServerShutdown` to a live server.

### Live results (2026-09-25, after enabling the channel)

- **V** Accepted and run: `ServiceBroadcast`, `ServerExec` (needs field `Exec`), `CheatScript` (needs field `ScriptName`; not yet explored).
- **V** Rejected as "unknown Server Command": `PrintNumPlayers`, `SandwormPrintLocations`, `SandwormTargetPlayer`, `AwardXPByEventTag`, `PauseServer`, `SetTimeDilation`. Cheat-manager functions are not server commands; the claim above that other cheat functions are callable directly is wrong.
- **V** `ServerExec` executes engine console commands at world level and changes console variables live: `t.MaxFPS 5` dropped the map server from 32% to 11% of a core; `t.MaxFPS 0` restored 31%. Output is not returned (`DumpConsoleCommands` printed nothing).
- **I** Cheat-manager commands through `ServerExec` need a player controller; whether a `PlayerId` routes them to that player (e.g. `SandwormTargetPlayer`) is untested because no player was online.

## Director HTTP API (127.0.0.1:18082)

- **V** ASP.NET routes: `v0/players[/online|queued|intransit|graceperiod|completion]`, `v0/battlegroup`, `v0/Battlegroup{Update,Clear}{CharacterTransfer,FlsReport,MapConfig}`, `v0/BattlegroupUpdateServerGroupConfig`, `v0/getPodset`. No kick, broadcast or shutdown.
- **V** `GET v0/players/online` and `GET v0/battlegroup` work (Survival_1 `playerHardCap` 60).

## Chat

- **V** (DASH `docs/private-chat-replies.md`) In-game messages: publish to game-broker exchanges `chat.map` or `chat.whispers` (per-player `<FLSID>_queue`) with a `TextChat` wrapper; confirmed rendering in-game by DASH. Payload shape may vary by build.

## Database (offline admin)

- **V** `admin_move_offline_player(fls_id, partition_label, vector)` and `admin_move_offline_player_to_partition(fls_id, partition_id, vector)`; both refuse online players.
- **V** Read-only: `admin_get_character_ids(search)`, `admin_get_character_details`, `admin_get_inventory_details`, `admin_get_journey_details`, `admin_get_mnemonic_recall_details`, `admin_get_partitions`, `admin_read_player_tags`.
- **V** Maintenance: `move_vehicles_in_lost_state_to_recovery()`, `disband_guild`, `disband_party`, `remove_party_member`, `update_respawn_locations`.

## What a `dune-world admin` CLI could support, safest first

1. Read-only `players` (Director `v0/players/*`, `admin_get_character_*`) and `partitions`.
2. Offline `move-offline <player> <partition> x y z` via `admin_move_offline_player`, after a backup.
3. `say` / `whisper` via the chat exchanges.
4. After enabling the server-command subsystem (token in the secret Engine.ini the launcher already writes, plus the cvar; needs a map-server restart): `kick`, `teleport`, `spawn-vehicle`, `refill-water`. Prove it first with `PrintAllowedCommands` / `PrintPos` and the "Now running ServerCommand" log line.
5. Sandworm: `SandwormTargetPlayer <name>` can only redirect a worm that is already near the player; `GiantWormForceSpawnSequence` needs a spice field. No true "spawn a worm here" command was found. Parameter names are unverified.

Sources: [Funcom: how to self-host](https://funcom.helpshift.com/hc/en/4-dune-awakening/faq/85-how-to-self-host-a-world-1778514422/), [snapetech/DuneAwakeningSelfHost admin-gm-console.md](https://github.com/snapetech/DuneAwakeningSelfHost/blob/main/docs/admin-gm-console.md), [Red-Blink/dune-awakening-selfhost-docker](https://github.com/Red-Blink/dune-awakening-selfhost-docker).
