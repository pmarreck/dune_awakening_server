# Administering the world

One place for every way to administer this world: commands run on the host, in-game chat commands for trusted players (the GM bridge), and the game's own in-game GM system. `dune` is short for `dune-awakening` (see the README). The host commands need a shell on the host with the private config; the chat commands need only a line in the operator's `gm_bridge.conf`. In-game privileges (User, PowerTester, GM, Admin) are the game's own, described in the last section.

Evidence labels: **verified** means observed on this world; **inferred** means read from the binaries or configs but not exercised.

## Commands from the host (`dune world`, `dune character`)

The map server starts with Funcom's server-command channel on: `dune-server` writes a generated `ServerCommandsAuthToken` (kept in `runtime/secrets/server_commands_token`, 0600) and `server.NotificationSystem.Enabled=true` into its private `Engine.ini`. `dune-live` wraps a command in Funcom's Version 2 envelope and has the game RabbitMQ node publish it (exchange `heartbeats`, routing key `notifications`, user `fls`, app `fls_backend`); the envelope travels through a 0600 file, never a command line. Commands are grouped by what they act on: `world` for the whole world, `character` for one character (the character tool hands its live subcommands to `dune-live`). Players are named by character; the tool resolves their FLS id (`accounts.user`, 16 hex digits), which is what the server-command channel's `PlayerId` takes. The Funcom id (name#number) is accepted and logged but silently does nothing (verified in game, 2026-09-26).

```bash
dune-awakening world say "Restart in 5 minutes" --duration 30
dune-awakening world kick-all
dune-awakening world exec t.MaxFPS 5            # world-level engine command or variable (ServerExec)
dune-awakening world cvar t.MaxFPS [5]         # read a console variable from the server log, or set it and verify
dune-awakening world partitions
dune-awakening world raw <ServerCommand> [--player P] [Key=value[:int|:float]...]
dune-awakening character list                   # ● online / ○ offline, Intel, skill points
dune-awakening character move <player> [to] <target>
dune-awakening character move <player> X Y Z [--partition LABEL|ID]
dune-awakening character where <player>
dune-awakening character kick <player>
dune-awakening character water <player> 5000
dune-awakening character xp <player> 1000 [Combat|Crafting|Gathering|Exploration|Sabotage]   # they receive about 1000
dune-awakening character level <player> 20      # raise to level 20 (never lowers)
dune-awakening character whisper <player> "message" [--from NAME]
dune-awakening character give <player> ITEM [COUNT]   # e.g. give Alice HarkAr2
dune-awakening character worm <player>          # experimental: SandwormTargetPlayer in the player's context
```

The server logs each command: `LogDuneServerCommands: Now running ServerCommand '…'`, or `unknown Server Command '…'` for names it does not implement. Verified live on build 2124138: `ServiceBroadcast` and `ServerExec` run; `ServerExec` changes engine variables at runtime (`t.MaxFPS 5` cut the map server from 32% to 11% of a core, `t.MaxFPS 0` restored it), but console output is not returned. Cheat-manager names (`SandwormTargetPlayer`, `PrintNumPlayers`, ...) are not server commands in their own right.

### Giving items

`dune-awakening character give <player> ITEM [COUNT]` sends Funcom's `AddItemToInventory` server command (fields `PlayerId`, `ItemName`, `Quantity`); the item appears in their inventory at once (verified in game with `HarkAr2`, 2026-09-26). The player must be online: the tool refuses an offline player (Funcom's `is_player_offline`) before publishing anything. The server logs `Now running ServerCommand 'AddItemToInventory'`; for an item id it does not know it adds `LogCheatManager: Warning: Cannot find item associated with spawn command <ID>` (**verified** on this world), so grep the server log after a give. The command itself reports success either way.

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

A display name is not an item id, and two items can share one. The id a recipe wants is in the crafting table, `DT_ItemsCraftingRecipes`: convert it with `retoc to-legacy -f DT_ItemsCraftingRecipes`, then read the recipe's ingredient names from its name map.

#### Item names (for `&give`)

The chat bridge's `&give` takes a name as well as an id. Names come from two lists, merged, the first winning where both name something:

1. **`data/items.tsv`** in this repository: hand-written, safe to publish. One line per item, tab-separated: item id, `yes`/`no` (seen working in game on this world), the most one give may hand out (`-` for the default, see [the cap per give](#the-cap-per-give); Solari allow 1000000), and `|`-separated aliases. To add a nickname, append it to an item's aliases (or add a line); the bridge reads the file for every `&give`, so no restart is needed. Case, spacing and punctuation never matter (`Karpov-38` = `karpov 38`).
2. **The generated list**, `runtime/items/generated.tsv` (0600; `DUNE_ITEMS_GENERATED` overrides the path): every item id in the game with its English display name, deprecated flag, table and stack size, read from the game's own tables by `dune-awakening items refresh`. It is derived from Funcom's content, so it is never committed (`generated.tsv` is gitignored). Run the refresh after each game update. It needs [retoc](https://github.com/trumank/retoc), which this project does not ship: point `DUNE_RETOC` at the binary (the dev shell's `DUNE_GCC_LIB` supplies its runtime library path). `--legacy DIR` reads an already converted tree instead.

How the ids and names link (**verified** by parsing the tables, 2026-09-28): each row of the `DT_BaseItems_*` tables is one item, its row name the item id (an FName number suffix n shows as `_n-1`, so `SandbikeChassis` number 2 is `SandbikeChassis_1`). The row's `StaticData.Name` is a text whose string-table history names a table (`ST_Localization_Items`, `ST_Localization_Buildings`, …) and a key, whose English value is the display name. The key need not resemble the id (`FremenComponent1` → `ITEMS/RESOURCE_EMF_GENERATOR_NAME`). Checked pairs: `SolarisCoin` → Solari, `HarkAr2` → Karpov 38, `FremenComponent1` → EMF Generator. `D_FremenComponent3` is also named EMF Generator but has `bIsDeprecated` set, which fits the recipes rejecting it. The 1.5 server tables give 4189 named items out of 4217 rows; 25 rows name a key that no `ST_Localization_*` table holds, and 3 have no name.

Each row's stack size is `StackAndDurability.MaxStackSize` (**verified** by parsing the 1.5 tables, 2026-09-28): an `IntProperty` inside the row's `ItemStackAndDurabilityStats` struct, a sibling of `StaticData`, present in all 4217 rows. The values fit the items (plausibility only; stack sizes have not been checked in game on this world): `SolarisCoin` 50000, `Ammo` and `HeavyAmmo` (darts) 1000, raw resources and components such as `FremenComponent1` 500, `SpiceSand` 2500, and 1 for weapons (`HarkAr2`), vehicle parts and fuel cells (`FuelCanister_Large`). 3999 rows have 1. `StaticData.MaxQuantity` is -1 everywhere and is not the stack size. A generated list written before this column existed still reads; its items count as having no known stack size.

##### The cap per give

The most one `&give` hands out is, in order: the item's max count in `data/items.tsv` when set (Solari: 1000000); else its stack size from the generated list, raised to at least 10; else 1000 (no generated list, or no stack size). So `&give` gives at most one full stack of a stackable item (500 iron bars, 1000 darts) and up to 10 of an item that does not stack. The floor of 10 exists because a cap equal to a stack size of 1 would stop anyone giving two rifles; 10 still refuses a slip like `&give karpov 38` (38 rifles, since a trailing number is the count), and each unstacked item takes an inventory slot, where a full inventory can drop items. `dune-awakening items find <name>` prints the cap as `max N`. The constants are `DEFAULT_CAP` and `MIN_STACK_CAP` in `libexec/lib/items.lua`.

Resolution, in order: an exact item id (any case); an exact name or alias; otherwise nothing is given and the reply lists up to five closest names ("did you mean"), or, when several items share the name, lists them to pick one by id. A generated item that is deprecated is dropped from a name a live item also has, and any name in `data/items.tsv` belongs to its curated items only, so `emf generator` always means `FremenComponent1`. Without a generated list, a single id-shaped word that names nothing is passed through as a raw id, as before. `dune-awakening items find <name>` shows what a name resolves to, without giving anything.

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

### XP and levels

The server's `AwardXP` command multiplies what it receives by the world's `GlobalXpMultiplier` (**verified** 2026-09-30: 4150 sent at `GlobalXpMultiplier=1.5` added 6225 to `TotalXPEarned`). `dune-awakening character xp <player> AMOUNT [CATEGORY]` therefore divides AMOUNT by the multiplier and rounds to the nearest whole number, so the player receives about AMOUNT, and says what it did: `sent 2767 Combat XP (x1.5 = 4150.5, ...)`. The multiplier comes from `Saved/UserSettings/UserServerCustomSettings.ini`, the copy the map server was started with; without it, from the operator's `$DUNE_CONFIG_DIR/UserSettings/UserServerCustomSettings.ini` (which applies only at the next start); a file without the key, or no file, means 1. A multiplier of 0 (no XP at all) is refused. Whether the per-category settings (`CombatXp`, `GatheringXp`, ...) also scale `AwardXP` is not known: all were 1 when it was measured, so the tool ignores them. `dune-live character xp` sends its amount as is.

`dune-awakening character level <player> N` raises an online character to level N (1 to 200): it reads their `TotalXPEarned` (the same value `character list` shows as xp), takes the game's XP total for level N, and sends the difference through the same division, rounded up so the player is never left short. `--json` reports the levels, totals and what was sent. It never lowers a level: XP can only be awarded, not removed. Two caveats. The database value can trail the server's own while the player is online (the server saves it periodically), so the player can land a little past the threshold. The XP goes in as Combat XP.

Levels come from the game's curve table `SkillXPPerLevel` (`m_SkillsXPTable` in `DefaultGame.ini`), shipped as [data/levels.tsv](../data/levels.tsv) with how it was extracted. Its `XPNeeded` row has keys (level:XP) 0:0, 1:40, 2:175, 3:225, 4:300, 5:500, 7:600, 100:600, 101:650, 127:650, 128:651, then rising to 200:13126, interpolated linearly between keys (level 6 needs 550). `MaxLevel` is 200. The tool reads `XPNeeded(L)` as the XP from level L-1 to L, starting at level 0 with 0 XP, so the total for level L is `XPNeeded(1) + ... + XPNeeded(L)`:

| Level | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 10 | 12 | 13 | 20 | 50 | 100 | 150 | 200 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Total XP | 40 | 215 | 440 | 740 | 1240 | 1790 | 2390 | 4190 | 5390 | 5990 | 10190 | 28190 | 58190 | 93099 | 344440 |

Evidence for that reading (2026-10-01), against two others that fit the curve's shape:

- A character with 5806 XP was shown in game as about two thirds through level 12. This reading gives level 12 at 69%. Starting at level 1 and not counting the level-1 key gives level 12 at 76%; counting it from level 1 (total for L = `XPNeeded(1..L-1)`) gives level 13 at 69%.
- `SkillPointsRewarded` gives one skill point per level from 2 up. Three characters' `TotalSkillPoints` match this reading and contradict the level-13 one: 390 XP held 1 point (level 2; the other gives level 3 and 2 points), 7032 XP holds 13 (level 14), and 9289 XP holds 37, of which 20 were added with `add-skill-points` (level 18; the other gives 38).
- `IntelPointsRewarded` pays 4 Intel at level 1 and `XPNeeded` has a key at level 0, so reaching level 1 is a step of its own.

Not settled: the 76% reading differs from this one only by 40 XP per total, and only the "two thirds" observation separates them. The tool uses the larger totals, so if the other reading were right, `level` would overshoot by 40 XP and never leave a player short. A character seen in game right after `level`, or at a level boundary, would settle it.

### Inventory slots cannot be raised (tried 2026-09-28)

The number of inventory slots is not adjustable. The server's 46 custom settings (`UserServerCustomSettings`) include `InventoryVolumeMultiplier`, which makes each slot hold more, but nothing for the slot count. The database does store a slot count per inventory (`dune.inventories.max_item_count`, 35 for a player's main backpack), but it is not authoritative: with the player offline, raising it from 35 to 50 changed nothing in game (still 35 slots), and the server wrote 35 back when the player logged in (editing it while the player is online does nothing either: the server keeps the inventory in memory and only writes the row). The count comes from the game's own data, and the game has its own way to raise it: a progression keystone, `KEYSTONE_INVENTORYSLOTINCREASE` in `ST_Localization_Progression` ("Increases inventory size by 1 row."), and the tech tree shows an "Inventory Slot Capacity" entry (`UI/TechTreeItem_InventorySlotCapacity`). But no skill tree offers it in game (checked by a player on this world, 2026-09-28), and player guides (game8, ScalaCube) say personal inventory slots cannot be increased, so the keystone looks unused or cut. Vehicle storage modules are the game's intended extra space.

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
| `&give <item> [count] [to <player>]` | puts items into your inventory, or with `to <player>` into another online player's (`character give`). The item is a name or an id ([Item names](#item-names-for-give)); count defaults to 1, at most one stack of the item (at least 10; 1000 when the stack size is unknown) unless `data/items.tsv` sets another max ([the cap per give](#the-cap-per-give)). Examples: `&give solari 5000`, `&give emf generator 2 to Alice`, `&give HarkAr2` |
| `&kick <player>` | disconnects a player |

To enable it, write `gm_bridge.conf` in the config directory (template: `config.sample/gm_bridge.conf.sample`) and `chmod 600` it. One line per player, `<character name or FLS id>: <command>...`, or `<who>: *` for every command; `#` starts a comment. The permissions are the command names, except that giving is split: `give` lets a player give to themselves, `give-others` to anyone else (`*` grants both). An entry of 16 hex digits is an FLS id and matches that account only; `dune-awakening character whois <FLS id>` names the character of an id. The file is read for every command, so edits apply at once; `dune-awakening doctor` fails if others can read or write it.

```
# ~/.config/dune_awakening_server/gm_bridge.conf
Alice: *
0123456789ABCDEF: where goto bring
```

How `&give` reads its words: everything after the last standalone `to` (any case) is the player; a standalone whole number just before it (or at the end) is always the count. So names containing numbers are typed hyphenated, and replies and suggestions show them that way: `&give karpov-38` is one Karpov-38 rifle, `&give karpov-38 2` is two, and `&give karpov 38` is 38 of the item called "karpov". Matching ignores spacing and punctuation, so `karpov-38` finds an item the game calls "Karpov 38". The same goes for an item name containing the word `to`: type it hyphenated (`ticket-to-ride`), since only a standalone `to` starts the player name. A give to another player needs them online; otherwise the reply says so and nothing is sent. The reply names what was given, to whom, with the item's name and id, notes ids not yet verified in game, and reminds that a full inventory can drop items.

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

## Storms: warning time and damage

The world has two storm kinds, configured in the game's DefaultGame.ini and overridable in `$DUNE_CONFIG_DIR/UserSettings/UserGame.ini` (restart the map servers afterwards):

- **Sandstorms** (`[/Script/DuneSandbox.SandStormConfig]`): random (`m_bAutoSpawnEnabled`), damaging (`m_SmallSandStormDamageConfig`, `m_LargeSandStormDamageConfig`, per Player/Building/Placeable/Vehicle; defaults 5 and 7), and short-warned by default: `m_WarningBuildupTimeInSeconds=10` then `m_BuildupTimeInSeconds=30`, so under a minute between the warning and full strength. Players who see "only a minute of warning" are seeing this, not a fault.
- **Coriolis storms** (`[/Script/DuneSandbox.CoriolisStormConfigMultiplayer]`): scheduled, warned 6 hours ahead with a 59-minute final stage, and harmless unless `m_bCoriolisDoesDamage` is turned on.

A struct value such as `m_SmallSandStormDamageConfig=(...)` replaces the whole struct, so give every field. Whether the client's warning display follows a longer `m_WarningBuildupTimeInSeconds` is not verified yet.

## Building height: the sub-fief console's claim box

A base must fit inside its console's landclaim, which is a box, not just a footprint. The sizes come from the game's DataTable `/Game/Dune/Systems/Building/Data/DT_DuneTotemData` (decoded 2026-10-01 from build 25610213 with retoc; vertical values are relative to the claim's stored origin, which is inferred from the `dune.totems` columns and server strings):

| Console | Width | Vertical range | Extendable |
|---|---|---|---|
| Sub-Fief Console (`Totem_Small_Placeable`) | 30.6 m | 12.8 m down, 17.92 m up (30.72 m) | no, in either direction |
| Advanced Sub-Fief Console (`Totem_Placeable`), level 1 | 53.8 m | 23.04 m down, 28.16 m up (51.2 m) | yes, horizontally and vertically |
| Advanced Sub-Fief Console, level 6 (max) | 53.8 m plus segments | 99.84 m down, 130.56 m up (230.4 m) | |

Each vertical level of the advanced console adds 15.36 m below and 20.48 m above. On a Sub-Fief Console the ceiling is about 13.8 m above the console itself.

No server setting changes these. No ini key mentions a claim radius or vertical range, and `m_BuildingHeightLimitInM` (which this world already raises from 980 to 1960) is an absolute altitude cap far above Hagga Basin bases. Editing `dune.totems.landclaim_vertical_level` does nothing for a Sub-Fief Console, because its row defines only one level. Replacing the DataTable would be a mod pak, which the client would also need. The supported way to build taller is to build the Advanced Sub-Fief Console and raise its vertical level in game.

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
