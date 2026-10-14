---json
{
  "schema": "dune-guide/v1",
  "title": "Contracts (types, chains, how they pay)",
  "description": "How contracts work: contract boards and issuers, the Regular, Chained, Exploration, Trainer, Atreides and Harkonnen types, repeatable and delivery contracts, Call Issuer, and the main contract chains by region.",
  "kind": "system",
  "section": "quests",
  "tags": ["contracts", "contract board", "call issuer", "chained", "repeatable", "delivery", "solari", "rewards", "side quests", "scrap mettle", "payback", "monster slaying", "dynamic encounters"],
  "aliases": ["contract", "Contract Board", "Call Issuer", "Hand In", "CONTRACTS_Type_Chained", "Scrap Mettle", "Payback", "Monster Slaying"],
  "region": "Tradeposts, cities and field NPCs",
  "related": ["quests/a-new-beginning", "quests/faction-join-a-house", "quests/calculated-calamity", "quests/regional-journeys", "quests/lost-harvest", "quests/index"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Contracts

Quick answer: contracts are the game's side quests. You pick them up from a Contract Board at a tradepost or city, or from an NPC (the "issuer"), and the contract menu tracks them. When a step says so, you "Call Issuer" over the communinet instead of walking back. Many come in chains whose next contract is offered when you finish the last. They pay Solari, items, XP, faction standing or skill-tree unlocks depending on type (game text, `UI/CONTRACTS_*`).

## Types (game text, contract menu)

| Type | What it is |
|---|---|
| Regular | Stand-alone jobs, including deliveries ("Deliver required Copper Ore to the Contract Board and then Call Issuer"). |
| Chained | Multi-part storylines, offered one after another ("New Contract offer from {issuer}: {title} Accept?"). |
| Exploration | Lead-in notices that point you to a person or place, such as the trainer notices. |
| Trainer | School training chains that unlock skill trees, Level 2 and 3 skills and capstones. |
| Atreides / Harkonnen | Faction contracts that raise faction standing to rank 5 (patch notes 1.3.0.0 per the progression chapter). |

Other status strings: "Repeatable Contract ... Locate the Contract Issuer to repeat the contract"; contracts can be time-limited ("Remaining Time", "Closing Soon!"), can fail, can be "taken by someone else", and there is a cap ("Cannot accept more contracts") (game text). Delivery conditions show "Backpack: {Valid}/{Required}" and flag low-durability items, which do not count when a contract demands a durability floor (game text; the Atreides "Test of Resourcefulness" asks for 50% durability).

## Pay

- Delivery and job contracts pay Solari: "Offload it at the contracts board and you'll get your solaris" (game text, a Griffin's Reach delivery). Exact amounts per contract are not in the strings read here (unverified).
- Item rewards: SCRAP METTLE's last contract hands over sandbike components (game text).
- Trainer contracts unlock skills (game text, `UI/CONTRACTREWARD_*`).
- Faction contracts give Faction Standing up to rank 5 (wiki, https://awakening.wiki/Faction).
- Contract XP is scaled by the server's "Mission Experience" setting, which covers "journeys, missions and contracts" (game text).

## Main chains by region

Chain names are game text (`UI/Contract_Chain_*`). The region column is inferred from each enemy faction's home territory in the world chapter and from place names in the contract text, so treat it as a guide; the Vermillius card itself asks for MONSTER SLAYING, a Slavers chain.

| Region | Chains |
|---|---|
| Hagga Basin South | Scrap Mettle (Scavengers: "Copper Required", "Fremen Finds", "Wrecking Crew", "Testing Limits", "Bike Building"); tradepost delivery funnels (Salvage Junket, Granite Delivery, Pistol Delivery); misc (Execution Order, Hostile Takeover, Present Danger, Vial Retrieval, Lost & Found, Find Olmen, Bounty). |
| Vermillius Gap (The Anvil) | Payback (Kirab: "Stealing From Thieves" ... "Revenge Never Ends"); Monster Slaying (Slavers: "Put Out the Eyes", "Take Out the Legs", "Clip the Wings", "Strike at the Heart"). The Vermillius regional card asks for both. |
| Jabal Eifrit | Finding Sehmo and Slaver Jobs (Slavers); The Tisiphone (a wreck in Jabal Eifrit Al-sharq). Pinching Spice (Kirab) may belong to the Vermillius Gap instead. |
| Hagga Rift | The Absent Colonel and Cleanup Detail (Deserters). |
| Shield Wall | Counter-Insurgency, Payload, Counter Agent (Sandflies). |
| O'odham / Mysa Tarill | The Cult, Dangerous Dealing, Cutting Edge (Maas Kharet). |
| Cities | Arrakeen: Athar Banquet, Salusan Jobs, Officer Scandal, Dr. Shaffat (recustomization). Harko Village: Market Manipulation, Merchandise Retrieval, Phrakk (recustomization). |
| Anywhere | Dynamic encounters: stranded merchants (Hoon's junk, DeCastille's ore, Demidenko's Sheol crates), "Ghoul" assassination targets per region, Pilgrims' totems per region, CHOAM event contracts. |

The 1.5 update added new contracts and dynamic encounters (patch notes 1.5, https://duneawakening.com/news/announcement/the-new-dune-awakening-is-here/). The recustomization chains appear to unlock character appearance changes (inference from the chain names "Dr. Shaffat" and "Phrakk" and "Help Needed at the Clinic"; unverified).

## Landsraad missions are separate

Landsraad missions (rank 6 to 20 faction progress, Specialization XP) are taken from the Landsraad > Missions menu, can be shared with a party member in a faction-aligned guild, and have a 16-hour cooldown after completion or abandonment (game text). See [Faction Chapter 3 journeys](faction-chapter-3.frontmatter.md).
