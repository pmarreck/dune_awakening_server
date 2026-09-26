# Operating the native Dune world

How to run a private Dune: Awakening 1.5 world natively on NixOS: no Docker, no Kubernetes, no Windows. [architecture.md](architecture.md) covers how the pieces connect and why. This page covers how to drive them.

## One-time operator inputs (outside Git and the Nix store)

| File | Created by | Contents |
|---|---|---|
| `~/.config/dune_awakening_server/fls_secret` (0600) | the operator, from https://account.duneawakening.com/ | Funcom self-host (FLS) token, retail. It expires one year after it is issued. |
| `~/.config/dune_awakening_server/world.conf` (0600) | dune-world init --display-name "My World" --region "North America"` | `WORLD_UNIQUE_NAME=sh-<hostid>-<suffix>` (never change it after first registration), display name, region |
| `~/.config/dune_awakening_server/join_password` (0600) | dune-world init` | In-game join password. Read it with `cat` and share it with your players privately |

## Payload

1. Download: `steamcmd +@sSteamCmdForcePlatformType linux +force_install_dir ~/.local/share/dune_awakening_server/steam-server +login anonymous +app_update 4754530 validate +quit`, run with `HOME=~/.local/share/dune_awakening_server/steamcmd` in `nix develop`. Anonymous login works for app 4754530.
2. Unpack each image with `libexec/dune-unpack <steam-server>/images/<dir>/<image>.tar ~/.local/share/dune_awakening_server/unpacked/<image>`. It handles plain and gzip layers and OCI whiteouts, and was verified byte-identical against the earlier helper for two images. The images needed are `server`, `server-bg-director`, `server-text-router`, `server-gateway` and `server-db-utils`.

The client and server must be on the **same build**. When Steam updates the Dune client, update the server the same day (see the update notes in architecture.md).

## Everyday commands (from any directory)

`bin/dune-world` (LuaJIT) resolves its own real path to find this checkout's flake, and re-executes itself inside `nix develop` on it when needed, so it works from any cwd once `bin/` is on PATH (or through a symlink).

```bash
dune-world start          # postgres → schema → partition → RabbitMQ admin/game → TextRouter → Director → Gateway → Survival_1
dune-world status         # one line per component, ● up / ○ down; exit 0 only if all are up
dune-world status --json  # plus world identity, external address, flake path, map-server uptime and memory vs cap (admin page)
dune-world stop           # reverse order
dune-world restart
```

The address clients use comes from `DUNE_EXTERNAL_ADDRESS`, else `EXTERNAL_ADDRESS=` in `world.conf`, else the source address of the default route.

Runtime state: `~/.local/share/dune_awakening_server/runtime/` (0700). Logs, all private:

| Component | Log |
|---|---|
| Postgres | `runtime/postgres/server.log` |
| RabbitMQ | `runtime/rabbitmq-{admin,game}/log/` |
| TextRouter | `runtime/textrouter/textrouter.log` (**contains credentials**) |
| Director | `runtime/director/director.log` (**contains credentials**) |
| Gateway | `runtime/gateway/gateway-console.log`, `runtime/gateway/root/Tools/Battlegroups/GatewayService/logs/` |
| Map server | `runtime/server/server-console.log`, `runtime/server/Saved/Logs/` |

## Ports

| Port | Component | Exposure |
|---|---|---|
| 15431/tcp | Postgres | 127.0.0.1 only |
| 5673/tcp | admin RabbitMQ (plain AMQP) | 127.0.0.1 only |
| 31982/tcp | game RabbitMQ (AMQPS) | all interfaces; needed by game clients |
| 18081/tcp | TextRouter auth API | 127.0.0.1 only |
| 18082/tcp | Director HTTP | 127.0.0.1 only |
| 7777/udp | game traffic (Survival_1) | clients |
| 7888/udp | IGW server-to-server | internal |

Player ingress (LAN or public) is opened by the host administrator. Nothing in this project changes the firewall.

`start` needs the user bus environment (`XDG_RUNTIME_DIR`, `DBUS_SESSION_BUS_ADDRESS`), because the map server's memory cap is a systemd user scope; the nix re-exec keeps both.

Overnight stability samples: `runtime/stability.ndjson` holds one status line every 5 minutes, with host available memory and PSI.

## Characters (`dune-world character`)

