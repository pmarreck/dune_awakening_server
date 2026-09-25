# Dune: Awakening Update 1.5 and self-hosted server compatibility

Researched 2026-09-24 (EDT). Every finding carries a source URL and is labeled
**Confirmed** (Funcom statement or machine-readable Steam data), **Community**
(third-party report or code), or **Inference** (my reasoning, not verified).

## Short answers

1. **Has the self-host package been updated for 1.5?** Yes. The PC release of
   Update 1.5 (1.5.3.0) was on 2026-09-17, five days before the 2026-09-22 console
   launch, and the self-host app 4754530 got a 1.5 build the same day. It has been
   updated repeatedly since then. The current public build is 25486303, from
   2026-09-23. Funcom's 1.5.3.4 hotfix notes say that "updated servers receive
   the corrected file".
2. **Can 1.5 clients join 1.4-build servers?** No. Client and server are
   version-locked. A server left on the 1.4 build (24653560) got 1.5 clients
   rejected with `M52 Outdated Client`. The 2026-07-14 hotfix showed the same
   thing within 1.4.
3. **Guidance.** Funcom says the self-host VM checks for updates and applies them
   so the battlegroups are "always compatible with the current Steam client". The
   community advice is to update the server (battlegroup.bat option 5, or a
   steamcmd reinstall/update) every time the client patches, including silent
   hotfixes. Then confirm that the installed `buildid` equals the published one.

## Timeline (all dates 2026, times EDT)

| Date | Event | Label | Source |
|---|---|---|---|
| May 14 20:35 | PTC self-host server app 3104830 last public build (buildid 23243500). It has not been updated since. | Confirmed (Steam API) | https://api.steamcmd.net/v1/info/3104830 |
| May 19 | Self-hosted servers go live (first iteration, "experimental") | Confirmed | https://duneawakening.com/news/self-hosted-servers-now-live/ |
| Jun 2 | Console date announced as Sep 22. "Self-hosted servers are not part of the console release." No PC/console crossplay at launch except Xbox and Windows PC Store. | Confirmed | https://duneawakening.com/news/console-date-and-single-player-announced/ |
| Jul 14 | A client hotfix shows "Outdated game client" and all Experimental (self-hosted) servers become unreachable until the self-host update lands minutes later. Hosts check for `Finished updating battlegroup to version 2036754-0-shipping`. | Community | https://steamcommunity.com/app/1172710/discussions/0/568165880361493359/ |
| Aug 13 | PTC patch 1.5.1.0 posted. No self-host package or compatibility notes in it. | Confirmed | https://duneawakening.com/news/public-test-client-patch-1-5-1-0/ |
| Sep 17 | **Update 1.5 (1.5.3.0) released on PC.** Patch notes published 12:05 UTC. Includes "Private and self-hosted servers can now edit server settings via .ini files and they are properly applied to clients." | Confirmed | https://duneawakening.com/news/dune-awakening-console-release-patch-notes/ |
| Sep 17 ~15:00 | Self-host app 4754530 public build **25351779** published, per a fixture captured from Steam app_info (`timeupdated` 1789671657). The 1.5 client advertised revision 2111270. A server still on 1.4 build 24653560 advertised 2064155 to FLS and was refused, and players saw `M52 Outdated Client`. | Community (pelican egg repo, dated code/changelog) | https://github.com/Sergentval/pelican-egg-dune-awakening/blob/main/scripts/check-game-build.sh , https://github.com/Sergentval/pelican-egg-dune-awakening/blob/main/CHANGELOG.md |
| Sep 19 | Hotfix 1.5.3.1 adds `UserServerCustomSettings.ini` for self-hosted servers ("found in the steamcmd download folder", to be copied into `UserSettings`). The BattlEye-optional launch was added and then disabled again in the same hotfix. | Confirmed | patch notes URL above |
| Sep 20 | Pelican egg PR #131 wires `UserServerCustomSettings.ini` in. The file ships in the depot at `server/scripts/setup/config/`. It has 45 keys, and Funcom ships 6 of them commented out as duplicates of `UserEngine.ini` knobs. | Community | https://github.com/Sergentval/pelican-egg-dune-awakening/pull/131 |
| Sep 21 | Hotfix 1.5.3.2 (no server-admin items). An AMP user on 4754530 **build 25396338** reports that `UserServerCustomSettings.ini` values are not applied even with `DifficultyLevel=Custom`, while `UserGame.ini` edits do work. | Confirmed / Community | patch notes; https://discourse.cubecoders.com/t/configuration-with-dune-awakening-userservercustomsettings-ini-custom-difficulty-values-not-applied/43144 , https://discourse.cubecoders.com/t/dune-awakening-userservercustomsettings-ini-present-in-usersettings-but-values-not-applied-1-5/43145 |
| Sep 22 | Console launch. Hotfix 1.5.3.3 (stability, progression loss, character-tab fixes). No self-host-specific items. | Confirmed | patch notes |
| Sep 23 12:10 / 12:24 | Client app 1172710 public build **25486029**, then self-host 4754530 public build **25486303** 14 minutes later. The self-host app's `timeupdated` is Sep 24 06:58. | Confirmed (Steam API) | https://api.steamcmd.net/v1/info/1172710 , https://api.steamcmd.net/v1/info/4754530 |
| Sep 24 | Hotfix 1.5.3.4 notes: "Fixed an issue where custom settings in ServerCustomSettings.ini on self-hosted servers were not applied because the file was missing DifficultyLevel=Custom. We also made sure updated servers receive the corrected file." Also: "Unblocked characters who were stuck after cross-realm transfers on private servers" and a fix for backed-up base origin markers being offset after a server restart. Page `dateModified` is 2026-09-24T11:02 UTC. | Confirmed | patch notes |
| Sep 24 | Funcom Known Issues page updated. It lists no self-host entries. | Confirmed | https://funcom.helpshift.com/hc/en/4-dune-awakening/faq/88-known-issues/ |

