# Dune: Awakening player guide

Notes for answering gameplay questions about Dune: Awakening (Funcom) quickly and accurately, written for this project's operators and for the AI sessions that help them. Game version 1.5.x; first researched 2026-10-06 against server build 25689360 and the game text of build 25610213.

| Chapter | Covers |
|---|---|
| [vehicles.md](vehicles.md) | every vehicle, modules and tiers, assembly, fuel, repair and maximum durability, the Vehicle Backup Tool, parking, losses |
| [bases-and-building.md](bases-and-building.md) | land claims and sub-fief consoles, height limits, building sets, garages, power, water, storage, stations, upkeep, base backup, permissions |
| [progression-and-skills.md](progression-and-skills.md) | XP and levels, skill points, Intel and research, the five schools and their trainers, respec, factions, Landsraad, contracts, the story |
| [world-and-maps.md](world-and-maps.md) | every map on this server, travel rules, Hagga Basin regions and places, tradeposts, cities, Deep Desert, security zones, hazards, enemies |
| [survival-combat-crafting.md](survival-combat-crafting.md) | water, heat, stamina, healing, spice, death drops, combat, armor, gathering, refining, crafting stations, durability |
| [economy-social-versions.md](economy-social-versions.md) | Solari, the Exchange, vendors, guilds, parties, chat, PvP, server types and settings, DLC, version history |

Each chapter opens with quick answers, then detail, then sources.

## Detailed entries

Beside the chapters, small entry files (one subject each, JSON frontmatter first) live in section directories. Each section has an `index.frontmatter.md`; the format is in [CONVENTIONS.md](CONVENTIONS.md).

| Section | Holds |
|---|---|
| [npcs/](npcs/index.frontmatter.md) | trainers, vendors, faction contacts, story characters, bosses, NPC groups |
| [zones/](zones/index.frontmatter.md) | regions, cities, tradeposts, points of interest, travel, the merchant directory |
| [residences/](residences/index.frontmatter.md) | base sites, layout, building sets, ideas |
| [quests/](quests/index.frontmatter.md) | the story and early-to-mid questlines in suggested order, trainer and faction contracts |
| [tips/](tips/index.frontmatter.md) | newcomer techniques; `newbie-tips.tsv` feeds the in-game `&newbie` command |
| [combat/](combat/index.frontmatter.md) | mechanics, weapon families, armor, builds per school |
| [resources/](resources/index.frontmatter.md) | every resource, where it is, how to gather it, what it makes |
| [crafting/](crafting/index.frontmatter.md) | tiers, stations, components, costs, with diagrams |
| [spice/](spice/index.frontmatter.md) | spice fields, harvesting, melange and its uses |
| [endgame/](endgame/index.frontmatter.md) | Deep Desert, Landsraad, top gear, this server's two-player endgame |

Find entries by metadata before reading bodies:

```
glob frontmatter --json -- 'docs/game-guide/*/*.frontmatter.md' | jq -r '.documents[] | select((.frontmatter.tags + .frontmatter.aliases) | map(ascii_downcase) | index("buggy")) | "\(.path)\t\(.frontmatter.description)"'
```

Newer findings supersede older ones: when an entry and a chapter disagree, prefer the more recent and better-sourced statement, and fix the older text.

## How much to trust a fact

Every substantive fact carries a tag. In decreasing order of authority:

- `(verified on this server)`: seen in game or in the server's data on this project's world.
- `(game text)`: the game's own English strings, extracted from the server's cooked content. Exact names and UI messages; descriptions can lag behind mechanics.
- `(item data)`: item ids, names and stack sizes from `dune-awakening items find`.
- `(patch notes ..., URL)`: Funcom's official notes.
- `(wiki, URL)` and `(community, URL)`: useful but often written for an older version. Items marked "pre-1.5" predate the 1.5 release (2026-09-17).

When a player's own observation contradicts a note, believe the player, then fix the note and tag the new fact `(verified on this server)`. For example, the Vehicle Backup Tool was first described here as holding one vehicle, but its screen showed "2/10" with two sandbikes stored.

## Checking and extending the notes

- Item ids and names: `dune-awakening items find "<name or id>"` (needs `items refresh` after a game update).
- Game text: the string tables of a build, dumped as `source<TAB>key<TAB>text`, are kept privately (Funcom's content is not committed) under the server's state directory, `strings/all-build<N>.tsv`. Search with `rg -i`. To regenerate after an update, convert the server's paks with retoc as described in [../admin.md](../admin.md) ("How the key was found").
- Server-side settings and their effects on this world: [../admin.md](../admin.md).
- Avoid filesystem-wide searches (over `/`, `$HOME`, Steam or the unpacked server images): on 2026-10-06 one saturated the host's disk and stalled logins.
- Keep the style of the chapters: one file per topic, quick answers first, provenance on every fact, no long copied passages, nothing personal (this repository is public).
