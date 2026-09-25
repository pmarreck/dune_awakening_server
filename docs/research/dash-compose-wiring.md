# DASH Compose wiring, read for a native NixOS port

Source: DASH pinned at `vendor/dash`, commit `b3a26c1` (2026-09-21). All
citations are `path:line` relative to `vendor/dash/` unless they start with
`docs/` of this repo (written `../../docs/...`). Read-only study; nothing was
executed.

Legend: **[F]** = stated in DASH code/config/docs at the cited line.
**[I]** = my inference from the cited material, not verified by running
anything. No secret values are copied here; only variable names.

Goal context: native NixOS services, one `Survival_1` map (plus `Overmap` only
if required) for 2 players, on image build `2124138-0-shipping` (game 1.5).

---

## 1. Services in the minimal set

DASH's own "prove the core" path is: state services, then `db-init`, then
`rmq-auth-shim text-router gateway director`, then `survival` alone
(`docs/setup.md:88-172`) [F]. `admin-panel`, `admin-chat-commands`,
`admin-panel-ingress`, and every other map are outside that path.

Shared plumbing for every service below:

- Compose network: bridge `172.31.240.0/24`, gateway `.1`, dynamic pool
  `172.31.240.128/25`, bridge name `dune-br0` (`compose.yaml:1340-1348`) [F].
  Static IPs exist so each game server has a stable `POD_IP` for `-MultiHome`
  (`docs/architecture.md:46`) and to stop restart-time address collisions
  (`docs/setup.md:206-211`) [F].
- Every service mounts DASH's static `rg`, `busybox`, `jq`, `curl` into
  `/usr/local/bin` (`compose.yaml:60-63`) [F]. These are operator
  conveniences [I]; nothing in the minimal launch path needs them.

### 1.1 `postgres`

| Item | Value |
| --- | --- |
| Image | `registry.funcom.com/funcom/self-hosting/igw-postgres:17.4-alpine-fc-13` (`compose.yaml:89`) [F]. Not tied to the game build tag. |
| Entrypoint | image default `docker-entrypoint.sh postgres` (`docs/teardown.md:183`) [F] |
| Env | `POSTGRES_DB=dune`, `POSTGRES_USER=dune`, `POSTGRES_PASSWORD` from `POSTGRES_DUNE_PASSWORD`, `POSTGRES_SUPER_PASSWORD` (`compose.yaml:92-96`) [F]. `POSTGRES_SUPER_PASSWORD` is a Funcom-image-specific variable; what the image does with it is not documented in DASH [I: probably creates a separate superuser]. |
| Persistent state | `./data/postgres:/var/lib/postgresql/data` (`compose.yaml:102`) [F] |
| Ports | `127.0.0.1:15431->5432` and `${POSTGRES_BRIDGE_BIND_ADDRESS:-172.31.240.1}:15432->5432` (`compose.yaml:103-105`) [F]. `15431` matches Director's built-in default DB port (`docs/teardown.md:228`) [F]. |
| Static IP | `172.31.240.2` (`compose.yaml:114`) |
| Healthcheck | `pg_isready -U dune -d dune`, 10s interval, 12 retries, 20s start (`compose.yaml:106-111`) [F] |
| Note | The game uses database `dune_sb_1_4_0_0`, not `dune`; `dune` is just the bootstrap/admin DB (`scripts/bootstrap_db.py:16-17`) [F]. |

Native mapping [I]: nixpkgs `services.postgresql` (PG 17) with a `dune` role
that owns its databases. Whether Funcom's image adds extensions or non-default
settings is not recorded in DASH; `bootstrap_db.py:76` passes
`extra_schema_names=["ext"]`, so check the SQL tree for `CREATE EXTENSION`
before trusting stock PG.

### 1.2 `admin-rmq` and `game-rmq`

| Item | admin-rmq | game-rmq |
| --- | --- | --- |
| Image | `seabass-server-rabbitmq:${DUNE_IMAGE_TAG}` (`compose.yaml:117`) | same (`compose.yaml:146`) |
| Entrypoint | image default `docker-entrypoint.sh rabbitmq-server` (`docs/teardown.md:177`) | same |
| hostname | `admin-rmq` (`:118`) | `game-rmq` (`:147`) |
| Env | `RMQ_AUTH_BACKEND_1=cache`, `RMQ_HTTP_TOKEN_AUTH_SECRET`, `FuncomLiveServices__RmqTlsEnabled=false` (`:120-123`) | same but `RmqTlsEnabled=true` (`:149-152`) |
| Plugins | `config/rabbitmq-enabled-plugins` -> `/etc/rabbitmq/enabled_plugins` (`:129`) | same (`:158`) |
| Config | `config/rabbitmq-admin.conf` -> `conf.d/99-dune.conf` (`:130`) | `config/rabbitmq-game.conf` (`:159`) |
| TLS | none | `config/tls/rabbitmq/{ca.crt,server.crt,server.key}` -> `/etc/rabbitmq/{cacert,cert,key}.pem` (`:160-162`) |
| State | `./data/rabbitmq/admin:/var/lib/rabbitmq` (`:131`) | `./data/rabbitmq/game` (`:163`) |
| Ports | `127.0.0.1:15672` mgmt, `127.0.0.1:5673->5672` AMQP (`:132-134`) | `${GAME_RMQ_HTTP_BIND_ADDRESS:-127.0.0.1}:15673->15672`, `${GAME_RMQ_BIND_ADDRESS:-0.0.0.0}:31982->5672` (`:164-166`) |
| Static IP | `.3` (`:143`) | `.4` (`:175`) |
| Healthcheck | `rabbitmq-diagnostics -q check_running` (`:135-140`) | same (`:167-172`) |

Config file contents [F]:

- `config/rabbitmq-enabled-plugins:1`: `rabbitmq_management`,
  `rabbitmq_prometheus`, `rabbitmq_auth_backend_http`,
  `rabbitmq_auth_backend_cache`. Matches Funcom's
  `messageQueues.templates[].spec.plugins.system` (`docs/teardown.md:103-110`).
