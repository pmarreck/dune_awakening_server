---json
{
  "schema": "dune-guide/v1",
  "title": "Prescience, spice addiction, withdrawal and tolerance",
  "description": "How consuming spice or standing in spice fields builds toward the Prescient state, what Prescience does, the withdrawal phase and rising tolerance, the spiced consumables, and the Spice Mask.",
  "kind": "system",
  "section": "spice",
  "tags": ["prescience", "prescient", "spice addiction", "addiction", "withdrawal", "tolerance", "spice blood", "melange spiced food", "spiced beer", "spice mask", "third ability slot", "buff"],
  "aliases": ["spice state", "Spice Addiction Level", "SpiceAddictionConsumable_01", "SpiceAddictionConsumable_02", "SpiceAddictionConsumable_03", "SpiceAddictionConsumable_04", "SpiceAddictionConsumable_T6", "Combat_Light_SpiceMask"],
  "related": ["spice/melange-uses", "spice/harvesting-by-hand-and-compactor", "spice/spice-fields"],
  "game_version": "1.5.x",
  "last_researched": "2026-10-13",
  "confidence": "medium"
}
---

# Prescience and addiction

"Consuming Spice, or being exposed to Spice fields, allows you to progress towards a Prescient state" (game text). Prescience is a temporary combat buff; afterwards you go through withdrawal, when you cannot take spice, and your tolerance rises, so the next Prescience takes more spice (game text). The HUD shows "Gaining Spice", "Prescient" or "Spice Withdrawal", and the Status UI shows your Spice Addiction Level (game text).

## The cycle

1. Gaining Spice: eat or drink spiced items, or stand in a spice field (game text).
2. Prescient: "Poison tolerance, increases all damage, reduces skill cooldowns, increases passive healing, and shows enemy info", and it opens a third ability slot (game text). The server config puts that slot at ability index 2 (`EquippedAbilitySpiceAddictionSlotIndex=2`, server config). There is a keybind "Activate Spice Prescience" (game text); whether Prescience must be triggered by hand once the meter is full is unverified. You "Can't consume Spice in Prescient state" (game text).
3. Withdrawal: "you cannot consume spice" and your Tolerance increases (game text).
4. Tolerance "will decay" over time, "but you can choose to overcome it by consuming greater quantities of spice instead" (game text).

Durations and amounts are not in the game text and no 1.5 source was found (unverified). A loading tip warns "too much and it will impact your perceptions, too little and you will suffer withdrawals" (game text). The melange item text says "Withdrawal leads to death"; no source shows withdrawal killing a player character (unverified).

## What benefits from Prescience

Each skill tree has a prescience passive marked "Requires Prescience" (game text), listed in [../progression-and-skills.md](../progression-and-skills.md). Examples: Prescient Strike (after a Swordmaster ability the next strike hits twice, second hit at 70%), Bindu Dodge (darts and blades pass through you after a successful parry), Reflexive Reload, Shield Overcharge, Screech, Heat Management for vehicles (game text). Advanced-trainer capstones add prescient bonuses, for example Spice Infused Poisons ("While prescient increase poison damage") (game text). One unique Maula pistol "greatly increases accuracy while Prescient" (game text).

## Spiced consumables

| Item | Id (item data) | Stack |
|---|---|---|
| Melange Spiced Food | `SpiceAddictionConsumable_01` | 200 |
| Melange Spiced Beer | `SpiceAddictionConsumable_02` | 200 |
| Melange Spiced Coffee | `SpiceAddictionConsumable_03` | 200 |
| Melange Spiced Wine | `SpiceAddictionConsumable_04` | 200 |
| Melange Spiced Liquor (Plastanium tier) | `SpiceAddictionConsumable_T6` | 200 |

Each "will raise the amount of spice in your blood" (game text). Schematics "Spiced Food" and "Spiced Drink" exist (item data). How much each adds is unverified.

## Avoiding exposure

The Spice Mask "prevents the wearer from inhaling airborne spice particles"; Dunemen wear it "to avoid adverse addictive effects while working the spice fields" (game text). Wear it while harvesting if you want to control when you go Prescient.

## Server switches

Spice addiction and spice visions are on by default (`m_bIsSpiceAddictionEnabled=True`, `m_bIsSpiceVisionEnabled=True`, server config), and the Deep Desert, the social hubs and the default map preset all have the spice-addiction feature enabled (`m_SpiceAddiction=True`, server config). This server does not override them.
