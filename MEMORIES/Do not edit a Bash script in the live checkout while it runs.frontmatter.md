---
description: "Bash reads a script as it runs, so editing libexec/dune-update during update apply made it resume at a shifted offset and fail with a bogus unbound-variable error; wait for long runs (apply, restart, backup) to finish before editing their scripts."
datetime: 2026-10-20T11:55:13-04:00 # EDT
tags: [bash, script, live-checkout, edit, update-apply, unbound-variable, incremental-read]
---
2026-10-20: `update apply` was running from the checkout when a 3-line insertion went into libexec/dune-update. Apply had already printed "updated to build 26051014"; Bash then read the rest of the file from its old byte offset and died with `line 187: installed: unbound variable`. No harm that time, because the edit landed after the last real step, but an earlier landing would have run arbitrary fragments mid-update.

The world's timers also run scripts from this checkout (heal every 5 minutes). Edit freely only when no long-running command from the checkout is active, or work in a separate worktree and merge when idle.
