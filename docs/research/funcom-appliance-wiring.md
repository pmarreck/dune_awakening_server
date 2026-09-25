# Funcom self-host appliance: how the pieces connect

Scope: Steam app 4754530, build 25486303, battlegroup image tag `2124138-0-shipping`
(`images/battlegroup/version.txt`), operator version `v1.7.0` (`images/operators/version.txt`).
Read-only study of Funcom's own scripts and CRDs, done 2026-09-24. Nothing was executed.

Every claim carries a citation. **[F]** marks a fact read directly from a file.
**[I]** marks an inference, and the reasoning is given. **GAP** marks behavior that only an
operator binary performs, which a native NixOS deployment would have to replicate.

## Citation keys

All paths are relative to `~/.local/share/dune_awakening_server/steam-server/`.

| Key | File |
|---|---|
| WT | `scripts/setup/templates/world-template.yaml` (2109 lines) |
| BG | `scripts/battlegroup.sh` |
| WS | `scripts/setup/world.sh` |
| SU | `scripts/setup.sh` |
| K3 | `scripts/setup/k3s.sh` |
| OP | `scripts/setup/operator.sh` |
| UM | `scripts/setup/update_maps.sh` |
| IP | `scripts/setup/battlegroup_ip.sh` |
| HE | `scripts/setup/helper.sh` |
| SW | `scripts/setup/experimental_swap.sh` |
| FS | `scripts/setup/templates/fls-secret.yaml` |
| RS | `scripts/setup/templates/rmq-secret.yaml` |
| DO | `scripts/setup/templates/databaseoperation.yaml` |
| UE / UG / UC | `scripts/setup/config/UserEngine.ini` / `UserGame.ini` / `UserServerCustomSettings.ini` |
| C:x | `images/operators/crds/x.yaml`. These files have CRLF line endings, and the line numbers are unaffected. |

---

## 1. Components

The world is a single `BattleGroup` custom resource (`igw.funcom.com/v1`), named
`{WORLD_UNIQUE_NAME}` in namespace `funcom-seabass-{WORLD_UNIQUE_NAME}` (WT:1-13). Four
operators turn it into pods: battlegroup, database, server and utilities. They run in
namespace `funcom-operators` (WS:95-100, OP:6-11). The template is created with
`stop: true` (WT:1770), so nothing runs until `battlegroup start` patches `stop:false` (BG:149).

Annotations on the resource: `igw.funcom.com/fls-auth-preset: BattlegroupInternal`,
`game-rmq-tls-enabled: "true"`, `language: en-US`, `flsEnvironment: default`,
`dynamicDatabaseName: "false"`, and `grid` with 27 entries of `1x1` (WT:4-11). [F] The template
has 35 partitions, so 27 does not match any count in it. [I] The grid annotation is probably
stale or unused.

### 1.1 Image inventory

Tarballs are loaded into containerd by BG:328-341 and K3:32-40. Once `update-from-downloads`
has run, every `seabass-server*` tag is `2124138-0-shipping` (§5).

| Component | Image (WT line) | Tarball |
|---|---|---|
| Game server, one per map set | `registry.funcom.com/funcom/self-hosting/seabass-server:{TAG}` (WT:413 and 34 more) | `images/battlegroup/server.tar` |
| Battlegroup director | `…/seabass-server-bg-director:{TAG}` (WT:1909) | `server-bg-director.tar` |
| Server gateway | `…/seabass-server-gateway:{TAG}` (WT:2055) | `server-gateway.tar` |
| Text router | `…/seabass-server-text-router:{TAG}` (WT:2090) | `server-text-router.tar` |
| RabbitMQ ×2 (`admin`, `game`) | `…/seabass-server-rabbitmq:{TAG}` (WT:1968, 2017) | `server-rabbitmq.tar` |
| Postgres | `…/igw-postgres:17.4-alpine-fc-13` (WT:39), `version: 17.4-alpine` (WT:58) | `images/prerequisites/igw-postgres.tar` |
| DB utility pods (init/update/dump/import) | Not named in the template. See C:databasedeployments:1401 (`utilityImage`) | `server-db-utils.tar` (BG:338) |
| PgHero | `ankane/pghero:v2.8.3` (WT:388) | none shipped, so it cannot be pulled offline [I] |
| File browser | `filebrowser/filebrowser:v2.18.0` (WT:1933) | none shipped [I] |
| Operators | `…/igw-k8s-{battlegroup,database,server,utilities}-operator:v1.7.0` (OP:19-22) | `images/operators/*.tar` |
| Cluster prerequisites | coredns, local-path-provisioner, metrics-server, cert-manager ×3 (K3:33-48) | `images/prerequisites/` |

**GAP (db-utils):** The template never references `server-db-utils`. [I] The database operator
fills in `utilityImage` itself, probably by deriving it from the server image tag. That image
holds the `<action>db.py` scripts (§4.2).

### 1.2 Game server sets (`spec.serverGroup.template.spec.sets[]`, WT:397-1769)

All 35 sets are identical except for `map`, `replicas`, `partitions`, `dedicatedScaling` and
the memory limit. I checked this mechanically by counting normalized lines across
WT:403-1769: every other line appears exactly 35 or 70 times. Common fields:

