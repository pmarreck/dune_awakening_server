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
dune-awakening start          # postgres → schema → partition → RabbitMQ admin/game → TextRouter → Director → Gateway → Survival_1 → always-on maps → map scaler → GM bridge → idle throttle
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
| `config-files` | `fls_secret`, `join_password`, `world.conf`, `backup.conf`, `public-scrub` or `gm_bridge.conf` is readable by others (✗) |
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
| Map server | `runtime/server/server-console.log`, `runtime/server/Saved/Logs/` (Survival_1); `runtime/server-<map>/…` for every other map |
| Map scaler | `runtime/map-scaler/map-scaler.log` (travel demand per map, starts, stops, players arriving and leaving) |
| GM bridge | `runtime/gm-bridge/gm-bridge.log` (only `&` chat commands, never other chat) |
| Idle throttle | `runtime/idle-throttle/idle-throttle.log` (rate changes, first and last connection, notices); its state in `runtime/idle-throttle/state` |

**Broker auth needs a CA bundle, even over plain HTTP (verified 2026-09-28).** Both brokers ask the TextRouter over plain HTTP (`auth_http.*_path`), yet each request resolves CA certificates: when `auth_http.ssl_options` has no `cacertfile`, RabbitMQ 4.2.5's `rabbit_ssl_options:fix_client` calls `public_key:cacerts_get()`, and with no ssl options at all Erlang/OTP 27.3's `httpc` computes its default `ssl` option the same way. Where none of OTP's hard-coded distro CA files exist (the Nix build sandbox's `/etc` holds only `group`, `hosts` and `passwd`), the lookup crashes with `function_clause` in `pubkey_os_cacerts:conv_error_reason(no_cacerts_found)` (public_key 1.17.1.3 has no clause for that reason), `fix_client`'s `catch _ ->` catches only throws, and every login fails with "authentication failed with internal error"; the stack trace appears only at `DUNE_RMQ_LOG_LEVEL=debug`. `libexec/dune-rabbitmq` therefore writes `auth_http.ssl_options.cacertfile` from `NIX_SSL_CERT_FILE` (the flake's pinned `cacert`), else `SSL_CERT_FILE`, and refuses to write a config without one. `tests/integration/rabbitmq` hides the OS CA store (`-public_key cacerts_path` to a missing file) so it covers this on the host too, and it runs in the Nix check.

## Ports