- `config/rabbitmq-admin.conf:1-9`: `auth_backends.1 = cache`, cache TTL
  600000 ms wrapping the `http` backend, POST to
  `http://rmq-auth-shim:8080/v0/auth/{user,vhost,resource,topic}`.
- `config/rabbitmq-game.conf:1-16`: same auth block, plus `listeners.tcp =
  none`, `listeners.ssl.default = 5672`, cert paths, `ssl_options.verify =
  verify_none`. The game broker speaks AMQPS on port 5672 (not 5671).
- The long TTL is deliberate, to avoid hammering HTTP auth during 30-map
  startup (`docs/troubleshooting.md:81`) [F].

Native mapping [I]: nixpkgs `services.rabbitmq` twice (two instances need
distinct node names, data dirs, ports, and Erlang distribution ports; the
nixpkgs module is single-instance, so the second one likely needs a hand-made
systemd unit or a NixOS container-free second module instance). The
`seabass-server-rabbitmq` image may carry Funcom-specific bits beyond stock
RabbitMQ (the `RMQ_*` and `FuncomLiveServices__*` env vars suggest a custom
entrypoint). DASH does not document what that entrypoint does with them. This
must be read out of the image layer before replacing it with stock RabbitMQ.

### 1.3 `rmq-auth-shim` (DASH-only)

- Image `seabass-server-db-utils:${DUNE_IMAGE_TAG}` used only as a Python
  runtime; command `/workspace/scripts/rmq_auth_shim.py`, repo mounted
  read-only at `/workspace` (`compose.yaml:177-193`) [F].
- Env: `WORLD_UNIQUE_NAME`, `TEXT_ROUTER_AUTH_BASE=http://text-router:8080`,
  `DUNE_RMQ_MANAGEMENT_USER` (default `bgd.${WORLD_UNIQUE_NAME}.duneadmin.admin`),
  `DUNE_RMQ_MANAGEMENT_PASSWORD` (`compose.yaml:181-185`) [F].
- Listens on `0.0.0.0:8080` (`scripts/rmq_auth_shim.py:79-80`) [F]. IP `.7`,
  depends on `text-router` (`compose.yaml:194-198`) [F].
- Behavior (`scripts/rmq_auth_shim.py:13-61`) [F]:
  - Management user: `allow administrator` only if the password matches.
  - Usernames matching `^(sg|bgd|tr)\.<WORLD_UNIQUE_NAME>\.[^.]+(\.(game|admin))?$`:
    `allow administrator` on `/user`, `allow` elsewhere. **No password check.**
  - Usernames matching `^[0-9A-Fa-f]{16}$` (player FLS ids): `allow` on every
    path. **No password check.**
  - Everything else is proxied to TextRouter; any proxy error returns `deny`.
- Why it exists: TextRouter rejected game-server users `sg.<world>.<id>.game/admin`
  with token timestamps `01/01/0001` (`docs/teardown.md:264-273`) [F].
- Security caveat [I]: anyone who can reach AMQPS `31982` and knows the world
  unique name (or just picks any 16-hex username) is admitted. DASH says not to
  expose `31982` publicly while the shim is on (`docs/teardown.md:275`,
  `docs/troubleshooting.md:79`), yet also says `31982/tcp` must be forwarded for
  live-client login (`docs/troubleshooting.md:130`) and ships
  `GAME_RMQ_BIND_ADDRESS=0.0.0.0` (`.env.example:1104`). These statements
  conflict. See section 2.3.

Native mapping [I]: a ~80-line stdlib HTTP service; trivially a systemd unit.
Worth re-deciding whether it is needed at all on build 2124138 (test
TextRouter alone first), and if kept, add a password/token check.

### 1.4 `db-init` (one-shot)

- Image `seabass-server-db-utils:${DUNE_IMAGE_TAG}`, `working_dir /root/PSQL`,
  `PYTHONPATH=/root/PSQL`, env `POSTGRES_DUNE_PASSWORD`, command
  `/workspace/scripts/bootstrap_db.py`, depends on `postgres`, IP `.42`
  (`compose.yaml:200-219`) [F]. Details in section 3.

### 1.5 `director`

- Image `seabass-server-bg-director:${DUNE_IMAGE_TAG}` (`compose.yaml:222`);
  image entrypoint `./Director` in `/Tools/Battlegroups/Director/BattlegroupDirector`
  (`docs/teardown.md:178`) [F].
- `restart: unless-stopped` because Director exits on malformed login
  envelopes (`compose.yaml:223-226`) [F].
- DNS forced to `1.1.1.1`, `8.8.8.8` (`compose.yaml:228-230`) [F].
- Args: `--RMQGameHostname game-rmq --RMQGamePort 5672 --RMQAdminHostname
  admin-rmq --RMQAdminPort 5672` (`compose.yaml:231-239`) [F].
- Env (`compose.yaml:240-255`) [F]:
  - `Database__address|port|user|password`: Postgres connection. Without an
    override Director defaults to `localhost:15431` (`docs/teardown.md:228`).
  - `RMQ_HTTP_TOKEN_AUTH_SECRET`: shared secret also given to both brokers,
    TextRouter, and Gateway [I: HMAC key for RabbitMQ HTTP-auth tokens].
  - `BATTLEGROUP_DISPLAY_NAME` and `OPT_SERVERNAME` = `WORLD_UNIQUE_NAME`;
    `WORLD_NAME` and `OPT_DISPLAY_NAME` = `WORLD_NAME`.
  - `FuncomLiveServices__ServiceAuthToken` = `FLS_SECRET` (the Funcom
    self-hosting token), `FuncomLiveServices__RmqTlsEnabled=true`,
    `FuncomLiveServices__DefaultFlsEnvironment` = `DUNE_FLS_ENV` (default `retail`).
  - `BATTLEGROUP_REGION_NAME` = `WORLD_REGION`, `HOST_DATACENTER_ID` =
    `WORLD_DATACENTER_ID`, `HOST_DATACENTER_IP_ADDRESS` = `EXTERNAL_ADDRESS`.