- **Arguments** (e.g. WT:403-406):
  - `-FarmRegion={WORLD_REGION}`
  - `-ini:engine:[FuncomLiveServices]:ServiceAuthToken={FLS_SECRET}`
  - `-RMQGameTlsEnabled=true`
- **Run command:** `runCommand: /home/dune/run.sh` (WT:439). The CRD says this is "supplied as
  their container's first argument" (C:battlegroups:6349-6354).
- **Map injection:** the operator injects `map` into each pod's command line
  (C:battlegroups:5012-5015). [F] **GAP:** the exact argv layout (map URL form, port flags,
  partition flags) is assembled by the server operator and does not appear in any file here.
- **Message queues:** two entries (WT:415-431):
  - `game` → `--RMQGameHostname` / `--RMQGamePort`
  - `admin` → `--RMQAdminHostname` / `--RMQAdminPort`

  Both use `mode: Internal` (the cluster service name) and service port name `amqp`. Semantics
  are in C:battlegroups:5024-5061.
- **Environment:** `envSecretSelectors: igw.funcom.com/env-for-server=default` (WT:409-411).
  This label matches both secrets in §3, so the pod receives `fls-apikey`,
  `FuncomLiveServices__ServiceAuthToken` and `RMQ_HTTP_TOKEN_AUTH_SECRET` as env vars through
  `EnvFrom` (C:battlegroups:4942-4948 description).
- **Connection and restart behavior:**
  - `connectDirector: false` (WT:407). The set is not given the director's address
    (C:battlegroups:4918-4924).
  - `connectionMode: AutoDiscovery` (WT:408). "servers discover each other automatically using
    built-in functionality" (C:battlegroups:4925-4935).
  - `ignoreUnreadyDatabase: false` (WT:412). Pod creation waits for the DB to be ready
    (C:battlegroups:5000-5005).
  - `restartMode: Individual` (WT:438). Each container restarts on failure
    (C:battlegroups:6336-6348).
  - `terminationGracePeriodSeconds: 120` (WT:442).
- **Storage:** `storageMode: Combined` (WT:441). "all server containers share a single storage
  directory" (C:battlegroups:6364-6372). The shared PVC carries label `role=igw-server` and is
  mounted at `/root/DuneSandbox/Saved` (BG:572-577, 595; the comment at BG:573-575 cites the
  operator source). Battlegroup storage is `local-path`, `1G`, RWO (WT:1771-1775).
- **Scheduler:** `schedulerName: memory-focused-scheduler` (WT:440). **GAP:** no file here
  defines this scheduler. [I] It is part of the appliance VM image, and running natively
  (without k8s) makes it irrelevant.
- **Resources:** memory limits only, no requests, no CPU (WT:435-437 etc.; per-map values in §6).
  `SW:8-37` shows the requests Funcom considers viable with swap, e.g. Survival_1 5Gi request /
  12Gi limit, DeepDesert_1 3Gi / 10Gi, and most others 200Mi / 1Gi.
- **Readiness:** `readinessPollMode` is absent from the template. It defaults to `ServerStats`
  (C:battlegroups:6260-6269), and update_maps adds it explicitly for new maps (UM:67).
- **Per-set ini:** the CRD supports `userIniConfig` files mounted through a ConfigMap
  (C:serversets:2442-2464). The template does not use it.
- **Replicas:** `replicas: 1` with explicit `partitions: [1]` for Survival_1 and `[2]` for
  Overmap (WT:432-434, 472-474). Every other set has `replicas: 0`, no partitions, and
  `dedicatedScaling: true` (e.g. WT:488, 513). Dedicated scaling means a `ServerSetScale`
  resource overrides replicas and partitions at runtime (C:serversetscales:49-75;
  C:battlegroups:4936-4941).
- **Restart scalers:** `restartScalers` of `^SH_.*` size 1 and `^(.*_)Story_.*` size 1
  (WT:392-396). These scale those maps back down "when starting the battlegroup back up after a
  restart" (C:battlegroups:3874-3877).

### 1.3 Director (`spec.utilities.director`, WT:1778-1928)

- Image at WT:1909. `resources: {}` (WT:1927).
- Config file `director.ini`, mounted at `/etc/app/conf.d` (WT:1782-1894):
  - `[Battlegroup] AuthorizationPreset = BattlegroupInternal`
  - `[InstancingModes] DeepDesert_1=ClassicalInstancing`
  - A per-map section with `NumExtraServers = 0` for every map.
  - `MinServers = 0` for SH_Arrakeen, SH_HarkoVillage, DeepDesert_1 and the three DLC maps.
  - `EnableAutomaticInstanceScaling = true` for Story_ArtOfKanly, Story_ProcesVerbal and the
    three DLC maps.
  - A section for `CB_Overland_S_05` (WT:1818), a map with **no** server set and **no** DB
    partition. [I] This is harmless leftover config.
- Env vars (WT:1898-1908):
  - `FuncomLiveServices__ServiceAuthToken={FLS_SECRET}`
  - `BATTLEGROUP_REGION_NAME={WORLD_REGION}`
  - `FuncomLiveServices__RmqTlsEnabled=true`
  - `HOST_DATACENTER_ID=dune-testing`
  - `HOST_DATACENTER_IP_ADDRESS=127.0.0.1`

  It also receives the secret env through label `env-for-battlegroup-director` (WT:1895-1897).
