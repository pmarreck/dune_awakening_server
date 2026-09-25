# Battlegroup container image internals

Read-only static inspection done 2026-09-24 (EDT) for private interoperability
analysis. Nothing from the images was executed. Layers were unpacked, in manifest
order with `.wh.` whiteouts applied, to
`~/.local/share/dune_awakening_server/unpacked/<image>/{oci,rootfs,config.json}`
(mode 0700, outside git). Paths below are inside each image's rootfs unless marked
otherwise. Secrets found in the images are named but redacted.

Source tarballs: `~/.local/share/dune_awakening_server/steam-server/images/`.
Every tar is an OCI layout (`oci-layout`, `index.json`, `blobs/sha256/`) that also
carries a docker-style `manifest.json`. All six battlegroup images are tagged
`registry.funcom.com/funcom/self-hosting/seabass-<name>:2124138-0-shipping`.
`battlegroup/version.txt` reads `2124138-0-shipping`, and
`operators/version.txt` reads `v1.7.0`. Postgres is
`registry.funcom.com/funcom/self-hosting/igw-postgres:17.4-alpine-fc-13`.

## Game version verdict: this is a 1.5.x build (1.5.3.x line, ProjectVersion 1.5.3.4)

| Evidence | Where |
|---|---|
| Image labels `code_branch=Seabass_sb-1.5.3.0`, `db_branch=sb_1_5_3_0` | `server` image config |
| `"path": "$File: //seabass/sb-1.5.3.0/DuneSandbox/Config/perforce-keywords.json $"`, `"cl": "$Change: 2094257 $"`, `"time": "$DateTime: 2026/09/02 11:43:44 $"` | `/home/dune/server/DuneSandbox/Config/perforce-keywords.json` (the same file is byte-identical in director, text-router, gateway and db-utils) |
| `ProjectVersion=1.5.3.4` | `/home/dune/server/DuneSandbox/Config/DefaultGame.ini` line 9 |
| UTF-16 strings `sb-1.5.3.0`, `1.5.3.0` and `2124138` in the server binary, plus the target name `Seabass.Server.UE5.Shipping.Linux` | `DuneSandbox/Binaries/Linux/DuneSandboxServer-Linux-Shipping` |
| The binary contains `Overriding ProjectVersion '%s' with '%s' from branch name.`, so the runtime version string is probably derived from the branch (`1.5.3.0`) (inference) | same binary |

No 1.4 strings turned up. 2124138 is the build changelist and matches the image
tag. 2094257 is the last change to the keywords file. For comparison,
`version-1.5-compatibility.md` records the 1.5 client advertising revision
2111270 on 2026-09-17, so 2124138 is a later 1.5.3.x hotfix build (inference).

## 1. `server` (seabass-server, the UE game server)

- **Base:** Ubuntu 24.04.5 LTS (`/etc/os-release`, label `org.opencontainers.image.version=24.04`).
- **Cmd:** `["/home/dune/run.sh"]`. No entrypoint. WorkingDir `/home/dune/server/`. Env `TZ=Etc/UTC`, `BUILD_REVISION=` and `BUILD_CONFIGURATION=` (both empty).
- **Users:** the `ubuntu` user is removed. `dune` has uid 1000 and gid 65534 (nogroup), home `/home/dune`, full sudo, and NOPASSWD for `/usr/bin/perf`. The image history contains a plaintext password for `dune` (`openssl passwd -1 <REDACTED>`). The build also sets `kernel.yama.ptrace_scope=0` and `kernel.perf_event_paranoid=-1` in `/etc/sysctl.d`.
- **Extra apt packages** (debug/ops tooling): rsync, lsof, net-tools, curl, dos2unix, gdb, lldb-15, llvm-15, less, tmux, screen, mc, sudo, postgresql-client, zip, gzip, jq, python3-venv, vim, gdbserver, inetutils-ping, libc6-dbg, several `linux-tools-6.8.0-*` / `6.17.0-14` builds, and openssh-server. apt sources point at Funcom's internal Nexus proxy `tools-osl.funcom.com`.

