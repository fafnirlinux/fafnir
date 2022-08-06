#!/bin/sh

umask 0022
unalias -a

pushd() { command pushd "$1" > /dev/null; }
popd() { command popd "$1" > /dev/null; }

export PATH=%tools/bin:$PATH

export GCCARCH=x86-64
export ARCH=x86_64
export GCCARGS="--with-arch=$GCCARCH --with-tune=generic"
export TARGET=$ARCH-linux-musl
export HOST=$(gcc -dumpmachine)

export CROSS_COMPILE=$TARGET-
export CC=$TARGET-gcc
export CXX=$TARGET-g++
export AR=$TARGET-ar
export AS=$TARGET-as
export RANLIB=$TARGET-ranlib
export LD=$TARGET-ld
export NM=$TARGET-nm
export STRIP=$TARGET-strip
export OBJCOPY=$TARGET-objcopy
export OBJDUMP=$TARGET-objdump
export SIZE=$TARGET-size

export PKG_CONFIG=$TARGET-pkgconf
export PKG_CONFIG_LIBDIR="%rootfs/usr/lib/pkgconfig:%rootfs/usr/share/pkgconfig"
export PKG_CONFIG_PATH="%rootfs/usr/lib/pkgconfig:%rootfs/usr/share/pkgconfig"
export PKG_CONFIG_SYSROOT_DIR="%rootfs"
export PKG_CONFIG_SYSTEM_INCLUDE_PATH="%rootfs/usr/include"
export PKG_CONFIG_SYSTEM_LIBRARY_PATH="%rootfs/usr/lib"

export HOSTFLAGS="--host=$TARGET --with-sysroot=%rootfs"
export BUILDFLAGS="--build=$HOST $HOSTFLAGS"
export TOOLFLAGS="--build=$HOST --host=$TARGET --target=$TARGET --with-sysroot=%rootfs"
export PERLFLAGS="--target=$TARGET"
export CMAKEFLAGS="-DCMAKE_CROSSCOMPILING=ON -DCMAKE_TOOLCHAIN_FILE=%rootfs/share/cmake/cmake.cross"

inst() {
    local action=$@
    if [[ -z $action ]]; then
        action="install"
    fi
    make DESTDIR=%dest $action
}

apply_patch() {
    echo "applying patch $(basename $1)"
    patch -p1 < $1
}

apply_patches() {
	for patch in $1/*; do
		apply_patch $patch
	done
}
