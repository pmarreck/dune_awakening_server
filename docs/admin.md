# Administering the world

One place for every way to administer this world: commands run on the host, in-game chat commands for trusted players (the GM bridge), and the game's own in-game GM system. `dune` is short for `dune-awakening` (see the README). The host commands need a shell on the host with the private config; the chat commands need only a line in the operator's `gm_bridge.conf`. In-game privileges (User, PowerTester, GM, Admin) are the game's own, described in the last section.

Evidence labels: **verified** means observed on this world; **inferred** means read from the binaries or configs but not exercised.

## Commands from the host (`dune world`, `dune character`)

The map server starts with Funcom's server-command channel on: `dune-server` writes a generated `ServerCommandsAuthToken` (kept in `runtime/secrets/server_commands_token`, 0600) and `server.NotificationSystem.Enabled=true` into its private `Engine.ini`. `dune-live` wraps a command in Funcom's Version 2 envelope and has the game RabbitMQ node publish it (exchange `heartbeats`, routing key `notifications`, user `fls`, app `fls_backend`); the envelope travels through a 0600 file, never a command line. Commands are grouped by what they act on: `world` for the whole world, `character` for one character (the character tool hands its live subcommands to `dune-live`). Players are named by character; the tool resolves their FLS id (`accounts.user`, 16 hex digits), which is what the server-command channel's `PlayerId` takes. The Funcom id (name#number) is accepted and logged but silently does nothing (verified in game, 2026-09-26).

```bash
dune-awakening world say "Restart in 5 minutes" --duration 30
dune-awakening world kick-all
dune-awakening world exec t.MaxFPS 5            # world-level engine command or variable (ServerExec)
dune-awakening world partitions
dune-awakening world raw <ServerCommand> [--player P] [Key=value[:int|:float]...]
dune-awakening character list                   # ● online / ○ offline, Intel, skill points
dune-awakening character move <player> [to] <target>
dune-awakening character move <player> X Y Z [--partition LABEL|ID]
dune-awakening character where <player>
dune-awakening character kick <player>
dune-awakening character water <player> 5000
dune-awakening character xp <player> 1000 [Combat|Crafting|Gathering|Exploration|Sabotage]
dune-awakening character whisper <player> "message" [--from NAME]
dune-awakening character give <player> ITEM [COUNT]   # e.g. give Alice HarkAr2
dune-awakening character worm <player>          # experimental: SandwormTargetPlayer in the player's context
```

The server logs each command: `LogDuneServerCommands: Now running ServerCommand '…'`, or `unknown Server Command '…'` for names it does not implement. Verified live on build 2124138: `ServiceBroadcast` and `ServerExec` run; `ServerExec` changes engine variables at runtime (`t.MaxFPS 5` cut the map server from 32% to 11% of a core, `t.MaxFPS 0` restored it), but console output is not returned. Cheat-manager names (`SandwormTargetPlayer`, `PrintNumPlayers`, ...) are not server commands in their own right.

### Giving items

`dune-awakening character give <player> ITEM [COUNT]` sends Funcom's `AddItemToInventory` server command (fields `PlayerId`, `ItemName`, `Quantity`); the player must be online, and the item appears in their inventory at once (verified in game with `HarkAr2`, 2026-09-26). The server logs `Now running ServerCommand 'AddItemToInventory'`; for an item id it does not know it adds `LogCheatManager: Warning: Cannot find item associated with spawn command <ID>` (**verified** on this world), so grep the server log after a give. The command itself reports success either way.

A full inventory appears to lose given items silently (not yet confirmed), so have the player free some space first.

Item ids are the row names of the game's item tables (`DT_BaseItems_*` in the cooked content). Some verified or read from those tables:

