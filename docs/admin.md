# Administering the world

One place for every way to administer this world: commands run on the host, and the game's own in-game GM system. `dune` is short for `dune-awakening` (see the README). Everything here needs a shell on the host with the private config; there is no weaker tier. In-game privileges (User, PowerTester, GM, Admin) are the game's own, described in the last section.

Evidence labels: **verified** means observed on this world; **inferred** means read from the binaries or configs but not exercised.

## Commands from the host (`dune world`, `dune character`)

The map server starts with Funcom's server-command channel on: `dune-server` writes a generated `ServerCommandsAuthToken` (kept in `runtime/secrets/server_commands_token`, 0600) and `server.NotificationSystem.Enabled=true` into its private `Engine.ini`. `dune-live` wraps a command in Funcom's Version 2 envelope and has the game RabbitMQ node publish it (exchange `heartbeats`, routing key `notifications`, user `fls`, app `fls_backend`); the envelope travels through a 0600 file, never a command line. Commands are grouped by what they act on: `world` for the whole world, `character` for one character (the character tool hands its live subcommands to `dune-live`). Players are named by character; the tool resolves their Funcom id.

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
dune-awakening character worm <player>          # experimental: SandwormTargetPlayer in the player's context
```

The server logs each command: `LogDuneServerCommands: Now running ServerCommand '…'`, or `unknown Server Command '…'` for names it does not implement. Verified live on build 2124138: `ServiceBroadcast` and `ServerExec` run; `ServerExec` changes engine variables at runtime (`t.MaxFPS 5` cut the map server from 32% to 11% of a core, `t.MaxFPS 0` restored it), but console output is not returned. Cheat-manager names (`SandwormTargetPlayer`, `PrintNumPlayers`, ...) are not server commands in their own right.

### Moving and messaging players

`dune-awakening character where <player>` prints a character's partition, map and X Y Z; `dune-awakening world partitions` lists the partitions. Both read the tables directly, because Funcom's own `admin_get_character_details` and `admin_get_partitions` refer to objects that no longer exist in 1.5.

`dune-awakening character move` works whether the player is online or not; Funcom's `is_player_offline` decides (it also counts a player whose server is gone as offline, so a stuck player can be rescued).

- `move <player> X Y Z`: online, the server's `TeleportTo` (same partition only); offline, a `pre-move` backup and then Funcom's `admin_move_offline_player_to_partition`, where `--partition LABEL|ID` may also change partition (default: the current one).
- `move <player> [to] <target>`: both online, the game's own `TeleportToPlayer <target>` console command run in the player's context, so the server chooses the landing spot; player offline, the offline move onto the target's last saved spot (ground a character stood on), after a backup. An online player is not sent to an offline target, whose body is not in the world.

An online character cannot be moved in the database: the map server holds it in memory, is authoritative for it and writes it back on its own schedule, so Funcom's procedure refuses with "Player must be Offline" (its Director depends on that text).

`dune-awakening character whisper <player> <message> [--from NAME]` sends a private chat line, shown as coming from NAME (default `Admin`). It follows the route DASH confirmed in game: a `TextChat` courier with channel `Whispers` published to exchange `chat.whispers` with the player's FLS id as routing key, bound for the call to their own `<FLS id>_queue`. That queue exists only while they are online, so an offline player gets an error. A binding the game made itself is left in place.

### Timeout (a break without logging off)

`dune-awakening world timeout on` (also `bio-break`, `call-timeout`, `safety-first`) records the current values of four world-level console variables, sets them off, verifies each change in the map server's log, and broadcasts it: `Dac.DamageEnabled` (all damage), `sandworm.dune.Enabled`, `Sandstorm.Enabled`, `Coriolis.Enabled`. `timeout off` restores the recorded values (kept in `runtime/timeout.state`), so a hazard you had disabled on purpose stays disabled. `timeout status` reads the live value.

Why not a real pause: the engine drops a connection after 60 s without traffic (`ConnectionTimeout=60.0` in the shipped `DefaultEngine.ini`, keepalive every 0.2 s), so freezing the server process would disconnect everyone after a minute, and Funcom's server commands include no pause or time-dilation command (`PauseServer` and `SetTimeDilation` are rejected as unknown). Verified on the server: the four variables exist, are settable at runtime, and read back as changed. Not yet verified in game: whether no damage also covers thirst and heat.

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

- **Console:** the configs bind the Unreal console to `~` and `Insert`, but community reports say the console is compiled out of the shipping client, so neither key does anything. Not verified here, because the client is not on this host.
- **Admin Panel:** the game has one. `UAdminPanelWidget` (`W_AdminPanel`) has a password box (`m_AdminLoginEditableTextBox`, `OnClickAdminLogin`), a teleport-to-player box, a teleport map (`W_Admin_TeleportMap`) and cheat buttons. Two ways it may open:
  - `OpenAdminPanel` sits among menu and HUD handlers in the binary's names, so an Escape-menu button is possible.
  - `ToggleAdminPanel` sits among cheat-manager console commands, so it is probably console-only.
- **The key: Home.** The game's general input mapping context (`/Game/Dune/Input/General/IMC_General`) binds the input action **`IA_AdminPanel` to the Home key** (**verified** in the server's copy of the cooked assets; to be confirmed against the client's copy and in game). The same asset confirms the ordinary bindings (I inventory, M map, J journey, Tab player menu, E interact, Enter chat, B crafting, K skills, Y tech tree, L Landsraad, O guild, P social, U customization, N Communinet) and shows the developer ones: End toggles the UI, Delete is `IA_KillNPC`, F6 frame capture, F8 QA bug report, F9 cinematic camera. The panel may still check privileges before it opens; its login box suggests it opens first and asks for the password.

To try in game: press **Home**. Compact keyboards without a Home key usually have it on **Fn+PgUp** (with End on Fn+PgDn and Insert on Fn+Del); the binding is fixed, not rebindable in the game's settings (only player-mappable actions carry a `KB_MKB_*` settings name, and this one has none), so a keyboard driver or PowerToys remap is the other way. If the Admin Panel opens, enter the password from `runtime/secrets/admin_password` in its login box, then try its teleport-to-player box. Record what happens here.

How the key was found (repeatable after game updates): build [retoc](https://github.com/trumank/retoc) in a scratch directory with `nix-shell -p cargo rustc pkg-config openssl --run 'cargo build --release'` (not part of the flake). Its Oodle loader fetches `liboo2corelinux64.so.9` and checks a pinned SHA-256; on NixOS run retoc with `LD_LIBRARY_PATH` pointing at nixpkgs `stdenv.cc.cc.lib` for `libstdc++`. `retoc to-legacy --no-shaders -f IMC_General -f IA_AdminPanel Content/Paks OUT` converts the two assets. In the legacy `IMC_General.uexp`, each mapping stores its `Action` as an import index; `IA_AdminPanel` is import -12, and the `Key` struct after it holds a `KeyName` `NameProperty` whose value is the key's name (`Home`).

### Why Home did nothing, and the fix being tried (2026-09-26)

Pressing Home (Fn+PgUp) on the first test did not open anything, and the configured console keys do nothing in the shipping client. What the game files show (client build fetched through Steam, server build 2124138):

- **The binding is the same in the client.** The client's `IMC_General` and `IA_AdminPanel` are byte-identical to the server's; Home is bound to `IA_AdminPanel` (**verified**). The same mapping context holds the everyday bindings (I, M, Tab, E), so it is active in game.
- **The panel is meant to open before you are an admin.** `W_AdminPanel` has an `m_AdminCheckWidgetSwitcher` that switches between a login page (`m_AdminLoginEditableTextBox`, a show-password toggle, a "Login As" combo box for the privilege level, `m_AdminLoginButton`) and the cheat tabs (Player, Items, Spawns, Sandworm, Time and Weather, NPCs, Skills, Contracts, Landsraad, Spice, Audio, UI, Server). `W_EscapeMenu` also has an Admin button (`m_AdminButton` in `OpenAdminPanelHBox`) whose visibility is switched at runtime.
- **Privileges are server-granted and replicated.** The client carries `m_AuthenticatedPrivileges` with `OnRep_AuthenticatedPrivileges`, `GetAuthenticatedPrivileges` and `HasAdminPrivileges_FromController`; the server side has `UPlayerPrivilegeComponent`, `SetAuthenticatedPrivileges`, and `FDuneAdministrationSettings` (`m_AdminPasswords`, `m_bRequiresAdminPassword`), which sits next to the replicated server custom settings.
- **A hidden switch.** Disassembling the server's config reader (x86-64, around `0xdd3cd20` in `DuneSandboxServer-Linux-Shipping`) shows it read `[AdminSetting.Global]` in this order: a boolean **`RequiresAdminPassword`** into the administration settings, then `Password_<Privilege>` for each `EDunePrivileges` value into `m_AdminPasswords`. Funcom's configs never set `RequiresAdminPassword`, so it takes its compiled-in default. The call targets are inferred from the shape of Unreal's config API, not from symbols.

**Hypothesis:** with `RequiresAdminPassword` at its default, the admin login flow (the Escape-menu button, the Home key) is disabled, so the panel never opens. `dune-server` now writes `RequiresAdminPassword=True`. That direction is safe regardless: both privilege levels already have private passwords, so it can only require one. **To test:** press Home, or open the Escape menu and look for an Admin entry; if the panel opens, choose the privilege level in "Login As" and enter the matching password.

If this is wrong, the next step is disassembling the client's handler for `IA_AdminPanel` to see which check it makes before opening.

### Other routes considered

- `-ExecCmds="AdminLogin …"` as a Steam launch option is suggested in community notes but unverified; it would run before any server connection exists.
- A whisper chat-command listener (DASH does this): a player whispers `&goto Alice` and a host process runs the matching `dune` command. It would need no client changes, at the cost of a long-running service.
- Sources: [Funcom's self-host FAQ](https://funcom.helpshift.com/hc/en/4-dune-awakening/faq/85-how-to-self-host-a-world-1778514422/), [DASH admin-gm-console.md](https://github.com/snapetech/DuneAwakeningSelfHost/blob/main/docs/admin-gm-console.md), [dune-awakening-truenas ADMIN-COMMANDS.md](https://github.com/Icehunter/dune-awakening-truenas/blob/main/ADMIN-COMMANDS.md), and [research/live-world-control.md](research/live-world-control.md).