- Message queues: `game` and `admin`, both Internal (WT:1910-1926).
- The CRD has a `database` block (address/name/user/password, C:battlegroupdirectors:989-1006).
  The template leaves it empty. [I] Either the director does not use the DB, or the operator
  fills the block in.

### 1.4 Server gateway (`spec.utilities.serverGateway`, WT:2028-2066)

- Image at WT:2055. `dataCenter: {WORLD_REGION}` (WT:2039). `database: {}` (WT:2040).
- `build.revision: 1862600` (WT:2035-2036) is deprecated. The gateway now uses "the revision of
  the first server found dynamically" (C:battlegroups:11484-11487).
- `apiKeySecret` = secret `server-gateway-secret`, key `fls-apikey` (WT:2032-2034).
- Config mount `/etc/app/conf.d` with no files (WT:2037-2038).
- Env vars (WT:2044-2054): FLS token, `RmqTlsEnabled=true`,
  `BattlegroupAuthorizationPreset=BattlegroupInternal`, `HOST_DATACENTER_ID=dune-testing`,
  `HOST_DATACENTER_IP_ADDRESS=127.0.0.1`. Plus secret env via `env-for-server-gateway`.
- Message queue: **`game` only, `mode: Public`** (WT:2056-2064). Public "uses the pod's
  external node ip address for connections" (C:servergateways:1248).

### 1.5 Text router (`spec.utilities.textRouter`, WT:2067-2109)

- Image at WT:2090. `databaseRequired: true` (WT:2073). The pod gets DB connection info, but
  the operator does not wait for DB readiness (C:battlegroups:12904-12909).
- Env vars (WT:2077-2089): FLS token, `RmqTlsEnabled=true`,
  `BattlegroupAuthorizationPreset=BattlegroupInternal`, `BATTLEGROUP_LANGUAGE=en-US`, and the
  datacenter ID/IP as above.
- Message queues: `admin` and `game`, both Internal (WT:2091-2107).
- Role label `role=igw-text-router` (inferred from WT:1943-1945).
- **The text router is the RabbitMQ HTTP auth backend.** Both queues' `authServiceSelector`
  points at `role: igw-text-router` (WT:1943-1945, 1983-1985). The resolved service is passed
  in as `RMQ_HTTP_AUTH_ADDRESS` (C:messagequeues:976-979), and RabbitMQ POSTs to
  `http://$(RMQ_HTTP_AUTH_ADDRESS)/v0/auth/{user,vhost,resource,topic}` (WT:1954-1958).

### 1.6 RabbitMQ: two instances (`spec.utilities.messageQueues.templates`, WT:1935-2027)

| | `admin` (WT:1937-1976) | `game` (WT:1977-2027) |
|---|---|---|
| Label | `messagequeue: admin` | `messagequeue: game` |
| Listener | default (plain AMQP, `listeners.tcp` not overridden) | `listeners.tcp = none`, `listeners.ssl.default = 5672` (WT:2000-2002) |
| TLS | none. Env `FuncomLiveServices__RmqTlsEnabled=false` (WT:1966-1967) | `cacertfile/certfile/keyfile` under `/etc/rabbitmq/*.pem`, `verify_none` (WT:2003-2007). Env `...=true` (WT:2015-2016) |
| NodePort | none | `amqp: 31982` (WT:2018-2019) |
| Auth | `auth_backends.1 = cache` wrapping `http`, 5000 ms cache TTL (WT:1948-1958) | same (WT:1988-1998) |
| Plugins | management, prometheus, auth_backend_http, auth_backend_cache (WT:1969-1974) | same (WT:2020-2025) |
| Storage | `Ephemeral` (WT:1976) | `Ephemeral` (WT:2027) |
| Secrets | `env-for-message-queue` (WT:1960-1962) | same (WT:2009-2011) |

**GAP (TLS material):** No file here creates `/etc/rabbitmq/{cacert,cert,key}.pem` for the
game queue. [I] Either the utilities operator (the cert-manager dependency points that way,
K3:46-48) or the rabbitmq image generates them. Clients connect with `verify_none`, so a
self-signed certificate is probably enough.

The CRD also offers a `login` username/password (C:messagequeues:1214-1223). The template does
not set it, so all auth goes through the HTTP backend.

### 1.7 Database (`spec.database`, WT:16-390)

- Postgres runs as a **StatefulSet** (WT:59).
  - `superUser: postgres` / `superPassword: {WORLD_POSTGRES_PASS}` (WT:42-43)
  - `user: dune` / `password: {WORLD_DUNE_PASS}` (WT:40, 49)
  - `gameDatabaseName: dune` (WT:38). The default database is always `postgres`
    (C:battlegroups:1333-1337).
- `maxConnections` has minimum 100 and buffer 10 (WT:17-19). The value reaches Postgres as
  `-N`, and the CRD describes it as an automatically calculated amount plus the buffer
  (C:battlegroups:86-102, 1344-1348). [I] It likely scales with the number of servers.
