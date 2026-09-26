# Architecture: how the server pieces connect

Synthesis as of 2026-09-24 22:30 EDT, for the native (no-container) NixOS design. Detailed evidence with file:line citations lives in:

- [research/funcom-appliance-wiring.md](research/funcom-appliance-wiring.md): Funcom's Kubernetes appliance (world template, CRDs, battlegroup.sh)
- [research/dash-compose-wiring.md](research/dash-compose-wiring.md): DASH's proven Docker Compose layout on plain Linux (1.4 builds)
- [research/image-internals.md](research/image-internals.md): contents of each official image
- [research/version-1.5-compatibility.md](research/version-1.5-compatibility.md): 1.5 release timeline, version lock, watch list

Tags: **[F]** read directly from a file or API; **[I]** inference; **[GAP]** something we must build or prove.

## Version (verified)

The downloaded payload (Steam app 4754530, buildid 25486303) is the 1.5 server. The following were re-checked by hand in `unpacked/server`:

- `DefaultGame.ini:9` `ProjectVersion=1.5.3.4`
- image labels `code_branch=Seabass_sb-1.5.3.0`, `db_branch=sb_1_5_3_0`
- `perforce-keywords.json`: stream `//seabass/sb-1.5.3.0/`, CL 2094257, 2026/09/02

Database name for this build: `dune_sb_1_5_3_0`, schema `dune` [F, image-internals]. DASH's hardcoded `dune_sb_1_4_0_0` is wrong for it.

Client and server must run the exact same build [community evidence: "M52 Outdated Client"]. Funcom publishes both Steam apps together: public branches updated 31 s apart on 2026-09-24 [F, api.steamcmd.net]. Every client patch therefore forces a same-day server update.

Correction: the DASH "post-1.5 schema" note dates from 2026-07-17, before 1.5 [F, GitHub commit e42a8b4]. Our vendor checkout is a single-commit shallow clone, so local `git log` cannot date lines.

## Components

| Component | Official image base | Binary / runtime | Role |
|---|---|---|---|
| Game server (per map) | Ubuntu 24.04 | UE5 Linux shipping binary, needs glibc >= 2.27 and base libs only; libpq linked in | Simulates a map. Talks to Postgres, the game RMQ, other servers over IGW UDP |
| Director | Alpine | self-contained single-file .NET 8.0.8 (musl), needs ICU | Battlegroup brain: travel, map lifecycle, FLS heartbeats and registration, settings pushes. Polls the DB every 5 s |
| TextRouter | Alpine | same .NET form | Chat/text routing; **also the HTTP auth backend for both RabbitMQs** (`/v0/auth/*`) |
| Gateway | Alpine | CPython 3.12 bytecode only; psycopg2, python-dateutil | Public server-list / login-facing gateway; reports the game RMQ's public address |
| db-utils | Alpine | CPython 3.12 scripts + PostgreSQL 17 client tools | `init/update/reset/dump/import`; ~83 base schema files, 922 upgrade patches tracked in `applied_patches` |
| Postgres | Alpine | stock 17.4 plus barman (S3 backup); extensions pgcrypto, pg_trgm in schema `ext` | Database `dune_sb_1_5_3_0`, users `dune` and `postgres` |
| RabbitMQ admin | Alpine | 3.13.7, OTP 26.2.5.16, management + prometheus plugins | Internal service bus, plain AMQP |
| RabbitMQ game | same | same | TLS-only AMQPS 5672, published as TCP 31982; game clients connect here |

Funcom runs 35 map server sets. Only `Survival_1` (12Gi limit) and `Overmap` (2Gi) are always on. Director starts the other 33 on demand through Kubernetes [F, funcom-appliance-wiring].

## Connection graph

