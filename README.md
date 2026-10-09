# IR

IR is an experimental fork of R. It keeps ordinary R spellings while adding shorter and Unicode forms for assignment, functions, equality, division, and tensor products.

It installs beside ordinary R rather than replacing it. The repository also builds a private ARMv7 Termux package.

## Syntax

### `fn` `λ` `→` `÷` `≟` `←` `⊗`

`→` and `←` can be used for assignment, not just `<-` and `->`.

`function(x) x**3` can be written `fn(x) x**3`, `λ(x) x**3`, or `ƒ(x) x**3`.

`÷` means division. `⊗` means the Kronecker/tensor product and matches R's existing `%x%` operator; `%o%` remains the outer product.

Existing R spellings remain available: `<-`, `<<-`, `->`, `->>`, `==`, `function`, and `%x%`.

```r
answer ← 8 ÷ 2
answer ≟ 4
```

The last line returns:

```text
[1] TRUE
```

A matrix tensor product can be written directly:

```r
A ← matrix(c(1, 2,
             3, 4), nrow = 2, byrow = TRUE)
B ← matrix(c(0, 5,
             6, 7), nrow = 2, byrow = TRUE)
A ⊗ B
```

This produces the same 4 × 4 matrix as `A %x% B` and `kronecker(A, B)`.

| This | Does |
| --- | --- |
| `x ← 3` | assign |
| `x ↞ 3` | assign in an enclosing frame |
| `3 → x` | assign |
| `3 ↠ x` | assign in an enclosing frame |
| `left ≟ right` | test equality |
| `fn(x) expression`, `λ(x) expression`, or `ƒ(x) expression` | construct a function |
| `left ÷ right` | divide |
| `left ⊗ right` | Kronecker/tensor product |

Prefer `≟` for equality. `?=`, `=?`, `?=?`, `¿=?`, `=`, and `==` are aliases for the same test.

Parameters are still supplied with `=`:

```r
clean.mean ← λ(x) mean(x, na.rm = TRUE)
```

## Compatibility limits

The `=` equality alias is contextual. Inside another call, wrap an equality comparison written with `=` in parentheses so it cannot be read as an argument name:

```r
stopifnot((answer = 4))
```

Code that used a single `=` as assignment must use an arrow. The comma and argument-label rules are otherwise unchanged.

`fn` was previously an ordinary name. It is reserved here, so old code using bare `fn` as a variable or argument must choose another name. This source uses `fun`; write `optim(par, fun = ...)` rather than `optim(par, fn = ...)`.

## Ordinary R remains separate

The tested Linux instructions install this build in its own folder and use a separate package library. They do not remove ordinary R, alter projects, rewrite scripts, or upload work. Close IR and launch ordinary R as before to switch back.

## ARMv7 Android / Termux

The `ARMv7 Termux binary` workflow builds an installable 32-bit `arm` package. Download its `ir_*.deb` artifact and install it in Termux:

```sh
apt install ./ir_*.deb
ir
```

The package installs `ir` and `irscript` with a private runtime. It does not replace the ordinary `R` or `Rscript` commands. The exact reproducible entry point is [`build-armv7-termux`](build-armv7-termux).
