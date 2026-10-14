---json
{
  "schema": "dune-guide/v1",
  "title": "Rigor of the Trooper (Trooper trainer questline)",
  "description": "How to unlock and complete the Trooper skill tree: Ghavouri's Proving Grounds at Griffin's Reach, then Kara Valk's six advanced contracts in Arrakeen.",
  "kind": "questline",
  "section": "quests",
  "tags": ["trooper", "trainer", "skill tree", "unlock", "ghavouri", "griffin's reach", "kara valk", "arrakeen", "proving grounds", "school", "class"],
  "aliases": ["Rigor of the Trooper", "TROOPER: BASICS: Proving Grounds", "Discipline of the Soldier", "Trooper: Advanced", "The Cleansing of Kara Valk"],
  "region": "Griffin's Reach (Hagga Basin South), Arrakeen, Harko Village, Jabal Eifrit",
  "related": ["quests/mentat-training", "quests/swordmaster-training", "quests/bene-gesserit-training", "quests/planetologist-training", "quests/index"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "high"
}
---

# Rigor of the Trooper

Quick answer: talk to Ghavouri at Griffin's Reach Tradepost (the starter tradepost) and finish "TROOPER: BASICS: Proving Grounds" to open the Trooper tree. For the rest, ask Ghavouri about advanced training. It is with Kara Valk in Arrakeen, through six contracts ending in "The Cleansing of Kara Valk" (game text, `JOURNEY_TRAINER_TROOPER_1_*`, `CONTRACT_TROOPER*`).

Trainer contracts as a group unlock the tree, then Level 2 skills, Level 3 skills and three capstones ("Unlocks Trooper Skill Tree", "Unlocks Level 2 Trooper Skills", ...) (game text, `UI/CONTRACTREWARD_*`). Which advanced contract grants which unlock is not mapped in the strings read here.

## Basic: Proving Grounds (Ghavouri, Griffin's Reach)

Lead-in: the tradepost notice "Discipline of the Soldier" ("Go to Griffin's Reach. Ask for Ghavouri.") (game text). Conditions (game text):

1. Kill Aatu Golven in Kaleff's Stand.
2. Kill Kirsi Tol in Shamal Tunnel.
3. Kill Cardanus Ulun in Edgeway Cavern.
4. Construct a Sandbike.
5. Report back to Ghavouri at Griffin's Reach.

Community guides say the three targets are in separate cave complexes in eastern Hagga Basin (community, itemlevel.net and keengamer search summaries, 2025, pre-1.5). The sandbike condition means you finish this around the end of [A New Beginning](a-new-beginning.frontmatter.md).

## Advanced: Kara Valk (Arrakeen)

The wiki places Kara Valk in Arrakeen's central plaza, later the Salusan Bull (wiki; see [progression-and-skills.md](../progression-and-skills.md#trainers)). Contracts in journey order (game text):

| Contract | Conditions |
|---|---|
| Seeking Control | Enter the slaver base at the Sweep; find intel on Servo-Stim Transmitters; kill the slaver officers and commander for their transmitters; deliver two to Kara. |
| Regaining Control | Meet Kara's smuggler contact in Harko Village (Anoushka Hannivar); ask the black market trader; locate Tuco's stash in Jabal Eifrit; investigate the mineral extraction facility; search Tuco's remains; report. |
| A Shot at Improving | Find the Suk doctor in Harko Village; investigate the medical supply problem; enter Taqwa's Watch and kill Maas Kharet; get medicine and deliver it to Kara in Arrakeen. |
| Master of Weapons | Deploy Assault Seekers, create Attractor Fields, deploy Gravity Fields; fetch and deliver medicine. |
| Surgical Strike | Enter Khidr's Shadow, kill slavers, find the shipping manifest, deliver the Coded Manifest. |
| The Cleansing of Kara Valk | Arrange transport with Campos Demari; find the smuggler dead-drop; access the upper floor of Khidr's Shadow and take the slaver commander's Servo-Stim Transmitter; deliver it to the Suk doctor; visit Kara after the operation. |

Master of Weapons asks you to use Trooper abilities, so you need them unlocked and slotted first (inference from the conditions).

Admin shortcut: on this server an operator can open a tree with `&unlock <school>` (verified on this server, `docs/admin.md`).