```
players ──UDP 7777──────────────▶ Survival_1 server ──▶ Postgres (dune_sb_1_5_3_0)
players ──TCP 31982 (AMQPS)─────▶ game RabbitMQ ──HTTP auth──▶ TextRouter
players ◀── server list via FLS ◀── Gateway / Director ──HTTPS──▶ Funcom Live Services (FLS token)
Survival_1 ◀──UDP 7888 IGW──▶ other map servers (Overmap etc.)
Director, TextRouter, Gateway, servers ──AMQP──▶ admin RabbitMQ ──HTTP auth──▶ TextRouter
Director, Gateway, db-utils ──▶ Postgres
```

Required external ingress for a one-map world: UDP 7777 and TCP 31982 [F, DASH README; Funcom template]. UDP 7888 is internal IGW. It may matter for the server-browser ping [I].

## Where the runtime settings come from

In Kubernetes, the four Funcom operators (v1.7.0) synthesize the per-process settings. None of the images carry them [F]:

- Server command line: `-DatabaseHost/Name/User/Password`, `-PartitionIndex`, `-ServerConnect`, `-ServerName`, plus `-MultiHome`, `-ExternalAddress`, `-IGWBindAddress` and the FLS token/env flags. The templates were recovered from the server-operator binary [F, image-internals]. DASH's `run_server_safe.sh` shows a working 1.4 set.
- The official `run.sh` asks the Kubernetes API for the node's external IP, rewrites those flags, drops to user `dune`, and starts sshd on game port − 1111. None of that applies natively.
- RabbitMQ config and definitions, TLS certs, DB credentials, and the RMQ HTTP auth secret (`openssl rand 64 | base64`).
- World identity `sh-<FLS HostId>-<6 letters>`. The HostId comes from the FLS token JWT [F]. It must stay stable after first registration.

## Native (option B) mapping and gaps

Ranked from least to most risk.

| # | Piece | Native plan | Status |
|---|---|---|---|
| 1 | Postgres | `libexec/dune-postgres`: nixpkgs `postgresql_17` 17.10, loopback-only, scram | **done** 2026-09-24 (tests/integration/postgres) |
| 2 | db-utils | `libexec/dune-db-setup` runs Funcom `updatedb.py --unattended --local-as-remote --no-backup` with python312 + psycopg2 + python-dateutil + debugpy; credentials in a private `DuneSandbox/Config/UserGame.ini` | **done** 2026-09-24: `dune_sb_1_5_3_0`, 921 patches, 123 tables, ~1 s, 13 MB (tests/payload/db-setup) |
| 3 | Gateway | `python312` + psycopg2 + python-dateutil, running Funcom's bytecode | needs exactly 3.12 (bytecode magic). [GAP] replace `config/gateway.ini` world id/title |
| 4 | TLS for game RMQ | self-signed CA + server cert generated once into secrets/rmq-tls by `dune-rabbitmq init game` | **done** 2026-09-24 |
| 5 | RMQ auth | `libexec/dune-textrouter`: TextRouter natively on 127.0.0.1, `-fls retail`, env mirrors DASH; DB name derived from payload perforce-keywords | **done** 2026-09-24: denies unknown users; authenticates its own minted credentials to the TLS game broker on RabbitMQ 4.2.5 (tests/payload/textrouter-auth). No FLS token needed for this. No DASH shim |
| 6 | RabbitMQ | `libexec/dune-rabbitmq`: nixpkgs rabbitmq-server 4.2.5 (OTP 27), Funcom's config (auth cache → http, game TLS-only verify_none, ephemeral). Fallback: exact 3.13.7 from nixpkgs e0464e47880a | **done** 2026-09-24 (tests/integration/rabbitmq); game compatibility with 4.x unproven until the game connects |
| 7 | Director, TextRouter | `libexec/dune-dotnet-prepare`: copy, patchelf interpreter to nixpkgs musl, `netcoredeps` symlink to the flake's musl libc/libstdc++/libgcc_s/zlib/ICU 76/OpenSSL 3 (the apps' RUNPATH is `$ORIGIN/netcoredeps`) | **runs** 2026-09-24: both print their CLI help natively (tests/payload/dotnet-apps). ICU 76 vs the image's ICU and `libAuthbuffer.so` still unproven under real load |
| 8 | Director without Kubernetes | runs natively (same prepare path as TextRouter); IGWO/Kubernetes client logs an error and continues | **runs to FLS** 2026-09-24: connects to DB (derives `dune_sb_1_5_3_0` itself), mints broker credentials, then stops at `Failed to load FLS Environment Auth Codes` with no token. Blocked only on the operator's FLS token |
| 9 | Game server | patchelf interpreter to nixpkgs glibc 2.42 `ld-linux-x86-64.so.2` and add-rpath gcc `libgcc_s`; replace `run.sh` with a unit supplying the flags | **links** 2026-09-24: all NEEDED libs resolve (LD_TRACE_LOADED_OBJECTS on a patched copy; binary needs GLIBC ≤ 2.27 symbols). [GAP] 1.5 flag set, `Saved/` layout, dlopen'd plugins (Oodle etc.) |
| 10 | Map scaling | none: `Survival_1` always on, `Overmap` only if login or first travel needs it | [GAP] confirm Director does not fail when it cannot scale other maps |
| 11 | Updates | the watcher detects a new buildid, then: download, re-unpack into a new versioned directory, run the db-utils update, restart units; roll back by switching to the previous directory and restoring the pre-update DB dump | design; the DB migration is one-way, so a backup before every update is mandatory |

