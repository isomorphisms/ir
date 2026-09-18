# R in the Mac Terminal

## Current status: the Mac build is not ready

There is no tested Mac command-line build here yet. Apple silicon and Intel require separate validation, and this project does not currently provide a signed package for either one.

You do not need to install developer tools merely to be an end user. When a tested build is attached to a release, this page will give one exact download and one exact command.

## What using it will look like

The release will state the real executable path. Starting the separate R will then look like:

```sh
"/path/from-the-release-notes/bin/R" --vanilla
```

Do not copy that placeholder before a tested release supplies the path.

At the R prompt, the quick check is:

```r
answer ← 8 ÷ 2
answer ≟ 4
```

The last line should print `TRUE`.

To leave, run `q()`. Starting the ordinary `R` command afterward returns you to your ordinary installation. The side-by-side build must not remove ordinary R, alter projects, rewrite scripts, or upload data.

People porting or packaging the source can use [`code/PATCHING.md`](code/PATCHING.md) and R's official [macOS development tools](https://mac.r-project.org/tools/). That is maintainer work, not a prerequisite for ordinary users.
