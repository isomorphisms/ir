TERMUX_PKG_HOMEPAGE=https://github.com/isomorphisms/ir
TERMUX_PKG_DESCRIPTION="R with ir's mathematical notation, isolated from ordinary R"
TERMUX_PKG_LICENSE="GPL-2.0-or-later, LGPL-2.1"
TERMUX_PKG_LICENSE_FILE="COPYING"
TERMUX_PKG_MAINTAINER="@isomorphisms"
TERMUX_PKG_VERSION="@IR_PACKAGE_VERSION@"
TERMUX_PKG_SRCURL=file:///data/data/com.termux/files/home/termux-packages/sources/ir
TERMUX_PKG_SHA256=SKIP_CHECKSUM
TERMUX_PKG_DEPENDS="libandroid-glob, libdeflate, libiconv, libbz2, libcurl, liblzma, pcre2, readline, zlib, zstd"
TERMUX_PKG_BUILD_DEPENDS="binutils, gcc-15, which"
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
ac_cv_have_decl_wctrans=yes
--with-x=no
--without-tcltk
--without-recommended-packages
--disable-java
--enable-R-shlib
--with-readline=yes
--libdir=$TERMUX_PREFIX/lib/ir
"

# R's build invokes the R executable it has just compiled.  Build it inside
# TUR's native 32-bit Android environment rather than pretending it can be
# cross-compiled by an ordinary NDK job.
TERMUX_PKG_MAKE_PROCESSES=1

termux_step_pre_configure() {
	if [ "${TERMUX_ON_DEVICE_BUILD}" = false ]; then
		termux_error_exit "ir requires TUR's native Android build environment."
	fi

	CFLAGS="${CFLAGS/-Oz/-O0}"
	CXXFLAGS="${CXXFLAGS/-Oz/-O0}"
	# Android's 32-bit wchar_t stores Unicode code points, but bionic does not
	# advertise that with the ISO 10646 feature macro expected by R.
	CPPFLAGS+=" -D__STDC_ISO_10646__=201706L"
	LDFLAGS="${LDFLAGS/-static-openmp/}"
	LDFLAGS+=" -landroid-glob"
	export LANG=C.UTF-8
	export LC_ALL=C.UTF-8
	CROSS_PREFIX=$TERMUX_ARCH-linux-android
	if [ "$TERMUX_ARCH" = arm ]; then
		CROSS_PREFIX=arm-linux-androideabi
	fi

	export AR=$CROSS_PREFIX-ar
	export AS=$CROSS_PREFIX-as
	export LD=$CROSS_PREFIX-ld
	export NM=$CROSS_PREFIX-nm
	export CC=$CROSS_PREFIX-gcc-15
	export FC=$CROSS_PREFIX-gfortran-15
	export CXX=$CROSS_PREFIX-g++-15
	unset CPP CXXCPP STRINGS
	export STRIP=$CROSS_PREFIX-strip
	export RANLIB=$CROSS_PREFIX-ranlib

	if [ "$TERMUX_ARCH" = arm ]; then
		export MAKEFLAGS="-j1 --jobserver-style=pipe"
	fi
}

termux_step_post_make_install() {
	test -f "$TERMUX_PREFIX/bin/R"
	test -f "$TERMUX_PREFIX/bin/Rscript"
	mv "$TERMUX_PREFIX/bin/R" "$TERMUX_PREFIX/bin/ir"
	mv "$TERMUX_PREFIX/bin/Rscript" "$TERMUX_PREFIX/bin/irscript"

	if test -f "$TERMUX_PREFIX/share/man/man1/R.1"; then
		mv "$TERMUX_PREFIX/share/man/man1/R.1" \
			"$TERMUX_PREFIX/share/man/man1/ir.1"
	fi
	if test -f "$TERMUX_PREFIX/share/man/man1/Rscript.1"; then
		mv "$TERMUX_PREFIX/share/man/man1/Rscript.1" \
			"$TERMUX_PREFIX/share/man/man1/irscript.1"
	fi
}