| Port | Component | Exposure |
|---|---|---|
| 15431/tcp | Postgres | 127.0.0.1 only |
| 5673/tcp | admin RabbitMQ (plain AMQP) | 127.0.0.1 only |
| 31982/tcp | game RabbitMQ (AMQPS) | all interfaces; needed by game clients |
| 5674/tcp | game RabbitMQ (plain AMQP, for the GM bridge's `gm_bridge` user only) | 127.0.0.1 only |
| 18081/tcp | TextRouter auth API | 127.0.0.1 only |
| 18082/tcp | Director HTTP | 127.0.0.1 only |
| 7777/udp | game traffic (Survival_1) | clients |
| 7778–7808/udp | game traffic of the other maps (7776 + the map's slot, see [Maps](#maps)) | clients, while that map runs |
| 7888/udp | IGW server-to-server (Survival_1) | internal |
| 7889–7919/udp | IGW of the other maps (7887 + slot) | internal (map servers reach each other on this host) |
| 10000/tcp, 10001+/tcp | map servers' ServerStatus HTTP listener (each takes the next free port from 10000) | 127.0.0.1 only |
| 4369/tcp | epmd (Erlang port mapper, shared by both brokers) | **all interfaces** (see [hardening.md](hardening.md)) |
| 25672/tcp, 25673/tcp | admin and game RabbitMQ Erlang distribution | **all interfaces**; cookie-protected |
| 35672/tcp | each `rabbitmqctl` run (dune-live, GM bridge, idle throttle), while it runs | **all interfaces** |

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
| `dune-world-heal.timer` | every 5 min, from 10 min after boot | `dune-awakening heal` while `dune-world.service` is active (see "Self-heal" below); `KillMode=process` so what it starts survives |
| `dune-backup.timer` | daily 04:30, catch-up after downtime | `dune-awakening backup create --label scheduled`, then `prune` (retention policy, see "Backups and retention") |
| `dune-backup-verify.timer` | Sundays 05:15 | `dune-awakening backup verify latest` (restore drill) |
| `dune-update-check.timer` | hourly, catch-up after downtime | `dune-awakening update check --json --notify` into the journal, plus one notice per new Steam build (see "Update notices" below); exit 1 (update available) is not a failure; it never applies the update |

`systemctl --user stop dune-world` stops the world and keeps it stopped (the heal timer only acts while the world unit is active).

**Self-heal.** `dune-awakening heal` runs the cheap liveness checks first, outside the dev shell: postgres and both brokers with `status --quick` (pid file plus a live process, and for the brokers the distribution port), the other components through their `status` (a pid file), and the map servers through their pid files. When every component and every always-on map is up, that is all it does: about 0.08 s of CPU per run against the live world, measured 2026-10-01 (user + system, 5 runs), where the previous `start` through `nix develop` cost about 5.4 s (journal, `Consumed … CPU time`). Only when something is down does it run the full, idempotent `dune-awakening start` inside `nix develop`, which starts what is missing. An on-demand map that is stopped is not down (the map scaler starts it when a player travels there), so heal leaves it alone; a stopped always-on map is down. Heal does nothing while an update holds the update lock (`runtime/update.lock`): `dune-awakening update apply` holds it from stopping the world until it has started it again, and waits up to `DUNE_UPDATE_LOCK_WAIT` seconds (default 1800) for a heal that holds it. On 2026-09-30 a heal run during an update's unpack started the map server from the old images, the update then swapped the images under it, and the server crashed (Oodle decompression errors, SIGSEGV).

**Temporary directories.** Every `nix develop` run creates a `nix-develop-*` and a `nix-shell.*` directory and, because it replaces itself with the command, never removes them; the heal timer alone left about 288 a day in `/tmp`. `dune-awakening` now gives `nix develop` the private `runtime/tmp` (0700) as `TMPDIR`, removes its own two directories there once inside, and removes empty ones older than 10 minutes left by runs that died. The components get `runtime/tmp` as their `TMPDIR`.

**Update notices.** The hourly check compares the installed build with Steam's public branch. When Steam has a build the server lacks, it sends one notice through `NOTIFY_CMD to <NOTIFY_TO> --as dune_awakening_server --subject … --body … --yes` (the same world.conf settings as the idle throttle's weekly notice) and records the build in `runtime/update-notified`, so the next checks stay quiet until Steam publishes another build. A failed notice is not recorded and is retried at the next check; with no `NOTIFY_TO` nothing is sent and the journal says so. The check never updates the server: run `dune-awakening update apply` when nobody is online. On 2026-09-30 Funcom published build 25610213 at 09:58 EDT; the daily 06:00 check missed it, players' clients updated themselves, and joins failed with "Outdated Client" until a manual apply at about 22:00. A possible next step is applying automatically when nobody is online (apply already refuses while anyone is); it is not done, so an update never lands unannounced.

## Status feed for admin pages

`dune-awakening status --json` returns one document; `--watch SECS` keeps running and prints one per interval (entering nix once, about 150 ms of work per sample afterwards), and `--count N` bounds it. A page backend should start the watcher when the page opens and kill it when the page closes.

```json
{"timestamp": "2026-09-25T13:05:28-04:00", "up": true,
 "world": {"unique_name": "sh-…", "display_name": "…", "region": "North America"},
 "external_address": "100.64.0.10", "flake": "/path/to/checkout",
 "components": [{"name": "postgres", "up": true}, {"name": "rabbitmq-admin", "up": true}, {"name": "rabbitmq-game", "up": true},
                {"name": "textrouter", "up": true}, {"name": "director", "up": true}, {"name": "gateway", "up": true}, {"name": "server", "up": true},
                {"name": "map-scaler", "up": true}, {"name": "gm-bridge", "up": true}, {"name": "idle-throttle", "up": true}],
 "characters": {"stored": 1, "online": 1},
 "server": {"uptime_seconds": 2107, "memory_bytes": 10231160832, "memory_max_bytes": 21474836480, "cpu_seconds": 905.18},
 "maps": [{"name": "Overmap", "mode": "on-demand", "up": false, "game_port": 7778, "igw_port": 7889, "uptime_seconds": null,
           "memory_bytes": null, "memory_max_bytes": null, "cpu_seconds": null},
          {"name": "SH_Arrakeen", "mode": "on-demand", "up": true, "game_port": 7779, "igw_port": 7890, "uptime_seconds": 312,
           "memory_bytes": 937824256, "memory_max_bytes": 4294967296, "cpu_seconds": 41.2}, …]}
```

`characters` is null when the database is unreachable; `server` (Survival_1) fields are null when the map server is down. `maps` lists every other map the world serves, with the same fields per map; `up` (the whole world) counts an always-on map that is down, never a stopped on-demand map. CPU % = Δ`cpu_seconds` / Δwall-clock × 100 (per core). RabbitMQ is probed with `dune-rabbitmq status BROKER --quick` (process alive + distribution port), because the full check boots an Erlang VM (~1 s).

## Maps

Hagga Basin (`Survival_1`) is the world's home map and always runs. Every other map Funcom's appliance can run is a separate map server: the Overmap (the world map you fly into when leaving Hagga Basin), the social hubs Arrakeen and Harko Village, Deep Desert, and the story, dungeon and DLC maps. In Funcom's appliance, Kubernetes starts those servers when Director asks for one. Here `dune-map-scaler` does that job: it starts a map when a player travels there and stops it once nobody has been on it for a while.

**How it works.** At `start`, `dune-world-partitions` gives every served map its database partition (one row in `world_partition`, dimension 0; existing rows are kept). When a player asks to travel, Director logs the request (`Received travel request for 1 player(s) to SH_Arrakeen …`) and, while the map has no server, keeps the player queued (`Processing travel queue for … SH_Arrakeen (… num: 1)`) for up to `TravelRequestExpirationTimeSeconds` (300 s in Funcom's Director config). The scaler reads Director's log every `MAP_POLL` seconds, starts the map's server with its partition, and Director routes the waiting player once the server registers. That Director queues the player while the server starts is inferred from DASH, which scales maps from the same log lines in production; it was not yet observed on this world (see [architecture.md](architecture.md#map-scaling)). An isolated test boot of Arrakeen loaded the map, bound its ports and claimed its partition about 10 s after launch. The scaler stops a map once nobody has been on it (the players its server reports in `farm_state`) for `MAP_IDLE_AFTER` seconds, counted from its start, the last travel request for it or the last player seen on it, whichever is latest. It never stops a map while the database cannot say who is on it, never touches `Survival_1` or an always-on map, and never copies a line of Director's log (it holds credentials) into its own log.

**Settings** go in `world.conf` (read at every `dune-awakening start`); an environment variable `DUNE_<key>` wins over the file. Invalid values stop `start` with a message naming the setting.

| Key | Default | Meaning |
|---|---|---|
| `MAPS` | `all` | maps served on demand besides `Survival_1`: `all`, `none`, or names from `data/maps.tsv` separated by spaces |
| `MAPS_ALWAYS_ON` | (none) | maps started with the world, right after `Survival_1`, and never stopped by the scaler (names) |
| `MAP_SCALER` | `1` | `0` stops starting and stopping maps on demand (travel requests are still logged); always-on maps still run |
| `MAP_IDLE_AFTER` | `900` | seconds with nobody on an on-demand map before it stops (at least 60) |
| `MAP_POLL` | `5` | seconds between checks of Director's log |

Examples: `MAPS="SH_Arrakeen SH_HarkoVillage Overmap"` serves only those three on demand. `MAPS_ALWAYS_ON="SH_Arrakeen"` keeps Arrakeen up permanently (no wait on the first trip, about 1 GiB more in use). `MAPS=none` goes back to Hagga Basin alone. Removing a map from `MAPS` leaves its partition row in the database (harmless; Director ignores a partition without a server) and stops its server at the next `dune-awakening stop`.

**The maps** (`data/maps.tsv`, from Funcom's own world template and the server's `DefaultGame.ini`). The slot is Funcom's partition id; game port = 7776 + slot, IGW port = 7887 + slot. The memory cap of each map's systemd scope is twice Funcom's Kubernetes limit (Survival_1 keeps its 20 GiB).

| Slot | Map | What it is | Game / IGW UDP | Memory cap |
|---|---|---|---|---|
| 1 | Survival_1 | Hagga Basin (always on) | 7777 / 7888 | 20G |
| 2 | Overmap | the world map between regions | 7778 / 7889 | 4G |
| 3 | SH_Arrakeen | Arrakeen social hub | 7779 / 7890 | 4G |
| 4 | SH_HarkoVillage | Harko Village social hub | 7780 / 7891 | 4G |
| 8 | DeepDesert_1 | Deep Desert | 7784 / 7895 | 30G |
| 5–7, 9–32 | story, dungeon, ecolab, overland and DLC maps | instanced content | 7776 + slot / 7887 + slot | 4–12G |

Funcom's slots 33–35 (`CB_Arrakis_Generic_Sietch_Room`, `CB_Arrakis_Story_Paranoid_PrayerRoom`, `CB_Arrakis_Story_Glutton_DiningRoom`) are not served: the server's list of command-line levels has no path for them. DLC maps need the DLC on the player's account, as in Funcom's appliance.

**Memory.** With `MAPS=all` nothing extra runs until someone travels. Each running map adds its own use (Arrakeen about 1 GiB idle in the isolated test; Funcom's limits suggest 2–3 GiB for most maps and up to 15 GiB for Deep Desert), bounded by its cap. Two players can have at most a few maps up at once.

**Firewall.** Players reach each map on its own game port, so the host firewall must allow UDP 7778–7808 from the players' network as well as 7777 (or only the ports of the maps in `MAPS`). The IGW ports stay internal: map servers on this host reach each other's IGW ports locally. Nothing in this project changes the firewall.

**With several maps running:**

- **Idle throttle:** frame-rate changes go through the server-command channel, which every map server receives, so all running maps follow the same rate; the read-back checks `Survival_1`'s log. A player on any map holds a broker connection, so nobody's map is slowed while anyone is connected.
- **GM bridge and `dune-awakening world` / `character` commands:** they publish on the same shared channel; a command for one player is acted on by the map server that player is on [I]. `world cvar` reads its answer from `Survival_1`'s log only.
- **Backups:** `backup restore` refuses while any map server runs.

## Live-world commands and in-game GM

Everything about administering the running world (the command channel, world and character commands, moving and messaging players, the break timeout, and the game's own GM system) is in [admin.md](admin.md).

## Idle frame-rate throttle

The map server runs its world simulation at the game's frame cap, `t.MaxFPS 20`, whether or not anyone is playing. `dune-idle-throttle` (started last by `dune-awakening start`, stopped first by `stop`) lowers that cap while nobody is connected and restores it as soon as someone connects. Measured on this world's map server with nobody online, 60 s at each setting:

| `t.MaxFPS` | Map-server CPU (one core = 100%) |
|---|---|
| 20 (the game's default) | 39% |
| 5 | 12.7% |
| 1 | 4.3% |

It has the active rate and two lower tiers:

1. **Active**: the game's 20 fps while anyone is connected, and for the first 5 minutes after the last player leaves.
2. **Idle**: 5 fps after 5 minutes (300 s) with nobody connected.
3. **Deep idle**: 1 fps after 24 hours with nobody connected.

Any connection restores 20 fps at once, from either tier. A player counts as connected while their game client holds a TCP connection to the game broker's TLS port (31982, `DUNE_RMQ_GAME_PORT`) from an address other than this host's loopback; the world's own components (TextRouter, Director, map server, GM bridge) connect over loopback and never count. The throttle reads this with `ss` every 10 s (every 30 s in deep idle), which costs next to nothing; it never polls `rabbitmqctl`, which boots an Erlang VM (about 1 s of CPU each time). Rates change through `dune-awakening world cvar t.MaxFPS N`, which sets the value and reads it back from the server log, so a change counts only once the server confirms it; a change that fails is retried at the next poll.

The cost is a delay when someone connects: up to one poll (10 s idle, 30 s deep idle) plus a few seconds for the command and its read-back before the frame rate is back to 20. `idle-throttle.log` records the moment each first connection is seen (`first connection (1 connection; nobody connected since …)`).

**Verified on 2026-09-28** (a login during 5 fps idle, times from the throttle log and the map server log): the client opened its broker connections at +0 s, the throttle restored 20 fps at +2.0 s, the map server accepted the client's game connection at +2.5 s and logged `Join succeeded` at +5.6 s. The client connects to the broker before it contacts the map server, so at the 10 s idle poll the rate is usually restored before or while the client loads in; in deep idle (30 s poll) the first seconds in the world may still run at 1 fps.

What a player notices at 5 fps (one player in game for two minutes at `t.MaxFPS 5`, 2026-09-28, walking and riding): nothing. Their own movement is predicted by the client, so a low server frame rate would show first in other players, NPCs and hit reactions, which this short test did not cover.

Nothing is lowered in the first 5 minutes after the throttle or the map server starts. A restarted map server runs at the game's default, so the throttle takes its rate to be 20 again. (That a console-set `t.MaxFPS` does not survive a map-server restart is assumed, not measured.) `stop` puts 20 fps back when the rate may be lowered and the map server is up.

**Weekly notice.** While the world stays in deep idle, the throttle sends a notice every 7 days (the first one 7 days after deep idle began) that the world is still up, with the time the last player left. A failed notice is retried at the next poll. The idle clock, the deep-idle start and the last notice time are kept in `runtime/idle-throttle/state`, so restarting the throttle neither resets the weekly clock nor sends a notice early. A connection ends the deep-idle stretch; the next one starts its own week. Notices go through a command with the arguments of the host's `post` mail tool: `NOTIFY_CMD to <NOTIFY_TO> --as dune_awakening_server --subject … --body … --yes`. With no `NOTIFY_TO` the notice is only written to the log. The world's tools run inside `nix develop` with the project's own PATH, so give `NOTIFY_CMD` as an absolute path (for example the output of `command -v post`).

**Settings** go in `world.conf` (read at every `dune-awakening start`, so a restart of the component applies them: stop it, and the heal timer starts it again with the new settings within 5 minutes); an environment variable `DUNE_<key>` wins over the file. Invalid values stop `start` with a message naming the setting.

| Key | Default | Meaning |
|---|---|---|
| `IDLE_THROTTLE` | `1` | `0` leaves the rate alone (connections are still logged, and a lowered rate is restored) |
| `ACTIVE_FPS` | `20` | the rate while anyone is connected |
| `IDLE_FPS` / `IDLE_AFTER` | `5` / `300` | idle tier: rate, and seconds with nobody connected before it |
| `DEEP_IDLE_FPS` / `DEEP_IDLE_AFTER` | `1` / `86400` | deep-idle tier: rate, and seconds with nobody connected before it |
| `IDLE_POLL` / `DEEP_IDLE_POLL` | `10` / `30` | seconds between checks, and between checks in deep idle |
| `DEEP_IDLE_NOTICE` | `604800` | seconds between deep-idle notices; `0` sends none |
| `NOTIFY_TO` | (none) | recipient of the notices |
| `NOTIFY_CMD` | `post` | notifier command (absolute path recommended) |

Rates are whole numbers of at least 1 (the engine takes 0 as unlimited), and the tiers may not raise the rate. `libexec/dune-idle-throttle stop` then `dune-awakening start` applies changed settings to a running world.

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
