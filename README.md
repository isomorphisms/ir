### λ → ÷ = ←

→ and ← can now be used for assignment, not just `<-` and `->`.

`function(x) x**3` can now be written `λ(x) x**3`.

÷ means division.


Existing R spelling remains available: `<-`, `<<-`, `->`, `->>`, `==`, and `function` still work.



```r
÷ ← λ(a, b) a / b
answer ← 8 ÷ 2
answer = 4
```

The last line returns

```text
[1] TRUE
```

because = now means equal.





| this | does |
|---|---|
| `x ← 3` | assign |
| `x ↞ 3` | assign in parent frame|
| `3 → x` | assign |
| `3 ↠ x` | assign in parent frame |
| `left = right` | test equality |
| `λ(x) expression` or `ƒ(x) expression` | construct a function |
| `left ÷ right`, after defining `÷` | infix operator 





Parameters are still supplied with =.

```r
clean.mean ← λ(x) mean(x, na.rm = TRUE)

```



------

*Actually this is worse than I thought it would be, I thought there would be no downsides....*

That compatibility is contextual. Inside another call, wrap an equality comparison in parentheses so it cannot be read as an argument name:

```r
stopifnot((answer = 4))
```

Code that used a single `=` as assignment must use an arrow in this R. The comma and argument-label rules have otherwise been left alone.


------


## You do not have to give up ordinary R

The tested Linux instructions install this build in its own folder and use a separate package library. They do not remove ordinary R, alter your projects, rewrite your scripts, or upload your work. Close this R and launch ordinary R as before whenever you want to switch back.