**`/home/dune/run.sh` (bash, runs as root):**
1. `install_cert`: if `/var/run/secrets/kubernetes.io/serviceaccount` exists, it symlinks the k8s CA into `/usr/local/share/ca-certificates/kubernetes.crt` and runs `update-ca-certificates`.
2. Creates `/home/dune/server/DuneSandbox/Saved/UserSettings`, chowns `Saved` to `dune:nogroup`, and symlinks `~dune/.config/Epic/Unreal Engine/Engine/Config` to that UserSettings directory, replacing any real directory already there.
3. `fetch_external_node_address`: if `NODE_NAME` is set and a service account exists, it GETs `https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT_HTTPS/api/v1/nodes/$NODE_NAME` and takes the `ExternalIP` with jq.
4. Builds `-MultiHome=$POD_IP -ExternalAddress=<ext>` (or only `-MultiHome=$POD_IP`). Any `-MultiHome=<ip|$POD_IP>` in the incoming args is replaced by that string with sed, and `-IGWBindAddress=$POD_IP` is appended.
5. Runs `su dune -c "./DuneSandboxServer.sh <args>"` in the background, then polls `ps` until the `DuneSandboxServer-Linux-Shipping DuneSandbox` process appears and writes its PID to `/home/dune/server_pid`.
6. Polls `lsof` until the process has at least two UDP ports starting with 7 or 8. The lower one goes to `/home/dune/game_port` and the higher to `/home/dune/igw_port`. The SSH port is game_port−1111, written to `/home/dune/ssh_port`, patched into `sshd_config`, and sshd is started.
7. `amend_kubernetes_metadata`: PATCHes its own pod status with annotations `gamePid`, `gamePort`, `igwPort` and `sshPort`.
8. Traps SIGTERM, forwards TERM to the game PID, waits, and exits with the server's exit code.

**`/home/dune/server/DuneSandboxServer.sh`:** a stock UE wrapper. It chmods the binary and execs `DuneSandbox/Binaries/Linux/DuneSandboxServer-Linux-Shipping DuneSandbox "$@"`.

**Env vars read by run.sh:** `POD_IP` (required), `NODE_NAME`, `POD_NAME`, `KUBERNETES_SERVICE_HOST`, `KUBERNETES_SERVICE_PORT_HTTPS`, `BUILD_REVISION`, `BUILD_CONFIGURATION`. All the k8s steps are skipped when the service-account directory is absent.

**Launch args.** They are not stored in the image. The server-operator binary (`operators/server-operator.tar`, `/app/operator`) contains the templates `-MultiHome=$POD_IP`, `-DatabaseHost=%s:%d`, `-DatabaseName=`, `-DatabaseUser=`, `-DatabasePassword=`, `-PartitionIndex=%d`, `-ServerConnect=` and `-ServerName=`. The game binary's UTF-16 `Key=` parse strings also include `IGWPort=`, `IGWBindAddress=`, `DimensionIndex=`, `DatacenterId=`, `FarmRegion=`, `RMQAdminHostname=`, `RMQAdminPort=`, `RMQGameHostname=`, `RMQGamePort=`, `RMQGameTlsEnabled=`, `RMQHttpPort=`, `ConnectFarm=`, `PvpPartitions=`, `BattlEye=`, `EXTERNALADDRESS=`, `MULTIHOME=`, `Port=`, `BeaconPort=`, `BindAddress=` and `LANGUAGE=`.

**Main binary** `DuneSandbox/Binaries/Linux/DuneSandboxServer-Linux-Shipping` (388 MB):
- ELF 64-bit PIE, x86-64, stripped, interpreter `/lib64/ld-linux-x86-64.so.2`, "for GNU/Linux 4.18.20".
- NEEDED: `libpthread.so.0 libdl.so.2 libm.so.6 librt.so.1 libc.so.6 ld-linux-x86-64.so.2 libgcc_s.so.1`. It does not need libstdc++ (UE links its own libc++).
- Highest symbol versions: `GLIBC_2.27`, so it needs glibc ≥ 2.27.
- RPATH points at `${ORIGIN}/../../../Engine/Binaries/ThirdParty/...` (PhysX3, Embree, OodleNetwork, BinkMedia, OpenVR, Qualcomm). None of those directories ship in the image, so those libraries are statically linked or unused.
- libpq is statically linked (the strings `PQconnectdbParams` and `libpq received bad/unexpected response`).
- Optional dlopen strings (SDL/graphics/audio, unused by a headless server): libvulkan.so.1, libGL/EGL/GLES, libX11 family, libpulse, libasound, libudev.
- Also shipped: `Engine/Binaries/Linux/CrashReportClient` and an embedded Python 3.9 in `Engine/Binaries/ThirdParty/Python3/Linux/` (`libpython3.9.so.1.0` plus stdlib).
- `BattlEye/BEServer_x64.so`: ELF shared object that NEEDs only `libc.so.6 libdl.so.2 libpthread.so.0` (GLIBC ≤ 2.14). `BEServer_x64.cfg` holds `GameID dune`, `MasterPort 8027`, `PreGameTimeout 120` and `InGameTimeout 90`.