- Config: `config/director.ini` -> `/etc/app/conf.d/director.ini`
  (`compose.yaml:261`) [F]. Contents (`config/director.ini:1-142`) [F]:
  `[ Database ]` with a placeholder password and `database=dune` (`:1-6`);
  `[ Battlegroup ] AuthorizationPreset = BattlegroupInternal` plus transfer
  knobs (`:8-19`); `[ InstancingModes ] Overmap=SingleServer,
  Survival_1=Dimension` (`:21-26`); global `[ Server ] PlayerHardCap=40`
  (`:28-36`); `[ Survival_1 ] PlayerHardCap=60,
  ShouldUpdatePlayerCountOnFls=true, NpeGrantDurationInMinutes=90`
  (`:41-44`); per-map `NumExtraServers=0/MinServers=0` for everything else;
  commented `[ GmeSettings ]` for voice chat (`:53-57`).
  - [I] The `Database__*` env vars override the ini (the .NET `Section__Key`
    convention). The ini's `database=dune` looks wrong versus the game DB, yet
    DASH says Director "is asking for database `dune_sb_1_4_0_0`"
    (`docs/teardown.md:232`), so Director appears to derive the name itself.
    Unverified; confirm on 2124138.
- No healthcheck. `depends_on: postgres, admin-rmq, game-rmq` (unconditioned)
  (`compose.yaml:262-265`). IP `.5`.

### 1.6 `text-router`

- Image `seabass-server-text-router:${DUNE_IMAGE_TAG}`; entrypoint
  `./TextRouter` in `/Tools/Battlegroups/TextRouter/TextRouter`
  (`docs/teardown.md:180`) [F].
- DNS `1.1.1.1`, `8.8.8.8`; same four `--RMQ*` args as Director
  (`compose.yaml:273-284`). TextRouter refuses to start without
  `--RMQGameHostname/--RMQGamePort` (`docs/teardown.md:226`) [F].
- Env (`compose.yaml:285-306`) [F]: both `DuneDatabaseInterfacePSQL_Database{Host,Port,User,Password,Name}`
  (name = `DUNE_GAME_DB_NAME`, default `dune_sb_1_4_0_0`) and `Database__*`;
  `RMQ_HTTP_TOKEN_AUTH_SECRET`; the same world/FLS/datacenter vars as Director;
  `BATTLEGROUP_LANGUAGE=en-US`.
- Serves the RabbitMQ HTTP-auth API on `:8080` (`compose.yaml:183`) [F]. In
  Funcom's k8s wiring the brokers call TextRouter directly
  (`docs/teardown.md:266`) [F].
- No config mount, no healthcheck. IP `.6`.

### 1.7 `gateway`

- Image `seabass-server-gateway:${DUNE_IMAGE_TAG}`; image entrypoint
  `python -m service -c /Tools/Battlegroups/GatewayService/service/configs/service.conf`
  (`docs/teardown.md:179`) [F].
- Command override `sh -lc "sleep 30; exec python -m service -c ...
  --RMQGameHostname ${GAME_RMQ_PUBLIC_HOST:-$EXTERNAL_ADDRESS}
  --RMQGamePort ${GAME_RMQ_PUBLIC_PORT:-31982}
  --RMQGameHttpPort ${GAME_RMQ_PUBLIC_HTTP_PORT:-15673}"`
  (`compose.yaml:326-335`) [F]. These are the **client-facing** broker
  address and ports that Gateway reports to FLS; without them it reports null
  RMQ addresses (`docs/teardown.md:262`) [F]. The 30 s sleep is an ordering
  hack in lieu of a health-gated dependency [I].
- Env (`compose.yaml:336-352`) [F]: `DuneDatabaseInterfacePSQL_*` (name from
  `DUNE_GAME_DB_NAME`), `FuncomLiveServices__ServiceAuthToken`,
  `FuncomLiveServices__RmqTlsEnabled=true`,
  `FuncomLiveServices__BattlegroupAuthorizationPreset=BattlegroupInternal`,
  `FuncomLiveServices__DefaultFlsEnvironment`, `BATTLEGROUP_DISPLAY_NAME` and
  `OPT_DISPLAY_NAME` = `PUBLIC_SERVER_NAME` or `WORLD_NAME`, `OPT_SERVERNAME` =
  `WORLD_UNIQUE_NAME`, `gateway_farm_api_key` = `FLS_SECRET` (Funcom's template
  has a separate `fls-apikey`, but the placeholder is rejected by FLS;
  `docs/teardown.md:262`), `RMQ_HTTP_TOKEN_AUTH_SECRET`, datacenter vars.
- Config: `config/gateway.ini` -> `/etc/app/conf.d/gateway.ini`
  (`compose.yaml:358`). Contents (`config/gateway.ini:1-8`) [F]:
  `[OnlineSubsystem] ServerName=` **a hard-coded DASH operator world id**,
  `DatacenterId=North America`, `[gateway] display_name=` the DASH operator's
  branded browser title. **Must be replaced for our world.** Preflight
  requires `display_name` non-empty and different from `WORLD_NAME` and
  `DUNE_SERVER_DISPLAY_NAME` (`scripts/preflight.sh:106-144`) [F].
- depends on `postgres`, `game-rmq` (`compose.yaml:359-361`). IP `.40`.

### 1.8 `survival` (Survival_1, Hagga Basin)

- Image `seabass-server:${DUNE_IMAGE_TAG}`, DNS `1.1.1.1/8.8.8.8`,
  depends on `postgres, admin-rmq, game-rmq` (`compose.yaml:47-58`) [F].
  Image default entrypoint `/home/dune/run.sh` in `/home/dune/server/`
  (`docs/teardown.md:182`) is replaced by `/workspace/scripts/run_server_safe.sh`
  (`compose.yaml:66`) [F].
- No map argument, so the server loads its default map, which is `Survival_1`
  (`compose.yaml:366-389`, `docs/architecture.md:16`) [F].
