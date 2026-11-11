---
description: "Funcom's images can change binary metadata between builds (build 26547981 dropped RUNPATH from TextRouter and Director), so the native prepare step must set every property it relies on instead of inheriting it."
datetime: 2026-11-11T00:56:29-05:00 # EST
tags: [memory, elf, runpath, rpath, patchelf, musl, dotnet, textrouter, director, update, funcom, payload]
---
On 2026-11-10 build 26547981 shipped TextRouter and Director without `RUNPATH $ORIGIN/netcoredeps`. Our prepare step
only repointed the interpreter and symlinked `netcoredeps`, relying on the image's RUNPATH, so musl found no
libstdc++ and the update left the world down ("Error relocating ./TextRouter: __cxa_pure_virtual: symbol not found";
the first lines of the log say "Error loading shared library libstdc++.so.6").

Fix: `libexec/dune-dotnet-prepare` now sets interpreter and RUNPATH together, and `tests/payload/dotnet-apps` asserts
the RUNPATH. When a native run depends on a property of Funcom's binaries (interpreter, RUNPATH, NEEDED, file layout),
set or check it explicitly in the prepare step and the payload test. Compare old and new with
`readelf -d` on `unpacked/<image>` and `unpacked/<image>.prev` after an update fails.