| Item id | What it is |
|---|---|
| `HarkAr2` | Karpov 38 rifle, light darts (**verified** in game) |
| `HarkAr1` … `HarkAr7` | the same rifle line by tier (read from the tables; icons `Wpn2HHarkRifle01_T1…T6`) |
| `SmugDmr1` … `SmugDmr6` | marksman rifles |
| `Ammo` | light darts (icon `LightDartAmmo`) |
| `HeavyAmmo` | heavy darts |
| `SandbikeChassis_1` | sandbike chassis (vehicle part ids carry a tier suffix, `_1` here) |
| `SandbikeEngine_1` | sandbike engine |
| `SandbikeGenerator_1` | sandbike power supply (PSU) |
| `SandbikeHull_1` | sandbike hull |
| `SandbikeLocomotion_1` | sandbike treads; a sandbike takes 3 or 4 (unconfirmed) |
| `SandbikeInventory_1` | sandbike storage |
| `FuelCanister_Large`, `FuelCanister_Medium`, `FuelCanister` | vehicle fuel (**verified**: a large canister refuelled a sandbike) |
| `FremenComponent1` | EMF Generator, the one crafting recipes accept (**verified**: the Survey Probe Launcher recipe took it) |
| `D_FremenComponent3` | also shown as "EMF Generator", but recipes reject it; do not use |
| `SolarisCoin` | Solari, the currency (**verified**: 5000 in one give arrived at once) |

`SandbikeBoost_1` does not exist.

A display name is not an item id, and two items can share one. The id a recipe wants is in the crafting table, `DT_ItemsCraftingRecipes`: convert it with `retoc to-legacy -f DT_ItemsCraftingRecipes`, then read the recipe's ingredient names from its name map. Display names live in `ST_Localization_Items`, keyed like `ITEMS/RESOURCE_FREMENCOMPONENT3_NAME`, but that key's number need not match the item id's.

`ServerExec "AddItemToInventory …"` does not work: `ServerExec` runs at world level, with no player to receive the item.

### Moving and messaging players

`dune-awakening character where <player>` prints a character's partition, map and X Y Z; `dune-awakening world partitions` lists the partitions. Both read the tables directly, because Funcom's own `admin_get_character_details` and `admin_get_partitions` refer to objects that no longer exist in 1.5.

`dune-awakening character move` works whether the player is online or not; Funcom's `is_player_offline` decides (it also counts a player whose server is gone as offline, so a stuck player can be rescued).

- `move <player> X Y Z`: online, the server's `TeleportTo` (same partition only); offline, a `pre-move` backup and then Funcom's `admin_move_offline_player_to_partition`, where `--partition LABEL|ID` may also change partition (default: the current one).
- `move <player> [to] <target>`: both online, the game's own `TeleportToPlayer <target>` console command run in the player's context, so the server chooses the landing spot; player offline, the offline move onto the target's last saved spot (ground a character stood on), after a backup. An online player is not sent to an offline target, whose body is not in the world.

An online character cannot be moved in the database: the map server holds it in memory, is authoritative for it and writes it back on its own schedule, so Funcom's procedure refuses with "Player must be Offline" (its Director depends on that text).

`dune-awakening character whisper <player> <message> [--from NAME]` sends a private chat line that the player sees in purple in their Private and All chat tabs as `To [NAME]: <message>` (NAME defaults to `Admin`; the GM bridge uses `GM`). **Verified in game on 2026-09-28** (build 1.5.3.4). It is a `TextChat` courier with channel `Whispers`, published to exchange `chat.whispers` with the player's FLS id as routing key, bound for the call to their own `<FLS id>_queue`. That queue exists only while they are online, so an offline player gets an error. A binding the game made itself is left in place.

#### How chat lines render (found by trial, 2026-09-28)

The format DASH documented (a spoofed sender name, `m_TimeStamp`) arrived but rendered as an empty `[]:` on this build. Sending labelled variants to a player and asking what appeared established:

- **The sender's name comes from the AMQP `user_id` property,** which the client looks up among known players. The name fields inside the message (`m_SpoofedUserNameFrom`, `m_FuncomIdFrom`) are not what it shows: an exact copy of a player's own real message showed `[]:` until `user_id` was added, and then showed `[TheirName]:`.
- **A line whose `user_id` is not a known player is dropped** (`GM`, `GM#00001`: nothing appeared). So a made-up sender such as "GM" cannot be shown as the sender.
- **Without `user_id`,** Proximity lines show their text after an empty `[]:`, and Whispers lines show `[]:` with no text at all.
- **With the recipient's own id as `user_id`,** a Whispers line renders as their own outgoing whisper, `To [<m_UserNameTo>]: <message>`, in purple. `m_UserNameTo` is shown as written, so it carries the label. That is the format `whisper` uses: private, clearly marked, and needing no second account.
- The timestamp field's spelling (`m_Timestamp` or `m_TimeStamp`) made no difference once `user_id` was set. `whisper` uses `m_Timestamp`, the spelling the game itself sends.
- Proximity chat does not travel to other players over RabbitMQ: the TextRouter republishes it to `chat.proximity`, and the map server distributes it in game. Only whispers go to players' `<FLS id>_queue` directly.