Proprietary files stay in `~/.local/share/dune_awakening_server/` (payload, `unpacked/`). The flake references them by path at runtime and never copies them into the Nix store or Git.

## Open questions to settle before writing Nix

1. Does Director start and register with FLS with no Kubernetes API present, on 1.5?
2. Does TextRouter's HTTP auth work for both brokers without DASH's shim?
3. RabbitMQ 4.2.5 vs 3.13.7: does the game's AMQP usage survive 4.x?
4. The exact 1.5 server command line and env, compared against DASH's 1.4 `run_server_safe.sh` and the operator-binary templates.
5. The db-utils init entry point and args for `sb_1_5_3_0`.
6. Is `Overmap` required for a Hagga Basin login?

Questions 1, 2 and 6 can only be answered by running the processes (a local, non-public boot). That needs the operator's FLS token file and sufficient free memory.

## First join test: LAN client

The first join test uses a game client on another machine on the same physical LAN as the server host (for example, a server at 192.0.2.10). It can use `-ExternalAddress` set to the server's LAN IP, with no public ingress and no router change. It still needs the host firewall to allow UDP 7777 and TCP 31982 from the LAN only. That is a host change for the host administrator. The server still lists through FLS, so outbound HTTPS to Funcom and the token are still required [I: DASH has LAN-reflection tooling for the case where a public address is advertised and LAN clients must hairpin; advertising the LAN IP avoids that for the test].

## Build log

