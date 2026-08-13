# R on Linux

## Current status: tested source preview

This route was clean-built and regression-tested on **Ubuntu 24.04 x86-64**. It is a lean R 4.7.0 development build: X11, Tcl/Tk, Java, and the recommended-package bundle are disabled. The language changes work, but this is not yet a polished binary distribution.

You do not need Git and you do not need to understand the source. The commands below install into your home folder, beside ordinary R.

## 1. Download this repository

On the repository's main page, select **Code → Download ZIP**, then unzip it. Open the extracted folder in your file manager and choose **Open in Terminal**.

## 2. Install the ordinary build prerequisites

On Ubuntu 24.04 or a compatible Debian-based system:

```sh
sudo apt update
sudo apt install build-essential gfortran perl pkg-config texinfo \
  libreadline-dev libpcre2-dev libcurl4-openssl-dev \
  libbz2-dev liblzma-dev zlib1g-dev libdeflate-dev
```

This installs standard compilers and libraries from Ubuntu; it does not replace R.

## 3. Build and install this R in its own folder

Run these commands from the extracted repository folder:

```sh
mkdir build
cd build
sh ../code/configure \
  --prefix="$HOME/.local/r-with-symbols" \
  --with-x=no \
  --without-tcltk \
  --without-recommended-packages \
  --disable-java
make -j2
make install
mkdir -p "$HOME/.local/r-with-symbols-library"
```

The build can take a while and prints a great deal of routine compiler output. The important result is that both `make` and `make install` finish without an error.

## 4. Start it in the Terminal

```sh
R_LIBS_USER="$HOME/.local/r-with-symbols-library" \
  "$HOME/.local/r-with-symbols/bin/R" --vanilla
```

Then try:

```r
÷ ← λ(a, b) a / b
answer ← 8 ÷ 2
answer = 4
```

The final line should print:

```text
[1] TRUE
```

Run `q()` to leave. Your ordinary `R` command still starts ordinary R.

## Use the same build in RStudio Desktop

If the `rstudio` command is available, launch a separate RStudio process from the Terminal:

```sh
R_LIBS_USER="$HOME/.local/r-with-symbols-library" \
RSTUDIO_WHICH_R="$HOME/.local/r-with-symbols/bin/R" \
  rstudio
```

In RStudio's Console, run `R.home()` and confirm that it begins with your `.local/r-with-symbols` folder. Posit documents `RSTUDIO_WHICH_R` as its Linux version-selection override: [Changing R versions for RStudio Desktop](https://support.posit.co/hc/en-us/articles/200486138-Changing-R-versions-for-the-RStudio-Desktop-IDE).

RStudio was not installed in the build environment used for this project, so the RStudio handoff follows Posit's documented mechanism but has not yet been exercised here. The R build itself and its regression tests were exercised.

## Switch back or remove it

Close this R or RStudio session. Launch ordinary R or open RStudio normally, without the two environment-variable lines above.

The experimental R lives in `~/.local/r-with-symbols`, and its package library lives in `~/.local/r-with-symbols-library`. Removing those two folders removes this build; it does not remove ordinary R or its packages. Your projects and scripts are not changed by installing or removing it.
