---json
{
  "schema": "dune-guide/v1",
  "title": "Weapon tiers and name prefixes",
  "description": "How to read a weapon's tier from its name (Standard, Artisan, House, Adept, Regis), Unique versus Great House items, grades, and the item-id pattern.",
  "kind": "system",
  "section": "combat",
  "tags": ["tier", "mk", "standard", "artisan", "house", "adept", "regis", "unique", "great house", "grade", "copper", "plastanium"],
  "aliases": ["weapon tiers", "Regis", "Adept", "Artisan"],
  "related": ["combat/unique-weapons", "combat/augments", "combat/index"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Weapon tiers and name prefixes

Quick answer: craftable "Great House" weapons climb a ladder of name prefixes, one per material tier: plain name (copper, tier 1), Standard (iron, 2), Artisan (steel, 3), House (aluminum, 4), Adept (duraluminum, 5), Regis (plastanium, 6). Uniques have their own names. This ladder is inferred from the journeys and the wiki, not stated outright by the game.

## Evidence for the ladder

- Journey steps pair prefixes with material tiers: the Vermillius Gap mid-game journey has you craft a "Standard Disruptor M11" alongside iron-tier Kirab Heavy Armor; the Jabal Eifrit journey crafts an "Artisan JABAL Spitdart" with steel-tier Slaver Scout Armor and concludes that "you need Steel components"; the O'odham late-game journey covers the Rapier, Vulcan GAU-92 and Drillshot FK7 with aluminum-tier Duneman Heavy Armor (game text).
- The wiki lists the House Rapier as aluminum and the Regis Rapier as plastanium (wiki, https://awakening.wiki/Rapier).
- Item ids count up with the prefix: Kindjal (`Kindjal`), Standard Kindjal (`Kindjal_0`), Artisan (`Kindjal_1`), House (`Kindjal_2`), Adept (`Kindjal_3`), Regis (`Kindjal_4`) (item data).
- Pistols have one more rung at the bottom: Improvised Maula Pistol (`ChoamSda1`) is the starter, then Maula Pistol, Standard ... Regis (`ChoamSda7`) (game text; item data).

## Other labels

- Great House item: craftable standard weapon (game text tag "A Great House item").
- Unique: a named variant with a special property; needs Imperial Permits per craft, from schematics found in the world (game text). See [unique weapons](unique-weapons.frontmatter.md).
- Grades 1 to 5: plastanium (tier 6) uniques and augments drop in grades from Testing Stations; higher grade means better stats; Recommended gear is shown as "Tier + Grade" (game text). Grade 3 stops dropping after difficulty 20 and Grade 4 gets rarer from 27 (patch notes 1.5, https://duneawakening.com/news/dune-awakening-console-release-patch-notes/).
- An id starting with `D_` is usually a deprecated item; for example `D_Rapier_1` (Atreides Rapier Mark II) and `D_HoltzmanShield` (item data).
