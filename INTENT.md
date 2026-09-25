# Dune Awakening on NixOS

The operator wants a private Dune: Awakening world for themselves and a couple of friends on an existing NixOS host, with no Windows, Docker or Kubernetes at runtime. The world runs as native nixpkgs services managed by this project's flake. This replaced the earlier plan of DASH containers or Funcom's Alpine/k3s VM. Funcom's own binaries, database scripts and stored procedures run unmodified; PostgreSQL 17 and RabbitMQ come from nixpkgs, matched to Funcom's behavior where it matters (locale, ports, auth).

Success means the players can join, characters persist across restarts, the dependencies stay healthy, backups verify through a restore drill, and updates follow Steam the same day because client and server builds must match exactly. Operating the world is scriptable (start/stop/status, update, backup, character tools) from any directory, and the host administrator gets service definitions and a machine-readable status.

The tooling, flake and documentation are meant to be shared publicly. Proprietary Funcom payloads, player state, backups, credentials and host-specific details stay outside Git and the Nix store; only `*.sample` / `*.default` templates are committed.

Constraints: preserve existing workloads and host configuration. Host changes (firewall, services, reboots, NixOS activation) go through the host administrator. No purchases and no disclosure of credentials. Behavior changes are test-first, and `./test` stays green.

Evidence of what has been proven lives in [docs/readiness.md](docs/readiness.md).
