# Runtime hardening: measured requirements

Funcom ships these components as containers. Here they run as ordinary processes of the operator's user, with no confinement. This page records what each component actually needs (files, network, kernel features), so that systemd sandboxing directives can be derived from evidence instead of guesses. It is step 1 of the hardening work; step 2 teaches `dune-units render` to emit the directives, and step 3 decides between systemd user units and system units with a dedicated service user.

Measured 2026-09-29, 13:58 to 14:25 EDT, on the live world (game build 1.5.3.4, Steam build 25486303), NixOS with kernel 6.18, systemd 261.2, one map (`Survival_1`), nobody online. Every claim is tagged:

- **[M]** measured on the live world: `/proc/<pid>/{status,maps,fd,fdinfo,environ (names only),cgroup,limits}`, `ss`, `lsof`, file mtimes, logs
- **[T]** measured by tracing an isolated test instance from launch: `strace -f -yy` over six suites (`tests/payload/textrouter-auth`, `tests/payload/dotnet-apps`, `tests/integration/{idle-throttle,gm-bridge,backup,update}`), each with its own ports and temporary state
- **[P]** measured with a throwaway transient unit: `systemd-run --user --wait --pipe --collect -p <directive> …` (commands under "Reproducing" below)
- **[C]** read from this project's code
- **[I]** inferred, not measured; each one names the test that would settle it

## Why the live components were not traced

`kernel.yama.ptrace_scope` is 1 on this host [M], so `strace -p` cannot attach to a process that is not its own descendant, and every live component was started by the systemd user manager. Lifting that needs a sysctl change (a host change), so it was not done. The traces therefore come from test instances launched under `strace` [T], which cover postgres, db-setup, both brokers, epmd, the Erlang CLI, TextRouter startup, both LuaJIT tools, backup and update. **The map server, Director at runtime and the Gateway were not traced**: none of the suites runs them (the Director suite only prints its help), and a second map server cannot be started beside the live one. Their entries rely on [M], [C] and [I].

## Roots

Paths below are relative to these roots, all resolved by `bin/dune-awakening` (`setup_env`) from the XDG variables [C]:

| Symbol | Default | Holds |
|---|---|---|
| `$CONFIG` | `$XDG_CONFIG_HOME/dune_awakening_server` | operator inputs: `fls_secret`, `world.conf`, `join_password`, `gm_bridge.conf`, `backup.conf`, `notify`, `UserSettings/` |
| `$DATA` | `$XDG_DATA_HOME/dune_awakening_server` | everything below |
| `$STATE` | `$DATA/runtime` | runtime state and logs of every component |
| `$SECRETS` | `$STATE/secrets` | generated passwords, broker TLS, symlinks to `$CONFIG/fls_secret` and `join_password` |
| `$UNPACKED` | `$DATA/unpacked` | Funcom images, read-only at runtime |
| `$STEAM` | `$DATA/steam-server` | the Steam download |
| `$STEAMCMD_HOME` | `$DATA/steamcmd` | steamcmd's `HOME` |
| `$BACKUPS` | `$DATA/backups` | backups |
| `$TRASH` | `$HOME/.Trash` (`DUNE_TRASH_DIR`) | pruned backups, replaced images |
| `$CHECKOUT` | this repository | `bin/`, `libexec/`, `data/items.tsv`, `flake.nix` |
| `$TMPDIR` | `/tmp/nix-shell.XXXXXX` | created by `nix develop` and inherited by every component [M] |

Every component also reads `/nix/store` (its own closure) and `/etc` (`localtime`, `nsswitch.conf`, `resolv.conf`, `hosts`, `ssl/certs`); glibc programs talk to `nscd` through `/var/run/nscd/socket` [T].

## Headline findings

1. **Two runtimes cannot run under `MemoryDenyWriteExecute=yes`** [P]. TextRouter and Director (.NET 8) dump core at startup; the control run without the directive exits 0. LuaJIT panics with "runtime code generation failed, restricted kernel?" as soon as it compiles a trace, and runs fine under the directive with `-joff`. Erlang (BEAM JIT), PostgreSQL 17.10 (the nixpkgs build has no `llvmjit` module) and the Gateway's CPython 3.12 with its imports (`psycopg2`, `dateutil`, `ssl`, `ctypes`) all run under it. The map server is untested. Details under "JIT and W^X".
2. **Erlang listens on every interface** [M]. epmd on `0.0.0.0:4369` and `[::]:4369`, the admin broker's distribution port on `0.0.0.0:25672`, the game broker's on `0.0.0.0:25673`, and each `rabbitmqctl` run (which `dune-live`, the GM bridge and the idle throttle use) opens a distribution listener on `0.0.0.0:35672` for its lifetime [T]. `docs/operations.md` lists none of these ports. They are protected by the Erlang cookie; whether the host firewall also blocks them was not checked (that is host configuration). Erlang distribution with the cookie is remote code execution on the broker.
   **Fixed 2026-09-29** (commit 7f95c76): `dune-rabbitmq` now sets `ERL_EPMD_ADDRESS=127.0.0.1` and `-kernel inet_dist_use_interface {127,0,0,1}` for the brokers and `rabbitmqctl`; after a world restart epmd and both distribution ports listen on loopback only, and a TCP probe from another Tailscale device found 4369, 25672 and 25673 closed (31982 open, as intended). `tests/integration/rabbitmq` asserts the loopback binding.