How to repeat such an experiment: RabbitMQ's firehose (`dune-rabbitmq ctl game trace_on`, with a queue bound to `amq.rabbitmq.trace` with `publish.#`) copies every publish, including the TextRouter's, to show what the game itself sends; turn it off (`trace_off`) and delete the queue afterwards, because it copies all chat.

### Timeout (a break without logging off)

`dune-awakening world timeout on` (also `bio-break`, `call-timeout`, `safety-first`) records the current values of four world-level console variables, sets them off, verifies each change in the map server's log, and broadcasts it: `Dac.DamageEnabled` (all damage), `sandworm.dune.Enabled`, `Sandstorm.Enabled`, `Coriolis.Enabled`. `timeout off` restores the recorded values (kept in `runtime/timeout.state`), so a hazard you had disabled on purpose stays disabled. `timeout status` reads the live value.

Why not a real pause: the engine drops a connection after 60 s without traffic (`ConnectionTimeout=60.0` in the shipped `DefaultEngine.ini`, keepalive every 0.2 s), so freezing the server process would disconnect everyone after a minute, and Funcom's server commands include no pause or time-dilation command (`PauseServer` and `SetTimeDilation` are rejected as unknown). Verified on the server: the four variables exist, are settable at runtime, and read back as changed. Not yet verified in game: whether no damage also covers thirst and heat.

## In-game chat commands (the GM bridge)

A trusted player can run a few admin commands from game chat, without host access: they type `&goto Alice` in any chat channel, and `dune-gm-bridge` runs the matching `dune-live` command on the host and whispers the result back (shown as coming from `GM`). It exists because the game's own Admin Panel cannot be opened in the shipping client (see below). **Verified** against a real RabbitMQ 4.2.5 game broker in `tests/integration/gm-bridge`; **not yet verified in game**.

| Command | Does |
|---|---|
| `&help` | lists the commands you may use |
| `&where` | your position, X Y Z rounded (from the chat message itself; no side effects) |
| `&goto <player>` | moves you to the player (`character move <you> to <player>`) |
| `&bring <player>` | moves the player to you |
| `&say <message>` | on-screen broadcast to everyone (`world say`) |
| `&timeout on\|off\|status` | the break for everyone (`world timeout`) |
| `&give <item id> [count]` | puts up to 1000 of an item into your own inventory (`character give`; ids above) |
| `&kick <player>` | disconnects a player |

To enable it, write `gm_bridge.conf` in the config directory (template: `config.sample/gm_bridge.conf.sample`) and `chmod 600` it. One line per player, `<character name or FLS id>: <command>...`, or `<who>: *` for every command; `#` starts a comment. An entry of 16 hex digits is an FLS id and matches that account only; `dune-awakening character whois <FLS id>` names the character of an id. The file is read for every command, so edits apply at once; `dune-awakening doctor` fails if others can read or write it.

```
# ~/.config/dune_awakening_server/gm_bridge.conf
Alice: *
0123456789ABCDEF: where goto bring
```

The bridge runs as a world component (`dune-awakening start` starts it last, `stop` stops it first, `status` lists it); its log is `runtime/gm-bridge/gm-bridge.log` (0600).

How it works and why it is safe to run:

- **What it sees.** The game client publishes every chat message to the game broker's topic exchange `chat.intercept`, bound with `#` to `queue.intercept`, which Funcom's TextRouter consumes (**verified** with a probe queue, 2026-09-27). The bridge binds its own exclusive, auto-deleted queue `gm.bridge.chat` to the same exchange with `#`, so it receives a copy of every message and chat itself is unaffected.
- **Who sent it.** A message's routing key and its JSON (`m_FuncomIdFrom`) carry the sender's Funcom id, but the client writes those, so the bridge ignores them. It trusts only the AMQP `user_id` property: RabbitMQ refuses a publish whose `user_id` differs from the connection's authenticated user, which for a player is their FLS id. Messages without a well-formed `user_id` are dropped. The id is turned into a character name with `dune-live character whois`.
- **Fail closed.** No `gm_bridge.conf`, an empty one, or a sender not listed: every `&` command is refused with a whispered `not allowed`. Unknown commands and malformed lines grant nothing. An account with no character gets no reply.
- **Privacy.** The bridge sees all chat but logs only `&` commands (sender id, character name, allowed or denied, the command line). Other chat is dropped without a trace.
- **No shell.** Each command becomes a fixed `dune-live` argument list; player text (a `say` message, a player name) is passed as a single quoted argument and never interpreted by a shell. Arguments starting with `-` are refused, since `dune-live` would read them as its own options.
- **Broker account.** The bridge connects as `gm_bridge`, a user in the game broker's internal database that `dune-rabbitmq` creates at boot from the 0600 `rabbitmq.conf` (`default_user`), so no `guest` user exists and the password (`runtime/secrets/gm_bridge_rmq_password`, generated once) never appears on a command line. It is loopback-only (`loopback_users`) and connects to a plain-AMQP listener bound to `127.0.0.1` (`DUNE_RMQ_GAME_LOCAL_PORT`, default 5674); players keep using TLS on 31982. The internal backend is tried before the TextRouter's HTTP backend, so the bridge does not depend on the TextRouter, and players, who are not in the internal database, still authenticate through it. Its permissions: configure and write only `^gm\.bridge\..*`, read `^(gm\.bridge\..*|chat\.intercept)$`; the tests confirm it cannot touch a player's `<FLS id>_queue` or bind to `chat.whispers`. RabbitMQ 4.2.5 swaps `default_permissions.read` and `.write` when it seeds the user, so the config sets them crosswise; the broker test fails if a RabbitMQ update changes that.
- **Reconnects.** When the broker goes away (a restart, a dropped connection) the bridge retries with backoff up to 30 s, logging each distinct error once.

A world whose game broker was started before this listener existed keeps refusing the bridge's connection (logged once) until its next restart.

## The game's own GM system

### How it works (from the server binary and Funcom's configs)

- Privileges: `EDunePrivileges` has User, PowerTester, GM and Admin (`DunePrivilege_*`, `UPlayerPrivilegeComponent`, `m_AuthenticatedPrivileges`).
- Configuration: section `[AdminSetting.Global]` in `Game.ini`. Keys are built at runtime as `Password_%s` (one password per privilege) and `Allowed_%s_Commands` (a command allow-list per privilege); `Allowed_Commands` applies to everyone.
- Funcom's `DefaultGame.ini` gives everyone `AdminLogin`, `PrintAllowedCommands`, `suicide` and the bug-report commands, and sets **`Password_Admin=sardaukar`**, a public default. `DedicatedServerGame.ini` adds 24 `Allowed_GM_Commands`: AddItemToInventory, AddBasicInventoryToCharacter, SpawnVehicle, PatrolShipTeleportToNearest, TeleportTo, TeleportToMap, TeleportToExact, TeleportToPlayer, TeleportToVehicleSpawner, TeleportToSandworm, TeleportToPersonalMarker, TravelTo, TravelToDimension, Fly, Ghost, Walk, DestroyTargetVehicle, DestroyTotem, DestroyPlaceable, DestroyEntireBuilding, DestroyBuildingPiece, PrintPos and two buried-treasure debug commands.
- Logging in: `AdminLogin <password>` (`ADunePlayerControllerBase::AdminLogin`) grants the privilege whose password matches; the server answers with `FAdminLoginResponse`.

### What this project changes

`dune-server` writes two generated passwords into the map server's private `Saved/Config/LinuxServer/Game.ini` (the file it already reads its database password from):