Inference: the Sep 23 build pair (client 25486029, server 25486303) is most
likely hotfix 1.5.3.4, with notes posted the next morning. The local image
tag `2124138-0-shipping` belongs to that build. The progression 2064155 (1.4
server) → 2111270 (1.5.3.0 client) → 2124138 (current) fits, but I have not seen
Funcom publish a mapping from revision to patch version.

## Client/server compatibility rules

- **Confirmed (Funcom):** the self-host VM "will be checking for updates,
  download and apply them to the battlegroups, so they're always compatible with
  the current Steam client." Funcom does not describe any cross-version
  tolerance.
  https://funcom.helpshift.com/hc/en/4-dune-awakening/faq/85-how-to-self-host-a-world-1778514422/
- **Community (strong):** the server advertises a game revision (the number in
  the `NNNNNNN-0-shipping` image tag) to Funcom's FLS/directory. A client on a
  different revision refuses the connection with `M52 Outdated Client`, or the
  server simply does not appear in the Experimental list. Two independent
  incidents (Jul 14 and Sep 17) show this. Sources: pelican egg
  `check-game-build.sh` and the Steam thread above.
- **Inference:** treat compatibility as an exact revision match, including for
  silent hotfixes that come with no patch notes. There is no evidence of a
  major/minor compatibility window. A 1.4 server cannot serve 1.5 clients.
- **Confirmed:** self-hosted servers are PC-only. Console players cannot join
  them.
- **Confirmed (1.5 character portability):** self-hosted characters can move
  between self-hosted servers. Official and private-server characters can move
  to self-hosted servers but can never come back. Single-player characters stay
  in single-player.
- **Community pitfall:** steamcmd can wedge with appmanifest `StateFlags "6"`.
  The update then reports "already up to date" while `buildid` differs from
  `TargetBuildID`, and the server silently falls behind the client.
  https://gamer-net.com/dune-awakening-server-not-showing/

## Known 1.5 self-host breakage and fixes

- **1.4-build servers were unreachable after Sep 17** until updated (M52). The
  fix is to update to the 1.5 build. (Community)
- **Custom settings file not applied** (`UserServerCustomSettings.ini` /
  `ServerCustomSettings.ini` missing `DifficultyLevel=Custom`). Reported Sep 21,
  and Funcom says 1.5.3.4 fixes it and pushes the corrected file to updated
  servers. (Confirmed fix; not yet independently verified.) Third-party
  launchers that seed configs themselves (AMP, pelican egg, possibly DASH) have
  to wire the new file in explicitly.
- **Stuck characters after cross-realm transfers on private servers.** Fixed in
  1.5.3.4. (Confirmed)
- **Backed-up base origin marker offset after a server restart.** Fixed in
  1.5.3.4. (Confirmed)
