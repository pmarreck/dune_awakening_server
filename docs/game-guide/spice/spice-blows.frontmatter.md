---json
{
  "schema": "dune-guide/v1",
  "title": "Spice blows",
  "description": "How a spice blow builds up and erupts into a spice field, the shockwave danger, and when it is safe to start harvesting.",
  "kind": "system",
  "section": "spice",
  "tags": ["spice blow", "spice bloom", "eruption", "shockwave", "purple cloud", "geyser", "spice field", "harvesting"],
  "aliases": ["spice bloom", "blow", "spice eruption"],
  "related": ["spice/spice-fields", "spice/harvesting-worm-risk", "spice/harvesting-by-hand-and-compactor"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Spice blows

A spice blow is the eruption that creates a spice field. Watch for geysers and rumbling as pressure builds, stay back until it goes off, then move in: "the shockwave destroys everything nearby" (game text).

## Sequence

1. A patch of pink, bubbling sand appears (wiki, https://awakening.wiki/Spice_Fields, 2026-09-19). Game text describes "geysers and rumblings on the surface as the pressure builds" (game text).
2. After an incubation period it erupts with an audible explosion and a violet mushroom cloud "that can be seen for kilometres around" (game text; wiki). Exact incubation time is not documented (unverified).
3. A high-energy gas spout stands at the center briefly; the cloud fades and the field becomes fully visible. The field is harvestable as soon as it exists, though hard to see through the cloud (wiki).

## Practical points

- Do not stand or park in the bubbling area; the blast destroys what is nearby (game text). Whether it kills a player outright is not stated (unverified).
- In Funcom's server defaults a sandstorm does not set off spice explosions (`m_bSandstormDestroySpiceExplosion=False`, server config; meaning inferred from the name).
- New blows are scheduled by the spice harvesting system, which checks every 30 seconds whether to prime another field (`m_PrimeRateInSeconds=30`) until the map's cap is reached (server config); see the caps in [spice-fields](spice-fields.frontmatter.md).
- A story NPC tells beginners to "cut your teeth within reach of Harko" and to "watch for those purple spice blows and get in quick" (game text). Blows form semi-randomly, not at fixed spots (wiki), except that the Deep Desert's large field reuses a set of crater sites.
