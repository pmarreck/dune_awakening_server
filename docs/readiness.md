# Hosting readiness

Evidence from the first native bring-up of a world (called "My World" here), September 2026. No containers, no Kubernetes, no Windows. Addresses, host ids and names below are documentation placeholders; the log lines are otherwise as recorded.

## Verdict

The world runs, is registered with Funcom Live Services (FLS), and a real game client has joined it over the LAN. Characters persist across a full world restart, gameplay settings apply in game, and the idle world ran for 7 hours of sampling without errors that needed intervention.

## Evidence (from logs, secrets filtered)

| Check | Result | Source |
|---|---|---|
| Server build | `Dreamworld build: 2124138`, branch `sb-1.5.3.0`, DB branch `sb_1_5_3_0` (1.5.3.4) | map server log |
| Director registered with FLS | `Director_InitializeDirector` → Request successful (HostId `0123456789ABCDEF`) | director.log |
| Battlegroup identity | `sh-0123456789abcdef-abcdef`, display "My World", region/datacenter North America | director.log, gateway.log |
| Gateway farm declaration | `GatewayDeclareFarmStatus` with our identity; 0 gateway errors afterwards | gateway.log |
| FLS heartbeat and population | `Battlegroups_SendBattlegroupHeartbeat` and `DeclarePopulationAndActivity` → successful | director.log |
| Map server ready | `Server farm is READY (1 server(s)), partition 1 … dimension 0`; Survival_1 loaded; 11 travel destinations | server log |
| Gateway sees server | `Server <server-id> (map=Survival_1, … address=192.0.2.10/0:7777, revision=2124138) came up!` | gateway.log |
| Broker auth | All components authenticate through the native TextRouter: 0 denials after the fix | textrouter.log |
| Game ports | UDP 7777 (game) and 7888 (IGW) bound on the LAN address; the TLS broker answers on TCP 31982 | `ss`, `openssl s_client` |
| Secrets on argv | None: the map server's command line (logged by Unreal) contains no token or passwords | server log |

## Resource use (idle, zero players)

| Component | RSS | CPU |
|---|---|---|
| Map server (Survival_1) | 9.5–9.7 GiB (cap 20 GiB, swap 0) | ~57% of one core |
| Director | 0.34 GiB | ~9% |
| RabbitMQ ×2 | 0.21 GiB each | ~0 |
| Postgres | 0.26 GiB | ~0 |
| TextRouter | 0.10 GiB | ~1% |
| Gateway | 0.04 GiB | ~1% |
| **Total** | **≈ 10.4 GiB** | |

The earlier estimate of 16–22 GiB assumed Funcom's 12 GiB limit plus overhead. The measured idle footprint is lower. Expect growth with players, building and exploration. [GAP] Measure with two players.

## Bugs found and fixed during bring-up (all committed)

1. The world name must use the **lowercase** HostId, as Funcom's `world.sh` does. FLS returned 403 "Invalid Authorization to manage SelfHosted Battlegroup" for the uppercase form. No world was registered under the wrong name.
2. The **map server needs `RMQ_HTTP_TOKEN_AUTH_SECRET`**. Without it, TextRouter rejects its self-minted broker tokens as invalid.
3. The **gateway reads `conf.d/*.ini` relative to its working directory**. Otherwise it falls back to `LOCAL-<HOST>-<USER>` and "Europe West", which FLS rejects.
4. The **gateway takes `DatabaseHost` as `host:port`**; it has no port key.
5. **Funcom parses RabbitMQ ports as Int16** (max 32767).
6. **`start` must be idempotent**. A second RabbitMQ start wiped the running node's data directory.
7. The **gateway honors only SIGINT** while in its retry backoff.
8. The **tests leaked `epmd`**: about 140 orphans, now fixed and asserted.

## Open items at the time of bring-up

- **Log hygiene.** TextRouter, Director and the gateway log credentials. The runtime root is 0700, but the individual files inside it should be 0600. A database password that appeared in a gateway log line was rotated.
- **Content warnings** in the server log: overlapping resource fields, BP_TankBase/Sandbike export errors, a JourneySubsystem ensure. These look like Funcom shipping noise, but that is unverified against an official server's log.

Supervision, backups with a restore drill, and the update procedure were added afterwards; see [operations.md](operations.md).

## Idle stability (7 hours)

One `dune-world status --json` sample every 5 minutes (`runtime/stability.ndjson`), idle with no players:

| Measure | Result |
|---|---|
| Samples with every component up | **84 / 84** (0 sampling errors) |
| Map-server uptime | continuous, 1,079 s → 26,272 s (no restarts) |
| Map-server memory | 9.35 GiB → 9.52 GiB (min 9.35, max 9.53): about +0.17 GiB over 7 h, no leak trend of note |
| FLS heartbeats (Director) | 842 successful |
| FLS errors | 2 in the same minute ("Resource temporarily unavailable", then a canceled request); self-recovered, likely a transient DNS or network blip |
| Gateway errors | 0 |
| Server crashes or fatal errors | 0 |

Conclusion: the idle world stayed up for at least 7 hours. Behavior with players (memory growth, CPU) was not measured in this run.

## Firewall

The host firewall must allow UDP 7777 and TCP 31982 from the players' network. Nothing else needs to be open to players: UDP 7888, Postgres, the admin RabbitMQ and the HTTP admin ports stay closed. No router NAT was configured, so only LAN and tailnet clients could reach the world.

## First player join

A player joined from another machine on the LAN (192.0.2.50) with the current Steam client. Server log: `AddClientConnection` from that address, then login flow `PreLogin` → `Welcomed` → `StartingNewPlayer` (all `[Success]`), then `Join succeeded`, and the FLS matchmaker acknowledged the login declaration. The client's game-broker logins went through the native TextRouter (6 allows). With one player the map server used 9.59 GiB and about 38% of one core.

Logout was clean: `UNetConnection::Close`, then login flow `End` `[Success]` with reason "Grace Period: Disconnected". Persisted afterwards in `dune_sb_1_5_3_0`: 1 account, 2 `encrypted_player_state` rows (1.5 allows several per account; DASH notes this), 6 actors (3 in partition 1).

## Restart persistence and gameplay settings

The world was fully restarted (`down`, DB password rotated, `up`). The player then rejoined as the same test character, whose research points rose 0 → 2 in `actors.properties` during the new session. The existing character was loaded and saved to, not recreated. In game, inventory space was visibly larger with `InventoryVolumeMultiplier=10` from the operator `UserServerCustomSettings.ini` override. The join password in use was the operator-chosen one.
