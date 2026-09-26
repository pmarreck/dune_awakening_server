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

`dune-server` replaces the public default with a private generated password: `runtime/secrets/admin_password` (0600), written as `[AdminSetting.Global] Password_Admin=…` into the map server's private `Saved/Config/LinuxServer/Game.ini`. The server reads its database password from that same file, so the file is loaded. That the override takes effect in game is **inferred**, because nothing can type `AdminLogin` yet (below). To see the password: `cat ~/.local/share/dune_awakening_server/runtime/secrets/admin_password`.

### Getting to it from the client (open question)

- **Console:** the configs bind the Unreal console to `~` and `Insert`, but community reports say the console is compiled out of the shipping client, so neither key does anything. Not verified here, because the client is not on this host.
- **Admin Panel:** the game has one. `UAdminPanelWidget` (`W_AdminPanel`) has a password box (`m_AdminLoginEditableTextBox`, `OnClickAdminLogin`), a teleport-to-player box, a teleport map (`W_Admin_TeleportMap`) and cheat buttons. Two ways it may open:
  - `OpenAdminPanel` sits among menu and HUD handlers in the binary's names, so an Escape-menu button is possible.
  - `ToggleAdminPanel` sits among cheat-manager console commands, so it is probably console-only.
- **A key binding:** the game's general input mapping context (`IMC_GeneralInput` in the server's content pack) includes an input action **`IA_AdminPanel`** next to Chat, Inventory, Journey, Landsraad, Map, Skills, TechTree and ToggleUI. The keys that asset uses are BackSpace, Delete, End, Enter, Escape, F6, F8, F9, Home, Tab, I, J, K, L, M, N, O, P, U and Y. Which key goes with which action is in compressed data that needs an IoStore extractor (retoc, FModel) to read. Most letters and Enter/Escape/Tab have obvious owners, so the likely Admin Panel key is one of **Home, End, Delete, BackSpace, F6 or F8** (**inferred**). The panel may still check privileges before opening.

To try in game: press each of those keys, look for an Admin entry in the Escape menu and in Settings → key bindings (the action may be player-mappable), and if a password box appears, enter the value from `admin_password`. Record what happens here.

### Other routes considered

- `-ExecCmds="AdminLogin …"` as a Steam launch option is suggested in community notes but unverified; it would run before any server connection exists.
- A whisper chat-command listener (DASH does this): a player whispers `&goto Alice` and a host process runs the matching `dune` command. It would need no client changes, at the cost of a long-running service.
- Sources: [Funcom's self-host FAQ](https://funcom.helpshift.com/hc/en/4-dune-awakening/faq/85-how-to-self-host-a-world-1778514422/), [DASH admin-gm-console.md](https://github.com/snapetech/DuneAwakeningSelfHost/blob/main/docs/admin-gm-console.md), [dune-awakening-truenas ADMIN-COMMANDS.md](https://github.com/Icehunter/dune-awakening-truenas/blob/main/ADMIN-COMMANDS.md), and [research/live-world-control.md](research/live-world-control.md).