- Storage is `local-path`, 2G, RWO (WT:20-24).
- Settings:
  - `allowConfigHotReload: true` (WT:33)
  - `enablePhysicalBackups: false` (WT:34)
  - `tempStatsInMemory: false`, `tempStatsMemAlloc: 128Mi` (WT:45-46)
  - `useNobodySecurityContext: false` (WT:47)
  - `useUtilityConfigMap: false` (WT:48). Utility scripts get connection details as script
    parameters, not through a DefaultGame.ini ConfigMap (C:battlegroups:1526-1531).
  - `userDataEncryption.keyType: None` (WT:50-51). Any other value would add
    `--setup-encryption=true` (C:battlegroups:1538-1559).
  - `scriptConnectionTimeout: 30` (WT:41)
- Utility runtime (WT:52-57): `supplySuperUser: true` (utility scripts get the postgres
  superuser), `useArtifactBridge: false`, and env via label `env-for-database-utils`. No secret
  carries that label, so utility pods get no FLS or RMQ env.
- The database pod's own env selector is `env-for-database: default` (WT:35-37). No secret
  carries that label either.
- The operator runs Postgres with `-c config_file=/etc/postgres/postgres.conf -h * -p <Port> -N
  <conns>` (C:databasedeployments:61-64). `port` is unset in the template. [I] That means
  default 5432.
- `worldPartitions` (WT:60-375) list 35 maps, each with one partition: `dimension 0`,
  `id 1..35`, bounds `(0,0)-(1,1)`. The operator writes these into the DB. The status field
  `partitionHash` records "the hash of the applied partition configuration"
  (C:databasedeployments:1574-1576). **GAP:** partition rows are created in the game DB by the
  operator or db-utils, not by the game server (see §4).
- Utilities (WT:376-390): a ServiceMonitor for `kube-prometheus-stack` (scrape interval 30s)
  and PgHero. Both are optional observability.

### 1.8 File browser (`spec.utilities.fileBrowser`, WT:1929-1934)

- The only setting is the image.
- The operator adds `--noauth --port <Port>` (C:filebrowsers:54-57), and a `selector` chooses
  which PVCs it exposes (C:filebrowsers:991-994).
- The pod has label `role=igw-filebrowser`. `apply-default-usersettings` copies `User*.ini` to
  `/srv/UserSettings` in that pod, and the script calls the result "Saved/UserSettings"
  (BG:247-266). [I] The file browser mounts the shared server PVC's `Saved` directory at
  `/srv`, so these ini files land in `/root/DuneSandbox/Saved/UserSettings/` for every server.
- Natively this component is unnecessary. Write the files directly.

---

## 2. Network graph

```
Players ──UDP? 7777+N──► game server pods (one per running map)          [UE:8; I: UDP]
game servers ◄──IGWPort 7888+N──► game servers  (AutoDiscovery)          [UE:12, WT:408]
game servers ──AMQPS 5672──► rmq-game   (--RMQGameHostname/Port)          [WT:415-423, 2002]
game servers ──AMQP (5672?)──► rmq-admin (--RMQAdminHostname/Port)        [WT:424-431; I port]
game servers ──SQL──► postgres "dune" as user dune                        [WT:38-49; I port 5432]
director   ──► rmq-game (Internal), rmq-admin (Internal)                   [WT:1910-1926]
text-router──► rmq-game, rmq-admin (Internal); postgres (databaseRequired) [WT:2073, 2091-2107]
rmq-game/admin ──HTTP POST /v0/auth/*──► text-router                      [WT:1954-1958]
gateway ──► rmq-game via NODE EXTERNAL IP : nodePort 31982 (Public mode)   [WT:2060, 2019]
gateway, director, text-router, servers ──HTTPS──► Funcom Live Services   [I: FLS token env/args]
db-utils pods ──SQL superuser──► postgres                                  [WT:56]
```

- **External (players/Internet), documented:**
  - Game ports start at `Port=7777` and each server "will use the next available port in a
    sequence" (UE:5-8).
  - `IGWPort=7888`, sequential, "for other servers" (UE:9-12). The two ranges must not overlap
    (UE:7, 11).
  - The game RabbitMQ gets a fixed NodePort, 31982/TCP (WT:2018-2019).
  - [I] 31982 is reached through the external IP because the gateway selects it in Public
    mode. The gateway presumably advertises that address to FLS or clients. Whether players
    connect to it directly is **not documented**, so **treat 31982/TCP as externally required
    until proven otherwise**.
  - [I] Whether 7888+ must be forwarded is unclear. On a single host it is server-to-server
    traffic, so probably internal only.
- **Internal:** rmq-admin, postgres, the text-router HTTP auth port, RMQ management/prometheus,
  PgHero, the file browser.
  - Servers report `gamePort`, `igwPort`, `sshPort`, `ip`, `gamePid` and `serverGuid` in status
    (C:serversets:2492-2525). **GAP:** the operator allocates the per-pod port numbers. The
    sequential scheme in UE:5-12 suggests the servers pick them from the base port.
  - The `sshPort` field hints at a debug port. [I]
