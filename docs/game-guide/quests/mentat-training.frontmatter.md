---json
{
  "schema": "dune-guide/v1",
  "title": "Discipline of the Mentat (Mentat trainer questline)",
  "description": "How to unlock and complete the Mentat skill tree: Samin Moro's First Blood at Riftwatch, then Zayn de Witte's advanced contracts in Arrakeen, starting with Calculated Calamity.",
  "kind": "questline",
  "section": "quests",
  "tags": ["mentat", "trainer", "skill tree", "unlock", "samin moro", "riftwatch", "zayn de witte", "arrakeen", "first blood", "calculated calamity", "school", "class"],
  "aliases": ["Discipline of the Mentat", "MENTAT: BASICS: First Blood", "Secrets of the Mentat", "Mentat: Advanced", "Untwisted Questions"],
  "region": "Riftwatch (Hagga Rift), Arrakeen, Vermillius Gap, Hagga Rift, Shield Wall",
  "related": ["quests/calculated-calamity", "quests/trooper-training", "quests/index"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Discipline of the Mentat

Quick answer: talk to Samin Moro at Riftwatch and complete "MENTAT: BASICS: First Blood" to open the Mentat tree. Then ask at Riftwatch about advanced training, which is with Zayn de Witte in Arrakeen (the wiki says Arrakeen's lower bar). His chain starts with "Calculated Calamity" and ends with "Untwisted Questions" (game text, `JOURNEY_TRAINER_MENTAT_1_*`; wiki per [progression-and-skills.md](../progression-and-skills.md#trainers)).

## Basic: First Blood (Samin Moro, Riftwatch)

Lead-in notice: "Secrets of the Mentat" ("seek me out at Riftwatch ... I am Samin Moro") (game text). Riftwatch is a Harkonnen fortress in the Hagga Rift (game text, per world chapter).

Samin asks for plant fibers and iron ore to brew a toxin, then has you practice on "Kirab camps near Mirzabah". Conditions include "Deliver the resources to Samin Moro" and "Plant the poison" (game text, `CONTRACT_DESCRIPTION_LONG_TRAINER_MENTAT`, `CONTRACT_CONDITION_*_TRAINER_MENTAT`). Exact ore and fiber counts are not in the strings (unverified).

## Advanced: Zayn de Witte (Arrakeen)

Journey order (game text). Some contracts have Atreides and Harkonnen variants.

| Contract | Conditions |
|---|---|
| Calculated Calamity | See [Calculated Calamity](calculated-calamity.frontmatter.md): Mobula gang in the Eastern Vermillius Gap, sabotage, minimic film back to Zayn. |
| An Olive Branch (Atreides) / Underhanded Hand-Over (Harkonnen) | Deliver the Mobula gang's film to Thufir Hawat, or discuss Zayn's plans with Piter de Vries; report back to Zayn. |
| Cataloging Defectors | Find a specific Deserter camp in the Hagga Rift; collect blood samples from Atreides Deserters; kill their leader and sample him; bring the data to Zayn. |
| Bloody Results / A Bloody Development | Deliver Zayn's minimic film analysis to Thufir Hawat at the Residency Approach (or the Harkonnen variant); return to Zayn. |
| The Price of Rejection | Enter the Passage of Artemis in the Shield Wall; place a Solido Decoy; deploy a Hunter-Seeker into the annex; place a Poison Mine; assassinate the informant with the Hunter-Seeker; report. |
| Untwisted Questions | Talk to the Tleilaxu trader at Pinnacle Station; find the wreck of the Ourea (Sheol); search it for Tleilaxu information; deliver the findings to Zayn. |

## Notes

- The Price of Rejection needs the Solido Decoy, Hunter-Seeker and Poison Mine abilities, so unlock those Mentat skills first (inference from the conditions).
- Untwisted Questions ends in the Sheol; bring radiation protection.
- An earlier project note placed Zayn in the Hagga Rift. That is where Cataloging Defectors sends you; Zayn himself is in Arrakeen (game text; see the correction in the progression chapter).