- `Password_Admin`, replacing Funcom's public default. For the host operator.
- `Password_GM`, for a trusted player who should have GM powers without host access. Their allow-list is Funcom's `Allowed_GM_Commands` minus the Destroy* commands and `AddItemToInventory`, removed with `-Allowed_GM_Commands=…` entries. A payload-tier test (`tests/payload/gm-allowlist`) fails if Funcom renames any of those, because a removal of a missing name would silently leave the real command allowed.

Both are typeable Dune passphrases (`word-word-word-NN`, e.g. `sietch-thumper-kynes-42`): three distinct words from a 65-word list shuffled by `random --true-random`, plus a number from 10 to 99, about 25 bits. That suits a world reachable only over Tailscale; on the open internet, use long random passwords instead. They live in `runtime/secrets/admin_password` and `runtime/secrets/gm_password` (0600). To read one: `cat ~/.local/share/dune_awakening_server/runtime/secrets/gm_password`. To change one, move the file to the trash and restart the world; a new one is generated. That the game accepts them is **inferred** until someone logs in with the Admin Panel.

### Getting to it from the client

- **Console:** the configs bind the Unreal console to `~` and `Insert`, but the console is compiled out of the shipping client, so neither key does anything (**verified**: `OpenConsoleCommand` has an empty body, see below, and no key opened it in game).
- **Admin Panel:** the game has one. `UAdminPanelWidget` (`W_AdminPanel`) has a password box (`m_AdminLoginEditableTextBox`, `OnClickAdminLogin`), a teleport-to-player box, a teleport map (`W_Admin_TeleportMap`) and cheat buttons. Two entry points exist in the code, and both are empty in the shipping client (see below):
  - `OpenAdminPanel` sits among menu and HUD handlers in the binary's names, so an Escape-menu button is possible.
  - `ToggleAdminPanel` sits among cheat-manager console commands, so it is probably console-only.
- **The key: Home.** The game's general input mapping context (`/Game/Dune/Input/General/IMC_General`) binds the input action **`IA_AdminPanel` to the Home key** (**verified** in the server's copy of the cooked assets; to be confirmed against the client's copy and in game). The same asset confirms the ordinary bindings (I inventory, M map, J journey, Tab player menu, E interact, Enter chat, B crafting, K skills, Y tech tree, L Landsraad, O guild, P social, U customization, N Communinet) and shows the developer ones: End toggles the UI, Delete is `IA_KillNPC`, F6 frame capture, F8 QA bug report, F9 cinematic camera. The panel may still check privileges before it opens; its login box suggests it opens first and asks for the password.

To try in game: press **Home**. Compact keyboards without a Home key usually have it on **Fn+PgUp** (with End on Fn+PgDn and Insert on Fn+Del); the binding is fixed, not rebindable in the game's settings (only player-mappable actions carry a `KB_MKB_*` settings name, and this one has none), so a keyboard driver or PowerToys remap is the other way. If the Admin Panel opens, enter the password from `runtime/secrets/admin_password` in its login box, then try its teleport-to-player box. Record what happens here.