- **Service discovery:** components find each queue through a service label selector
  (`messagequeue: game|admin`) and pass hostname/port as argv (WT:416-431,
  C:battlegroups:5024-5061). **GAP:** natively we must supply these flags ourselves,
  e.g. `--RMQGameHostname=127.0.0.1 --RMQGamePort=5672`.
- **External address configuration:**
  1. `battlegroup_ip.sh` writes `$HOME/.dune/settings.conf` as three blank lines followed by the
     IP. The script describes this as "the file k3s reads to know which IP the battlegroup
     listens on for players". An empty value means k3s auto-detects the private IP
     (IP:3-4, 25-36).
  2. The choice (public/private/manual) is stored in `battlegroup-ip.conf`, and only `public` is
     re-resolved (from api.ipify.org) on each `start` (IP:6, 13-16, 102-116; BG:143).
  3. Changing the VM IP without a reboot leaves "k3s … advertising the old address" and the
     "gateway/director crash-loop, players can't connect" (BG:211-216).

  [I] The IP becomes k3s's node external IP, which is what `mode: Public` resolves to. Director
  and gateway both depend on it. Yet both also get `HOST_DATACENTER_IP_ADDRESS=127.0.0.1`
  (WT:1907-1908, 2053-2054). **GAP:** the exact env var or argument that carries the player-facing
  IP into the gateway and servers is injected by the operator and is not visible here.

---

## 3. Credentials and secrets

| Secret | Generation | Where it goes |
|---|---|---|
| **FLS self-host token** (JWT) | The user pastes it from the Dune account page (WS:20). The script decodes the JWT, takes `payload.HostId` lowercased as `G_FLS_PLAYER_ID`, and uses the whole JWT as `G_FLS_SECRET` (WS:21-23). | (a) sed-substituted into every server's argv as `-ini:engine:[FuncomLiveServices]:ServiceAuthToken=` (WT:405 etc.; WS:82); (b) env `FuncomLiveServices__ServiceAuthToken` on director, gateway and text router (WT:1899, 2045, 2078); (c) Secret `server-gateway-secret` key `FuncomLiveServices__ServiceAuthToken` (FS:4, 14; WS:85) |
| `fls-apikey` | Literal placeholder `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` (FS:13) | Gateway `apiKeySecret` (WT:2032-2034). [I] Not a real credential in self-host mode. |
| **RMQ HTTP token auth secret** | `openssl rand 64 \| base64 -w 0` (WS:57) | Secret `rmq-game-secret`, key `RMQ_HTTP_TOKEN_AUTH_SECRET` (RS:4, 14) |
| Postgres superuser password | 24 random `[A-Za-z0-9]` chars (WS:65) | `superPassword` in the BattleGroup spec, in plaintext (WT:42) |
| `dune` DB user password | 24 random chars (WS:66) | `password` (WT:40) |
| World unique name | `sh-<HostId>-<6 random a-z>` (WS:61) | Resource name and namespace (WT:12-13). [I] It also serves as the battlegroup identity registered with FLS. |

- Both secrets carry the labels `env-for-{server,server-gateway,battlegroup-director,message-queue,text-router}=default`
  (FS:5-10, RS:6-11). Every such component therefore gets all their keys as environment
  variables. [I] `RMQ_HTTP_TOKEN_AUTH_SECRET` is a shared HMAC-style key: services mint RMQ
  credentials with it, and the text router validates them when RabbitMQ calls
  `/v0/auth/*`. Natively, every component needs the same value.
- Rendered specs, including the plaintext token and passwords, are stored in
  `/home/dune/.dune/<name>*.yaml` (WS:8, 70-89).
- `WORLD_NAME` and the other values are substituted with `sed` without escaping (WS:75-82). [I]
  A `/` or `&` in the world name would corrupt the spec. The RMQ secret uses `|` as the
  delimiter for this reason (WS:87-88).

---

## 4. Startup order, DB lifecycle and FLS registration

### 4.1 Install order (SU:6-24)

1. `battlegroup_ip.sh prompt` (SU:8).
2. `k3s.sh` (SU:11):
   - Starts k3s through OpenRC and waits for the node (K3:8-26).
   - Imports the prerequisite images (K3:32-40) and scales up coredns, local-path,
     metrics-server and cert-manager (K3:42-49).
   - Runs `update_operators` (K3:78). This patches the database operator's args to single
     concurrency (OP:25-51), adds configmap RBAC to serveroperator (OP:53-55), and, if the
     version differs, imports the operator images, replaces the CRDs and sets the images
     (OP:57-95).
   - Deletes stale leases and webhook certificates (K3:51-59) and scales the four operators to 1
     (OP:97-102).
3. `system.sh`: symlinks `battlegroup` and `bg-util` into `~/.dune/bin` (system.sh:9-24).
4. `world.sh` (WS:138-168):
   - Prompts for name, region (Asia, Europe, North America, Oceania or South America; WS:45)
     and token.
   - Generates the secrets and renders the templates **with image tag `0-0-shipping`** (WS:78).
   - Waits for the operators (four deployments at `readyReplicas=1`, the cert-manager
     cainjector lease, the `battlegroup.igw.funcom.com` lease and the webhook cert secret;
     WS:91-129).
   - Runs `kubectl create` on the namespace, both secrets and the BattleGroup (WS:131-136).
