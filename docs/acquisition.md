# Server package and token acquisition

Findings from the pinned DASH checkout `vendor/dash` (b3a26c1b, VERSION 0.1.0-beta.1), reviewed 2026-09-24. Paths below are relative to `vendor/dash`. Lines marked "inference" are not documented upstream.

## Steam server package

- DASH downloads with SteamCMD (`scripts/update-steam-tool.sh:263-280`) or a running desktop Steam client (`:137-187`). DepotDownloader is not used.
- AppID `4754530`, "Dune: Awakening Self-Hosted Server" (`docs/maintenance-updates.md:248`). This is still upstream evidence only; not yet confirmed against Steam app metadata.
- The default public branch is used. No `-beta` flag exists anywhere in DASH.
- Anonymous login is refused: `scripts/update-owned-steam-build-and-restart.sh:130` dies with "anonymous SteamCMD no longer has access to app 4754530". The docs require an account that owns the tool (`docs/maintenance-updates.md:249-251`). `.env.example` still defaults to `anonymous`, which is stale.
- Output: `images/battlegroup/*.tar` and `images/prerequisites/igw-postgres.tar` under `DUNE_STEAM_SERVER_DIR`, loaded with `docker load` (`scripts/load-images.sh:77-93`). The game image is about 10.3 GB.
- Version record: `buildid` from `appmanifest_4754530.acf`, and the `seabass-server` tag from each tar manifest (`scripts/check-steam-update.sh:131-202`). Build pins in DASH docs disagree (1968181, 1963158, 1988751), so only the downloaded manifest counts.
- DASH passes a Steam password on SteamCMD argv when one is configured (`update-steam-tool.sh:264-265`). We should rely on a cached Steam Guard login in a private `DUNE_STEAMCMD_HOME` and supply no password.

## FLS self-host token

- The token comes from https://account.duneawakening.com/ (`.env.example:142-144`). The generating Steam account must own the self-hosted server entitlement (`docs/troubleshooting.md:45`).
- DASH reads it as `FLS_SECRET` in `.env`, passes it on each map's command line (`compose.yaml:68`) and in service environments (`compose.yaml:250,301,342`). Anyone who can run `docker inspect` or read process lists on the host can see it; that is a DASH design limit.
- The channel is `DUNE_FLS_ENV`, default `retail` (`compose.yaml:69`). Since DASH installs the public Steam branch, the retail token is the matching pair. PTC is only for a matching PTC build (`docs/setup.md:16`).
- The format is undocumented. The Makefile secret scanner matches `FLS_SECRET=eyJ` (inference: probably a JWT).

## Proposed private inputs (not yet created)

| Input | Location | Mode | Who creates it |
|---|---|---|---|
| FLS token, one line, retail channel | `~/.config/dune_awakening_server/fls_secret` | 0600, dir 0700 | the operator |
| SteamCMD cache (anonymous; no login needed) | `~/.local/share/dune_awakening_server/steamcmd` | 0700 | agent, created |
| Downloaded server payload | `~/.local/share/dune_awakening_server/steam-server` | 0700 | agent, in progress |

All three stay outside Git and the Nix store. The runtime `.env` would be generated at launch from the token file and never committed.

## Host sizing inputs

DASH states no RAM minimum. Its data points: `Survival_1` limit 12 GiB in Funcom's template, overmap 2 to 5 GiB, core services about 2 to 3 GiB total (`compose.limits.example.yaml`, `compose.64g-limits.yaml`). Minimal map set: `survival` alone, or `survival`+`overmap` (`docs/autoscaling-memory.md:178-184`). Estimate for two players: 16 to 22 GiB (inference, unmeasured). The DASH host-tuning script assumes no swap and `vm.overcommit_memory=1`; we will not apply it.

## Other cautions

- Many defaults name the DASH author's hosts (`kspls0`, `/home/keith`, login `ksnape`); hostname-gated features refuse until overridden.
- DASH disagrees with itself about exposing `31982/tcp` (`docs/teardown.md:125` vs `README.md:789-793`) and about the UDP ranges. Resolve these before any ingress proposal.
- The admin panel mounts the Docker socket, and the restart helper creates privileged host-network containers. Don't enable those for a two-player world without review.

## Verified on this host (2026-09-24 ~13:40 EDT)

`steamcmd` (nixpkgs steamcmd-20180104 wrapper, self-updating Valve bootstrap) is in the devShell. The flake admits only `steamcmd` and `steam-unwrapped` as unfree. SteamCMD state lives in `~/.local/share/dune_awakening_server/steamcmd`, selected by running with that directory as `HOME`.

Anonymous `+app_info_print 4754530` returned:
- name "Dune: Awakening Self-Hosted Server", type Tool, parent app 1172710, ReleaseState released, `freetodownload` 1, oslist windows,linux
- Linux depot 4754532, Windows depot 4754531
- public branch buildid 25486303 (build updated 2026-09-23 12:24 EDT, branch updated 2026-09-24 06:58 EDT); private branches exist but are not listed anonymously

An anonymous `+app_update 4754530` then downloaded 1.4 GB in a 90-second probe, so the DASH claim that anonymous access is refused is stale for this build. No Steam account is needed for the payload. The FLS token still requires the operator's account at the Funcom portal.

The Steam buildid (25486303) is a different number space from the image tag (e.g. `1968181-0-shipping`); read the tag from the downloaded tar manifests.

## Downloaded payload (2026-09-24 13:44 EDT)

Anonymous `app_update 4754530 validate` completed: `Success! App '4754530' fully installed.` The appmanifest shows buildid 25486303 = TargetBuildID, StateFlags 4, 5,129,198,720 bytes downloaded, 5,206,359,961 on disk. The payload is at `~/.local/share/dune_awakening_server/steam-server` (0700). SHA-256 of all 66 payload files is committed in [payload/steam-4754530-build-25486303.sha256](payload/steam-4754530-build-25486303.sha256), checkable with `sha256sum -c` from that directory. The payload itself is never committed.

- Game image tag: `2124138-0-shipping` (`images/battlegroup/version.txt`, and every battlegroup tar manifest). `server.tar` is 4,455,908,864 bytes.
- Postgres: `igw-postgres:17.4-alpine-fc-13`. Kubernetes operators v1.7.0, plus cert-manager, coredns, local-path-provisioner, and metrics-server tars used only by Funcom's k3s appliance path.
- Funcom's own `scripts/` (k3s-based `battlegroup.sh`, `bg-util`, world template) are included. The template keeps `Survival_1` at 12Gi and `Overmap` at 2Gi.

Compatibility risk: the pinned DASH (b3a26c1, 2026-09-21, still upstream HEAD at 13:50 EDT) references builds up to `2036754-0-shipping`, never 2124138. DASH hardcodes database `dune_sb_1_4_0_0` and patches server internals by build. Treat DASH as unproven against this build until a bootstrap run shows the DB schema and startup work. The Funcom k3s scripts are the build-matched fallback.

## Game version (checked 2026-09-24 16:55 EDT)

Patch 1.5 released on all platforms on 2026-09-22 with the console launch (duneawakening.com news, via search). The downloaded server image `2124138-0-shipping` was built 2026-09-23, so it is very likely the 1.5 server. That is inference: the database name was not found in the payload without running it. DASH already handles the "post-1.5 schema" (`docs/player-identity-integrity.md:19`), but it still hardcodes the database name `dune_sb_1_4_0_0`. Check the actual database name at the first bootstrap. The community wiki lists separate Steam apps: 3104830 for PTC and 4754530 for Live.
