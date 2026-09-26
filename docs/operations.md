# Operating the native Dune world

How to run a private Dune: Awakening 1.5 world natively on NixOS: no Docker, no Kubernetes, no Windows. [architecture.md](architecture.md) covers how the pieces connect and why. This page covers how to drive them.

## One-time operator inputs (outside Git and the Nix store)

| File | Created by | Contents |
|---|---|---|
| `~/.config/dune_awakening_server/fls_secret` (0600) | the operator, from https://account.duneawakening.com/ | Funcom self-host (FLS) token, retail. It expires one year after it is issued. |
| `~/.config/dune_awakening_server/world.conf` (0600) | dune-awakening init --display-name "My World" --region "North America"` | `WORLD_UNIQUE_NAME=sh-<hostid>-<suffix>` (never change it after first registration), display name, region |
| `~/.config/dune_awakening_server/join_password` (0600) | dune-awakening init` | In-game join password. Read it with `cat` and share it with your players privately |

## Payload

1. Download: `steamcmd +@sSteamCmdForcePlatformType linux +force_install_dir ~/.local/share/dune_awakening_server/steam-server +login anonymous +app_update 4754530 validate +quit`, run with `HOME=~/.local/share/dune_awakening_server/steamcmd` in `nix develop`. Anonymous login works for app 4754530.
2. Unpack each image with `libexec/dune-unpack <steam-server>/images/<dir>/<image>.tar ~/.local/share/dune_awakening_server/unpacked/<image>`. It handles plain and gzip layers and OCI whiteouts, and was verified byte-identical against the earlier helper for two images. The images needed are `server`, `server-bg-director`, `server-text-router`, `server-gateway` and `server-db-utils`.

The client and server must be on the **same build**. When Steam updates the Dune client, update the server the same day (see the update notes in architecture.md).

## Everyday commands (from any directory)

`bin/dune-awakening` (LuaJIT) resolves its own real path to find this checkout's flake, and re-executes itself inside `nix develop` on it when needed, so it works from any cwd once `bin/` is on PATH (or through a symlink).

```bash
dune-awakening start          # postgres → schema → partition → RabbitMQ admin/game → TextRouter → Director → Gateway → Survival_1
dune-awakening status         # one line per component, ● up / ○ down; exit 0 only if all are up
dune-awakening status --json  # plus world identity, external address, flake path, map-server uptime and memory vs cap (admin page)
dune-awakening stop           # reverse order; refuses while characters are online (--force overrides)
dune-awakening restart        # same guard
dune-awakening doctor         # health check of the setup (read-only; exit 1 on a failure; --json)
```

`dune-awakening doctor` checks, and names a fix for each problem:

| Check | ✗ fail / ⚠ warn when |
|---|---|
| `config-dir` | the config directory is missing, not yours, or open to group/others (✗) |
| `config-files` | `fls_secret`, `join_password`, `world.conf`, `backup.conf` or `public-scrub` is readable by others (✗) |
| `secrets` | the generated secrets directory or a file in it is readable by others (✗); it does not exist yet (⚠) |
| `data-dirs` | the state, unpacked payload or Steam download directory is missing or unreadable (✗) |
| `templates` | `*.sample` / `*.default` files are left in the config directory (⚠) |
| `default-passwords` | the join, admin, GM or database password is empty or a known default (`sardaukar`, `seabass`, `postgres`, `change-me`), or the map server's `Game.ini` carries `sardaukar` (✗) |
| `world-config` | `world.conf` is missing or names no world (✗) |
| `fls-token` | the Funcom token has expired (✗), expires within 30 days or cannot be read (⚠) |
| `components` | a component is not running (⚠: fine when the world is meant to be stopped) |
| `database` | postgres rejects the admin, listens beyond loopback, lacks the game database, or rejects the game's role (✗) |
| `backups` | there is no backup, or the newest is more than 2 days old (⚠) |

It prints no secret. `DUNE_NOW` (ISO time) replaces the clock, for tests.

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