5. `battlegroup.sh update-from-downloads` retags every `seabass-server*` image to the downloaded
   version (SU:20; §5).
6. `apply-default-usersettings` copies `User*.ini` into the file browser (SU:23; BG:237-267).

At this point the battlegroup is created but still `stop: true` (WT:1770). `battlegroup start`
refreshes the public IP, then retries `stop:false` for up to 120 s while the operator webhook
comes up (BG:141-166). `stop` patches `stop:true` and polls for phase `Stopped` for 90 s
(BG:113-139). `restart` does a stop, sleeps 5 s, then starts (BG:107-111).

### 4.2 Runtime dependency order

Documented facts, then inferred ordering:

- Game servers wait for the DB to be **ready** (`ignoreUnreadyDatabase: false`, WT:412;
  C:battlegroups:5000-5005).
- The text router only needs the DB **service to exist** (C:battlegroups:12904-12909).
- Message queues need the text-router service to exist for `RMQ_HTTP_AUTH_ADDRESS`
  (C:messagequeues:976-979). Without it, all RMQ auth fails. [I]
- The DB status phase is one of: Ready, Starting, Modifying, Pending, DataReset, Operation,
  CreatingBackup, RestoringBackup, Migrating, Suspended, NotReady
  (C:databasedeployments:1578-1592).
- Status also records **`schema`, "the last applied schema"** (C:databasedeployments:1594-1595).
  No schema version number appears in any shipped file.

[I] The native start order is therefore: Postgres → (db init/update) → text router → rmq-admin
and rmq-game → director and gateway → Survival_1 and Overmap → the director requests on-demand
maps.

### 4.3 DB creation and migration: **GAP (the main one)**

- `DatabaseOperation.spec.action` is one of `init | update | reset | dump | import`, and it
  "matches the name of the Python script to run without its fixed `db.py` suffix"
  (C:databaseoperations:60-70). The scripts are therefore `initdb.py`, `updatedb.py`,
  `resetdb.py`, `dumpdb.py` and `importdb.py`. BG:491 and BG:575 confirm `dumpdb.py` and
  `importdb.py` by name.
- [I] They live in the `server-db-utils` image, which is the only image with no reference in the
  template.
- The appliance scripts only ever create `dump` and `import` operations (BG:502, 607). **Init
  and update are triggered implicitly by the database operator.** Two signals point that way:
  the operator tracks `schema`, and the phase list includes `Modifying` and `Operation`.
- [I] A fresh DB therefore gets `initdb.py`, and each image-tag change gets `updatedb.py`, both
  run as a superuser utility pod (`supplySuperUser: true`, WT:56) with the world partitions
  applied.
- **For a native build we must extract `server-db-utils.tar`,** find the entrypoint and the
  arguments that `*db.py` expects, and run init/update ourselves before the servers start. Also
  worth checking whether the game server's `run.sh` performs its own migrations.

### 4.4 Funcom Live Services registration

- No script calls FLS directly. Registration happens inside the Funcom binaries, which receive:
  - the JWT token (§3)
  - `-FarmRegion` (WT:404)
  - `BATTLEGROUP_REGION_NAME` (WT:1901-1902)
  - gateway `dataCenter` (WT:2039)
  - `AuthorizationPreset = BattlegroupInternal` (WT:1786, 2049-2050, 2082-2083)
  - the title `{WORLD_NAME}` (WT:1776, "player-facing title", C:battlegroups:6506-6507)
- [I] The gateway is the component that registers the battlegroup and its public endpoint with
  FLS. It holds the API key secret, the datacenter and the only Public-mode queue. **GAP:** how
  `spec.title` and the resource name reach the binaries (env or argv) is operator-injected and
  unknown.

---

## 5. Update, backup and import

### 5.1 `battlegroup update` (BG:612-652)

1. Runs `steamcmd +force_install_dir $HOME/.dune/download +login anonymous +app_update 4754530`,
   with one automatic retry and then an interactive prompt (BG:618-633).
2. Re-sources the freshly downloaded scripts (BG:636-638).
3. Runs `update_operators` (BG:641; OP:57-95).
4. Runs `update_maps` (BG:644; UM:220-237):
   - For each of 7 newer maps (UM:3) that has no set, it appends a DB `worldPartitions` entry
     with id = max+1 and a server set copied from set index 10. It first checks that set 10 is
     `DLC_Story_LostHarvest_EcolabB` as a sanity check (UM:13-18), and uses 2Gi memory,
     `readinessPollMode: ServerStats` and replicas 0 (UM:19-79).
   - Replaces `director.ini` unless it already mentions one of those maps (UM:87-213).
   - Unconditionally appends the text router env `BattlegroupAuthorizationPreset` (UM:215-217).
     [I] This duplicates the env var on every update.
5. Runs `update_battlegroup_from_downloaded_image` (BG:647).
6. Refreshes the symlinks through `system.sh` (BG:650-651).

### 5.2 `update-from-downloads` (BG:355-370)

