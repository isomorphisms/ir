# IR R-devel synchronization

Original source: SVN r90406, Git 3da432e44c5ab99eef6da071183fa0ff315381f1.
New source: SVN r90659, Git 93ee4ba84357570bc20c0ae05442d08f3735a91e.
Upstream source: https://github.com/wch/r-source.git.
Upstream commit date: 2026-10-10 09:08:16 +0000.

The full IR source delta was reapplied using git apply --3way --index to
the pinned upstream tree. Conflicts stop publication. The nested code/
source alone was updated; the independent cxxr/ snapshot was untouched.
Generated gram.c must match gram.y using GNU Bison 3.8.2.

This update is not evidence of a successful build, R regression,
Unicode semantic execution, S4 compliance, or ARMv7 Termux installation.
ICK qualification and runtime acceptance remain required before merging.
