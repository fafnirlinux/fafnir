#!/bin/sh

umask 0022
unalias -a

pushd() { command pushd "$1" > /dev/null; }
popd() { command popd "$1" > /dev/null; }

export PATH=%tools/bin:/bin:/usr/bin

export XARCH=x86-64
export LARCH=x86_64
export MARCH=$LARCH
export GCCARGS="--with-arch=$XARCH --with-tune=generic"
export XTARGET=$LARCH-pc-linux-musl
export XHOST=$(gcc -dumpmachine)

export CROSS_COMPILE=$XTARGET-
export CC=$XTARGET-gcc
export CXX=$XTARGET-g++
export AR=$XTARGET-ar
export AS=$XTARGET-as
export RANLIB=$XTARGET-ranlib
export LD=$XTARGET-ld
export NM=$XTARGET-nm
export STRIP=$XTARGET-strip
export OBJCOPY=$XTARGET-objcopy
export OBJDUMP=$XTARGET-objdump
export SIZE=$XTARGET-size

#export PKG_CONFIG=$XTARGET-pkgconf
#export PKG_CONFIG_LIBDIR="%tools/usr/lib/pkgconfig:%tools/usr/share/pkgconfig"
#export PKG_CONFIG_PATH="%tools/usr/lib/pkgconfig:%tools/usr/share/pkgconfig"
#export PKG_CONFIG_SYSROOT_DIR="%rootfs"
#export PKG_CONFIG_SYSTEM_INCLUDE_PATH="%rootfs/usr/include"
#export PKG_CONFIG_SYSTEM_LIBRARY_PATH="%rootfs/usr/lib"

export HOSTFLAGS="--host=$XTARGET --with-sysroot=%rootfs"
export BUILDFLAGS="--build=$XHOST $HOSTFLAGS"
export TOOLFLAGS="--build=$XHOST --host=$XTARGET --target=$XTARGET --with-sysroot=%rootfs"
export PERLFLAGS="--target=$XTARGET"
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