- Command args, in order (`compose.yaml:65-84, 368-389`) [F]:
  - `-FarmRegion=${WORLD_REGION}`
  - `-ini:engine:[FuncomLiveServices]:ServiceAuthToken=${FLS_SECRET}`
  - `-ini:engine:[FuncomLiveServices]:DefaultFlsEnvironment=${DUNE_FLS_ENV:-retail}`
  - `-ini:engine:[FuncomLiveServices]:ServerCommandsAuthToken=${DUNE_SERVER_COMMANDS_AUTH_TOKEN}` (optional, empty default; `.env.example:278`)
  - `-ini:engine:[ConsoleVariables]:server.NotificationSystem.Enabled=false` (optional)
  - `-ini:engine:[OnlineSubsystem]:ServerName=${WORLD_UNIQUE_NAME}`
  - `-ini:engine:[ConsoleVariables]:Bgd.ServerLoginPassword=${DUNE_SERVER_LOGIN_PASSWORD}` (optional join password)
  - `-ini:engine:[OnlineSubsystem]:DatacenterId=${WORLD_DATACENTER_ID}`
  - `-ini:game:[DuneDatabaseInterfacePSQL]:DatabaseHost=postgres:5432`, `...DatabaseUser=dune`, `...DatabasePassword=${POSTGRES_DUNE_PASSWORD}`. **No `DatabaseName` is passed**; see section 5.
  - `-RMQGameTlsEnabled=true`
  - `-ExternalAddress=${EXTERNAL_ADDRESS}`
  - `--RMQGameHostname=game-rmq --RMQGamePort=5672 --RMQAdminHostname=admin-rmq --RMQAdminPort=5672`
  - `-MultiHome=$POD_IP` (literal; the wrapper substitutes it)
  - `-ini:game:[/Script/DuneSandbox.BuildingSettings]:m_BaseBackupToolTimeRestrictionInSeconds=0` (gameplay tweak, optional)
  - `-PartitionIndex=1`
- Env: `POD_IP=172.31.240.10`, `NODE_NAME=dune-node`,
  `BATTLEGROUP_DISPLAY_NAME=${WORLD_UNIQUE_NAME}`, `WORLD_NAME`, plus the
  `x-game-server-env` and `x-game-server-preload-env` blocks (patch toggles,
  all default `false`) (`compose.yaml:1-45, 390-395`) [F].
- Ports `7777/udp` (game) and `7888/udp` (IGW) (`compose.yaml:396-398`) [F].
  The `7777/7888` defaults come from `config/UserEngine.ini:1-3` `[URL]
  Port=7777 IGWPort=7888` [F].
- Volumes: repo at `/workspace:ro`; `./data/server-saved` ->
  `/home/dune/server/DuneSandbox/Saved` (`compose.yaml:399-401`) [F].
- No healthcheck. IP `.10`.

### 1.9 `overmap` (optional for this goal, see section 6)

Same base; extra args `/Game/Dune/Systems/Overmap/Overmap.Overmap -Port=7778
-IGWPort=7889 -PartitionIndex=2`, `POD_IP=172.31.240.11`, ports
`7778/udp, 7889/udp`, save dir `./data/server-saved/overmap`
(`compose.yaml:406-446`) [F].

---

## 2. Network graph

### 2.1 Internal edges (from compose args/env)

| From | To | Proto/port | Source |
| --- | --- | --- | --- |
| director, text-router, gateway, db-init, maps | postgres | TCP 5432 | `compose.yaml:75, 241-242, 286-287, 337-338`; `scripts/bootstrap_db.py:14-15` |
| director, text-router, maps | admin-rmq | AMQP 5672 (plain) | `compose.yaml:82-83, 236-239, 282-284` |
| director, text-router, maps | game-rmq | AMQPS 5672 | `compose.yaml:78, 80-81, 232-235`; `config/rabbitmq-game.conf:11-12` |
| admin-rmq, game-rmq | rmq-auth-shim | HTTP 8080 | `config/rabbitmq-*.conf:5-9` |
| rmq-auth-shim | text-router | HTTP 8080 | `compose.yaml:183`; `scripts/rmq_auth_shim.py:10,22-26` |
| map <-> map | IGW | UDP 7888/7889... | `docs/full-farm.md:13-14`; troubleshooting on `igw_addr` (`docs/troubleshooting.md:138-143`) |

Gateway gets the public broker address (`GAME_RMQ_PUBLIC_HOST`), not
`game-rmq` (`compose.yaml:333`). [I] It does not appear to connect to
RabbitMQ itself; it advertises that address. Not confirmed.

### 2.2 Outbound (internet)

- FLS at `sb-retail.fls.funcom.com:443` from Director, Gateway, TextRouter and
  every map server. Maps call `Auth_VerifyFlsServerToken` during login and
  travel (`docs/operations.md:243-257`) [F]. Survival shows "outbound HTTPS
  connections to external services" (`docs/network-investigation.md:67`) [F].
- DNS: control-plane and maps use `1.1.1.1`, `8.8.8.8` (`compose.yaml:49-51,
  228-230, 273-275, 323-325`) [F].
- **FLS IPv4 pinning**: `compose.fls-ipv4-hosts.yaml:1-73` adds `extra_hosts`
  `sb-retail.fls.funcom.com -> 13.107.253.70, 13.107.226.70` to director,
  gateway, text-router and all maps [F]. Rationale: on 2026-05-28 players got
  HP3 disconnects on travel because maps logged `Couldn't resolve host name`
  for that host, then `VerifyIdentity Failed` (`docs/operations.md:243-250`)
  [F]. The trigger was DNS resolution failure, not IPv6 as such. Enabled by
  default through `DUNE_FLS_IPV4_HOSTS_ENABLED` defaulting to true
  (`scripts/compose-files.sh:89-93`) [F].
  - [I] These are shared anycast/CDN IPs that Funcom can change. On NixOS a
    local caching resolver (`services.unbound` or `resolved` with fallbacks) is
    a less brittle fix than `networking.hosts`. Treat pinning as optional
    hardening.

### 2.3 External exposure

- Game UDP: `7777/udp` for single Survival (`docs/troubleshooting.md:129`)
  [F]. IGW UDP `7888` published by compose (`compose.yaml:398`) [F]; the server
  browser's ping uses `farm_state.igw_addr`
  (`docs/troubleshooting.md:138-143`) [F], so [I] forward `7888/udp` too.
