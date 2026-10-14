---
description: "Recursive rg/fd/find over the unpacked Dune server images, the Steam directory or the home directory stalls the whole host with iowait; search known small files or use the game-text dump instead."
datetime: 2026-10-13T23:41:19-04:00 # EDT
tags: [performance, iowait, disk, search, ripgrep, fd, operations]
---
On 2026-10-06 two background searches (rg over the unpacked images, fd over the Steam directory) plus a backup drove load to 89 with 80+ processes blocked on I/O; interactive logins hung. Killing the searches restored it at once. For game data use the private string-table dump (state dir `strings/all-build<N>.tsv`), `dune-awakening items find`, or a targeted `retoc to-legacy -f <name>` extraction (it reads only the requested assets). Timebox any search with `timeout` and run it with `nice`/`ionice -c3`.