How the key was found (repeatable after game updates): build [retoc](https://github.com/trumank/retoc) in a scratch directory with `nix-shell -p cargo rustc pkg-config openssl --run 'cargo build --release'` (not part of the flake). Its Oodle loader fetches `liboo2corelinux64.so.9` and checks a pinned SHA-256; on NixOS run retoc with `LD_LIBRARY_PATH` pointing at nixpkgs `stdenv.cc.cc.lib` for `libstdc++`. `retoc to-legacy --no-shaders -f IMC_General -f IA_AdminPanel Content/Paks OUT` converts the two assets. In the legacy `IMC_General.uexp`, each mapping stores its `Action` as an import index; `IA_AdminPanel` is import -12, and the `Key` struct after it holds a `KeyName` `NameProperty` whose value is the key's name (`Home`).

### Why Home did nothing (2026-09-26)

Pressing Home (Fn+PgUp) on the first test did not open anything, and the configured console keys do nothing in the shipping client. What the game files show (client build fetched through Steam, server build 2124138):

- **The binding is the same in the client.** The client's `IMC_General` and `IA_AdminPanel` are byte-identical to the server's; Home is bound to `IA_AdminPanel` (**verified**). The same mapping context holds the everyday bindings (I, M, Tab, E), so it is active in game.
- **The panel is meant to open before you are an admin.** `W_AdminPanel` has an `m_AdminCheckWidgetSwitcher` that switches between a login page (`m_AdminLoginEditableTextBox`, a show-password toggle, a "Login As" combo box for the privilege level, `m_AdminLoginButton`) and the cheat tabs (Player, Items, Spawns, Sandworm, Time and Weather, NPCs, Skills, Contracts, Landsraad, Spice, Audio, UI, Server). `W_EscapeMenu` also has an Admin button (`m_AdminButton` in `OpenAdminPanelHBox`) whose visibility is switched at runtime.
- **Privileges are server-granted and replicated.** The client carries `m_AuthenticatedPrivileges` with `OnRep_AuthenticatedPrivileges`, `GetAuthenticatedPrivileges` and `HasAdminPrivileges_FromController`; the server side has `UPlayerPrivilegeComponent`, `SetAuthenticatedPrivileges`, and `FDuneAdministrationSettings` (`m_AdminPasswords`, `m_bRequiresAdminPassword`), which sits next to the replicated server custom settings.
- **A hidden switch.** Disassembling the server's config reader (x86-64, around `0xdd3cd20` in `DuneSandboxServer-Linux-Shipping`) shows it read `[AdminSetting.Global]` in this order: a boolean **`RequiresAdminPassword`** into the administration settings, then `Password_<Privilege>` for each `EDunePrivileges` value into `m_AdminPasswords`. Funcom's configs never set `RequiresAdminPassword`, so it takes its compiled-in default. The call targets are inferred from the shape of Unreal's config API, not from symbols.

`dune-server` writes `RequiresAdminPassword=True` because of that switch. It is harmless (both privilege levels already have private passwords), but it did not help: after it, no key opened anything on a Windows client, and the server log showed no admin login attempt.

**Conclusion: the shipping client cannot open the Admin Panel (verified statically, 2026-09-26).** Unreal's generated reflection tables pair each native `UFUNCTION` name with its exec thunk. In `DuneSandbox-Win64-Shipping.exe`:

- the Escape menu's `OpenAdminPanel` and `OpenConsoleCommand` both point at the same thunk (`0x1412cf520`), which only advances the script bytecode pointer (`P_FINISH`) and calls nothing. Their neighbours (`OpenLeaveGameDialog`, `OpenRespawnDialog`, …) each have their own thunk.
- the cheat manager's `ToggleAdminPanel` points at the same empty thunk, as does `ToggleAlignmentDebugUI`.

So both entry points were compiled out of the shipping build, the same way as the console. The widget's own code (`UAdminPanelWidget`) is still in the binary, but nothing reachable opens it. The client's chat has no slash-command handling either. The GM passwords stay configured, since they cost nothing and would work if Funcom ever enables the panel.

How to repeat the check after a client update: find the file offsets of the ASCII names (`strings -t x`), convert them to virtual addresses with the section table (`objdump -h`), search the binary for 8-byte pointers to those addresses, and read the qword after each hit. Two tables hold the names: one pairs a name with its `Z_Construct_UFunction_*` builder, the other with its exec thunk. A thunk shared by several unrelated functions that only touches `[rdx+0x20]` is an empty body.

### Other routes considered

- `-ExecCmds="AdminLogin …"` as a Steam launch option is suggested in community notes but unverified; it would run before any server connection exists.
- A chat-command listener (DASH does this): a player types `&goto Alice` and a host process runs the matching `dune` command. With the Admin Panel unreachable, this is the remaining in-game route for a trusted player; this project now has one, the GM bridge (see "In-game chat commands" above).
- Sources: [Funcom's self-host FAQ](https://funcom.helpshift.com/hc/en/4-dune-awakening/faq/85-how-to-self-host-a-world-1778514422/), [DASH admin-gm-console.md](https://github.com/snapetech/DuneAwakeningSelfHost/blob/main/docs/admin-gm-console.md), [dune-awakening-truenas ADMIN-COMMANDS.md](https://github.com/Icehunter/dune-awakening-truenas/blob/main/ADMIN-COMMANDS.md), and [research/live-world-control.md](research/live-world-control.md).
