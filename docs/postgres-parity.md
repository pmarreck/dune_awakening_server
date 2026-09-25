# Funcom igw-postgres vs our nixpkgs PostgreSQL

The goal is that every difference between Funcom's PostgreSQL and ours is known and documented. Evidence comes from the unpacked official image `igw-postgres:17.4-alpine-fc-13` (`images/prerequisites/igw-postgres.tar`, Steam build 25486303) and from the pinned flake's `postgresql_17`.

"Funcom's fork" is not a source fork. The image is the stock Docker Hub `postgres:17.4-alpine` recipe plus barman and an AWS config ([research/image-internals.md](research/image-internals.md) §4). No PostgreSQL source patches or extra extensions were found.

| Aspect | Funcom igw-postgres | Ours (`libexec/dune-postgres`) | Impact / decision |
|---|---|---|---|
| Version | 17.4 | 17.10 (nixpkgs `c0a89c37`) | Same major version, so the on-disk format and `pg_dump` compatibility hold. 17.10 carries upstream bug and security fixes. |
| libc | musl (Alpine 3.21.3) | glibc 2.42 | Affects locale behavior only; see the locale row. |
| Build flags | `--with-icu --with-llvm --with-lz4 --with-zstd --with-openssl --with-libxml --with-libxslt --with-gssapi --with-ldap --with-perl --with-python --with-tcl --with-uuid=e2fs --enable-tap-tests` | Same set, minus `libxslt`, `ldap` and `tap-tests`, plus `--with-systemd --with-pam --enable-debug` | None for the game: it uses no LDAP, XSLT or PAM. Debug symbols only. |
| Extensions shipped | 59 `.control` files | 45 in the main output | The 14 extra are PL languages and their transforms (plperl, plpython3u, pltcl, `*_plperl`, `*_plpython3u`). nixpkgs ships those separately. The Funcom schema uses only `pgcrypto` and `pg_trgm`, in schema `ext`, and both are present (tested). |
| Locale / encoding | Docker entrypoint `initdb` with `LANG=en_US.utf8` on musl, so UTF8 encoding, codepoint collation (musl `strcoll` is `strcmp`) and Unicode case mapping | `initdb --encoding=UTF8 --locale=C --locale-provider=builtin --builtin-locale=C.UTF-8` (PostgreSQL 17 builtin provider) | **Matched deliberately.** Codepoint collation plus Unicode `upper()`/`lower()`/`ILIKE`. The game DB inherits it: `datlocprovider=b`, `datlocale=C.UTF-8`, UTF8, asserted in `tests/integration/postgres` and `tests/payload/db-setup`. Plain `C` would have folded case for ASCII only. The libc `lc_collate`/`lc_ctype` are `C`, used only for `lc_messages`/`lc_monetary` formatting. |
| Timezone data | Alpine `/usr/share/zoneinfo` | nixpkgs tzdata 2026b | Newer tzdata. The server timezone defaults to UTC in both [I: Docker image default]. |
| Runtime config | The operator mounts `/etc/postgres/postgres.conf` (absent from the image; contents unknown). Image sample: `listen_addresses='*'` | Stock defaults plus `listen_addresses='127.0.0.1'`, socket in the data dir, scram-sha-256 | Tuning such as `shared_buffers` is unknown for Funcom and default for us. [GAP] Measure under load before tuning. Listening only on loopback is intentional. |
| Auth | Operator-generated passwords in the world spec (plaintext) | 32-char generated passwords in `secrets/` (0600), scram-sha-256 | Stricter. |
| Backups | barman 3.x to S3 via `backup-restore.sh` and an AWS config | Not used. `pg_dump` / Funcom `dumpdb.py` path planned | [GAP] Backup and restore design is still to do. |
| Port | 5432 in the container; the game default is `localhost:15431` (`BaseGame.ini`) | 15431 in production | Matches the game default. |
| Superuser / DB user | `postgres` / `dune` | `postgres` / `dune` | Same. |

Open verification: when the game runs, compare `SHOW ALL` against expectations and watch for any error that points at a missing extension or setting.
