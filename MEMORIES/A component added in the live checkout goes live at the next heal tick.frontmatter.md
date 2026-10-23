---
description: "The installed heal unit runs dune-awakening start every 5 minutes, so a new component registered in bin/dune-awakening starts on the live world within 5 minutes, before any commit or restart."
datetime: 2026-10-23T14:47:41-04:00 # EDT
tags: [deployment, heal, systemd, components, live-checkout, timer]
---
On 2026-10-23 dune-world-watch was added to COMPONENTS while it was still under test; the 14:39 heal run started it from the working tree. The host's heal unit runs `start --no-warn` (not `heal`) until its unit change is activated. Finish a component's tests before registering it, and do not leave a mutated copy of a component file in place across a heal tick (mutation testing overwrites the live file).
