# ARMv7 Termux build

Run `./build-armv7-termux` at the repository root.  It produces an `arm`
Termux `.deb`, `SHA256SUMS`, and `build-record.txt` under
`artifacts/termux-armv7/`.

This is a native 32-bit Android build inside TUR's ARM environment.  R runs
newly built R code during its own build, so an ordinary NDK cross-build is not
an equivalent test.

The package installs `ir` and `irscript`.  Its runtime lives under
`$PREFIX/lib/ir/R`; it does not install `R` or `Rscript` and therefore does not
replace an ordinary R installation.

The TUR and `termux-packages` source revisions are pinned in
`build-armv7-termux`.  The two Android patches are derived from TUR's
`tur-on-device/r-base` recipe at that same TUR revision.  The build also fixes
its locale to `C.UTF-8`, because ir's source contains Unicode grammar symbols.

Acceptance requires all of the following inside the ARM Termux environment:

- package architecture is `arm`;
- the runtime is an ELF32 ARM executable;
- `ir` and `irscript` exist while `R` and `Rscript` do not;
- `x ← 8 ÷ 2; stopifnot((x = 4))` succeeds.
