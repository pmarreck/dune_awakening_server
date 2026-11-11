---
description: "Extract the relevant map server and Director log lines when an in-game incident happens; both logs are truncated at each start and Unreal keeps only one backup."
datetime: 2026-11-11T04:14:58-05:00 # EST
tags: [logs, logging, incident, evidence, director, map-server, unreal, trial-of-aql, debugging]
---

The launchers truncate `runtime/server/server-console.log` and `runtime/director/director.log` every time a component starts, and the map server's `Saved/Logs` keeps the current log plus one backup. A world restart, an update or a heal-driven start therefore erases the evidence of anything that happened before it.

On 2026-11-11 the Trial of Aql "Connecting..." hang (2026-10-13, 2026-10-26) could not be investigated further: the server binary showed where the hang must be, but every log line from both incidents was gone after the 2026-11-10 update restart.

When a player reports something odd in game, grep the relevant lines out right away (by time window and keyword, cut to a safe width, never the credential lines of the Director or TextRouter logs) and keep the summary in the PLAN item's context file. Account names in log lines are private: summarize them in the repository.
