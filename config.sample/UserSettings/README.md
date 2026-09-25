# Gameplay setting overrides

Put a file here with the same name as one of Funcom's defaults in `<steam-server>/scripts/setup/config/`
(`UserServerCustomSettings.ini`, `UserGame.ini`, `UserEngine.ini`). It replaces that default **whole**, so start from a
copy of Funcom's file and edit it:

    cp <steam-server>/scripts/setup/config/UserServerCustomSettings.ini ~/.config/dune_awakening_server/UserSettings/

Funcom's files are not redistributed here. See docs/operations.md ("Gameplay settings") for the keys that matter.