**Engine version:** UE5. The target string is `Seabass.Server.UE5.Shipping.Linux`, and a TSR cvar help text says "as TSR was in 5.0 and 5.1", which implies ≥ 5.2. No `++UE5+Release-5.x` string was found, so the exact minor version is unconfirmed. `5.2.1` appears in the binary, but that is Mercuna middleware's version.

**Content:** `DuneSandbox/Content/Paks/` is 3.7 GB, IoStore plus pak, each chunk with a `.sig`: `global`, and `pakchunk{0,100,120,130,140,150,155,170,190,200,210,220,230,240}-LinuxServer`. There is also `Content/GameDemo/GameDemo.db` (SQLite 3.51.0) and `Content/Splash/Splash.bmp`.

**Maps:** `ServerDefaultMap=/Game/Dune/Maps/Arrakis/SOC_1/Survival_1` and `GameDefaultMap=/Game/Dune/Maps/CharacterSelectionCave/CB_CS_Cave.CB_CS_Cave` (`DefaultEngine.ini` lines 185 and 187). The full list of battlegroup maps comes from the Director config below.

**Config ini names:** `DuneSandbox/Config/`: DedicatedServerEngine.ini, DedicatedServerGame.ini (admin/GM command allow-lists), DefaultDeviceProfiles, DefaultDreamworld, DefaultEngine, DefaultGame, DefaultGameplayTags, DefaultHardware, DefaultInput, DefaultScalability, GeneratedServerCustomSettings.ini (`DifficultyLevel=Custom`), `Linux/{DefaultEngine,GeneratedLinuxGame,LinuxEngine}.ini`, `Steam/SteamEngine.ini`, `Tags/*.ini`, `TLS/{cacert,cert,key}.pem`, projectconfig.json (`{}`) and branchmap.json (`{}`). `Engine/Config/` holds the stock Base*.ini files.

**Default ports and settings:**
- `Engine/Config/BaseEngine.ini` `[URL]`: `Port=7777`, `IGWPort=7888`. Also `GameServerQueryPort=27015`.
- `DedicatedServerEngine.ini`: `[OnlineSubsystem] DefaultPlatformService=FLS`, `dw.ServerStatus.PortRangeStart=10000`, `PortRangeEnd=11000`, `[MessageQueue] RMQHttpPort=15672 bEnabled=True HeartbeatIntervalSeconds=10`.
- `[DuneDatabaseInterfacePSQL]` in `Engine/Config/BaseGame.ini:317`: `DatabaseHost=localhost:15431`, `DatabaseName=dune%_BRANCH%` (which becomes `dune_sb_1_5_3_0`), `DatabaseUser=dune`, `DatabaseAdminDatabaseName=postgres`, `DatabaseAdminUser=postgres`. The passwords are present in the file and redacted here.
- run.sh treats UDP ports starting with 7 or 8 as game and IGW ports, and SSH as game−1111.

**Copies of other components:** `/home/dune/server/PSQL/` and `DuneSandbox/Database/` are identical (`diff -rq`) to db-utils' `/root/PSQL` and `/root/DuneSandbox/Database`. `DuneSandbox/Config/TLS/cert.pem` is byte-identical to rabbitmq's `/etc/rabbitmq/cert.pem`.

## 2. `server-bg-director` (Battlegroup Director, .NET)

