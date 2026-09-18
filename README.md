### fn λ → ÷ ≟ ← ⊗

→ and ← can now be used for assignment, not just `<-` and `->`.

`function(x) x**3` can now be written `fn(x) x**3`, `λ(x) x**3`, or `ƒ(x) x**3`.

÷ means division.

⊗ means the Kronecker/tensor product. It matches R's existing `%x%` operator; `%o%` remains R's outer product.


Existing R spelling remains available: `<-`, `<<-`, `->`, `->>`, `==`, `function`, and `%x%` still work.



```r
answer ← 8 ÷ 2
answer ≟ 4
```

The last line returns

```text
[1] TRUE
```

because ≟ tests equality.

A matrix tensor product can be written directly:

```r
A ← matrix(c(1, 2,
             3, 4), nrow = 2, byrow = TRUE)
B ← matrix(c(0, 5,
             6, 7), nrow = 2, byrow = TRUE)
A ⊗ B
```

which produces the same 4 × 4 matrix as `A %x% B` and `kronecker(A, B)`.



| this | does |
|---|---|
| `x ← 3` | assign |
| `x ↞ 3` | assign in an enclosing frame |
| `3 → x` | assign |
| `3 ↠ x` | assign in an enclosing frame |
| `left ≟ right` | test equality |
| `fn(x) expression`, `λ(x) expression`, or `ƒ(x) expression` | construct a function |
| `left ÷ right` | divide |
| `left ⊗ right` | Kronecker/tensor product |



Prefer `≟` for equality. `?=`, `=?`, `?=?`, `¿=?`, `=`, and `==` are aliases for the same test.

Parameters are still supplied with =.

```r
clean.mean ← λ(x) mean(x, na.rm = TRUE)

```

------

*Actually this is worse than I thought it would be, I thought there would be no downsides....*

Only the `=` equality alias is contextual. Inside another call, wrap an equality comparison written with `=` in parentheses so it cannot be read as an argument name:

```r
stopifnot((answer = 4))
```

Code that used a single `=` as assignment must use an arrow in this R. The comma and argument-label rules have otherwise been left alone.

`fn` also used to be an ordinary name. It is reserved here, so old code using bare `fn` as a variable or argument must choose another name. This source uses `fun`; in particular, write `optim(par, fun = ...)` rather than `optim(par, fn = ...)`.


------


## You do not have to give up ordinary R

The tested Linux instructions install this build in its own folder and use a separate package library. They do not remove ordinary R, alter your projects, rewrite your scripts, or upload your work. Close this R and launch ordinary R as before whenever you want to switch back.


## ARMv7 Android / Termux

The `ARMv7 Termux binary` workflow builds an installable 32-bit `arm` package.
Download its `ir_*.deb` artifact and install it in Termux:

```sh
apt install ./ir_*.deb
ir
```

The package installs `ir` and `irscript` with a private runtime. It does not
replace the ordinary `R` or `Rscript` commands. The exact reproducible entry
point is [`build-armv7-termux`](build-armv7-termux).