- Game broker AMQPS `31982/tcp` -> `game-rmq:5672`: FLS hands clients the
  broker host from `GAME_RMQ_PUBLIC_HOST` (`.env.example:1096-1100`) [F], and
  DASH says to forward it for live-client login
  (`docs/troubleshooting.md:130`) [F]. This conflicts with "do not expose
  31982/tcp publicly while this workaround is enabled"
  (`docs/teardown.md:275`) and with preflight failing on `0.0.0.0:31982`
  (`scripts/preflight.sh:201-202`) [F]. [I] Clients must reach it, so the real
  fix is to tighten the shim, not hide the port. [I] Preflight's regex probably
  never matches `docker compose config` output (long-form ports), which is why
  the 0.0.0.0 default passes.
- `GAME_RMQ_PUBLIC_HTTP_PORT` (15673 -> broker management 15672) is
  advertised by Gateway (`compose.yaml:335`) but bound to `127.0.0.1` by
  default (`.env.example:1105`) [F]. [I] Clients evidently do not need it.
- TLS: the broker cert is self-signed by a local CA
  (`scripts/generate-rabbitmq-cert.sh:102-119`) with SANs for
  `GAME_RMQ_PUBLIC_HOST` (falls back to `EXTERNAL_ADDRESS`), `game-rmq`,
  `localhost`, `127.0.0.1` (`scripts/generate-rabbitmq-cert.sh:92-97`) [F]. A
  SAN mismatch shows up as client disconnects during login
  (`docs/troubleshooting.md:49-59`) [F]. [I] So clients check hostname but
  apparently not the CA chain.
- `-ExternalAddress` on a NAT'd host: the bind to the public address fails with
  a warning; that is expected, and the server should still log
  `listening for Clients on <EXTERNAL_ADDRESS>:<port>`
  (`docs/troubleshooting.md:136`) [F]. Same-LAN clients need hairpin NAT or a
  /32 route (`docs/troubleshooting.md:145-162`) [F].

### 2.4 Where DASH deviates from Funcom's k8s wiring, and why

| Deviation | Why | Source |
| --- | --- | --- |
| `rmq-auth-shim` between brokers and TextRouter | TextRouter rejects `sg.<world>.<id>.game/admin` users | `docs/teardown.md:264-273` |
| `run_server_safe.sh` replaces `/home/dune/run.sh` | preserve list args with spaces (e.g. `-FarmRegion=North America`); no forced `-IGWBindAddress=$POD_IP` | `docs/teardown.md:206-208`; `docs/architecture.md:28`; `docs/troubleshooting.md:365-367` |
| Upstream `run.sh` appends `-IGWBindAddress=$POD_IP`; DASH does not by default | private IGW address made browser ping fail; toggle `DUNE_FORCE_PRIVATE_IGW_BIND_ADDRESS` | `docs/teardown.md:206`; `docs/troubleshooting.md:138-143`; `scripts/run_server_safe.sh:205-209` |
| Static bridge IPs as `POD_IP` | stable `-MultiHome` without k8s pod IPs | `docs/architecture.md:46` |
| Explicit DB env/config for Director/Gateway/TextRouter | k8s operators synthesize these | `docs/teardown.md:210-230` |
| One always-on container per map | k8s operator starts maps on demand | `docs/setup.md:182` |
| `gateway_farm_api_key = FLS_SECRET` | template placeholder rejected by FLS | `docs/teardown.md:262` |
| Gateway gets public broker host/port args | otherwise null RMQ addresses sent to FLS | `docs/teardown.md:262` |
| Hostnames `postgres`, `admin-rmq`, `game-rmq`, `text-router`, `rmq-auth-shim` | Compose DNS names; hard-coded in args and ini files | `compose.yaml:75, 80-83, 183`; `config/rabbitmq-*.conf:6-9`; `scripts/bootstrap_db.py:14` |
| k8s CA install | `install_cert` is a no-op without `/var/run/secrets/kubernetes.io/serviceaccount` | `scripts/run_server_safe.sh:861-867` |

Native consequence [I]: every hard-coded hostname can become `127.0.0.1` with
distinct ports (admin broker and game broker both want 5672, so one moves), or
entries in `networking.hosts`. The game server's `-MultiHome` becomes the
host's LAN IP or is dropped (`DUNE_DISABLE_MULTIHOME`,
`scripts/run_server_safe.sh:195-196`).

---

## 3. First-run bootstrap

Order from `docs/setup.md` [F]: generate `.env` + TLS (`:7-20`), preflight
(`:24-38`), load images (`:57-63`), start `postgres admin-rmq game-rmq`
(`:88-92`), `db-init` (`:94-100`), start `rmq-auth-shim text-router gateway
director` (`:158-162`), start `survival` (`:165-172`), then prune extra
Survival dimensions (`:174-178`).

### 3.1 Secrets and identities generated (names only)

`scripts/populate-local-env.sh:11-21` [F] generates with `openssl rand`:
`POSTGRES_SUPER_PASSWORD`, `POSTGRES_DUNE_PASSWORD`,
`POSTGRES_REPLICATION_PASSWORD` (optional replica), `RMQ_HTTP_TOKEN_AUTH_SECRET`,
and a random suffix for `WORLD_UNIQUE_NAME`. The operator supplies
`FLS_SECRET` (from `https://account.duneawakening.com/`, `.env.example:142-144`,
`docs/teardown.md:153`) and `EXTERNAL_ADDRESS` (`populate-local-env.sh:32`).
TLS CA/server key pair from `scripts/generate-rabbitmq-cert.sh` (section 2.3).

`WORLD_UNIQUE_NAME` is the durable FLS battlegroup identity; never rotate it
for a world, and never run two hosts with the same one, or the second can mark
the battlegroup inactive (`docs/setup.md:20`;
`docs/troubleshooting.md:282-293`) [F].

### 3.2 Database creation and schema

`scripts/bootstrap_db.py` [F]:

