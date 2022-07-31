#!/bin/sh

umask 0022
unalias -a

pushd() { command pushd "$1" > /dev/null; }
popd() { command popd "$1" > /dev/null; }

export PATH=%tools/bin:$PATH

export XARCH=x86-64
export LARCH=x86_64
export MARCH=$LARCH
export XGCCARGS="--with-arch=$XARCH --with-tune=generic"
export XPURE64=$XARCH
export XTARGET=$LARCH-linux-musl
export XHOST=$(gcc -dumpmachine)
#export XHOST="$(echo $(gcc -dumpmachine) | sed -e 's/-[^-]*/-cross/')"

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

export BUILDFLAGS="--build=$XHOST --host=$XTARGET"
export TOOLFLAGS="--build=$XHOST --host=$XTARGET --target=$XTARGET"
export PERLFLAGS="--target=$XTARGET"

export xcflags="-D_FORTIFY_SOURCE=2 -g0 -Os -flto -fomit-frame-pointer -fno-asynchronous-unwind-tables -fno-unwind-tables -ffunction-sections -fdata-sections -fstack-protector-strong -fstack-clash-protection -mretpoline --param=ssp-buffer-size=4 -pipe"
export xldflags="-Wl,-z,relro,-z,now -Wl,--as-needed -Wl,--gc-sections -Wl,-z,noexecstack -s"

export HOSTCC=$CC HOSTCXX=$CXX

#alias make="make INFO_DEPS= infodir= ac_cv_prog_lex_root=lex.yy MAKEINFO=true"

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