- **Base:** Alpine 3.19.4, following the `mcr.microsoft.com/dotnet/runtime-deps`-style recipe (apk ca-certificates-bundle, libgcc, libssl3, libstdc++, zlib, plus `icu` and `bash`). A `dotnet-runtime-8.0.8-linux-musl-x64` tarball is also installed under `/usr/share/dotnet` (Microsoft.NETCore.App 8.0.8 only), but the app does not use it.
- **User:** `app` (uid/gid 1654) is created, but the config sets no `User`, so the container runs as root.
- **Entrypoint:** `["./Director"]`. WorkingDir `/Tools/Battlegroups/Director/BattlegroupDirector`. Env `ASPNETCORE_HTTP_PORTS=8080`, `DOTNET_RUNNING_IN_CONTAINER=true`, `DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true`, `DOTNET_VERSION=8.0.8`.
- **Files:** `Director` (112 MB), `director_config.ini`, `libAuthbuffer.so`, `wwwroot/{Icons,Script,Stylesheet}` (web dashboard assets). Also `/DuneSandbox/Config/{perforce-keywords.json,DefaultEngine.ini,projectconfig.json}` and `/DuneSandbox/branchmap.json`, which the app reads to resolve the FLS environment and branch.
- **Binary:** ELF PIE with interpreter `/lib/ld-musl-x86_64.so.1`. NEEDED `libz.so.1 libgcc_s.so.1 libstdc++.so.6 libc.musl-x86_64.so.1`, RUNPATH `$ORIGIN/netcoredeps`. It is a **self-contained single-file bundle**. The embedded runtimeconfig has `tfm net8.0`, `includedFrameworks` Microsoft.NETCore.App 8.0.8 and Microsoft.AspNetCore.App 8.0.8 (runtime packs `linux-musl-x64`), and `configProperties` `System.GC.Server=true`, `System.Globalization.Invariant=false`, `EnableUnsafeBinaryFormatterSerialization=false`. Because Invariant is false in runtimeconfig, it probably needs libicu at runtime, consistent with `apk add icu` (inference).
- **Notable embedded deps (deps.json):** Npgsql 9.0.2, Dapper 2.1.35, RabbitMQ.Client 6.8.1, **KubernetesClient 17.0.14**, Azure.Data.Tables 12.9.1, Azure.Storage.Blobs 12.19.1, Refit 8.0.0, Polly 8.5.1, Serilog 4.0.0 (+AspNetCore, Console, File, Async sinks), Swashbuckle 6.4.0, System.CommandLine 2.0.0-beta4, YamlDotNet 16.3.0, plus the in-house BattlegroupUtils and SimpleShaTokens.
- **CLI flags** (UTF-16 strings): `--RMQAdminHostname`, `--RMQAdminPort`, `--RMQGameHostname`, `--RMQGamePort`, `--RMQCredentials` (`username:password`), `-uselocalfls`, `--help`, `--version`.
- **Env vars referenced:** `BATTLEGROUP`, `BATTLEGROUP_DISPLAY_NAME`, `BATTLEGROUP_REGION_NAME`, `BATTLEGROUP_TITLE`, `BATTLEGROUPS_DEFAULT_GRANT_DURATION_IN_SECONDS`, `RMQ_HTTP_TOKEN_AUTH_SECRET`, `RMQ_HTTP_TOKEN_AUTH_TIME_SKEW_SECONDS`, `SERVER_LOGIN_PASSWORD_SECRET`, `SERVER_LOGIN_PASSWORD_SKEW_SECONDS`, `KUBERNETES_SERVICE_HOST/PORT`, `KUBECONFIG`, and the standard `PG*` variables (via Npgsql).
- **Kubernetes coupling:** it calls `/apis/igw.funcom.com/v1/namespaces/.../battlegroups/` and `/battlegroupdirectorstats/` (the operator CRDs), plus core `/api/v1`. It also calls FLS APIs `api/Director_InitializeDirector`, `api/Battlegroups_DeclarePopulationAndActivity`, `api/Battlegroups_DeclareMaxPlayerCapacities`, `api/Battlegroups_DeclareBattlegroupUpdates` and `api/Battlegroups_SendBattlegroupHeartbeat`.
- **`director_config.ini` sections:** `[Database]` (address=localhost, port=15431, user=dune, password redacted), `[RMQAdmin]` and `[RMQGame]` (localhost:5672), `[RMQSettings]`, `[Logging]` (level=debug), `[Battlegroup]` (about 35 timing, transfer and FLS knobs), `[InstancingModes]`, `[Server]` (PlayerHardCap=40, DauCap, WauCap=3360, AllowGroupTravel=false), `[ClassicalInstancing]`, one section per map with PlayerHardCap, QueueFailMap and QueueFailLocation, `[Editor_Default]`, `[FuncomLiveServices]` (empty ServiceAuthToken), `[FlsApi]`, `[FlsApi_Http]`, `[FlsSettings]`, and `[ServerAuthenticationSecrets]` (two base64 secrets, redacted).
- **Map list** from `[InstancingModes]`:
  - SingleServer: Overmap.
  - Dimension: Survival_1, DeepDesert_1, PolarCap_1.
  - ClassicalInstancing: SH_HarkoVillage, SH_Arrakeen, SH_FallenLight, CB_Story_Hephaestus, CB_Story_Ecolab_Carthag, CB_Story_WaterFatManor, Story_ProcesVerbal, Story_ArtOfKanly, DLC_Story_LostHarvest(+_EcolabA, _EcolabB, _ForgottenLab), Story_HeighlinerDungeon, CB_Dungeon_Hephaestus, CB_Dungeon_OldCarthag, CB_Story_BanditFortress01, CB_Overland_S_04/05/06/07/08, CB_Overland_M_01, Story_Faction_Outpost_Hark/Atre, CB_Ecolab_Bronze_Green_024/089/136/152/195, CB_Story_DestroyedZanovar, CB_Story_OrbitalMonitor, CB_Dungeon_TheFacility, CB_Dungeon_ThePit, CB_Arrakis_Generic_Sietch_Room, CB_Arrakis_Story_Paranoid_PrayerRoom, CB_Arrakis_Story_Glutton_DiningRoom.