1. Reads `images/battlegroup/version.txt`, which contains `2124138-0-shipping`.
2. Imports the six battlegroup tarballs into containerd (BG:328-341).
3. JSON-patches every `image` field that matches
   `(?<prefix>.*/seabass-server[^:]*:)(?<tag>[0-9]+-0-[a-zA-Z0-9_-]+)` to the new tag
   (BG:11, 270-313).

   Postgres, PgHero and the file browser are **not** retagged. Tag `0-0-shipping` matches the
   pattern, which is how the first install gets real tags.

[I] The operator then rolls the pods and, per §4.3, probably runs `updatedb.py`.

### 5.3 Backup (BG:489-518)

- Creates a `DatabaseOperation` with `action: dump` and backup name
  `<bg>-<UTC yyyymmdd-HHMMSS>.backup` (DO:1-9; BG:435-457).
- Polls `.status.phase` for `Succeeded` or `Failed`, timing out after 600 s (BG:459-487).
- The output is `/funcom/artifacts/database-dumps/<bg>/<name>` on the host, written by
  `dumpdb.py` (BG:490-500). The script also saves the BattleGroup spec YAML next to it
  (BG:512-517).
- Dump is described as runtime-safe; import is not (BG:557).
- [I] The file format is probably `pg_dump` custom format (`.backup`). Unverified.

### 5.4 Import (BG:520-610)

1. Picks a file from `/funcom/artifacts/database-dumps/<bg>/`, excluding `*.yaml` (BG:525-549).
2. Asks for a typed "yes" and tells the user to stop the battlegroup first (BG:557-570).
3. Resolves the `role=igw-server` PVC to its host path (BG:576-594) and copies the dump to
   `<pv>/Saved/DatabaseDumps/<name>` (BG:595-601). The dump must be there because `importdb.py`
   reads `/root/DuneSandbox/Saved/DatabaseDumps/<backup>` (BG:572-575).
4. Applies an `import` operation and waits for it (BG:603-609).

The CRD's `import` block also supports a remote-download init container and `skipBackup`
(C:databaseoperations:80-105). [I] That implies import takes an automatic pre-import backup by
default.

---

## 6. Maps

The template has 35 server sets, 35 DB partitions (ids 1-35) and 35 director sections, plus an
orphan S_05 director section.

- The only sets **running by default** are Survival_1 and Overmap (`replicas: 1`). Their
  memory limits total **14Gi**.
- Everything else has `replicas: 0` plus `dedicatedScaling: true` and is spawned on demand.
  [I] The director does this through ServerSetScale.
- The sum of all 35 limits is **110Gi**, and memory is the only resource declared.

| DB id (WT line) | Map | Set `map:` line | Default replicas | Mem limit | Director notes |
|---|---|---|---|---|---|
| 1 (61) | Survival_1 | 414 | **1** (partition 1) | 12Gi | no section |
| 2 (70) | Overmap | 454 | **1** (partition 2) | 2Gi | no section |
| 3 (79) | SH_Arrakeen | 495 | 0 | 2Gi | MinServers 0 |
| 4 (88) | SH_HarkoVillage | 534 | 0 | 2Gi | MinServers 0 |
| 5 (97) | CB_Story_Hephaestus | 573 | 0 | 2Gi | no section |
| 6 (106) | CB_Story_Ecolab_Carthag | 612 | 0 | 2Gi | no section |
| 7 (115) | CB_Story_WaterFatManor | 651 | 0 | 2Gi | no section |
| 8 (124) | DeepDesert_1 | 690 | 0 | **15Gi** | ClassicalInstancing, MinServers 0 |
| 9 (133) | Story_ProcesVerbal | 729 | 0 | 2Gi | AutoInstanceScaling |
| 10 (142) | DLC_Story_LostHarvest_EcolabA | 768 | 0 | 3Gi | AutoScaling, MinServers 0 |
| 11 (151) | DLC_Story_LostHarvest_EcolabB | 807 | 0 | 2Gi | AutoScaling, MinServers 0 |
| 12 (160) | DLC_Story_LostHarvest_ForgottenLab | 846 | 0 | 2Gi | AutoScaling, MinServers 0 |
| 13 (169) | Story_ArtOfKanly | 885 | 0 | 2Gi | AutoScaling |
| 14 (178) | CB_Dungeon_Hephaestus | 924 | 0 | 3Gi | |
| 15 (187) | CB_Dungeon_OldCarthag | 963 | 0 | 3Gi | |
| 16 (196) | Story_Faction_Outpost_Atre | 1002 | 0 | 3Gi | |
| 17 (205) | Story_Faction_Outpost_Hark | 1041 | 0 | 3Gi | |
| 18 (214) | Story_HeighlinerDungeon | 1080 | 0 | 3Gi | |
| 19 (223) | CB_Ecolab_Bronze_Green_089 | 1119 | 0 | **6Gi** | |
| 20 (232) | CB_Ecolab_Bronze_Green_152 | 1158 | 0 | 3Gi | |
| 21 (241) | CB_Ecolab_Bronze_Green_024 | 1197 | 0 | 3Gi | |
| 22 (250) | CB_Ecolab_Bronze_Green_195 | 1236 | 0 | 3Gi | |
| 23 (259) | CB_Ecolab_Bronze_Green_136 | 1275 | 0 | 3Gi | |
| 24 (268) | CB_Overland_M_01 | 1314 | 0 | 3Gi | |
| 25 (277) | CB_Overland_S_04 | 1353 | 0 | 3Gi | |
| 26 (286) | CB_Overland_S_06 | 1392 | 0 | 3Gi | |
| 27 (295) | CB_Story_BanditFortress01 | 1431 | 0 | 2Gi | |
| 28 (304) | CB_Overland_S_07 (trailing space in the YAML source, which the plain scalar strips [I]) | 1470 | 0 | 2Gi | |
| 29 (313) | CB_Overland_S_08 | 1509 | 0 | 2Gi | |
| 30 (322) | CB_Dungeon_ThePit | 1548 | 0 | 2Gi | |
| 31 (331) | CB_Story_DestroyedZanovar | 1587 | 0 | 2Gi | |
| 32 (340) | CB_Story_OrbitalMonitor | 1626 | 0 | 2Gi | |
| 33 (349) | CB_Arrakis_Story_Paranoid_PrayerRoom | 1665 | 0 | 2Gi | |
| 34 (358) | CB_Arrakis_Story_Glutton_DiningRoom | 1704 | 0 | 2Gi | |
| 35 (367) | CB_Arrakis_Generic_Sietch_Room | 1743 | 0 | 2Gi | |

