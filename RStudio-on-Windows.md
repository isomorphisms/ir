# RStudio on Windows

## Current status: the installer is not ready

There is not yet a Windows installer for this R. It has not been built or tested on Windows, so this page will not ask you to install Rtools, apply a patch, or pretend that an unverified download is safe.

You can keep this page bookmarked. When a tested installer exists, the status above will change and the exact download will be named here.

## What the finished route will protect

The Windows build must install beside ordinary R. It must not remove your current R, change your project files, rewrite scripts, or send your data anywhere. Trying it should be reversible by choosing your usual R again in RStudio.

## Selecting it in RStudio, after it exists

RStudio supports side-by-side R installations on Windows. After installing the tested build:

1. Close any R sessions you no longer need.
2. In RStudio, open **Tools → Global Options → General → Basic → R Sessions**.
3. Next to **R version**, select **Change**.
4. Choose the separately installed build described by this page, then restart RStudio.

You can also hold **Ctrl** while RStudio starts to open its R-version chooser. These are Posit's documented Windows controls: [Changing R versions for RStudio Desktop](https://support.posit.co/hc/en-us/articles/200486138-Changing-R-versions-for-the-RStudio-Desktop-IDE).

In the Console, check the result:

```r
R.version.string
one ← 1
one = 1
```

The final expression should print `TRUE`.

## Switching back

Repeat the same R-version choice and select your ordinary R installation. Your projects are still where you left them. Uninstalling the experimental build must not uninstall ordinary R.

Until this page says **Windows tested**, please stop here. The missing installer is work remaining in this project, not work the user is expected to do.