- **`libAuthbuffer.so`:** unstripped ELF .so that NEEDs `libstdc++.so.6 libgcc_s.so.1 libc.so.6`. It is linked against **glibc**, but the image is musl-only (`/lib` has no `libc.so.6` and gcompat is not installed). It cannot load as shipped, so it is probably unused or optional (inference).

## 3. `server-text-router` (chat routing / profanity filter, .NET)

The recipe matches Director: Alpine 3.19.4, the same musl dotnet-runtime 8.0.8 layer, icu and bash, root user. Entrypoint `["./TextRouter"]`, WorkingDir `/Tools/Battlegroups/TextRouter/TextRouter`, with the same env as Director.
- `TextRouter` (112 MB) is a self-contained single-file musl bundle with the same ELF/NEEDED profile as Director (same host BuildID) and the same embedded runtimeconfig (net8.0, NETCore 8.0.8 + AspNetCore 8.0.8, Server GC, Invariant=false).
- `appsettings.json` sets `Serilog.MinimumLevel.Override` (Microsoft, `Serilog.AspNetCore.RequestLoggingMiddleware`) and `AllowedHosts=*`. `appsettings.Development.json` sets `Logging.LogLevel` (Default, Microsoft.AspNetCore). No secrets.
- `router_config.ini` has `[ ProfanityFilterModerationSettings ]` with SessionIdMinutesGranularity=15, DuplicateMessageFilterCacheSizeMax=100 and DuplicateMessageFilterProximityOnly=true.
- CLI flags: `--RMQGameHostname`, `--RMQGamePort`, `--RMQCredentials`, `-uselocalfls`. Env vars are the same set as Director minus the SERVER_LOGIN and GRANT variables.

## 4. `server-gateway` (Gateway service, Python)

- **Base:** Alpine 3.24.2, official `python:3.12.14-alpine` recipe (CPython built into `/usr/local`), plus `libpq` (18.6-r0), `icu` and `bash`. No user is set, so it runs as root.
- **Cmd:** `["python","-m","service","-c","/Tools/Battlegroups/GatewayService/service/configs/service.conf"]`. WorkingDir `/Tools/Battlegroups/GatewayService/`. Env `ROOT_FOLDER=/usr/local`, `PROJECT_NAME=app`.
- **Code:** bytecode only (`.pyc`, magic `cb0d0d0a` = CPython 3.12), so it **requires CPython 3.12 exactly**. Modules: `__main__`, `main`, `battlegroup`, `gateway_requests`, `gateway_settings`, `active_server_monitor`, `character_deletion`, `utilities/{db_helper,error_handling,fls_settings,logger,path_helper,settings}`, and `tests/`.
- **requirements.txt:** `python-dateutil` and `psycopg2`. site-packages holds psycopg2 2.9.13, python-dateutil 2.9.0.post0, six 1.17.0 and pip 25.0.1.
- **service.conf sections:** `[DuneDatabaseInterfacePSQL] DatabaseConnectTimeout=10`, `[gateway] matchmaker_request_max_retries=10`, `[server_monitor] interval_seconds=5 db_check_max_retries=10`, `[error_handling]`, `[logging] path=logs/gateway.log`, `[character_deletion] interval_minutes=240`.
- **Other settings keys (from the .pyc):** `[FuncomLiveServices]` BattlegroupAuthorizationPreset, FlsHostUrl, RmqTlsEnabled, ServiceAuthToken, DefaultFlsEnvironment. `[OnlineSubsystem]` ServerName, DatacenterId. `[gateway]` admin_rmq_hostname/port, game_rmq_hostname/port/http_port/secret, farm_api_key, display_name, title, battlegroup_language, battlegroup_close_date, host_datacenter_id/ip_address, revision, queues_disabled, battlegroup_heartbeat_disabled.
- **Launch-option aliases:** `RMQGameHostname`, `RMQGamePort`, `RMQGameHttpPort`, `RMQAdminHostname`, `--useLocalFls` (the local FLS default is `http://localhost:7071/`).
- **Env vars:** `HOST_DATACENTER_ID`, `HOST_DATACENTER_IP_ADDRESS`, `RMQ_HTTP_TOKEN_AUTH_SECRET`, `BATTLEGROUP_LANGUAGE`, `USERPROFILE`.
- **Behaviour (from the names):** it sends gateway up/down, `api/GatewayDeclareServerStatus` and `api/GetCharactersRipeForDeletion` to FLS, monitors active servers in the farm DB, and runs periodic character deletion.
- **File paths it reads:** it walks up from the script directory to find `DuneSandbox/`, which is `/DuneSandbox/Config/{perforce-keywords.json,DefaultEngine.ini,projectconfig.json}` and `/DuneSandbox/branchmap.json` in this image. It reads the UE ini chain (Default, Base, DedicatedServer, User, and `Saved/Config/WindowsServer`).