3. **The .NET apps expose a debugger and diagnostics endpoint** [M][T]. Each creates `$TMPDIR/dotnet-diagnostic-<pid>-…-socket` and `clr-debug-pipe-<pid>-…-{in,out}`. Any process of the same user can attach through them and read the process's memory, which holds the database password and minted broker credentials. `DOTNET_EnableDiagnostics=0` disables them [I: documented .NET setting; confirm the files disappear].
4. **Secrets reach the Funcom processes as environment variables** [C][M]. The database password, the broker HTTP auth secret and the FLS token are exported to TextRouter, Director, Gateway and the map server (`RMQ_HTTP_TOKEN_AUTH_SECRET`), readable through `/proc/<pid>/environ` by any process of the same user. With TextRouter's and Director's credential logging (already documented), the operator's user id is the trust boundary today. A dedicated service user moves that boundary; sandboxing a unit alone does not.
5. **Components write inside their own runtime trees** [M]. TextRouter and Director write `logs/director<date>.log` next to their binaries in `$STATE/{textrouter,director}-root`; the Gateway writes `logs/gateway.log` in `$STATE/gateway/root`; the map server writes `serverstatus_port` into `$STATE/server/tree/DuneSandbox/Binaries/Linux/` and a lock file `/tmp/DuneSandboxServer-Linux-Shipping`. All but the lock file are already under `$STATE`, so `ReadWritePaths=$STATE/<component>…` covers them, but the runtime trees cannot be mounted read-only.
6. **Components inherit the sandbox of whatever starts them** [C][M]. Today `dune-world.service` and `dune-world-heal.service` run `dune-awakening start`, which launches every component as its child with `setsid`; eight processes (postgres, epmd, both brokers, TextRouter, Director, Gateway and their children) sit in the `dune-world.service` cgroup, and the map server in its own `systemd-run --user --scope`. Any directive on `dune-world.service` therefore applies to all of them at once, which forces the union of their needs (no `MemoryDenyWriteExecute`, all address families, every writable path). Per-component sandboxing needs one unit per component.
7. **The GM bridge and idle throttle are in `herdr.service`, not the world unit** [M]. They were started from an agent terminal on 2026-09-28 (19:28 and 21:40), so they carry that terminal's `TMPDIR` and cgroup. The heal timer did not start them because they were already running.
8. **The heal job rewrites state every 5 minutes** [M][C]. Each run re-renders both `rabbitmq.conf` and `enabled_plugins`, re-links `$SECRETS/fls_token` and `join_password`, re-copies Funcom's db-utils into `$STATE/db-utils` and runs the schema installer, writes `$STATE/db-setup.log` and the nix evaluation cache in `~/.cache/nix`, and leaves one empty `/tmp/nix-shell.*` directory behind: each heal run between 13:01 and 13:58 matches one such directory to the second, so the heal timer alone adds about 288 a day (1789 were present in all, from every `nix develop` user on the host). Each run cost 47.4 s of CPU over 3.8 s of wall time (journal, 14:18).
9. **No component holds or needs a capability** [M][T]. `CapEff`, `CapPrm` and `CapAmb` are 0 for every process. `CapInh` is `0000000800000000` (bit 35, `CAP_WAKE_ALARM`) for all of them, inherited from the user manager (whose own `CapInh` has the same value; PID 1's is 0); with no permitted or ambient bits it grants nothing. `NoNewPrivs` and `Seccomp` are 0 everywhere today. The traces contain no `ptrace`, `io_uring_setup`, `unshare`, `setns`, `mount`, `mlock`, `set*uid`, `capset`, `bpf`, `perf_event_open` or `keyctl` call [T]. `VmLck` is 0 for every process [M]. The only calls that fail on privilege are Nix binary wrappers' `prctl(PR_SET_MM, PR_SET_MM_ARG_START)`, which already return `EPERM` today and change nothing.
10. **steamcmd needs user and mount namespaces** [C][P]. nixpkgs `steamcmd` runs through `steam-run`, a bubblewrap FHS environment. Under `RestrictNamespaces=yes` bwrap fails ("No permissions to create a new namespace"); under `SystemCallFilter=@system-service` it dies with SIGSYS (exit 159). `RestrictNamespaces=user mnt pid ipc uts net cgroup` with `SystemCallFilter=@system-service @mount` works.
11. **A user manager enforces most, not all, directives** [P]. `IPAddressDeny=`, `ProtectProc=` and `ProcSubset=` have no effect in a user unit; `CapabilityBoundingSet=` fails the unit (exit 218/CAPABILITIES) unless `PrivateUsers=yes` is also set; and `ProtectSystem=strict` leaves `$HOME` writable, so it must be paired with `ProtectHome=`. Table under "User units versus system units".

## JIT and W^X

| Runtime | Components | Evidence | Under `MemoryDenyWriteExecute=yes` |
|---|---|---|---|
| .NET 8 (musl, single-file) | TextRouter, Director | double-maps code through `memfd:doublemapper` (TextRouter 582 and Director 778 such mappings live [M]); 640 `mprotect(…, PROT_READ\|PROT_EXEC)` calls during one TextRouter test run [T] | **core dump** at startup, both apps [P] |
| LuaJIT 2.1 | GM bridge, idle throttle, `bin/dune-awakening` (so the world, heal, backup, backup-verify and update-check units) | one anonymous executable mapping live (the trace buffer) [M]; 63 and 73 `mprotect(PROT_READ\|PROT_EXEC)` in the bridge and throttle suites [T] | **panic** as soon as a trace compiles; works with `luajit -joff` [P] |
| Erlang/OTP 27.3 JIT | both brokers, epmd, every `rabbitmqctl` (from `dune-live`, the GM bridge, the idle throttle, status checks) | at boot maps one 4 KiB `PROT_READ\|PROT_WRITE\|PROT_EXEC` page (a probe), then dual-maps JIT code through `memfd_create("vmem", MFD_EXEC)` as a shared `r-x` view plus a `rw-` view [T]; live brokers show exactly that pair [M] | runs (JIT flavour reported as `jit`) [P] |
| CPython 3.12 | Gateway, db-setup (`updatedb.py`) | no executable anonymous or shared mappings [M][T] | runs, including `psycopg2`, `dateutil`, `ssl`, `ctypes` imports [P] |
| PostgreSQL 17.10 | postgres, `pg_dump`, `pg_restore`, `psql` | no `llvmjit` module in the nixpkgs build [M] | [I] runs: no code generation path exists |
| Unreal Engine 5 shipping binary | map server | no RWX, anonymous executable or memfd mappings live [M] | [I] untested: run a copy with the directive at the next planned restart |

systemd 261.2 applies `MemoryDenyWriteExecute=yes` through the kernel (`prctl(PR_SET_MDWE)`): a probe unit showed no seccomp filter installed (`Seccomp_filters: 0`) while LuaJIT and .NET still failed [P]. The kernel rule refuses new write-and-execute mappings and refuses adding execute permission to an existing mapping; that is why BEAM's dual mapping (fresh `r-x` mappings of a memfd) passes and .NET's and LuaJIT's `mprotect(PROT_EXEC)` do not.

## Per component

Each entry lists what was observed; the candidate directives follow it. Directives marked *(system only)* do nothing, or break the unit, in a user unit (see the support table).

### postgres

- **Process:** `postgres` 17.10 from `/nix/store`, postmaster plus checkpointer, background writer, walwriter, autovacuum launcher, logical replication launcher, and one backend per client (seven live) [M]. Started by `libexec/dune-postgres` [C]; cwd `$STATE/postgres`.
- **Writes:** `$STATE/postgres/**` (the cluster, `server.log`, `postmaster.pid`, the socket `.s.PGSQL.15431` and its lock) [M][T]; `/dev/shm/PostgreSQL.*` (dynamic shared memory) and one SysV segment (`shmget` 56 bytes, key-based) [M][T].
- **Reads:** its store closure (glibc, ICU 76, OpenSSL, krb5, libxml2, lz4, zstd, systemd-minimal-libs, tzdata), `/proc/meminfo`, `/proc/sys/kernel/*` [T].
- **Network:** listens on TCP `127.0.0.1:15431` and the Unix socket in `$STATE/postgres` [M]. Clients: TextRouter, Director, Gateway, the map server (all TCP loopback), db-setup, backup, character tools [M][C]. No outbound. Families `AF_INET`, `AF_UNIX` [T].
- **Special:** needs `/dev/shm` and SysV IPC; no JIT.
- **Candidate:** `ProtectSystem=strict`, `ReadWritePaths=$STATE/postgres`, `ProtectHome=tmpfs` + `BindPaths=$STATE/postgres` (user unit) or `ProtectHome=yes` with the data under the service user's own directory (system unit), `PrivateTmp=yes`, `PrivateDevices=yes` (keeps `/dev/shm`) [P], `PrivateIPC=yes` [P], `NoNewPrivileges=yes`, `CapabilityBoundingSet=` + `AmbientCapabilities=`, `RestrictAddressFamilies=AF_UNIX AF_INET`, `SystemCallFilter=@system-service`, `MemoryDenyWriteExecute=yes` (no JIT module), `LockPersonality=yes`, `RestrictNamespaces=yes`, `RestrictRealtime=yes`, `RestrictSUIDSGID=yes`, `ProtectKernelTunables=yes`, `ProtectKernelModules=yes`, `ProtectKernelLogs=yes`, `ProtectControlGroups=yes`, `ProtectClock=yes`, `ProtectHostname=yes`, `PrivateNetwork=no`, `IPAddressDeny=any` + `IPAddressAllow=localhost` *(system only)*.

### epmd

- **Process:** `epmd -daemon` from the Erlang store path, started by the first broker; parent is the user manager, cgroup `dune-world.service`, cwd `/` [M]. Shared by both brokers and every `rabbitmqctl`.
- **Writes:** nothing but `/dev/null` [T].
- **Network:** listens on TCP `0.0.0.0:4369` and `[::]:4369` [M][T]. Families `AF_INET`, `AF_INET6` [T].
- **Special:** binding it to loopback (`ERL_EPMD_ADDRESS=127.0.0.1`) would close the widest listener [I: not tried].
- **Candidate:** as postgres, with no writable paths at all, `RestrictAddressFamilies=AF_INET AF_INET6`, `MemoryDenyWriteExecute=yes` [I: epmd is C without a JIT], `IPAddressAllow=localhost` *(system only)*. It should become its own unit, or be started with the admin broker's, so that it stops being a stray child of whichever unit ran first.

### rabbitmq admin and rabbitmq game

- **Process:** `rabbitmq-server` (nixpkgs 4.2.5) → `beam.smp` (OTP 27.3.4.12, 272 threads) → `erl_child_setup` → `inet_gethost` (×2) [M]. `HOME=$STATE/rabbitmq-<broker>` (the Erlang cookie lives there), cwd is the operator's `$HOME` [M][C].
- **Writes:** `$STATE/rabbitmq-<broker>/{mnesia,log,pid}` [M][T]. The heal job rewrites `rabbitmq.conf` and `enabled_plugins` there every 5 minutes [M].
- **Reads:** `$STATE/rabbitmq-<broker>/{rabbitmq.conf,enabled_plugins,.erlang.cookie}`, `$SECRETS/rmq-tls/*` (game), the CA bundle from `NIX_SSL_CERT_FILE` in the store, the Erlang and RabbitMQ store trees, `/etc/{nsswitch.conf,protocols,resolv.conf,host.conf}`, `/proc/self/{cgroup,mountinfo,maps,statm}`, `/proc/sys/vm/*`, `/sys/devices/system/cpu/*` (thousands of reads: CPU topology), `/sys/fs/cgroup/*`, `/sys/kernel/mm/*` [T].
- **Network** [M]:

| Broker | Listens | Talks to |
|---|---|---|
| admin | TCP `127.0.0.1:5673` (AMQP), TCP `0.0.0.0:25672` (Erlang distribution) | TextRouter `127.0.0.1:18081` (HTTP auth), epmd `127.0.0.1:4369` |
| game | TCP `0.0.0.0:31982` (AMQPS, players), TCP `127.0.0.1:5674` (AMQP for the GM bridge), TCP `0.0.0.0:25673` (Erlang distribution) | the same |

  Families `AF_INET`, `AF_UNIX` (socketpair with `erl_child_setup`, `nscd` from `inet_gethost`), `AF_NETLINK` (raw, bound once per VM; interface enumeration) [T]. The test brokers also connected to `127.0.0.2` (epmd lookups), still loopback [T].
- **Special:** Erlang distribution listens on all interfaces (finding 2); binding it to loopback needs `inet_dist_use_interface` in the broker config [I]. JIT runs under `MemoryDenyWriteExecute=yes` [P].
- **Candidate:** the postgres set with `ReadWritePaths=$STATE/rabbitmq-<broker>`, `ReadOnlyPaths=$SECRETS/rmq-tls`, `WorkingDirectory=$STATE/rabbitmq-<broker>`, `PrivateDevices=yes`, `RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6 AF_NETLINK`, `MemoryDenyWriteExecute=yes`, `IPAddressAllow=localhost` for admin *(system only)*; the game broker needs the players' networks as well (any, or the LAN and tailnet ranges).

### TextRouter

- **Process:** `$STATE/textrouter-root/Tools/Battlegroups/TextRouter/TextRouter/TextRouter`, a self-contained .NET 8 single-file app copied from `$UNPACKED/server-text-router` by `dune-dotnet-prepare`, its interpreter patched to nixpkgs musl, libraries through a `netcoredeps` symlink into the store; 151 threads, cwd its app directory [M][C].
- **Writes:** `$STATE/textrouter/textrouter.log` (credentials, 0600), `$STATE/textrouter-root/…/logs/director<date>.log` [M]; in `$TMPDIR`: `dotnet-diagnostic-<pid>-…-socket`, `clr-debug-pipe-<pid>-…-{in,out}` (FIFOs, created with `mknod`) and `system-commandline-sentinel-files/` [M][T]; `/proc/self/task/<tid>/comm` (thread names) [T].
- **Reads:** its runtime tree, `/etc/ssl/certs/*`, `/etc/localtime`, the store's ICU 76 and OpenSSL 3, `/proc/self/{maps,stat,cgroup,mountinfo}`, `/proc/meminfo`, `/sys/devices/system/cpu/*`, `/sys/fs/cgroup/*`, `/dev/urandom` [T].
- **Network:** listens on TCP `127.0.0.1:18081` (the brokers' HTTP auth backend) and the Unix diagnostics socket [M]. Outbound: postgres `:15431` and the game broker `:31982` over TLS, both loopback [M]. No internet connection was open at measurement time and it needs no FLS token to start (architecture.md). Families `AF_INET`, `AF_INET6`, `AF_UNIX` (stream and datagram) [T].
- **Special:** .NET: **no `MemoryDenyWriteExecute`** [P]. Needs a writable `$TMPDIR` unless diagnostics are disabled (finding 3).
- **Candidate:** `ProtectSystem=strict`, `ReadWritePaths=$STATE/textrouter $STATE/textrouter-root`, `ProtectHome=` as for postgres, `PrivateTmp=yes`, `PrivateDevices=yes`, `NoNewPrivileges=yes`, empty capability sets, `RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6`, `SystemCallFilter=@system-service` [I: .NET's JIT needs nothing outside it; test], `MemoryDenyWriteExecute=no`, `LockPersonality=yes`, `RestrictNamespaces=yes`, `ProtectKernel*`, `ProtectClock=yes`, `IPAddressAllow=localhost` *(system only)*, `Environment=DOTNET_EnableDiagnostics=0`.

### Director

- **Process:** as TextRouter, from `$STATE/director-root/Tools/Battlegroups/Director/BattlegroupDirector/Director`, 151 threads, about 340 MiB resident [M].
- **Writes:** `$STATE/director/director.log` (credentials), `$STATE/director-root/…/logs/director<date>.log`, the same `$TMPDIR` diagnostics files [M].
- **Reads:** as TextRouter [I: same runtime; the Director suite only ran `--help`].
- **Network:** listens on TCP `127.0.0.1:18082` [M]. Outbound: postgres (4 connections), the admin broker `:5673`, the game broker `:31982` (loopback) [M]; Funcom Live Services over HTTPS (`sb-retail.fls.funcom.com:443`) through an `AF_INET6` socket carrying an IPv4-mapped address [M]; `sevent-seabass.funcom.com:80` over plain HTTP (one "Resource temporarily unavailable" DNS failure in its log) [M]. Families `AF_INET6` (used for IPv4 too), `AF_INET`, `AF_UNIX` [M]; `AF_NETLINK` not seen [I: allow it if startup fails without it].
- **Special:** .NET: **no `MemoryDenyWriteExecute`** [P: core dump under it]. The only component besides the map server that needs the internet.
- **Candidate:** TextRouter's set with its own paths, `IPAddressAllow=localhost` plus the FLS endpoints *(system only)*. The FLS host resolves to rotating CDN addresses (IPv4 and IPv6) [M], so an address allow-list is brittle; allow outbound TCP 80 and 443 to anything instead, or leave `IPAddressDeny` off for this unit.

### Gateway

- **Process:** `python3.12` (nixpkgs 3.12.13 env with `psycopg2` 2.9.11 and `python-dateutil`) running Funcom's bytecode, single thread, cwd `$STATE/gateway/root/Tools/Battlegroups/GatewayService` [M][C].
- **Writes:** `$STATE/gateway/gateway-console.log`, `$STATE/gateway/root/Tools/Battlegroups/GatewayService/logs/gateway.log` [M]; `dune-gateway start` refreshes `$STATE/gateway/root` with `rsync` and writes `conf.d/gateway.ini` [C].
- **Reads:** its tree and `conf.d/` [C]; `/etc/app/conf.d` is also searched [C] (absent here).
- **Network:** listens on nothing [M]. Outbound: postgres (loopback) and FLS over HTTPS (`sb-retail.fls.funcom.com`, from its log) [M]. It advertises, but does not connect to, the game broker's external `:31982` and `:15673` [M]. Families `AF_INET`, `AF_UNIX` (`nscd`) [I]; add `AF_INET6` because the FLS host has IPv6 addresses [M].
- **Special:** CPython runs under `MemoryDenyWriteExecute=yes` [P].
- **Candidate:** the postgres set with `ReadWritePaths=$STATE/gateway`, `RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6`, `MemoryDenyWriteExecute=yes`, outbound TCP 443 to the internet.

### Map server (Survival_1)

- **Process:** `$STATE/server/tree/DuneSandbox/Binaries/Linux/DuneSandboxServer-Linux-Shipping`, a copy of Funcom's Unreal Engine 5 binary with its interpreter patched to nixpkgs glibc 2.42 and gcc's `libgcc_s` added to its RUNPATH; the rest of `tree/` is a symlink farm into `$UNPACKED/server/rootfs/home/dune/server` [C]. 94 threads, about 9.6 GiB resident [M]. It runs under `setsid systemd-run --user --scope -p MemoryMax=20G -p MemorySwapMax=0` in `dune-server-<world>.scope` [M][C]. `HOME=$STATE/server/home` [C].
- **Writes:** `$STATE/server/Saved/**` (`Config/LinuxServer/*.ini` including the 0600 secret overrides, `UserSettings/`, `Logs/`, `Config/CrashReportClient/`), `$STATE/server/server-console.log`, `$STATE/server/home/.config/Epic/`, `$STATE/server/tree/DuneSandbox/Binaries/Linux/serverstatus_port`, `$STATE/server/tree/Engine/Saved/Config/`, and `/tmp/DuneSandboxServer-Linux-Shipping` (an empty file, 0644, held open read-write: a per-binary lock) [M]. `dune-server start` also writes `$STATE/server/{pid,tree,tree.stamp}` and the patched binary [C].
- **Reads:** the paks under `$UNPACKED/server/…/DuneSandbox/Content/Paks` (held open) and the rest of the tree, glibc and `libgcc_s` from the store, `/dev/urandom` [M]; the UserSettings defaults come from `$STEAM/scripts/setup/config` and overrides from `$CONFIG/UserSettings` at start [C].
- **Network** [M]: listens on UDP `<external address>:7777` (players) and `:7888` (IGW), both bound to the `-MultiHome` address, and TCP `127.0.0.1:10000` (Unreal's ServerStatus `HttpListener`; `DedicatedServerEngine.ini` sets the range 10000–11000). Outbound: postgres, the admin broker (2 connections), the game broker over TLS (2), FLS over HTTPS, and one HTTPS connection to a Google Cloud address (reverse DNS `*.bc.googleusercontent.com`; the service was not identified). It also polls `http://127.0.0.1:15672/api/users/…` (RabbitMQ's management API, which nothing serves here): 105 failed attempts in `server-console.log`. One loopback TCP pair connects the process to itself. Families `AF_INET` (TCP and UDP), `AF_UNIX` (a datagram socket connected to `/run/systemd/journal/dev-log`: it logs to syslog) [M]; `AF_NETLINK` [I: `-MultiHome` address selection usually enumerates interfaces through netlink at startup; not seen live].
- **Special:** the memory cap is resource control, not sandboxing; `MemoryMax=` and `MemorySwapMax=` already work in the user manager [M]. The UDP sockets are bound to one address, so the unit must start after that address exists (`network-online.target`, or the tailnet interface).
- **Candidate:** `ProtectSystem=strict`, `ReadWritePaths=$STATE/server`, `ProtectHome=` as for postgres with `$UNPACKED/server` and `$STEAM/scripts/setup/config` readable, `PrivateTmp=yes` (the lock file becomes private to the unit), `PrivateDevices=yes`, `NoNewPrivileges=yes`, empty capability sets, `RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6 AF_NETLINK`, `SystemCallFilter=@system-service` [I: test], `MemoryDenyWriteExecute=yes` [I: test first], `LockPersonality=yes`, `RestrictNamespaces=yes`, `ProtectKernel*`, `ProtectClock=yes`, `MemoryMax=20G`, `MemorySwapMax=0`, `Environment=HOME=$STATE/server/home`.

### GM bridge

- **Process:** `luajit libexec/dune-gm-bridge`, cwd the checkout [M].
- **Writes:** `$STATE/gm-bridge/{gm-bridge.log,pid}` [M][T]. Through `dune-live` it can also write `$BACKUPS` (`character move` backs up first) and read `$STATE/server/server-console.log` [C].
- **Reads:** `$CHECKOUT/libexec/**`, `$CHECKOUT/data/items.tsv`, `$CONFIG/gm_bridge.conf`, `$SECRETS/gm_bridge_rmq_password`, `$STATE/items/generated.tsv` [T][C].
- **Network:** one TCP connection to the game broker's plain AMQP port `127.0.0.1:5674` [M]. Its commands run `dune-live`, which runs `rabbitmqctl eval` against the game broker (Erlang distribution: epmd `127.0.0.1:4369`, the broker's `:25673`, its own listener on `0.0.0.0:35672`) and `psql` [C][T]. Families: its own `AF_INET`; through children `AF_UNIX`, `AF_INET6`, `AF_NETLINK` [T].
- **Special:** LuaJIT and its BEAM children: **no `MemoryDenyWriteExecute` unless it runs with `luajit -joff`** [P]. It must read the game broker's Erlang cookie (`$STATE/rabbitmq-game/.erlang.cookie`), so it shares the broker's trust domain.
- **Candidate:** `ProtectSystem=strict`, `ReadWritePaths=$STATE/gm-bridge $BACKUPS` (or drop `move` from the bridge's allow-list), read-only `$CHECKOUT $CONFIG $STATE`, `PrivateTmp=yes`, `PrivateDevices=yes`, `NoNewPrivileges=yes`, empty capability sets, `RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6 AF_NETLINK`, `SystemCallFilter=@system-service`, `MemoryDenyWriteExecute=yes` only with `-joff`, `RestrictNamespaces=yes`, `ProtectKernel*`, `IPAddressAllow=localhost` *(system only)*.

### Idle throttle

- **Process:** `luajit libexec/dune-idle-throttle`, cwd the checkout [M].
- **Writes:** `$STATE/idle-throttle/{idle-throttle.log,pid,state}` [M][T].
- **Reads:** `$CHECKOUT/libexec/**`, `$STATE/server/server-console.log` (cvar read-back through `dune-live`), `$CONFIG/notify` (the notifier, a 0700 script) [C][M].
- **Network:** every 10 s (30 s in deep idle) it runs `ss -Htn state established '( sport = :31982 )'`, which asks the kernel over `AF_NETLINK` (`sock_diag`) for the host's TCP table [C][T]. It needs the host network namespace: **`PrivateNetwork=yes` would make every player invisible**. Rate changes run `dune-live world cvar`, so it has the GM bridge's Erlang needs; notices run `$CONFIG/notify`, whose network needs depend on the host's mail tool [I].
- **Special:** LuaJIT (as the bridge). `ss` without `-p` does not read other processes' `/proc/<pid>/fd` [C]; the test tier's own `ss -p` port checks do [T].
- **Candidate:** the GM bridge's set with `ReadWritePaths=$STATE/idle-throttle`, `PrivateNetwork=no`, and `AF_NETLINK` required.

### Timer and world jobs (not running at measurement time)

From the rendered units (`libexec/dune-units`), their code, the journal and the test traces:

| Unit | Runs | Writes | Network and special needs |
|---|---|---|---|
| `dune-world.service`, `dune-world-heal.service` | `bin/dune-awakening start` (LuaJIT), which re-executes itself in `nix develop` and launches every component | `$STATE/**` (see finding 8), `$SECRETS`, `~/.cache/nix/` (eval and fetcher caches, measured), `/tmp/nix-shell.*` | the Nix daemon socket `/nix/var/nix/daemon-socket/socket`; `ip -4 route get` (netlink) when `EXTERNAL_ADDRESS` is unset; everything its children need, because they inherit its sandbox (finding 6); `KillMode=process` on heal |
| `dune-backup.service` | `backup create` then `prune` | `$BACKUPS/<timestamp>/`, `$TRASH` (prune moves old backups there) | reads `$CONFIG` whole (it is archived into `config.tar`, `fls_secret` included) and `$SECRETS/postgres_admin_password`; TCP to postgres on loopback; `pg_dump`, `pg_dumpall` [T] |
| `dune-backup-verify.service` | `backup verify latest` | `$BACKUPS/.verify.err`; creates and drops a scratch database in the **live** cluster | TCP to postgres; `pg_restore` [C][T] |
| `dune-update-check.service` | `update check --json` → `steamcmd +app_info_print` | `$STEAMCMD_HOME/**` (`.local/share/Steam`, updated at every run, measured) | internet to Steam; `steam-run` needs user and mount namespaces and `@mount` syscalls (finding 10) |
| (manual) `update apply` | backup, `world stop`, steamcmd download, unpack, `world start` | `$STEAM/**`, `$UNPACKED/*.new`, `*.prev`, `$TRASH`, `$BACKUPS`, then everything `start` writes | as update-check plus control of every component: with per-component units it must be able to stop and start them |

Candidate directives for these, in the order of what they allow:

- **backup, backup-verify:** `ProtectSystem=strict`, `ReadWritePaths=$BACKUPS $TRASH`, read-only `$CONFIG $SECRETS`, `PrivateTmp=yes`, `PrivateDevices=yes`, `NoNewPrivileges=yes`, `RestrictAddressFamilies=AF_UNIX AF_INET`, `SystemCallFilter=@system-service`, `RestrictNamespaces=yes`, `IPAddressAllow=localhost` *(system only)*. `MemoryDenyWriteExecute=yes` only if `bin/dune-awakening` runs with `luajit -joff`. The Nix re-exec needs `~/.cache/nix` writable and the daemon socket reachable, or the units must call the tools without `nix develop`.
- **update-check:** `ReadWritePaths=$STEAMCMD_HOME`, `RestrictNamespaces=user mnt pid ipc uts net cgroup`, `SystemCallFilter=@system-service @mount`, internet access; no `MemoryDenyWriteExecute` [I: steamcmd is a 32-bit closed binary; untested] and no `PrivateUsers=` conflict [P: bwrap ran under `ProtectSystem=strict`, which already puts a user unit in a user namespace].
- **world, heal, update apply:** no meaningful sandbox while they launch the components. Once each component is its own unit, these become `systemctl start/stop` of those units and need only permission to do that (trivial in a user manager; a polkit rule or a small privileged helper for system units).

## User units versus system units

Measured with transient user units under systemd 261.2 [P] (the "System unit" column is systemd's documented behaviour, not measured here):

| Directive | User unit (measured) | System unit |
|---|---|---|
| `ProtectSystem=strict` | enforced, through an implicit user namespace (`uid_map` `1000 1000 1`), **but `$HOME` stays writable** | enforced, `/home` read-only too |
| `ReadWritePaths=`, `ReadOnlyPaths=` | enforced | enforced |
| `ProtectHome=read-only`, `ProtectHome=tmpfs` + `BindPaths=` | enforced | enforced |
| `PrivateTmp=yes` | enforced (empty `/tmp`) | enforced |
| `PrivateDevices=yes` | enforced (`/dev` holds `null zero full random urandom tty ptmx pts shm mqueue hugepages` and the std streams) | enforced |
| `PrivateIPC=yes`, `PrivateNetwork=yes` | enforced (`PrivateNetwork` leaves only `lo`) | enforced |
| `ProtectKernelTunables=yes` | enforced (`/proc/sys` read-only) | enforced |
| `ProtectKernelModules`, `ProtectKernelLogs`, `ProtectControlGroups` | accepted | enforced |
| `NoNewPrivileges=yes` | enforced (`NoNewPrivs: 1`) | enforced |
| `SystemCallFilter=`, `RestrictAddressFamilies=`, `RestrictNamespaces=`, `LockPersonality=`, `RestrictRealtime=`, `RestrictSUIDSGID=`, `ProtectClock=` | enforced (seccomp filters installed; `AF_INET` refused under `AF_UNIX` only; `unshare` refused) | enforced |
| `MemoryDenyWriteExecute=yes` | enforced (kernel MDWE) | enforced |
| `AmbientCapabilities=` (empty) | accepted | enforced |
| `CapabilityBoundingSet=` (empty) | **unit fails** (218/CAPABILITIES: "Failed to drop capabilities") unless `PrivateUsers=yes` is also set, which then shows `CapBnd: 0` | enforced |
| `IPAddressDeny=`, `IPAddressAllow=` | **not enforced** (a connection to a public address succeeded under `IPAddressDeny=any`) | enforced (cgroup BPF) |
| `ProtectProc=invisible`, `ProcSubset=pid` | **not enforced** (`/proc` still lists every process) | enforced |
| `User=`, `Group=`, `DynamicUser=` | not available | available |
| `MemoryMax=`, `MemorySwapMax=` | enforced (the live map server scope) [M] | enforced |

What this means for the choice in step 3:

- A user unit can give every component a private `/tmp`, a private `/dev`, a read-only system with named writable paths, a syscall and address-family filter, and W^X where the runtime allows it. Its mount-namespace directives depend on unprivileged user namespaces, which this host allows.
- A user unit cannot restrict IP destinations, hide other processes, or change who owns the files. Under the operator's uid, anything else that user runs (agents, browsers, shells) can still read `$SECRETS` and `/proc/<pid>/environ` [M: readable today], and probably reach the .NET diagnostics sockets inside a unit's private `/tmp` through `/proc/<pid>/root` [I: not tried].
- A system unit with a dedicated user adds `IPAddressDeny`, `ProtectProc`, a real capability bounding set, and above all a different uid, which is the only one of these that closes findings 3 and 4.

## What blocks strict sandboxing

1. .NET (TextRouter, Director) needs `MemoryDenyWriteExecute=no` [P].
2. LuaJIT tools need `luajit -joff` for `MemoryDenyWriteExecute=yes` [P]; `-joff` costs speed in a tool that mostly waits on I/O.
3. steamcmd needs user and mount namespaces and `@mount` syscalls [P].
4. The components are launched by one oneshot unit, so they share one sandbox; per-component units are a precondition for everything above (finding 6).
5. The GM bridge and the idle throttle (through `dune-live`) need the game broker's Erlang cookie and its distribution port, which gives them full control of the broker; that cannot be narrowed by a sandbox directive, only by replacing `rabbitmqctl eval` with an AMQP publish from a least-privileged broker user.
6. The idle throttle needs the host network namespace and `AF_NETLINK` to see player connections.
7. In a user unit, `ProtectSystem=strict` alone does not protect `$HOME`, and `IPAddressDeny`, `ProtectProc` and `CapabilityBoundingSet` are unavailable or need `PrivateUsers=yes` [P].
8. Untested: the map server under `MemoryDenyWriteExecute=yes` and `SystemCallFilter=@system-service`, and Director and the Gateway under a syscall filter. Test them at the next planned restart, one directive at a time, with a copy of the unit.

## Reproducing

Test-instance traces (run from the checkout; each suite uses its own ports and temporary state):

```bash
nix develop --ignore-environment --keep HOME --keep TMPDIR --keep USER -c \
	/run/current-system/sw/bin/strace -f -qq -yy --seccomp-bpf -s 200 \
	-e 'trace=%file,%network,%process,mprotect,mmap,memfd_create,io_uring_setup,unshare,setns,mlock,mlockall,shmget,shmat,ptrace,setuid,setgid,setresuid,capset,prctl,personality,keyctl,bpf,perf_event_open,mount,chroot,pivot_root' \
	-o textrouter-auth.st bash --norc --noprofile tests/payload/textrouter-auth </dev/null
```

Directive probes (a transient user unit per probe; nothing live is touched). The user manager has its own `PATH`, so give `luajit` and `steam-run` as absolute store paths (from `nix develop -c command -v luajit`, and the `steam-run` path inside the `steamcmd` wrapper):

```bash
probe() { systemd-run --user --wait --pipe --collect --quiet "$@"; }
probe -p MemoryDenyWriteExecute=yes luajit -e 'local s=0 for i=1,3e7 do s=s+i%7 end print(s)'   # panics
probe -p MemoryDenyWriteExecute=yes luajit -joff -e 'local s=0 for i=1,3e7 do s=s+i%7 end print(s)'   # runs
probe -p MemoryDenyWriteExecute=yes --working-directory="$APP" "$APP/TextRouter" --help   # core dump (APP: a dune-dotnet-prepare copy)
probe -p IPAddressDeny=any bash -c 'exec 3<>/dev/tcp/1.1.1.1/443 && echo not-enforced'
probe -p CapabilityBoundingSet= true   # 218/CAPABILITIES in a user unit
probe -p ProtectSystem=strict bash -c 'touch ~/.probe && echo home-writable'
probe -p SystemCallFilter=@system-service steam-run true   # SIGSYS
probe -p 'SystemCallFilter=@system-service @mount' steam-run true   # runs
```
