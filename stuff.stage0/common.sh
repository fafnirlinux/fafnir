#!/bin/sh

umask 0022
unalias -a

pushd() { command pushd "$1" > /dev/null; }
popd() { command popd "$1" > /dev/null; }

export PATH=%tools/bin:/bin:/usr/bin

export CFLAGS="-O2 -march=x86-64 -pipe"
export LC_ALL=C

export XARCH=x86-64
export LARCH=x86_64
export MARCH=$LARCH
export GCCARGS="--with-arch=$XARCH --with-tune=generic"
export XTARGET=$LARCH-fafnir-linux-gnu
export XTARGET32=i686-fafnir-linux-gnu
export XHOST=$(gcc -dumpmachine)

unset LD_LIBRARY_PATH

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