## 5. `server-db-utils` (schema install and migrations, Python)

- **Base:** Alpine 3.21.2, official `python:3.12.8-alpine` recipe, plus apk `libpq` and `postgresql17` (17.11-r0) for the client and server tools psql, pg_dump, pg_restore, pg_ctl and initdb.
- **Entrypoint:** `["python"]`, no Cmd. WorkingDir `/root/PSQL`. Label `version=1`. It runs as root.
- **site-packages:** psycopg2 2.9.13, debugpy 1.8.22, pip.
- **Scripts in `/root/PSQL`** (plain `.py` source), all using `funcomdb.app.run`:
  - `startdb.py` / `initdb.py`: start or initialize a local server.
  - `stopdb.py`
  - `updatedb.py`: optional backup (`--no-backup`, `--ignore-backup-failure`), then applies patches.
  - `resetdb.py`
  - `dropdb.py`
  - `dumpdb.py` / `importdb.py`: `--file`, `--force`, `--update`, `.sql` or `.zip`.
  - `debugdb.py`: interactive psql.
  - `testdb.py`
  - `diff.py`
  - packages `funcomdb/` (config, connection, database, dump, restore, update, installation) and `ToolsDB/` (setupdb, updatedb, dumpdb, settings).
- **Common options:** `--host/--dbhost host:port`, `--project-database/--dbname`, `--project-user/--user`, `--project-password/--password`, `--admin-user`, `--admin-password`, `--admin-database`, `--connection-timeout`, `--unattended` (a comment says IGWO adds `--unattended` to every call), `--schema-path`, `--skip-patch-check`, plus an installation-dir option.
- **Env vars:** `FUNCOM_POSTGRES_INSTALL` (legacy `DW_PSQL_DIR`) for the Postgres install dir, and `FUNCOM_DATABASE_COMMAND_TIMEOUT`.
- **Connection settings:** read from `[DuneDatabaseInterfacePSQL]` in `/root/Engine/Config/BaseGame.ini` (then DefaultGame, User and Saved overrides). The defaults are host `localhost:15431` (`funcomdb/version.py`: `POSTGRES_VERSION='17.4'`, `POSTGRES_PORT=15431`) and `DatabaseName=dune%_BRANCH%`. `%_BRANCH%` is expanded from the perforce-keywords stream `sb-1.5.3.0`, which becomes `_sb_1_5_3_0`, so the project database is **`dune_sb_1_5_3_0`**. The user is `dune`, and the admin is `postgres` on DB `postgres`.
- **Schema layout:** the schema name equals the project user (`dune`). There is an extra schema `ext`, which holds the extensions `pgcrypto` and `pg_trgm` (`CREATE EXTENSION ... WITH SCHEMA ext`); no other extensions are referenced. Patch tracking uses table `applied_patches(name text unique, date timestamp)` and function `get_applied_patches()` (`ToolsDB/setupdb.py`). A downgrade is refused if the DB has unknown patches.
- **SQL:** `/root/DuneSandbox/Database/` holds about 83 top-level base schema files, applied in the order listed in `Database/__init__.py`. Examples are `01_Dune.sql`, `actor_core.sql`, `02_player.sql` ... `93_player_access_codes.sql`, `igw.sql`, `igwo_interface.sql` (IGWO functions such as `igwo_get_partitions` and `igwo_insert_world_partition`), `character_transfers.sql` and `demo_trial.sql`. `Database/Upgrade/` holds 922 patch files (numbered `01.sql`...`NNN.sql` plus `TECH-xxxxx_*.sql`), and `dbtests/` holds the tests. There are 1001 `.sql` files in total. World-partition presets include `IGW_Test_Small`, `IGW_Training` and `IGW_Test`.

## 6. `server-rabbitmq`

