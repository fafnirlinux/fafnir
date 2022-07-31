#!/bin/sh

export PATH=%tools/bin:$PATH

export XARCH=x86-64
export LARCH=x86_64
export MARCH=$LARCH
export XGCCARGS="--with-arch=$XARCH --with-tune=generic"
export XPURE64=$XARCH
export XTARGET=$LARCH-linux-musl

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

export PKG_CONFIG=$XTARGET-pkgconf
export PKG_CONFIG_LIBDIR="%rootfs/usr/lib/pkgconfig:%rootfs/usr/share/pkgconfig"
export PKG_CONFIG_PATH="%rootfs/usr/lib/pkgconfig:%rootfs/usr/share/pkgconfig"
export PKG_CONFIG_SYSROOT_DIR="%rootfs"
export PKG_CONFIG_SYSTEM_INCLUDE_PATH="%rootfs/usr/include"
export PKG_CONFIG_SYSTEM_LIBRARY_PATH="%rootfs/usr/lib"

export HOSTCC=$CC HOSTCXX=$CXX

alias make="make INFO_DEPS= infodir= ac_cv_prog_lex_root=lex.yy MAKEINFO=true"

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