- 2026-09-24 22:20 EDT: the Postgres and schema steps pass. Funcom's tool connected as `dune` and reported server version 170010. Partition presets available: `basic_battlegroup`, `basic_survival_1`, `development_battlegroup`, `editor_default_1x1`, `full_battlegroup`, `igw_test_small_2x1`, `igw_test_small_2x2`, `igw_training`. `basic_survival_1` looks like the right one for a one-map world [I]; it is not applied yet. Funcom's `funcomdb/app.py` imports `debugpy` unconditionally, so debugpy is a hard dependency.
- Test tiers: `./test` runs everything, including `tests/payload/*`, which needs the local proprietary payload. The Nix check runs `./test --hermetic`, which excludes only the payload tier.
- 2026-09-24 22:50 EDT: TextRouter and Director run natively. Their CLIs show TextRouter requires `--RMQGameHostname`/`--RMQGamePort`, and both accept `--RMQAdminHostname`/`--RMQAdminPort` (Director), `--RMQCredentials user:pass`, `-fls <env>` and `-uselocalfls`. Config comes from `router_config.ini` / `director_config.ini` in the working directory.
- RabbitMQ: `-detached` launches died right after startup under RabbitMQ 4.2.5, so `libexec/dune-rabbitmq` runs the node in the foreground under `setsid` (systemd will run it in the foreground too) and polls `rabbitmq-diagnostics ping` for up to 60 s before `await_startup`.
- 2026-09-24 23:00 EDT: TextRouter observations. It connects to `dune_sb_1_5_3_0` and to the game broker via AMQPS, and serves `/v0/auth/*`. RabbitMQ 4.2.5 accepted its connection. Unknown users get `deny` ("Token is Malformed"). It logs an IGWO error looking for a Kubernetes API at port 6443 with empty host and battlegroup name, then continues. **It logs credentials at INFO**: its minted broker passwords and built-in `bob`/`guest` passwords. Its log is created 0600 and must never be shared. `-uselocalfls` fails (developer "scratch" environment); `-fls retail` works. It does not need the FLS token to start.
- 2026-09-24 23:00 EDT: Director probe, with no token and no Kubernetes. It logs `Failed to parse instancing mode PolarCap_1 Dimension` and `CB_Dungeon_TheFacility ClassicalInstancing`, both non-fatal ini entries its enum does not know. It logs the IGWO/Kubernetes error and continues, connects to the DB, and generates `bgd.<world>.<id>.game/.admin` broker credentials. It then fails at FLS init because the token is absent. It fails locally before any call to Funcom. Its default log level is debug, and it **logs the DB password and minted credentials**, so its log must also be created 0600.
- 2026-09-24 23:05 EDT: game server `DuneSandboxServer-Linux-Shipping` (388 MB) needs only libpthread, libdl, libm, librt, libc, ld-linux and libgcc_s. All resolve against nixpkgs glibc 2.42 after an interpreter patch plus `--add-rpath` for gcc's lib. The original stays untouched; this was checked on a copy.
- 2026-09-24 23:50 EDT: launchers for every piece exist: `libexec/dune-director`, `libexec/dune-gateway`, `libexec/dune-server` and `bin/dune-awakening` (up, down, status in dependency order). Notes:
  - `libexec/dune-world-partitions` creates only Survival_1 dimension 0 with Funcom's `add_partition_unique` and prints its `partition_id`, which becomes `-PartitionIndex`. The fresh schema has no partitions, and Funcom's `basic_survival_1` preset would create four dimensions.
  - Director and Gateway take world overrides from a `conf.d/` directory beside their config, which both binaries search besides `/etc/app/conf.d`. So nothing is written to `/etc`.
  - The game server runs from a symlink farm of the payload tree. Only the binary is copied and patched. `Saved/` is persistent and outside the farm. The FLS token, DB password and join password go into 0600 `Saved/Config/LinuxServer/{Engine,Game}.ini` overrides, not argv [I: Unreal's saved-config hierarchy should apply them; to be verified at first boot]. The server runs under `systemd-run --user --scope` with `MemoryMax=20G` and `MemorySwapMax=0`.
  - `libexec/dune-unpack` replaces the ad-hoc unpack helper. It handles plain and gzip layers and OCI whiteouts. It was verified byte-identical (`diff -rq`) against the helper's trees for the TextRouter and Gateway images.
- 2026-09-25 00:30 EDT: intermittent test failures traced to two root causes, each reproduced before it was fixed:
  - **Funcom parses RabbitMQ ports as Int16.** TextRouter and Director use `StartWebservice(String, Int16 gamePort, …)` and print their usage text for any port above 32767. The tests drew ports from 20000–39999. It reproduced in 7 of 25 runs, and 0 of 25 after the fix. The launchers now refuse such ports with an explicit message. Production 31982 is within the limit, but that makes 31982 close to the maximum usable RabbitMQ port.
  - **Ephemeral-range port collisions.** The tests now pick port blocks with `tests/lib/ports.bash` (20000–32767, checked free with `ss`). The RabbitMQ test then passed 25 of 25.