Memory limits come from WT:437-1764 (the line after each map line + 23). Every map row not
marked otherwise in the director column has `NumExtraServers = 0`.

- **Ports per map:** the template does not declare any. Each server takes the next free port
  from `Port=7777` and `IGWPort=7888` (UE:5-12). With N concurrent servers that needs ranges of
  about 7777..7777+N-1 and 7888..7888+N-1. [I] Keep N ≤ 110 so the ranges do not collide.
- **Required minimum:** [F] Survival_1 and Overmap are the only always-on sets. [I] A playable
  world probably also needs on-demand spawning of SH_* (social hubs) and DeepDesert_1, which the
  director drives.
- **The 7 maps in `update_maps`:** these are the last seven rows (ids 29-35). update_maps adds
  them to worlds created before they existed (UM:3).

---

## 7. Operator-only behavior to replicate natively (GAPS)

1. **DB init/update/migration** (§4.3): run `initdb.py`, then `updatedb.py` on each version
   change, from `server-db-utils`, with superuser credentials. Also write the 35 world partitions
   and track the schema/partition hash.
2. **Server argv assembly** (§1.2):
   - `runCommand` as argv[0], map name, partition/dimension, RMQ host/port flags, DB connection
     parameters.
   - The server identity and index that populate `serverId` and `serverGuid`, and the ports.

   The exact format is unknown. The next step is to inspect `run.sh` inside `server.tar` and
   the operator binary strings.
3. **DB connection injection** into servers, director, text router and gateway. The template
   gives no env or argument names for these.
4. **RMQ plumbing:**
   - The service-discovery-to-argv mapping.
   - `RMQ_HTTP_AUTH_ADDRESS` resolution to the text router.
   - Generating the game queue's TLS cert/key/CA.
   - Rendering `rabbitmq.conf` from `configs.system` with `$(VAR)` env expansion.
   - Enabling the plugins.
5. **Public address propagation:** k3s node external IP → Public-mode RMQ address for the
   gateway, and probably the advertised player IP for game servers.
6. **Dynamic scaling:**
   - The director requests servers for on-demand maps. The operator materializes
     `ServerSetScale` (replicas and partitions) into pods.
   - `restartScalers` behavior on restart.
   - Natively we need a supervisor that the director can ask to start or stop map servers.
     [I] This goes over RMQ (admin queue) or a k8s API call from the director. Inspect the
     director binary. The director CRD has `serviceAccountName`
     (C:battlegroupdirectors:1340), which hints that the **director talks to the k8s API
     itself** [I]. That would be the hardest piece to replace natively.
7. **Readiness and status:** the `ServerStats` polling that fills players, phase and readiness
   (C:serverstats), and battlegroup phase aggregation. These only matter for status tooling.
8. **Config files:** mount `director.ini` into `/etc/app/conf.d`. Put the `User*.ini` files into
   `Saved/UserSettings`. Supply the empty `/etc/app/conf.d` for gateway and text router.
9. **Dump and import:** the `dumpdb.py` / `importdb.py` invocation, the artifact path, and
   staging into `Saved/DatabaseDumps`. A native `pg_dump`/`pg_restore` may be equivalent, but
   that is unverified.
10. **Things natively irrelevant:** memory-focused-scheduler, cert-manager webhooks,
    local-path PVCs, the file browser, PgHero and the ServiceMonitor.

### Suggested next evidence to gather (read-only)

- `tar -tf` on `server.tar` and `server-db-utils.tar`, then extract `run.sh`, the `*db.py`
  scripts and the entrypoints.
- `strings` on the operator binaries in `images/operators/*.tar`, searching for argv and env
  names such as `--RMQ`, `DATABASE`, `ServerConnect`, `-Port=` and `SeabassDatabase`.
- Image config JSON (`Entrypoint`, `Env`, `ExposedPorts`) for each battlegroup image.
