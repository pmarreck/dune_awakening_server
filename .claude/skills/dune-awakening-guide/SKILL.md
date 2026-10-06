---
name: dune-awakening-guide
description: >-
  Answer Dune: Awakening gameplay questions (vehicles, bases and building,
  skills and trainers, Intel and research, maps and locations, water and
  survival, combat, crafting and refining, Solari, guilds and parties, patches)
  from this project's sourced player guide, and record new findings in it.
  Use whenever a player asks how something in the game works, where something
  is, or why something happened in game.
---

# Dune: Awakening guide

The guide lives in `docs/game-guide/`. Start at `docs/game-guide/README.md`, which lists the six chapters and explains the provenance tags.

## Answering

1. Open the chapter for the topic and read its quick answers first; search it with `rg -i` for exact names.
2. Answer with the exact in-game names, and say how sure you are: a `(verified on this server)` or `(game text)` fact can be stated plainly; a wiki or community fact, especially one marked pre-1.5, should be presented as probable.
3. If the guide is silent or the question is about an exact item, check before guessing:
   - item ids and names: `bin/dune-awakening items find "<name>"`;
   - game text: `rg -i '<pattern>' "$HOME/.local/share/dune_awakening_server/strings/"all-build*.tsv` (columns: source asset, key, text; use the newest build);
   - then web search, preferring Funcom's patch notes and pages dated after 2026-09-17.
4. Never run filesystem-wide searches (over `/`, `$HOME`, Steam or the unpacked server images); one stalled the host on 2026-10-06.

## Recording

When an answer needed new research, or a player reports something in game that contradicts the guide, update the chapter in the same session:

- add or correct the fact with its provenance tag (a player's observation on this server is `(verified on this server)` and outranks the wiki);
- keep quick answers short, write in your own words, keep nothing personal (the repository is public);
- run `./test`, then commit the guide change on its own.

Server-side actions (giving items, Intel, refills, unlocking trees, settings) are operations, not guide content: see `docs/admin.md`.
