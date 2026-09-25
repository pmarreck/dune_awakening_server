# Dune: Awakening self-hosted server, natively on Linux with Nix

[![Mechatron Prime CI](https://img.shields.io/endpoint?url=https%3A%2F%2Fthelio-nixos.tail66c90.ts.net%2Fbadges%2Fdune_awakening_server.json&style=for-the-badge)](https://thelio-nixos.tail66c90.ts.net/mechatron-prime/)

Run Funcom's official Dune: Awakening 1.5 self-hosted server (a "battlegroup") as ordinary Linux processes managed by a Nix flake: no Windows, no Hyper-V virtual machine, no Docker, no Kubernetes. Funcom ships the server as a Windows-hosted Alpine VM running Kubernetes; this project runs the same Funcom binaries and database scripts directly, with nixpkgs PostgreSQL 17 and RabbitMQ standing in for Funcom's containers.

**Status (September 2026, game build 1.5.3.4 / Steam build 25486303):** in daily use by two players. Players join over LAN or Tailscale, characters persist across restarts, gameplay settings apply, and the idle world was stable for 7 hours of sampling. See [docs/readiness.md](docs/readiness.md) for the evidence.

## Why Nix

This setup requires [Nix](https://nixos.org/download/). Nix pins every tool this project uses (PostgreSQL 17, RabbitMQ and Erlang, LuaJIT, steamcmd, the loaders Funcom's .NET services need) to exact versions in `flake.lock`. One `nix develop` gives you all of them at those versions, on any x86_64 Linux machine, without touching the rest of your system. The result is reproducible: the same checkout builds and tests the same way everywhere, and `nix flake check` proves it.

Nix is what made the rest of Funcom's stack unnecessary. Funcom's supported path is a Windows Pro host running Hyper-V, which runs an Alpine Linux appliance, which runs Kubernetes, which runs Docker containers. Those layers exist to deliver the right dependency versions to Funcom's binaries. Nix delivers the same dependencies directly, so the binaries run as plain processes and setup comes down to a few commands.

## If Nix looks intimidating

You do not need to learn Nix to use this. Everything runs through a few scripts that call Nix for you. When something needs changing, an LLM coding assistant (Claude Code, Codex and similar) removes most of the friction: it reads `flake.nix`, runs the test suite and explains failures. This project was built that way, and its docs are written so that an assistant can follow them step by step. Point one at this README and at [docs/operations.md](docs/operations.md).

## What you need

Funcom's stated requirements for a self-hosted battlegroup ([self-hosting requirements FAQ](https://funcom.helpshift.com/hc/en/4-dune-awakening/faq/84-self-hosting-requirements-faq/)):

- **Memory:** 20 GB, "depending on how many servers the battlegroup will have". This project runs one map (Hagga Basin, `Survival_1`). Measured: about 10.4 GiB idle for the whole stack, and about 9.6 GiB for the map server with one player (capped at 20 GiB, no swap).
- **CPU:** Intel Core i5-8400 / AMD Ryzen 5 1600 class, with AVX2.
- **Storage:** 100 GB on SSD. The Steam download is about 5.2 GB, and the unpacked images take a similar amount again.
- **Ports:** Funcom lists 7777–7810 UDP for game servers and 31982 TCP for RabbitMQ (RMQ). One map uses UDP 7777 (players) and 7888 (server-to-server, internal); the game broker listens on TCP 31982 with TLS.
- **Token:** a self-host token from Funcom's account page, https://account.duneawakening.com/. The token this project was developed with expires one year after it was issued.
- **Client and server builds must match exactly.** When Steam updates the game, update the server the same day (`dune-world update apply`).

This project additionally needs x86_64 Linux with [Nix](https://nixos.org/download/) (flakes enabled) and systemd user sessions. It is developed on NixOS.

## Setup

```bash
git clone <this repo> && cd dune_awakening_server
nix develop            # enters the toolchain; the scripts below also do this themselves

# 1. Operator config (outside the repo). Copy the templates, fill them in, drop the suffixes.
mkdir -p -m 700 ~/.config/dune_awakening_server
cp -r config.sample/. ~/.config/dune_awakening_server/
#    fls_secret.sample   -> fls_secret     (your Funcom token, one line)
#    join_password.sample -> join_password (optional in-game password)
#    world.conf.sample   -> generate it instead: dune-world init --display-name "My World" --region "North America"
chmod 600 ~/.config/dune_awakening_server/fls_secret

# 2. Funcom's server payload from Steam (anonymous login works for app 4754530).
HOME=~/.local/share/dune_awakening_server/steamcmd steamcmd +@sSteamCmdForcePlatformType linux \
  +force_install_dir ~/.local/share/dune_awakening_server/steam-server +login anonymous +app_update 4754530 validate +quit
for i in server server-bg-director server-text-router server-gateway server-db-utils; do
  libexec/dune-unpack ~/.local/share/dune_awakening_server/steam-server/images/battlegroup/$i.tar ~/.local/share/dune_awakening_server/unpacked/$i
done

# 3. Run it.
bin/dune-world start
bin/dune-world status
```

Leftover `*.sample` / `*.default` files in the config directory make `dune-world` print a yellow warning (silence it with `--no-warn` or `DUNE_NO_WARNINGS=1`). Open UDP 7777 and TCP 31982 in your firewall for the players' network. For friends outside your LAN, [Tailscale node sharing](https://tailscale.com/kb/1084/sharing) works well: share just the server machine with their own Tailscale account, and set `EXTERNAL_ADDRESS` in `world.conf` to the server's Tailscale address (`tailscale ip -4`). Tailscale Funnel cannot work, because it carries TCP only.

## The `dune-world` command

Everything runs through one command, `bin/dune-world`. It works from any directory (it finds its own checkout) and enters the project's `nix develop` environment by itself. Every script in this repository was written for this project; none of them is Funcom's. Funcom's own tooling (`battlegroup.sh`, the Kubernetes operators and the Alpine VM) ships in the Steam download and is not used; Funcom's server binaries run unmodified under the components below. With [direnv](https://direnv.net/), `direnv allow` once puts `bin/` on your PATH inside the checkout (see `.envrc`).

| Subcommand | Purpose and options |
|---|---|
| `start`, `stop`, `restart` | Bring the whole world up in dependency order (database, schema, brokers, Funcom services, map server), or down in reverse |
| `status [--json] [--watch SECS]` | One line per component; `--json` adds world identity, characters online, map-server memory and CPU (for admin pages) |
| `admin …` | Live-world commands: `players`, `partitions`, `where`, `move` (offline players, after a backup), `whisper`, `say`, `kick`, `teleport`, `water`, `xp`, `exec`, `worm`, `raw`, and `timeout on/off` (a break for everyone: no damage, sandworms or storms) |
| `update …` | Steam build: `check` (exit 0 current, 1 update available, 3 unknown), `apply` (backup, stop, download, unpack, start, re-check) |
| `backup …` | `create`, `list`, `verify` (restore drill), `restore --yes`, `prune` (retention policy in `backup.conf`) |
| `character …` | Characters in the database: `list`, `show`, `set-intel` / `add-intel`, `set-skill-points` / `add-skill-points`, `export` / `validate` / `import` |
| `init …` | One-time setup: writes `world.conf` from your Funcom token |
| `units render DEST` | systemd user units for unattended running (world at boot, self-heal, backups, update check) |

`dune-world <subcommand> --help` lists each subcommand's options.

**Components** live in `libexec/`. `dune-world` calls them; you rarely run them directly. Each manages one piece of Funcom's stack: `dune-server` (the map server, Funcom's Unreal binary), `dune-postgres` (database cluster), `dune-db-setup` (Funcom's schema installer), `dune-world-partitions`, `dune-rabbitmq` (admin and game message brokers), `dune-textrouter`, `dune-director` and `dune-gateway` (Funcom's broker authentication, director and gateway services), plus setup helpers `dune-dotnet-prepare`, `dune-unpack` and `dune-usersettings`. The subcommand tools (`dune-admin`, `dune-update`, `dune-backup`, `dune-character`, `dune-world-init`, `dune-units`) live there too.

Gameplay settings (XP, harvest yield, crafting time, death penalties, sandstorm damage and more) go in override files under `~/.config/dune_awakening_server/UserSettings/`; see [docs/operations.md](docs/operations.md#gameplay-settings). Funcom's guide describes the same `UserSettings` files for its VM.

## Tests

```bash
./test               # everything, including host-tier suites that need the downloaded Funcom payload
./test --hermetic    # what the Nix check runs (no payload, no network)
nix flake check
```

## Documentation

- [docs/architecture.md](docs/architecture.md): how Funcom's components connect, and what replaces Kubernetes here
- [docs/operations.md](docs/operations.md): day-to-day operation, characters, gameplay settings
- [docs/postgres-parity.md](docs/postgres-parity.md): Funcom's PostgreSQL fork vs nixpkgs PostgreSQL, and the locale match
- [docs/acquisition.md](docs/acquisition.md): the Steam payload and the Funcom token
- [docs/readiness.md](docs/readiness.md): evidence from the first bring-up
- [docs/research/](docs/research/): Funcom appliance wiring, image internals, 1.5 compatibility

## Notes for LLM agents

- Read [INTENT.md](INTENT.md) first. Behavior changes go test-first: write a failing test under `tests/`, then make it pass. `./test` must stay green.
- Secrets never enter Git, the Nix store, command lines or logs. They live in `~/.config/dune_awakening_server/` (0600). Only `*.sample` / `*.default` templates are committed, and `tests/unit/public-hygiene` enforces that.
- Funcom's payload (binaries, images, default ini files) is proprietary and is never committed. Scripts read it from `~/.local/share/dune_awakening_server/`.
- The live database belongs to the running server. Edit characters only through `dune-world character`, which refuses while the account is online and backs up first.

## Legal

Dune: Awakening and its server software are Funcom's. This repository contains only original tooling and documentation; you need your own Steam download and Funcom token.
