# RStudio on a Mac

## Current status: the Mac build is not ready

There is not yet a tested, signed Mac build of this R for either Apple silicon or Intel. This page will not direct you to an unrelated R installer or ask you to replace the R framework you already use.

When a tested side-by-side build exists, this page will name the exact download and its exact R executable. Until then, nothing is wrong with your Mac; the artifact simply is not ready.

## Opening the finished build in RStudio

RStudio can be pointed at a particular R executable with `RSTUDIO_WHICH_R`. Once the release notes provide the real path, the launch will look like this:

```sh
export RSTUDIO_WHICH_R="/path/from-the-release-notes/bin/R"
open -na RStudio
```

Do not copy that placeholder now. The path must come from a tested release.

After RStudio opens, verify the session in its Console:

```r
R.home()
one ← 1
one ≟ 1
```

The final expression should print `TRUE`. Posit documents the environment-variable selection method here: [Changing R versions for RStudio Desktop](https://support.posit.co/hc/en-us/articles/200486138-Changing-R-versions-for-RStudio-Desktop-IDE).

## Switching back

Quit that RStudio instance and open RStudio normally from Finder or the Dock. Because the override belongs only to the Terminal launch, the normal launch uses your normal R again.

The finished installer must live beside ordinary R. It must not delete ordinary R, modify your projects, rewrite scripts, or upload your work. This repository will not mark the Mac route ready until both installation and switching back have been tested on real Macs.