Everything about one character lives here. The record commands below work on the database; the live ones (`move`, `where`, `kick`, `water`, `xp`, `whisper`, `worm`) are described under [Live-world commands](#live-world-commands-dune-world-world-dune-world-character).

The record commands read the database settings from the game's own ini chain, so they reach whatever database the server uses. Edits and imports refuse while any live character on the account is online, because the server would overwrite them. Rows the server marked `character_state = Deleted` are ignored; its first-login placeholder stays "Online" forever.

```bash
dune-world character list                          # ● online / ○ offline, Intel, skill points, XP
dune-world character set-intel PlayerOne 100        # Intel points (spent on research); add-intel adds
dune-world character set-skill-points PlayerOne 10  # unspent pool; the lifetime total moves with it
dune-world character add-skill-points PlayerOne 20  # unspent and lifetime total both grow
dune-world character export PlayerOne -o playerone.json   # 0600; default stdout
dune-world character validate playerone.json        # dry run of the server's own import; exit 1 with reasons
dune-world character import playerone.json          # validate, back up, import
```

Export, validate and import use Funcom's own stored procedures from `character_transfers.sql`, the code behind in-game character transfers:

- **Export** calls `character_transfer_export(fls_id)` in a transaction that is always rolled back. It covers the whole account: account, controller/state/pawn actors, FGL entities (skills), permissions, vehicles, blueprints, currency, dungeon completions and Landsraad rewards. Ids are replaced with portable transfer ids. The file adds a `_dune_character` header (character name, FLS id, export time) because Funcom passes those separately. Account identifiers (FLS, Funcom and platform ids) are in cleartext, so files are written 0600.
- **Validate** checks the header and shape, refuses an online account, then runs `character_transfer_import` inside a transaction that is always rolled back. Whatever the server's code rejects (patch checksum from a different game build, bad enum values, constraint or foreign-key violations) is reported as a clean line with Funcom's error code. `--json` gives `{valid, errors, ...}`.
- **Import** validates, writes the account's current state as an export file under `runtime/char-backups/` (importing that file undoes the import), then runs `character_transfer_import` in one transaction under row locks.

Import semantics come from Funcom: `delete_account` marks the current character Deleted (rows are kept, not removed) and removes it from its guild and party, then the file's copy is inserted with new local ids and `transfer_count + 1`. Guild and party membership are not in the export, so they are lost on import. Repeated imports accumulate Deleted rows. The file only imports into a world whose applied schema patches match (`_patches_checksum`), so a Funcom patch invalidates older exports.

## Gameplay settings

`dune-server start` copies every `User*.ini` from Funcom's defaults (`steam-server/scripts/setup/config/`) into the map server's `Saved/UserSettings`, with a same-named file in `~/.config/dune_awakening_server/UserSettings/` replacing the default whole. Changes take effect at the next map-server start. Keys verified against Funcom's shipped files:

| Goal | File | Key |
|---|---|---|
| XP rate | UserServerCustomSettings.ini | `GlobalXpMultiplier` (also `CombatXp`, `GatheringXp`, `MissionXp`) |
| Instant crafting and refining | UserServerCustomSettings.ini | `CraftingTimeMultiplier=0` |
| Harvest amount | UserEngine.ini | `Dune.GlobalMiningOutputMultiplier`, `Dune.GlobalVehicleMiningOutputMultiplier` (the `GatheringAmount` key is documented as an alias) |
| Death drops | UserServerCustomSettings.ini | `DropEquipmentOnDeath` and `SandwormConsequences`: All, Backpack, Default, None |
| Inventory volume | UserServerCustomSettings.ini | `InventoryVolumeMultiplier` |
| Environmental building damage | UserServerCustomSettings.ini | `bAllowDynamicBuildingDamage` (on/off only) |
| Sandstorm damage per tick, by target | UserGame.ini `[/Script/DuneSandbox.SandStormConfig]` | `m_SmallSandStormDamageConfig` / `m_LargeSandStormDamageConfig` = `(Player=5,Building=5,Placeable=5,Vehicle=5)` / `(… 7 …)` by default |
| Buildings ignore sandstorms | UserGame.ini `[/Script/DuneSandbox.BuildingSettings]` | `m_bMitigateAllSandstormDamage` |

The sandstorm structs come from the server's `DuneSandbox/Config/DefaultGame.ini`, and Funcom's own `UserGame.ini` overrides those same sections, which is why UserGame.ini is the place for them. Polar storms have their own `m_PolarStormSettings.m_StormDamageConfig` there (Building=5, Placeable=5).

## Unattended operation (systemd user units)

`dune-world units render DEST` writes the units below for this checkout, with the host's `nix` and `luajit` filled in and every path quoted for systemd. Installing them is a host change for the host administrator; `dune-world units --help` prints the install commands.

| Unit | Schedule | Does |
|---|---|---|
| `dune-world.service` | boot (`default.target`, needs `loginctl enable-linger`) | `dune-world start`; `stop` at shutdown |
| `dune-world-heal.timer` | every 5 min, from 10 min after boot | `dune-world start` (only missing components start) while `dune-world.service` is active; `KillMode=process` so what it starts survives |
| `dune-backup.timer` | daily 04:30, catch-up after downtime | `dune-world backup create --label scheduled`, then `prune` (retention policy, see "Backups and retention") |
| `dune-backup-verify.timer` | Sundays 05:15 | `dune-world backup verify latest` (restore drill) |
| `dune-update-check.timer` | daily 06:00 | `dune-world update check --json` into the journal; exit 1 (update available) is not a failure |

`systemctl --user stop dune-world` stops the world and keeps it stopped (the heal timer only acts while the world unit is active).

## Status feed for admin pages

`dune-world status --json` returns one document; `--watch SECS` keeps running and prints one per interval (entering nix once, about 150 ms of work per sample afterwards), and `--count N` bounds it. A page backend should start the watcher when the page opens and kill it when the page closes.

```json
{"timestamp": "2026-09-25T13:05:28-04:00", "up": true,
 "world": {"unique_name": "sh-…", "display_name": "…", "region": "North America"},
 "external_address": "100.64.0.10", "flake": "/path/to/checkout",
 "components": [{"name": "postgres", "up": true}, {"name": "rabbitmq-admin", "up": true}, {"name": "rabbitmq-game", "up": true},
                {"name": "textrouter", "up": true}, {"name": "director", "up": true}, {"name": "gateway", "up": true}, {"name": "server", "up": true}],
 "characters": {"stored": 1, "online": 1},
 "server": {"uptime_seconds": 2107, "memory_bytes": 10231160832, "memory_max_bytes": 21474836480, "cpu_seconds": 905.18}}
```

`characters` is null when the database is unreachable; `server` fields are null when the map server is down. CPU % = Δ`cpu_seconds` / Δwall-clock × 100 (per core). RabbitMQ is probed with `dune-rabbitmq status BROKER --quick` (process alive + distribution port), because the full check boots an Erlang VM (~1 s).

## Live-world commands (`dune-world world`, `dune-world character`)

The map server starts with Funcom's server-command channel on: `dune-server` writes a generated `ServerCommandsAuthToken` (kept in `runtime/secrets/server_commands_token`, 0600) and `server.NotificationSystem.Enabled=true` into its private `Engine.ini`. `dune-live` wraps a command in Funcom's Version 2 envelope and has the game RabbitMQ node publish it (exchange `heartbeats`, routing key `notifications`, user `fls`, app `fls_backend`); the envelope travels through a 0600 file, never a command line. Commands are grouped by what they act on: `world` for the whole world, `character` for one character (the character tool hands its live subcommands to `dune-live`). Players are named by character; the tool resolves their Funcom id.

```bash
dune-world world say "Restart in 5 minutes" --duration 30
dune-world world kick-all
dune-world world exec t.MaxFPS 5            # world-level engine command or variable (ServerExec)
dune-world world partitions
dune-world world raw <ServerCommand> [--player P] [Key=value[:int|:float]...]
dune-world character list                   # ● online / ○ offline, Intel, skill points
dune-world character move <player> [to] <target>
dune-world character move <player> X Y Z [--partition LABEL|ID]
dune-world character where <player>
dune-world character kick <player>
dune-world character water <player> 5000
dune-world character xp <player> 1000 [Combat|Crafting|Gathering|Exploration|Sabotage]
dune-world character whisper <player> "message" [--from NAME]
dune-world character worm <player>          # experimental: SandwormTargetPlayer in the player's context
```

The server logs each command: `LogDuneServerCommands: Now running ServerCommand '…'`, or `unknown Server Command '…'` for names it does not implement. Verified live on build 2124138: `ServiceBroadcast` and `ServerExec` run; `ServerExec` changes engine variables at runtime (`t.MaxFPS 5` cut the map server from 32% to 11% of a core, `t.MaxFPS 0` restored it), but console output is not returned. Cheat-manager names (`SandwormTargetPlayer`, `PrintNumPlayers`, ...) are not server commands in their own right.

### Moving and messaging players

`dune-world character where <player>` prints a character's partition, map and X Y Z; `dune-world world partitions` lists the partitions. Both read the tables directly, because Funcom's own `admin_get_character_details` and `admin_get_partitions` refer to objects that no longer exist in 1.5.

`dune-world character move` works whether the player is online or not; Funcom's `is_player_offline` decides (it also counts a player whose server is gone as offline, so a stuck player can be rescued).

- `move <player> X Y Z`: online, the server's `TeleportTo` (same partition only); offline, a `pre-move` backup and then Funcom's `admin_move_offline_player_to_partition`, where `--partition LABEL|ID` may also change partition (default: the current one).
- `move <player> [to] <target>`: both online, the game's own `TeleportToPlayer <target>` console command run in the player's context, so the server chooses the landing spot; player offline, the offline move onto the target's last saved spot (ground a character stood on), after a backup. An online player is not sent to an offline target, whose body is not in the world.

An online character cannot be moved in the database: the map server holds it in memory, is authoritative for it and writes it back on its own schedule, so Funcom's procedure refuses with "Player must be Offline" (its Director depends on that text).

`dune-world character whisper <player> <message> [--from NAME]` sends a private chat line, shown as coming from NAME (default `Admin`). It follows the route DASH confirmed in game: a `TextChat` courier with channel `Whispers` published to exchange `chat.whispers` with the player's FLS id as routing key, bound for the call to their own `<FLS id>_queue`. That queue exists only while they are online, so an offline player gets an error. A binding the game made itself is left in place.

### Timeout (a break without logging off)

`dune-world world timeout on` (also `bio-break`, `call-timeout`, `safety-first`) records the current values of four world-level console variables, sets them off, verifies each change in the map server's log, and broadcasts it: `Dac.DamageEnabled` (all damage), `sandworm.dune.Enabled`, `Sandstorm.Enabled`, `Coriolis.Enabled`. `timeout off` restores the recorded values (kept in `runtime/timeout.state`), so a hazard you had disabled on purpose stays disabled. `timeout status` reads the live value.

Why not a real pause: the engine drops a connection after 60 s without traffic (`ConnectionTimeout=60.0` in the shipped `DefaultEngine.ini`, keepalive every 0.2 s), so freezing the server process would disconnect everyone after a minute, and Funcom's server commands include no pause or time-dilation command (`PauseServer` and `SetTimeDilation` are rejected as unknown). Verified on the server: the four variables exist, are settable at runtime, and read back as changed. Not yet verified in game: whether no damage also covers thirst and heat.

## Backups and retention

`dune-world backup create` writes a checksummed backup (every world database, the cluster's roles, and the operator config directory) to `~/.local/share/dune_awakening_server/backups/<UTC timestamp>[-label]/`. The daily timer (`dune-backup.timer`, 04:30) runs `create --label scheduled` and then `prune`; `dune-backup-verify.timer` restore-drills the newest backup every Sunday.

Default retention, applied by `dune-world backup prune`:

1. Keep every backup from the last 7 days.
2. Beyond that, keep the newest backup of each week until it is 91 days (about 3 months) old.
3. Move everything older to the trash (`DUNE_TRASH_DIR`, default `~/.Trash`). The newest backup is always kept.

To change it, copy `config.sample/backup.conf.sample` to `~/.config/dune_awakening_server/backup.conf` and edit the two values:

```ini
KEEP_ALL_DAYS=7       # keep everything newer than this
KEEP_WEEKLY_DAYS=91   # then one per week until this age
```

The file is optional, read on every prune, and validated: an unknown key, a value that is not a whole number, or `KEEP_WEEKLY_DAYS` below `KEEP_ALL_DAYS` stops the prune with an error that names the file and line. `dune-world backup prune --keep N` keeps the newest N instead, ignoring the policy.
