# Working on this R

This page is for maintainers, porters, and people reviewing the parser change. Everyone else should start at the repository's [friendly README](../README.md).

## Source and patch boundary

The complete R source tree lives in this `code/` directory. The semantic work is based on upstream R Subversion revision **90397**, mirrored by Git commit `086ed882c4`.

The reviewable semantic series is:

1. `c802b83f12` — directional assignment and single-`=` equality.
2. `cffe68ab28` — `λ` and `ƒ` procedure constructors.
3. `b7e7e17970` — bindable mathematical infix glyphs.
4. `af7c3450ff` — regression proof. Its central test is that single `=` evaluates equality rather than assignment; named arguments and formal defaults remain contextual exceptions.
5. `b7f3a18887` — convert the remaining assignment expressions in R's own libraries, tests, examples, and Windows installer so the new R can bootstrap itself.

Commit `a510d8d1ed` is only the content-preserving move of the full source tree under `code/`. Commit `16dd75b6ac` records the upstream revision metadata needed when building from the nested tree or a repository archive. Neither belongs in the semantic patch series for a normal upstream checkout.

To export only the five semantic patches:

```sh
git format-patch --output-directory ../r-symbol-patches \
  086ed882c4..b7f3a18887
```

Apply them in the numbered order to a checkout at the stated base. Keeping grammar, generated parser, tests, and bootstrap conversions separate is intentional.

## Parser invariants

- `←`, `↞`, `→`, and `↠` are reserved assignment operators. Existing ASCII assignment arrows still work.
- A single `=` produces R's equality operation in expression position and has equality precedence. Chained equality remains non-associative.
- `name = value` remains an argument label inside calls and a default marker in formal parameter lists. The comma/argument-label design is deliberately unchanged.
- `λ` and `ƒ` enter the same function-construction path as `function`.
- A supported mathematical glyph is a bindable name at the start of an expression and an infix operator after a completed expression. The parser supplies syntax, not a built-in meaning.
- Lexer context follows tokens actually returned to the parser. Ignored comments and continuation newlines preserve it; a returned top-level newline resets it.
- Malformed UTF-8 must still be rejected without reading past the input buffer.

## Files that define the change

- `src/main/gram.y` is the parser and lexer source.
- `src/main/gram.c` is generated from it and is committed so ordinary builders do not need Bison.
- `tests/reg-encodings.R` contains the focused semantic regression coverage.
- The bundled-R conversion is intentionally mechanical: genuine expression assignments use `<-`; argument labels and formal defaults keep `=`.

After changing `gram.y`, regenerate the committed parser with GNU Bison 3.8.2. From the repository root:

```sh
cd code
bison -y -l src/main/gram.y
mv y.tab.c src/main/gram.c
```

Review both files in the same implementation commit.

## Tested Linux build

Use an out-of-tree build. From the repository root:

```sh
mkdir build-maintainer
cd build-maintainer
sh ../code/configure \
  --with-x=no \
  --without-tcltk \
  --without-recommended-packages \
  --disable-java
make -j2
```

The public [Linux guide](../R-on-Linux.md) lists the Ubuntu 24.04 prerequisites. For a full-featured or release build, follow R's own [`INSTALL`](INSTALL) file and [`R-admin.texi`](doc/manual/R-admin.texi) rather than assuming the lean configuration above.

Run the focused regression:

```sh
make -C tests reg-encodings.Rout
```

Then run R's normal checks:

```sh
make check
```

In the restricted root container used for the initial validation, `reg-tests-1e.R` could not provoke the invalid-UID warning it expects because the container blocks that `chown` operation. All other standard regression targets were run separately and passed; small PDF-coordinate differences from the available fonts were informational.

## Platform claims

Do not mark Windows or macOS as supported merely because the shared parser compiles on Linux. A platform becomes supported only after its native build, installer or package, notation smoke test, R regression tests, RStudio selection path, and switch-back path have all been exercised on that platform.
