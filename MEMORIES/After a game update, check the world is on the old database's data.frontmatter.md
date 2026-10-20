---
description: "The game database name follows the payload version (dune_sb_1_5_3_0 -> dune_sb_1_5_15_0), so a game update can start the world on an empty database; after any update compare character counts, and dune-db-setup now carries the old database over."
datetime: 2026-10-20T12:09:29-04:00 # EDT
tags: [database, postgres, update, version, dune-sb, empty-world, characters, migration]
---
2026-10-20: build 26051014 changed perforce-keywords.json from sb-1.5.3.0 to sb-1.5.15.0. Every service derives the database name from it, so after `update apply` the world ran on a freshly created `dune_sb_1_5_15_0` (0 accounts) while the real data sat in `dune_sb_1_5_3_0`. The first symptom was an empty `character list`. Fixed by stopping the world, keeping postgres up, and renaming the empty DB aside and the old one into place; start then applied the 10 new patches.

After any update, check `character list` is not empty. Funcom's own template pins `gameDatabaseName: dune` with `dynamicDatabaseName: "false"`; this project instead renames the one older `dune_sb_<version>` database in `dune-db-setup`.
