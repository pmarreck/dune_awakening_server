---
description: "Starting world components inside ( flock 9 ... ) 9>>update.lock let the daemons inherit fd 9 and hold the update lock indefinitely; close the lock fd for children with 9>&- or use flock -o."
datetime: 2026-10-20T12:09:29-04:00 # EDT
tags: [flock, lock, file-descriptor, fd-inheritance, daemon, update-lock, bash]
---
2026-10-20: to keep the heal timer away during a manual database swap, the commands ran in `( flock -w 60 9; ...; bin/dune-awakening start ) 9>>runtime/update.lock`. The started postgres, brokers, map server and tools inherited fd 9, so `fuser` showed them all holding the lock after the subshell exited, which would have blocked heal and the next `update apply`. Fix: start children with `9>&-` (or `flock -o LOCK cmd`), then confirm with `fuser LOCK` that nothing holds it afterward.

Also, in that same sequence a failed step did not stop later ones, and `start` brought the world back up on the wrong database. Write such sequences as a script that exits on each failed step.