1. Connects to DB `postgres` as `dune` on `postgres:5432` (`:14-19, 24-32`).
2. Creates `dune_sb_1_4_0_0` owned by `dune` if missing (`:35-42, 56-58`).
3. If schema `dune` already exists, only sets
   `search_path = dune, public` on the DB and exits (`:60-66`). Idempotent.
4. Otherwise calls Funcom's `ToolsDB.setupdb.setupdb(...)` from the
   db-utils image with `bin_path=/usr/bin`, `schema_name=dune`,
   `module_path=/root/DuneSandbox/Database`, `tables_to_dump=["applied_patches"]`,
   `extra_schema_names=["ext"]`, using `dune` for both user and admin
   credentials (`:68-80`).
5. Sets `search_path = dune, public` (`:82-85`). This is required because the
   SQL creates functions like `dune.update_universe_time`
   (`docs/teardown.md:238`) [F].

Discrepancy [F]: `docs/teardown.md:232-236` says db-init runs
`/root/PSQL/initdb.py --host postgres:5432 --project-database dune_sb_1_4_0_0`,
but the code calls `ToolsDB.setupdb` directly. The code is authoritative.

Native mapping [I]: the db-utils payload (`/root/PSQL` Python + the SQL tree
at `/root/DuneSandbox/Database`) plus `psycopg2` and the Postgres client
binaries in `/usr/bin` are all that is needed; no container required.
`bin_path=/usr/bin` suggests setupdb shells out to `psql`/`pg_dump`, so point
it at the nixpkgs Postgres `bin`.

### 3.3 Upgrades (migrations)

`scripts/apply-official-db-patches.sh` [F] reads
`/home/dune/server/DuneSandbox/Database/Upgrade/__order.txt` from the **game
server image** (`:118, 170-171`), diffs it against `dune.applied_patches`
(`:173-186`), and applies missing `<name>.sql` files with
`search_path dune, public`, recording each in `applied_patches`
(`:194-201`). Run before maps start in maintenance (`docs/maintenance-updates.md:323-326`).
On a fresh setupdb install these are presumably already applied [I].

### 3.4 Partitions

- The bundled `initialize_partitions_basic_survival_1()` creates four
  `Survival_1` dimensions; with one container only dimension 0 is served and
  Director loops on `Partition's ServerId is null or empty!`
  (`docs/troubleshooting.md:221-238`) [F]. DASH does not say what calls that
  function (setupdb or Director on first run) [I: unknown].
- `scripts/single-survival-partition.sh:34-45` [F] deletes unassigned
  `Survival_1` rows with `dimension_index > 0`, after a `pg_dump` backup,
  then restarts Director and Survival.
- `-PartitionIndex=N` lines up with `world_partition.partition_id`
  (`docs/full-farm.md:13-14`; `scripts/full-world-partitions.sh:61-64`) [F for
  the table; I for the semantics].
- For Survival + Overmap, DASH has no two-partition script;
  `full-world-partitions.sh` only accepts 30 or 31 (`:27-35`) and inserts
  `(2,'Overmap',0)` with a fixed id and a dummy `box2d_array` definition
  (`:61-64, 95-108`) [F]. [I] Run the single-survival prune first (it frees ids
  2-4), then insert just the Overmap row, then `select
  dune.update_partition_labels(false); notify world_partition_update;` as that
  script does (`:162-163`).
- Stale-server-id trap: a map that restarts with a new server id while its
  partition row still points at an old id in `active_server_ids` crashes with
  `Local partition is not found` (`docs/troubleshooting.md:182-201`) [F].
  DASH's fix is `scripts/recover-map.sh`. A native unit needs the same
  recovery or a restart delay long enough for the old id to age out [I].

### 3.5 RabbitMQ users, vhosts, definitions

DASH ships **no** definitions file, users, or vhosts [F: none present in
`config/`, and the brokers mount only plugins, conf, TLS and data dir,
`compose.yaml:129-131, 158-163`]. All authentication goes through the HTTP
backend. Service users are named `sg.<world>.<server-id>.{game,admin}`,
`bgd.<world>.*`, `tr.<world>.*` (`scripts/rmq_auth_shim.py:13`,
`docs/troubleshooting.md:79`), players are 16-hex FLS ids (`:14`) [F].
Per-player queues `<FLS_ID>_queue` and `<FLS_ID>_rpcQueue` are created at
login; stale ones can block reconnects and DASH clears them before restarts
(`docs/maintenance-updates.md:327-330`) [F]. [I] The default `/` vhost is used,
since nothing configures another.

### 3.6 World registration with FLS

No explicit registration step. Director and Gateway register the battlegroup
on start using `FLS_SECRET` plus the world identity env vars [F: Director
fails FLS init with a blank token, `docs/teardown.md:242`; Gateway publishes
`GatewayDeclareFarmStatus`, `docs/troubleshooting.md:295-299`; Director sends
`Battlegroups_DeclareBattlegroupUpdates` and heartbeats,
`docs/troubleshooting.md:269-275`]. Success signals: `farm_state.ready` with
non-empty game/IGW addresses (`docs/troubleshooting.md:132`), and
`Server farm is READY (1 server(s))` in the game log
(`docs/troubleshooting.md:238`) [F]. The `Autologin attempt failed` and
`GgwpApiKey was not found` warnings are non-fatal
(`docs/troubleshooting.md:313-322`) [F].

---

## 4. Workarounds and patches DASH applies

What `run_server_safe.sh` does before exec (`scripts/run_server_safe.sh:16-493`) [F]:

| Step | Needed for minimal world? | Source |
| --- | --- | --- |
| Copy vendored rg/busybox/jq/curl into the image | No | `:593-638` |
| `install_cert` (k8s CA) | No (no-op outside k8s) | `:861-867` |
| Building-piece-limit pak patch (needs Oodle lib) | No, default off | `:869-893`; `compose.yaml:35-36` |
| Landsraad vendor faction gate patch | No, default off | `:1077+`; `compose.yaml:37` |
| Subfief cap binary patch | No, default off | `:895-917`; `compose.yaml:38-40` |
| Deep Desert BRT patches (invalid map, action gate, buildable region pak, tool state, tool enable) | No, default off, DD only | `:919-1075`; `compose.yaml:41-44, 697-705` |
| Copy `config/UserEngine.ini` to `Saved/Config/LinuxServer/Engine.ini` and `Saved/UserSettings/UserEngine.ini`; same for `UserGame.ini` -> `Game.ini` | Partly. The `[URL] Port/IGWPort` lines matter only if you rely on them instead of `-Port`/`-IGWPort`. The rest is DASH's gameplay tuning | `:640-661`; `config/UserEngine.ini:1-33`; `config/UserGame.ini` |
| **Edit the shipped `DuneSandbox/Config/DefaultGame.ini` in place** with ~25 keys from `UserGame.ini` (`m_Maps`, landclaim, Coriolis, etc.) | No, gameplay tuning. On a read-only Nix store path this must become an overlay or be skipped | `:663-680` |
| Write `Bgd.ServerLoginPassword` and `Bgd.ServerDisplayName` into `Engine.ini` and `UserEngine.ini` `[ConsoleVariables]` | Display name: effectively yes (it defaults to `WORLD_NAME`). Password: optional | `:737-793` |
| `mkdir Saved/UserSettings`, `chown -R dune:nogroup Saved`, symlink `~dune/.config/Epic/Unreal Engine/Engine/Config -> Saved/UserSettings` | Yes: the Unreal saved/config layout the server expects (`docs/architecture.md:28`) | `:40-48` |
| Rewrite `-MultiHome=$POD_IP` to the real IP, or drop it | Yes (or drop) | `:190-204` |
| Optional `-IGWBindAddress`, `-ExecCmds` | No | `:205-212` |
| `LD_PRELOAD` loader (UE4SS-style probe/Lua mod loader) | No, default off | `:214, 355-490, 496-542` |
| `exec runuser -u dune -- ./DuneSandboxServer.sh <args>` from `/home/dune/server` | Yes | `:50, 493` |

Other host-side patches [F]:

- Logoff timer runtime patch, live memory writes into running map processes
  at offsets keyed by the server binary's ELF build id
  (`scripts/patch-logoff-timers-runtime.sh:6-40`), re-applied after restart by
  `scripts/restart-post-start-health.sh:20, 53-55`, on by default in `.env.example:16-20`.
  Not needed for a minimal world. It aborts on unknown builds unless offsets
  are supplied (`:89-95`).
- `rmq-auth-shim` (section 1.3): the one workaround that is on the critical
  path in DASH.
- `restart: unless-stopped` for Director crash-on-bad-envelope
  (`compose.yaml:223-226`): native `Restart=always`.
- Gateway `sleep 30` (`compose.yaml:330`): native ordering via systemd
  `After=`/readiness.
- Neighbor seeding for Docker bridge ARP failure
  (`docs/troubleshooting.md:83-112`): Docker-specific; irrelevant natively.
- Game server does not survive a Postgres restart (SIGSEGV in
  `PSqlProcessingThread`); restart it after the DB
  (`docs/troubleshooting.md:164-180`) [F]. Native: `BindsTo=`/`PartOf=`
  postgresql.service [I].

---

## 5. Build-specific assumptions vs build 2124138 (game 1.5)

Local facts: the downloaded image tag is `2124138-0-shipping`, built
2026-09-23; DASH references tags only up to `2036754-0-shipping`
(`../../docs/acquisition.md:59-67`) [F]. Tags in DASH:
`1963158` (teardown), `1968181` (`.env.example:2`), `1973075`, `1988751`,
`2036754` [F, grep count across the repo].

1. **Database name.** Hard-coded `dune_sb_1_4_0_0` in `scripts/bootstrap_db.py:17`,
   `scripts/single-survival-partition.sh:7`, `scripts/full-world-partitions.sh:17`,
   and as the default of `DUNE_GAME_DB_NAME` (`compose.yaml:290, 341`;
   `.env.example:150`) [F]; 129 references across 92 files [F]. DASH's own
   live host has moved on to `dune_sb_1_4_5_0` and `dune_sb_1_4_10_0`
   (`docs/artificial-exchange.md:62`; `docs/specialization-xp.md:20`) [F].
   The name is derived from the image, and `apply-official-db-patches.sh`
   documents how [F]: read the branch `sb-X.Y.Z.W` from
   `DuneSandbox/Config/perforce-keywords.json`, map `-` and `.` to `_`, and
   substitute it into `DatabaseName` in `DuneSandbox/Config/DedicatedServerGame.ini`
   (template default `dune%_BRANCH%`) (`scripts/apply-official-db-patches.sh:61-79`).
   On a version change it clones the old DB into the new name
   (`:81-109, 150-156`).
   - [I] Build 2124138 almost certainly expects `dune_sb_1_5_*`, not
     `dune_sb_1_4_0_0`. The map server gets no `DatabaseName` argument
     (`compose.yaml:75-77`), so it will use the image-derived name. Running
     `bootstrap_db.py` unchanged would create the wrong DB. **Read those two
     files from the 2124138 server payload and set `DUNE_GAME_DB_NAME` from
     them before bootstrap.**
2. **Director DB name** comes from somewhere other than `director.ini`
   (`database=dune`, `config/director.ini:6`), per `docs/teardown.md:232`
   [F]. [I] Verify on 2124138 which name Director connects to.
3. **Schema shape.** `docs/player-identity-integrity.md:18-20` mentions a
   "post-1.5 schema" where `encrypted_player_state.account_id` is no longer
   unique [F]. That line was committed 2026-09-21, before 1.5's 2026-09-22
   release (`../../docs/acquisition.md:67`) [F], so it may describe a PTC
   schema [I]. Weak evidence of 1.5 compatibility.
4. **Binary/pak patches** are keyed to build ids or byte signatures (e.g.
   `scripts/patch-logoff-timers-runtime.sh:12-40` lists three ELF build ids)
   [F]. Expect all of them to miss on 2124138 [I]. None is needed for the
   minimal world.
