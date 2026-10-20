---
description: "Scheduled notices failed silently for days because the notifier ran under the unit's PATH (a plain luajit without luv) and its stderr was discarded; test notifiers under the unit environment and keep their error text."
datetime: 2026-10-20T11:50:00-04:00 # EDT
tags: [notify, notifier, post, systemd, unit, path, luajit, luv, silent-failure, update-check]
---
2026-10-20: Steam build 25936522 was found by the daily update check on 2026-10-19 and 2026-10-20, but both notices failed with only "update notice ... failed". The notifier (a private wrapper around the mail tool) appended the system profile to PATH, so the unit's own luajit came first; the mail tool had since started requiring the luv module, which that luajit lacks. Interactively it worked, because the interactive PATH finds the system luajit first.

Reproduce under the unit's environment: `systemd-run --user --wait --pipe --setenv=PATH="$(systemctl --user show UNIT -p Environment --value | tr ' ' '\n' | sed -n 's/^PATH=//p')" CMD --help`.

Fixes: the wrapper now puts the system paths first; dune-update now logs the notifier's last error line instead of discarding it.