- **Duplicate player-state rows in the DB.** The pelican egg fixed "players
  reads the decrypted view again, and stops seeing double (#121)" on Sep 20.
  DASH documents a "post-1.5 schema" in which
  `encrypted_player_state.account_id` is no longer unique
  (https://github.com/snapetech/DuneAwakeningSelfHost/blob/main/docs/player-identity-integrity.md).
  Caveat: that DASH text was committed on **2026-07-17**, two months before
  Update 1.5, so its "1.5" label cannot refer to the Sep 17 game release. It may
  mean an internal schema version or the 1.5 PTC. (Community; label ambiguous)
- **DASH is behind.** Its newest image-tag reference is `2036754-0-shipping`,
  the July 1.4 build. Its only Sep commit (2026-09-21, `b3a26c1`) is a CI and
  screenshot fix. It has no 1.5 image pin, no mention of
  `UserServerCustomSettings.ini`, and no open issues (issue creation is
  restricted). (Confirmed from repo contents)

## Open questions

- Why PTC self-host app 3104830 has not been updated since 2026-05-14 even
  though PTC 1.5.1.0 ran in August. Possibly PTC self-hosting was quietly
  abandoned. Unverified.
- Whether a server can be deliberately held on an older build for a mixed
  fleet. All evidence says no.
- SteamDB (steamdb.info) returned 403 to automated fetches, so its full
  patch-history list for 4754530 was not read. The build list above comes from
  the steamcmd API plus third-party fixtures.
- I could not reach Reddit (r/duneawakening) or Funcom's Discord.

## URLs to watch (for a periodic watcher)

| URL | What to look for |
|---|---|
| https://api.steamcmd.net/v1/info/4754530 | `data."4754530".depots.branches.public.buildid` and `timebuildupdated`. The primary signal: a new server build means update now. |
| https://api.steamcmd.net/v1/info/1172710 | Client `branches.public.buildid`. If the client moves and 4754530 does not follow within about an hour, expect M52 lockouts. |
| https://api.steamcmd.net/v1/info/3104830 | PTC self-host server build. Any movement signals a new PTC cycle (a preview of the next server changes). |
| https://steamdb.info/app/4754530/patchnotes/ and https://steamdb.info/app/4754530/depots/ | Human-readable build history (needs a browser; blocks bots). |
| https://duneawakening.com/news/dune-awakening-console-release-patch-notes/ | `article:modified_time` meta. New "Hotfix 1.5.3.x" sections. Lines mentioning self-hosted, private server, ini, steamcmd, battlegroup. |
| https://duneawakening.com/news/category/patch-notes/ | New patch-note posts (1.5.4+, 1.6 PTC). |
| https://funcom.helpshift.com/hc/en/4-dune-awakening/faq/88-known-issues/ | "Last Updated" date. Any server, self-host or transfer entries. |
| https://funcom.helpshift.com/hc/en/4-dune-awakening/faq/85-how-to-self-host-a-world-1778514422/ | Changes to the update procedure, Linux support, new config files. |
| https://funcom.helpshift.com/hc/en/4-dune-awakening/faq/84-self-hosting-requirements-faq/ | Linux or cloud support status, requirement changes. |
| https://duneawakening.com/self-hosted-servers/ | Official setup page revisions (battlegroup.bat options, ports). |
| https://steamcommunity.com/app/1172710/discussions/ | New threads with "Outdated", "M52", "self-hosted", "experimental servers" in the title right after a client build change. |
| https://github.com/Sergentval/pelican-egg-dune-awakening (commits, CHANGELOG.md, issues) | The fastest-moving Linux self-host project, and it records build IDs and revisions in its code. Watch `scripts/check-game-build.sh` and the CHANGELOG for new build numbers or breakages. |
| https://github.com/snapetech/DuneAwakeningSelfHost (commits; `.env.example` `DUNE_IMAGE_TAG`) | A 1.5 image pin (a tag at or above 2111270) and `UserServerCustomSettings` support. Neither is present yet. |
| https://discourse.cubecoders.com/tag/dune-awakening (and threads 43144, 43145) | AMP-side breakage reports tied to specific 4754530 build IDs. |
| https://github.com/Icehunter/dune-admin | Admin-tool schema-compat changes after server builds. |
| https://awakening.wiki/Self-Hosted_Server_Guide | Last-edited date (2026-09-07 as of this writing). Still has no 1.5 content. |
