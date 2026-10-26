---
description: "Components and dune-live run by hand from libexec lack the environment bin/dune-awakening sets (state, secrets, ports), so they fail quietly or with misleading errors; call them through bin/dune-awakening."
datetime: 2026-10-26T14:56:14-04:00 # EDT
tags: [operations, dune-live, idle-throttle, environment, wrapper, bin-dune-awakening, debugging]
---

On 2026-10-26 this cost time twice in one session:

- `libexec/dune-live world cvar Dac.DamageEnabled` printed nothing and exited 1. `bin/dune-awakening world cvar Dac.DamageEnabled` printed `1`. The direct call had no `DUNE_SECRETS_DIR`/ports, and `cvar_get` hides the publish error (`2>/dev/null`).
- `DUNE_STATE_DIR=... libexec/dune-idle-throttle stop` stopped the loop but then failed to restore the frame rate ("exit status 1"), because the `dune-live` it calls had the same missing environment.

Rule: for live commands use `bin/dune-awakening world ...` / `bin/dune-awakening character ...`. To restart one component, stop it only if needed and let `bin/dune-awakening start --no-warn` (idempotent; starts what is missing) bring it back. If a direct call is unavoidable, export the environment the wrapper builds (see `bin/dune-awakening`, its env table near `DUNE_USERSETTINGS_OVERRIDES`) instead of guessing.