## Characters (`dune-awakening character`)

Everything about one character lives here. The record commands below work on the database; the live ones (`move`, `where`, `kick`, `water`, `xp`, `whisper`, `worm`) are described under [Live-world commands](admin.md).

The record commands read the database settings from the game's own ini chain, so they reach whatever database the server uses. Edits and imports refuse while any live character on the account is online, because the server would overwrite them. Rows the server marked `character_state = Deleted` are ignored; its first-login placeholder stays "Online" forever.

```bash
dune-awakening character list                          # ● online / ○ offline, Intel, skill points, XP
dune-awakening character set-intel PlayerOne 100        # Intel points (spent on research); add-intel adds
dune-awakening character set-skill-points PlayerOne 10  # unspent pool; the lifetime total moves with it
dune-awakening character add-skill-points PlayerOne 20  # unspent and lifetime total both grow
dune-awakening character export PlayerOne -o playerone.json   # 0600; default stdout
dune-awakening character validate playerone.json        # dry run of the server's own import; exit 1 with reasons
dune-awakening character import playerone.json          # validate, back up, import
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

`dune-awakening units render DEST` writes the units below for this checkout, with the host's `nix` and `luajit` filled in and every path quoted for systemd. Installing them is a host change for the host administrator; `dune-awakening units --help` prints the install commands.

| Unit | Schedule | Does |
|---|---|---|
| `dune-world.service` | boot (`default.target`, needs `loginctl enable-linger`) | `dune-awakening start`; `stop` at shutdown |
| `dune-world-heal.timer` | every 5 min, from 10 min after boot | `dune-awakening start` (only missing components start) while `dune-world.service` is active; `KillMode=process` so what it starts survives |
| `dune-backup.timer` | daily 04:30, catch-up after downtime | `dune-awakening backup create --label scheduled`, then `prune` (retention policy, see "Backups and retention") |
| `dune-backup-verify.timer` | Sundays 05:15 | `dune-awakening backup verify latest` (restore drill) |
| `dune-update-check.timer` | daily 06:00 | `dune-awakening update check --json` into the journal; exit 1 (update available) is not a failure |

`systemctl --user stop dune-awakening` stops the world and keeps it stopped (the heal timer only acts while the world unit is active).

## Status feed for admin pages

`dune-awakening status --json` returns one document; `--watch SECS` keeps running and prints one per interval (entering nix once, about 150 ms of work per sample afterwards), and `--count N` bounds it. A page backend should start the watcher when the page opens and kill it when the page closes.

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

## Live-world commands and in-game GM

Everything about administering the running world (the command channel, world and character commands, moving and messaging players, the break timeout, and the game's own GM system) is in [admin.md](admin.md).

## Backups and retention

`dune-awakening backup create` writes a checksummed backup (every world database, the cluster's roles, and the operator config directory) to `~/.local/share/dune_awakening_server/backups/<UTC timestamp>[-label]/`. The daily timer (`dune-backup.timer`, 04:30) runs `create --label scheduled` and then `prune`; `dune-backup-verify.timer` restore-drills the newest backup every Sunday.

Default retention, applied by `dune-awakening backup prune`:

1. Keep every backup from the last 7 days.
2. Beyond that, keep the newest backup of each week until it is 91 days (about 3 months) old.
3. Move everything older to the trash (`DUNE_TRASH_DIR`, default `~/.Trash`). The newest backup is always kept.

To change it, copy `config.sample/backup.conf.sample` to `~/.config/dune_awakening_server/backup.conf` and edit the two values:

```ini
KEEP_ALL_DAYS=7       # keep everything newer than this
KEEP_WEEKLY_DAYS=91   # then one per week until this age
```

The file is optional, read on every prune, and validated: an unknown key, a value that is not a whole number, or `KEEP_WEEKLY_DAYS` below `KEEP_ALL_DAYS` stops the prune with an error that names the file and line. `dune-awakening backup prune --keep N` keeps the newest N instead, ignoring the policy.
