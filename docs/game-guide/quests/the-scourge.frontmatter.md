---json
{
  "schema": "dune-guide/v1",
  "title": "The Scourge (Halloween event, 2026)",
  "description": "Limited-time Halloween event, Oct 23 to Nov 2 2026: how to start it with Frida Maltros, the contract chain, Blood Marks and the reward store.",
  "kind": "questline",
  "section": "quests",
  "tags": ["event", "halloween", "scourge", "infected", "blood marks", "frida maltros", "shaffat", "limited time", "seasonal", "cosmetics"],
  "aliases": ["Scourge event", "Halloween event", "Frida Maltros", "Dr. Shaffat", "CB_MTXEvents_VG_Infected_ThopterWreck", "HalloweenCoin"],
  "region": "Hagga Basin, Arrakeen, Harko Village",
  "related": ["quests/contracts", "zones/the-anvil", "npcs/kirab"],
  "game_version": "1.5.x (server build 26081962)",
  "last_researched": "2026-10-26",
  "confidence": "medium"
}
---

# The Scourge (Halloween event, 2026)

Quick answer: a plague event that runs from Oct 23 to Nov 2, 2026. Kill a glowing Infected enemy and loot the pamphlet "Are You Infected?". Then find Frida Maltros in a tent at a tradepost (or at Shaffat's Clinic in Arrakeen) and take her first contract. Blood from kills, turned in beside her, buys event cosmetics (community, sietch.ru and method.gg, URLs below).

## On this server

The event content loads on a self-hosted world with no extra setting. On build 26081962 the map server loaded the event's content blocks `CB_MTXEvents_TP_Infected_Camp` (at tradeposts), `CB_MTXEvents_VG_Infected_Camp`, `CB_MTXEvents_J_Infected_Camp` and `CB_MTXEvents_VG_Infected_ThopterWreck` (the first contract's crash site, near Mirzabah's Head) (verified on this server, 2026-10-26, server log). The server binary also carries an item id `HalloweenCoin` and a console variable `dw.Inventory.Item.Event.Enabled`, which read `1` (verified on this server). What that variable gates is unverified.

## Starting it

- Kill a glowing Infected enemy; it drops the pamphlet "Are You Infected?" (community, sietch.ru). A GameFAQs report says Frida did not appear until the player had it (community, gamefaqs).
- Frida Maltros: tents at The Crossroads, The Anvil and Pinnacle Station (not Griffin's Reach), or Shaffat's Clinic in Arrakeen, west of the landing pad across the Central Plaza; from stage 2 also Phrakk's Clinic in Harko Village (community, sietch.ru).
- First contract, Vital Equipment: Dr. Shaffat's cargo crashed near Mirzabah's Head in the Vermillius Gap. Fight off the ambush, take the Lost Shipment and deliver it to Dr. Shaffat in Arrakeen (community, sietch.ru; method.gg). One guide reports the wreck missing on one server until the player changed servers (community, method.gg); on a private world, tell the operator.

## Contracts

Reported chain (community, sietch.ru; amounts to be checked in game):

| Stage | Contract | Task | Area | Blood Marks |
|---|---|---|---|---|
| Start | Vital Equipment | Deliver the Lost Shipment | Vermillius Gap crash site | 100 + emote |
| Start | Harkonnen Help | A meeting | Harko Village | 100 + emote |
| 1 | Eyes of the Kirab | 5 Infected Eyeballs from Kirab | Vermillius Gap | 300 |
| 1 | Eyes of the Outlaw | 5 Infected Eyeballs from Slavers and Deserters | Jabal Eifrit | 200 |
| 1 | Eyes of the Forsaken | 5 Infected Eyeballs from Sand Flies and Maas Kharet | Shield Wall | 200 |
| 2 | The Kirab, Outlaw and Forsaken Cortex | 5 Mutated Brain Tissue from the same groups | same areas | 300 / 200 / 200 |
| 3 | The Hieronymus story | Stage 3 quests | Wreck of the Hieronymus | 100 / 200 / 100 |

- Infected only drop eyeballs while the matching eyeball contract is active (community, sietch.ru).
- Completing Eyes of the Kirab (the second contract taken) opens Frida's reward store (community, method.gg).
- Stages unlock over the event's days; in stage 3 Frida flies you to the wreck if you have no ornithopter (community, sietch.ru).
- Whether party members share contract credit is unverified; take each contract on every character.

## Blood Marks and rewards

Donate blood from any enemy at the Blood Collector beside Frida: 1 Blood Mark per 1000 ml (community, sietch.ru; method.gg). Rewards reported: Contagion Cowl, Contagion Visor, Derelict Recovery Suit, the Hot Zone swatch, seven base decorations (among them Cadaverous, Osseous and Flesh Sculpting Displays), the emotes Infection Takes Hold and Sun-Sick, and the consumable Vial of Pestilent Mien, a temporary plague aura (community, sietch.ru). Prices are unlisted. Rewards are said to leave with the event on Nov 2 (community, gamefaqs search summary).

## Sources

- https://sietch.ru/en/news/mor-2026 (locations, contract table, rewards)
- https://www.method.gg/dune-awakening/dune-awakening-scourge-event-how-to-start-it-how-to-earn-blood-marks-and-all-rewards (start, store unlock, wreck bug)
- https://gamefaqs.gamespot.com/boards/378350-dune-awakening/81205608 (pamphlet before Frida)
- https://mmohuts.com/news/dune-awakenings-halloween-event-sends-infected-into-hagga-basin-through-november-2 (dates)
