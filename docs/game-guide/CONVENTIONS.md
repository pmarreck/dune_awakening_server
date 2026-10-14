# Guide entry conventions

The topic chapters (`vehicles.md`, `bases-and-building.md`, ...) are the overviews. Detailed knowledge lives in small entry files under section directories, one subject per file, so a reader can find an entry by its metadata without loading every body.

## Layout

```
docs/game-guide/<section>/<slug>.frontmatter.md
docs/game-guide/<section>/index.frontmatter.md     section overview: what is here, how it is organized, links
```

Sections: `npcs`, `zones`, `quests`, `tips`, `combat`, `resources`, `crafting`, `spice`, `endgame`, `residences`. Slugs are lowercase words joined by hyphens (`the-anvil`, `trial-of-aql`, `duraluminum-ingot`).

## Frontmatter

Every entry starts with a JSON block between `---json` and `---`:

```
---json
{
  "schema": "dune-guide/v1",
  "title": "The Anvil",
  "description": "Tradepost in the Eastern Vermillius Gap: vendors, faction representatives, sandbike garage.",
  "kind": "location",
  "section": "zones",
  "tags": ["tradepost", "vendor", "vermillius gap", "hagga basin"],
  "aliases": ["Anvil tradepost"],
  "region": "Eastern Vermillius Gap",
  "related": ["npcs/tyg-rolsum", "zones/vermillius-gap"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-14",
  "confidence": "high"
}
---
```

- `kind`: one of `npc`, `location`, `region`, `quest`, `questline`, `tip`, `weapon`, `armor`, `ability`, `combat-style`, `resource`, `item`, `recipe`, `station`, `system`, `index`.
- `description`: one sentence that answers "what is this and why would a player look it up".
- `tags`: several lowercase search words, including what a player would type.
- `aliases`: other names, misspellings and in-game ids (item ids from `dune-awakening items find`).
- `related`: other entries as `<section>/<slug>`.
- `confidence`: `high` (verified on this server or game text), `medium` (official notes or several agreeing sources), `low` (single community source, pre-1.5, or inference).

## Body

- Quick answer first (two or three sentences), then detail.
- Provenance on every substantive fact, inline: `(verified on this server)`, `(game text)`, `(item data)`, `(server config)`, `(patch notes X, URL)`, `(wiki, URL)`, `(community, URL)`. Mark pre-1.5 (before 2026-09-17) information. Say "unverified" when unsure; never invent numbers, coordinates or recipes.
- Your own words; quote in-game strings only briefly. No personal names, hostnames or IPs (public repository).
- American English; plain prose and tables; no em-dash clusters, hype words or closing summaries.
- Mermaid diagrams (```mermaid fences) are welcome where a hierarchy or chain is clearer as a graph.

## Searching

```
frontmatter --json -- docs/game-guide/*/*.frontmatter.md | jq -r '.documents[] | select(.frontmatter.tags | index("vendor")) | .path'
```

(In a shell with globbing disabled, wrap with `glob`.) Then read only the entries you need.