- **Base:** Alpine 3.22.2, following the official `rabbitmq:3.13-management-alpine` recipe. It uses RabbitMQ **3.13.7** (`RABBITMQ_VERSION`, `plugins/rabbit_common-3.13.7`) with **Erlang/OTP 26.2.5.16** in `/opt/erlang` (`OTP_VERSION`) and OpenSSL **3.1.8** in `/opt/openssl`.
- **Entrypoint and Cmd:** `docker-entrypoint.sh rabbitmq-server`. User `rabbitmq` (uid 100, gid 101), `HOME=/var/lib/rabbitmq` (a volume), `RUNNING_UNDER_SYSTEMD=true`. Exposed ports: 4369, 5671, 5672, 15671, 15672, 15691, 15692, 25672.
- **`/usr/local/bin/docker-entrypoint.sh`** (50 lines, upstream): if the container starts as root it chowns `/var/lib/rabbitmq` and re-execs as `rabbitmq` via su-exec. It exits if any deprecated `RABBITMQ_*SSL*` or `RABBITMQ_DEFAULT_*_FILE` env var is set, sets `RABBITMQ_USE_LONGNAME=true` when the long and short hostnames differ, then runs `exec "$@"`.
- **Enabled plugins:** `/etc/rabbitmq/enabled_plugins` = `[rabbitmq_management,rabbitmq_prometheus].` The stock plugin set (76 entries) includes `rabbitmq_auth_backend_http`, which is not enabled in the image.
- **Config:** only `/etc/rabbitmq/conf.d/10-defaults.conf` (`loopback_users.guest = false`, `log.console = true`). There is no `rabbitmq.conf`, `advanced.config` or `definitions.json` in the image. The CRDs (`operators/crds/messagequeues.yaml`, `battlegroups.yaml`) say the operator mounts a ConfigMap into `/etc/rabbitmq/conf.d/`, overrides `enabled_plugins`, and can pass `RMQ_HTTP_AUTH_ADDRESS` for a custom HTTP auth service. Users, vhosts and queues are therefore defined at runtime and are not visible here.
- **TLS:** `/etc/rabbitmq/{cacert,cert,key}.pem`. `cacert.pem` and `cert.pem` are the same self-signed cert (`CN=*.funcom.com`, `O=Corp, OU=Test`, SAN `iliak-vm1/vm2.funcom.com` plus two public IPs). It expired on 2022-04-22. The private key is present (not reproduced).

## 7. `igw-postgres` (17.4-alpine-fc-13)

- **Base:** Alpine 3.21.3, an unmodified official `postgres:17.4-alpine` recipe (PG 17.4 built from source with LLVM19 JIT, gosu 1.17). The image carries compose labels (`com.docker.compose.service=postgres17`).
- **Entrypoint and Cmd:** `docker-entrypoint.sh postgres`. User `postgres` (uid/gid 70). `PGDATA=/var/lib/postgresql/data`, port 5432, `STOPSIGNAL SIGINT`. `docker-entrypoint.sh` contains no Funcom changes (grep finds no "funcom").
- **What fc-13 adds on top of upstream:**
  1. `apk add py3-setuptools py-lz4` and `barman` from Alpine edge/testing, which pulls in barman 3.13.0, py3-boto3/botocore 1.35.71, py3-lz4 4.3.3 and python3 3.12.10. This provides the `barman-cloud-*` tools.
  2. `/var/lib/postgresql/scripts/` (owner nobody):
     - `archive-command.sh`: `barman-cloud-wal-archive --cloud-provider aws-s3 --lz4 s3://$BARMAN_CLOUD_BUCKET_NAME/artifacts/$BATTLEGROUP database-backups`
     - `restore-command.sh`: `barman-cloud-wal-restore`
     - `backup-create.sh <port> <user> <name>`: `barman-cloud-backup --gzip`
     - `backup-restore.sh <backup_id> [target_time]`: wipes PGDATA, runs `barman-cloud-restore`, writes `recovery.signal` and a `postgresql.auto.conf` with `restore_command` pointing at restore-command.sh, starts `postgres -c config_file=/etc/postgres/postgres.conf` until recovery completes, then cleans up.
  3. An AWS CLI config with `[default] s3 = addressing_style = virtual`, copied to `/root/.aws/config`, `/var/lib/postgresql/.aws/config` and `/.aws/config`. No credentials.
- **Env vars used by the scripts:** `BARMAN_CLOUD_BUCKET_NAME`, `BATTLEGROUP`, plus AWS credentials supplied at runtime.
- **Unchanged from upstream:** no extra extensions. The `.control` files and `/usr/local/lib/postgresql/*.so` are exactly the contrib set plus plperl, plpython3u and pltcl. `/docker-entrypoint-initdb.d/` is empty. The only change to `postgresql.conf.sample` is the upstream `listen_addresses = '*'`. `/etc/postgres/postgres.conf`, which backup-restore.sh refers to, is not in the image and is mounted at runtime.
- **`postgres` NEEDED:** libzstd, liblz4, libxml2, libssl/libcrypto 3, libgssapi_krb5, libz, libldap, libicui18n/libicuuc 74, musl libc.

