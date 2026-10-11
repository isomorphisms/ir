#!/usr/bin/env python3
"""Normalize only audited legacy formatting exposed by reserved-fn renames.

The pre-existing whitespace becomes a newly changed line when fn becomes fun.
Do not run generic trimming over upstream source or normalize CRLF files.
"""
from pathlib import Path
import sys

if len(sys.argv) != 2:
    raise SystemExit("usage: fix-r-devel-replay-whitespace.py SOURCE_ROOT")

root = Path(sys.argv[1])
trailing = {
    "src/library/stats/R/free1way.R": (
        b"fun <- function(par)",
        b"ret <- fun(par)",
        b"objective = fun,",
    )
}
indents = {
    "src/library/utils/R/askYesNo.R": (
        b"fun <- match.fun(prompts)",
        b"return(fun(msg = msg, default = default, prompts = prompts, ...))",
    ),
    "src/library/utils/R/citation.R": (b"fun <- citeNatbib",),
    "src/library/utils/R/findLineNum.R": (
        b"fdef=fun",
        b"environment(fun)$.AllMTable",
    ),
}
changes = []

for name in sorted(set(trailing) | set(indents)):
    path = root / name
    content = path.read_bytes()
    # These target files, unlike the separate Rd file, are Unix line-ending files.
    if b"\r" in content:
        raise SystemExit(f"BLOCKED: unexpected carriage return in {name}")
    lines = content.splitlines(keepends=True)
    for needle in trailing.get(name, ()):
        matches = [i for i, line in enumerate(lines) if needle in line]
        if len(matches) != 1:
            raise SystemExit(f"BLOCKED: non-unique trailing-whitespace site: {name}: {needle!r}")
        index = matches[0]
        before = lines[index]
        if not before.endswith(b" \n"):
            raise SystemExit(f"BLOCKED: expected old trailing space not found in {name}: {needle!r}")
        lines[index] = before[:-2] + b"\n"
        changes.append(f"{name}:{index+1} trailing space")
    for needle in indents.get(name, ()):
        matches = [i for i, line in enumerate(lines) if needle in line]
        if len(matches) != 1:
            raise SystemExit(f"BLOCKED: non-unique mixed-indent site: {name}: {needle!r}")
        index = matches[0]
        before = lines[index]
        if not before.startswith(b"    \t"):
            raise SystemExit(f"BLOCKED: expected legacy mixed indent missing in {name}: {needle!r}")
        lines[index] = b"\t" + before[5:]
        changes.append(f"{name}:{index+1} leading spaces before tab")
    updated = b"".join(lines)
    if updated == content:
        raise SystemExit(f"BLOCKED: no audited whitespace changes in {name}")
    path.write_bytes(updated)

if len(changes) != 8:
    raise SystemExit(f"BLOCKED: expected 8 exact corrections; observed {len(changes)}")
for change in changes:
    print("NORMALIZED", change, flush=True)