5. **Hard-coded external data**: FLS IPs in `compose.fls-ipv4-hosts.yaml:2-3`;
   `config/gateway.ini:2` world id; `config/UserGame.ini` Coriolis cycle dates
   (`:44-49`) and a comment calling its defaults "observed in build 1963158"
   (`:58`) [F]. INI section/key names such as
   `[/Script/DuneSandbox.BuildingSettings]` can be renamed between builds [I].
6. **FLS environment** must match the build: `DUNE_FLS_ENV=retail` for live
   builds (`docs/setup.md:16`; `docs/troubleshooting.md:47`) [F].
7. **Partition helper** names (`initialize_partitions_basic_survival_1`,
   `update_partition_labels`, `world_partition` columns) are SQL-tree
   specific [I]; re-check against the 2124138 `Database/` tree.
8. **Image layout paths** DASH relies on: `/root/PSQL`, `/root/DuneSandbox/Database`
   (db-utils), `/home/dune/server/DuneSandboxServer.sh`,
   `/home/dune/server/DuneSandbox/{Saved,Config,Content/Paks,Binaries/Linux/DuneSandboxServer-Linux-Shipping}`,
   `/Tools/Battlegroups/{Director/BattlegroupDirector,TextRouter/TextRouter,GatewayService}`
   (`docs/teardown.md:175-183`; `scripts/run_server_safe.sh:17, 667, 840, 902`)
   [F]. Verify each against the 2124138 layers before writing Nix derivations.

---

## 6. Smallest set for 2 players in Survival_1

Required (DASH-proven path, `docs/setup.md:88-178`):

1. **PostgreSQL 17** with role `dune`, the game DB under the
   **image-derived name** (section 5.1), `search_path = dune, public`.
2. **Schema bootstrap** once: Funcom's `ToolsDB.setupdb` from the db-utils
   payload (section 3.2). Then prune `Survival_1` dimensions > 0
   (section 3.4), or give Director four servers to chase.
3. **admin RabbitMQ** (plain AMQP) and **game RabbitMQ** (AMQPS, self-signed
   cert with SANs for the public host), both with management, prometheus,
   `auth_backend_http`, `auth_backend_cache` plugins and the HTTP-auth config
   pointing at the auth endpoint. Check the Funcom rabbitmq image for
   entrypoint extras first (section 1.2).
4. **TextRouter** (RabbitMQ HTTP auth, 8080) with DB env and `--RMQ*` args.
5. **Auth shim** or an equivalent fix, in DASH's experience, so
   `sg.<world>.*` map users can log in (section 1.3). Retest without it on
   2124138; if kept, add real password checks because 31982 is public.
6. **Director** with DB, broker, FLS, world and datacenter env, and a
   `director.ini` (at least `[ InstancingModes ] Survival_1=Dimension`,
   `[ Battlegroup ] AuthorizationPreset = BattlegroupInternal`).
7. **Gateway** with DB/FLS env, `gateway_farm_api_key`, public broker
   host/port args, and our own `gateway.ini` (`ServerName` = our
   `WORLD_UNIQUE_NAME`, a `display_name`).
8. **Survival_1 server** run as user `dune` from the server root, with the
   arg list from section 1.8 (`-PartitionIndex=1`), writable `Saved/`, and the
   `~/.config/Epic/Unreal Engine/Engine/Config -> Saved/UserSettings` symlink.
9. **Secrets**: `FLS_SECRET` (Funcom token), `POSTGRES_DUNE_PASSWORD`,
   `RMQ_HTTP_TOKEN_AUTH_SECRET`, plus the fixed `WORLD_UNIQUE_NAME`.
10. **Firewall/NAT**: `7777/udp`, `7888/udp` [I], `31982/tcp`; outbound HTTPS to
    `sb-retail.fls.funcom.com`; a resolver that stays up.

Probably not required for 2 players who stay in Hagga Basin:

- **Overmap.** DASH's single-Survival step starts only `survival` and calls
  it enough to prove token, auth and public address (`docs/setup.md:165-172`)
  [F]. Funcom's own template runs Survival_1 and Overmap by default
  (`docs/teardown.md:187-192`) [F]. DASH says client login and travel still
  need live validation (`docs/architecture.md:54`) [F]. [I] Start without
  Overmap; add it (partition 2, ports 7778/7889, 2 GiB per Funcom's limit)
  if login or first travel fails. Funcom caps Survival_1 at 12 GiB
  (`docs/teardown.md:189`).

Explicitly optional DASH features (skip):

- `admin-panel`, `admin-panel-ingress` (Caddy), `admin-chat-commands`
  (`compose.yaml:760-1338`; `docs/setup.md:219-225`).
- All other maps, `compose.allmaps.yaml`, full-farm partition scripts.
- Postgres streaming replica, backup/offsite timers
  (`docs/setup.md:102-156`), Prometheus metrics overlay, failover overlays.
- FLS IPv4 host pinning (replace with a reliable resolver) [I].
- All binary/pak patches, the Oodle library, LD_PRELOAD loader, logoff-timer
  runtime patch (section 4).
- DASH's `UserGame.ini`/`UserEngine.ini` gameplay tuning and the in-place
  `DefaultGame.ini` rewrite.
- Artificial exchange bot, Discord bot, watchdogs, systemd units under
  `config/systemd/` (`docs/setup.md:227-258`).
- GME voice chat credentials (`docs/troubleshooting.md:324-352`).
- `DUNE_SERVER_LOGIN_PASSWORD`, `DUNE_SERVER_COMMANDS_AUTH_TOKEN`,
  notification system flag.

## Open questions to settle on 2124138 before writing Nix

1. Actual game DB name (section 5.1) and which name Director uses.
2. What the `seabass-server-rabbitmq` entrypoint does with `RMQ_*` and
   `FuncomLiveServices__*` env vars.
3. Whether TextRouter still rejects `sg.*` users (is the shim still needed?).
4. What creates the four default `Survival_1` partitions.
5. Whether clients need `7888/udp` and whether Overmap is needed for first login.
6. Runtime dependencies of the non-container binaries (Director/TextRouter
   look like .NET, Gateway is Python, the game server is UE Linux shipping) for
   packaging under Nix (`buildFHSEnv` or autopatchelf) [I].
