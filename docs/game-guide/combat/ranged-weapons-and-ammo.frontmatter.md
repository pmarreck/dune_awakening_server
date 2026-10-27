---json
{
  "schema": "dune-guide/v1",
  "title": "Ranged weapons and ammunition",
  "description": "How ranged combat works with shields, the ammo types (light darts, heavy darts, incendiary gel, missiles, power) and which weapons use which, plus weapon stats.",
  "kind": "system",
  "section": "combat",
  "tags": ["ranged", "ammo", "ammunition", "light darts", "heavy darts", "incendiary gel", "missile", "rocket", "power pack", "reload", "ammo pack"],
  "aliases": ["darts", "bullets", "ammo types"],
  "related": ["combat/pistols", "combat/rifles", "combat/scatterguns", "combat/disruptors", "combat/light-machine-guns", "combat/lasguns", "combat/flamethrowers-and-pyrocket", "combat/missile-launchers", "combat/shields-and-the-slow-blade"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-26",
  "confidence": "medium"
}
---

# Ranged weapons and ammunition

Quick answer: most guns fire darts. Light Darts (`Ammo`) feed most weapons, Heavy Darts (`HeavyAmmo`) the bigger ones, Incendiary Gel (`Napalm`) the flamethrowers and Pyrocket, Missiles (`InfantryRocketAmmo`) the infantry launchers, and lasguns draw power instead of ammo (game text; item data). Firing drops your own shield for a moment (game text).

## Ammo (game text names; ids from item data)

| Ammo (id) | Stack/give cap | Used by |
|---|---|---|
| Light Darts (`Ammo`) | 1,000 | "Standard ammunition for most ranged weapons": Maula pistols, Karpov 38, Disruptor M11 and others (game text; community, https://game8.co/games/Dune-Awakening/archives/528662). Not the JABAL Spitdart, which fires Heavy Darts (verified on this server, 2026-10-26), although the same community source lists it here |
| Heavy Darts (`HeavyAmmo`) | 1,000 (unverified) | "Standard ammunition for more advanced weapons"; can pierce certain armor; also loads the Heavy Turret. The unique disruptors Abulurd's Rapture, Piter's Disruptor and Sardaukar Intimidator fire heavy darts (game text), and so does the JABAL Spitdart (verified on this server, 2026-10-26). |
| Incendiary Gel (`Napalm`) | not checked | Incendiary weapons: flamethrowers, Pyrocket (game text) |
| Missile (`InfantryRocketAmmo`) | 250 | Infantry missile launchers (game text; item data) |
| Rocket | not checked | Vehicle rocket launchers (game text) |
| Power | n/a | Lasguns drain the Power Pack; efficiency depends on pack tier (wiki, https://awakening.wiki/Lasgun, edited 2026-03-27); Experimental Lightning Gun "uses electrical power rather than standard ammunition" (game text) |

Ammo packs exist for bulk: "Ammo Pack: Light Darts" (`D_AmmoPack_Dart_Light`), "Ammo Pack: Heavy Darts" (`D_AmmoPack_Dart_Heavy`), "Ammo Pack: Incendiary Gel" (item data); the `D_` prefix suggests these are deprecated. The early journey has you craft 90 Light Darts (game text). The Crafting specialization can double consumable crafts, including ammo (game text, Batch Crafting Chance).

## Weapon stats on item cards (game text)

Damage Per Shot, Shield Damage Per Shot, Rate of Fire, Clip Size, Reload Time, Effective Range, Maximum Range, Accuracy, Recoil, Stability, Projectile Spread, Shots Per Burst, Ammo Per Shot, Fire Mode (Automatic, Burst, Semi-Automatic), ADS Mode, Flame Radius, Power Consumption, Poison/Fire Damage Over Time, Durability Loss on Defeat.

## Combat notes

- Your Holtzman shield switches off while you fire and comes back after its refresh time (game text).
- Ranged weapons are common on Arrakis because shields are discouraged there (game text, Pipecleaner lore).
- Damage passives: Ranged Damage (Mentat and Trooper both have one), Rifle Damage, Pistol Damage, Scattergun Damage, Disruptor Damage, Heavy Weapon Damage (game text). See [weapon tiers](weapon-tiers-and-names.frontmatter.md) for family pages.
- 1.5 fixed weapon swaps keeping the previous weapon's accuracy and swaps being dropped during stuns (patch notes 1.5, https://duneawakening.com/news/dune-awakening-console-release-patch-notes/).
