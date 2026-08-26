# CXXR source snapshot

The `cxxr/` directory is an unmodified source snapshot of CXXR's continuation,
Rho. CXXR was renamed Rho while retaining the project goal of refactoring the R
interpreter into a compatible, efficient C++ virtual machine.

- Upstream: <https://github.com/rho-devel/rho>
- Commit: `bf6c652b826cd892e88630eb35f182b614af52b1`
- Source tree: `b12c08f052d89467122a0deee381f13609ea4e40`
- Commit date: 2017-06-30
- Upstream status at that commit: development suspended
- License: GNU GPL version 2; see `cxxr/COPYING`

The snapshot is kept separate from `code/`, which contains ir's active R source.
It is reference material for comparing interpreter representation, evaluation,
promise, pairlist, memory-management, and virtual-machine designs. Nothing in
the ir build currently compiles or links `cxxr/`.