## 8. What nixpkgs would need to run each natively

nixpkgs versions were evaluated against the flake-registry `nixpkgs` on 2026-09-24: postgresql_17 17.10, rabbitmq-server 4.2.5, erlang_26 (removed as EOL), default erlang 28.5, dotnetCorePackages.aspnetcore_8_0 8.0.29, python312 3.12.13, barman 3.19.1, python312Packages.psycopg2 2.9.12, debugpy 1.8.21, musl 1.2.6, glibc 2.42.

| Component | Native requirement | Gap |
|---|---|---|
| Game server | glibc ≥ 2.27 (nixpkgs has 2.42), libgcc_s. Set the interpreter with patchelf to nixpkgs glibc's `ld-linux-x86-64.so.2`, or run under `buildFHSEnv`/nix-ld. Keep the relative layout `server/{DuneSandbox,Engine}` because of the RPATH `${ORIGIN}/../../../Engine/...`. Needs `lsof`, `procps`, `util-linux (su)`, `curl`, `jq` if run.sh is reused. | **Moderate.** run.sh needs k8s (skippable) and root+su. A native wrapper should replace it, pass `-MultiHome`, `-ExternalAddress`, `-IGWBindAddress` and the DB/RMQ args itself, and not rely on the lsof port probe or sshd. |
| Postgres | `postgresql_17` with contrib (pgcrypto, pg_trgm). 17.10 vs 17.4 is the same major, so the on-disk format is compatible. Port 15431 is the game default. | **Minor.** barman is only needed for S3 backup parity (nixpkgs barman 3.19.1). Everything else is stock. |
| db-utils | `python312` + `psycopg2` (+ `debugpy` optional), and postgresql_17 client tools on PATH or at `FUNCOM_POSTGRES_INSTALL`. The directory layout must put `DuneSandbox/Database` in a parent of the PSQL dir, and ini files are read from `<root>/Engine/Config/BaseGame.ini`. | **None** for the packages. The files are proprietary and have to come from the image or depot. |
| Gateway | Exactly **CPython 3.12** (pyc-only) + `psycopg2` + `python-dateutil` (+six). The files need `/DuneSandbox/Config/*`, or a `DuneSandbox/` directory in a parent of the service dir. | **None** for the packages. nixpkgs 3.12.13 vs 3.12.14 has the same pyc magic. |
| RabbitMQ | 3.13.7 on Erlang 26.2 with the management and prometheus plugins. | **Gap.** nixpkgs ships only rabbitmq-server 4.2.5, and erlang_26 has been removed. Options: (a) use 4.2.5 (AMQP 0-9-1 client RabbitMQ.Client 6.8.1 should still work; 3.13→4.x removes classic mirrored queues and changes some defaults, which needs testing), or (b) package the 3.13.7 generic-unix tarball with an Erlang 26 derivation. The runtime conf.d and definitions come from the operator and are not in the image, so they still have to be reconstructed. |
| Director / TextRouter | Self-contained **musl** single-file bundles. The simplest native route is patchelf with interpreter `pkgsMusl`'s `ld-musl-x86_64.so.1` and an rpath to musl-built `zlib`, `libgcc_s` and `libstdc++` (`pkgsMusl.stdenv.cc.cc.lib`), plus musl `icu` (Invariant=false) and musl `openssl` 3 (Npgsql and RabbitMQ TLS dlopen libssl). An alternative is to extract the bundle's managed assemblies and run them framework-dependent on glibc `aspnetcore_8_0`. That is untested (inference). | **Gap.** No glibc build exists, `dotnet-runtime_8` in nixpkgs is glibc, and the bundle embeds its own musl runtime. `libAuthbuffer.so` is glibc-linked and would need the glibc loader if it is ever loaded. Director also expects a Kubernetes API (`igw.funcom.com/v1` BattleGroup CRs); a native setup needs a shim or a way to disable that path. |
| All | Environment wiring: `POD_IP`, `BATTLEGROUP*`, `RMQ_HTTP_TOKEN_AUTH_SECRET`, `SERVER_LOGIN_PASSWORD_SECRET`, `HOST_DATACENTER_*`, FLS host URL and ServiceAuthToken. | **Gap:** the runtime values come from the operators and CRs, not from these images. |
