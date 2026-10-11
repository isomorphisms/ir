#!/usr/bin/env python3
"""Resolve only provably mechanical conflicts in the pinned IR/R-devel merge.

Fail closed on any unknown path, unexpected IR delta, or changed upstream
message-count invariant. Stage resolved paths, never commit or merge here.
"""
from __future__ import annotations

import hashlib
from pathlib import Path
import re
import subprocess
import sys

if len(sys.argv) != 5:
    raise SystemExit("usage: resolve-r-devel-conflicts.py IR_ROOT SOURCE_ROOT BASE_SHA NEW_SHA")
root, source = map(Path, sys.argv[1:3])
base_sha, upstream_sha = sys.argv[3:5]


def git(cwd: Path, *args: str) -> bytes:
    return subprocess.check_output(["git", "-C", str(cwd), *args])


def blob(commit: str, filename: str) -> bytes:
    return git(root, "show", f"{commit}:{filename}")


unmerged_bytes = git(source, "diff", "--name-only", "--diff-filter=U", "-z")
conflicts = [s.decode("utf-8") for s in unmerged_bytes.split(b"\0") if s]
if not conflicts:
    raise SystemExit("blocked: failed git apply, but no merge conflicts were reported")
replacements: list[tuple[str, bytes, str]] = []

identifier_fn = re.compile(rb"\bfn\b")


def rename_fn(data: bytes) -> bytes:
    return identifier_fn.sub(b"fun", data)


def fix_free1way(data: bytes) -> bytes:
    return rename_fn(data).replace(b"STATISTIC =", b"STATISTIC <-")


def fix_regression(data: bytes) -> bytes:
    lines = data.splitlines(keepends=True)
    return b"".join(
        line if line.lstrip().startswith(b"#") else rename_fn(line)
        for line in lines
    )


for filename in conflicts:
    a = blob(base_sha, filename)
    ir = blob("HEAD", "code/" + filename)
    new_r = blob(upstream_sha, filename)

    if re.fullmatch(r"src/library/(base|stats)/po/[^/]+\.po", filename):
        # The original IR patch changed only the reserved identifier "fn"
        # in gettext strings. Keep upstream catalogue regeneration/metadata.
        if not a.count(b"fn") or ir != a.replace(b"fn", b"fun"):
            raise SystemExit(f"blocked: nonmechanical IR .po delta in {filename}")
        if new_r.count(b"fn") != a.count(b"fn"):
            raise SystemExit(f"blocked: unexpected translated fn count in {filename}")
        merged = new_r.replace(b"fn", b"fun")
        rule = "translation message fn->fun (counts and exact old diff verified)"
    elif filename == "po/Makefile.in":
        old = b"R_DEFAULT_PACKAGES=NULL LC_ALL=C $(R_EXE)"
        new = b"R_DEFAULT_PACKAGES=NULL LC_ALL=$(IR_BUILD_LOCALE) $(R_EXE)"
        if a.count(old) != 1 or ir != a.replace(old, new):
            raise SystemExit("blocked: unrecognized IR gettext Makefile change")
        if new_r.count(old) != 1:
            raise SystemExit("blocked: changed upstream gettext Makefile interface")
        merged = new_r.replace(old, new)
        rule = "retain IR UTF-8 locale plus upstream gettext options"
    elif filename == "src/library/stats/R/free1way.R":
        if a.count(b"STATISTIC =") != 2 or new_r.count(b"STATISTIC =") != 2:
            raise SystemExit("blocked: changed free1way assignment sites")
        if ir != fix_free1way(a).removesuffix(b"\n"):
            raise SystemExit("blocked: unrecognized original IR free1way changes")
        merged = fix_free1way(new_r)
        rule = "function-name and STATISTIC assignment adaptations"
    elif filename == "tests/reg-tests-1e.R":
        if ir != fix_regression(a):
            raise SystemExit("blocked: unrecognized original IR regression edits")
        merged = fix_regression(new_r)
        rule = "reserved fn identifier renames; leave comments intact"
    else:
        raise SystemExit(f"blocked: unclassified code conflict {filename}")

    if merged == new_r:
        raise SystemExit(f"blocked: candidate merge is unchanged upstream: {filename}")
    replacements.append((filename, merged, rule))

# Verify every file before mutating the conflicted worktree.
for filename, merged, rule in replacements:
    path = source / filename
    path.write_bytes(merged)
    git(source, "add", "--", filename)
    digest = hashlib.sha256(merged).hexdigest()[:16]
    print(f"RESOLVED {filename} sha256={digest} rule={rule}", flush=True)

remaining = git(source, "diff", "--name-only", "--diff-filter=U", "-z")
if remaining:
    raise SystemExit(f"blocked: unresolved merge entries: {remaining!r}")
print(f"All {len(replacements)} mechanically classified conflicts resolved; "
      "semantic/runtime acceptance still required.", flush=True)
