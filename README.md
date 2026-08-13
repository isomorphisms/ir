# R, with the symbols it means

Assignment points somewhere. Equality is equality. A lambda may look like λ. Mathematical operators may look mathematical.

This is a small change to R itself—not an RStudio plug-in and not a program that rewrites your files.

> [!IMPORTANT]
> This is currently a **tested Linux source preview**. The Windows and macOS installers have not been built or tested yet. Their guides say so plainly; if you use either platform, the missing installer is not a problem on your computer.

## Start with the one page that matches you

| You use | Open this |
|---|---|
| RStudio on Windows | [RStudio on Windows](RStudio-on-Windows.md) |
| RStudio on a Mac | [RStudio on a Mac](RStudio-on-Mac.md) |
| R in the Mac Terminal | [R in the Mac Terminal](R-in-the-Mac-Terminal.md) |
| Linux, with or without RStudio | [R on Linux](R-on-Linux.md) |

You do not need to browse the source code. It is all inside [`code/`](code/) so these five pages can be the front door.

## What it looks like

```r
÷ ← λ(a, b) a / b
answer ← 8 ÷ 2
answer = 4
```

The last line returns:

```text
[1] TRUE
```

The example defines `÷` before using it. Mathematical glyphs are ordinary bindable operators here; the project does not secretly choose their meanings for you.

## What changed

| You write | It means |
|---|---|
| `name ← value` | assign to `name` |
| `name ↞ value` | assign outside the current environment |
| `value → name` | assign to `name` |
| `value ↠ name` | assign outside the current environment |
| `left = right` | test equality |
| `λ(x) expression` or `ƒ(x) expression` | construct a function |
| `left ÷ right`, after defining `÷` | call a mathematical infix operator |

Existing R spelling remains available: `<-`, `<<-`, `->`, `->>`, `==`, and `function` still work.

Named arguments and function defaults also keep their familiar spelling:

```r
mean(x, na.rm = TRUE)
increment ← λ(amount = 1) amount + 1
```

That compatibility is contextual. Inside another call, wrap an equality comparison in parentheses so it cannot be read as an argument name:

```r
stopifnot((answer = 4))
```

Code that used a single `=` as assignment must use an arrow in this R. The comma and argument-label rules have otherwise been left alone.

## You do not have to give up ordinary R

The tested Linux instructions install this build in its own folder and use a separate package library. They do not remove ordinary R, alter your projects, rewrite your scripts, or upload your work. Close this R and launch ordinary R as before whenever you want to switch back.

Because this source is based on **R 4.7.0 Under development (unstable)**, treat it as an experimental R installation. Packages may need to be installed again for it; that does not remove the packages used by your ordinary R installation.

Windows and Mac will get the same side-by-side promise only after their installers have actually passed platform testing. This repository will not call those installers ready before then.

If you maintain or port the implementation, the patch order, parser invariants, and build checks live in [`code/PATCHING.md`](code/PATCHING.md).
