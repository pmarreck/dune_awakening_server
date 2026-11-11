# Trial of Aql: the hang on the way back from a vision

Symptom (2026-10-13, 2026-10-26): at the end of a Trial of Aql vision the client shows "Connecting..." and drops; after one or more drops a fresh login lands the player back in Hagga Basin, and the server logs "First trial completed!" seconds later. The trial counts.

What the server binary shows (2026-11-11, symbol names): a vision is a challenge room, a separate level the client plays off the server (`UDunePlayerJourneyComponent::TravelToChallengeRoom`, `ClientLoadChallengeRoom`, client phases `LoadingChallengeRoom` and `ChallengeRoom`, game mode `ADuneSandboxChallengeRoomGameModeBase`). Meanwhile the server holds the character in a login grace period ("Grace Period: Challenge Room with Id: N"). At the end, a dialog button calls `TransitionPlayerBackToArrakisFromChallengeRoom` and the client reconnects (`HandleReturnFromChallengeRoomOnClient`, `CheckIfReturningFromChallengeRoomOnClient`); the server then runs `CompleteChallengeRoom`. Director has no challenge-room code and Gateway's service none either, so the return involves only the client and the map server.

Why the October logs cannot settle it: the map server keeps its current log and one backup, and both the server and Director logs are truncated at each start, so nothing from October survives.

Capture at the next attempt (Thufir, while the player runs a trial):

1. Note the minute the player touches the altar and the minute the vision ends.
2. Map server log (`runtime/server/server-console.log`), that window: lines matching `ChallengeRoom|Challenge Room|Grace Period|Login request|Join succeeded|ControlChannelClose|NetworkFailure|Travel|PreLogin|Welcomed`. Account names in these lines are private: summarize, do not paste into the repo.
3. Director log, same window: only lines matching `travel` (case-insensitive), cut to 160 columns; the log holds credentials.
4. Ask the player what the client showed at the end (dialog, button pressed, "Connecting..." duration, error text) and whether the trial counted without a relog.

Questions the capture should answer: does the client try to reconnect at all (a `Login request` after the vision ends)? If it does, does the login stall in the grace-period handoff on the server (no `Join succeeded`)? Does it connect to the same address and port as a normal login?
