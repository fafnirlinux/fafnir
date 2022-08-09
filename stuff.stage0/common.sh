#!/bin/sh

umask 0022
unalias -a
#set -e

pushd() { command pushd "$1" > /dev/null; }
popd() { command popd "$1" > /dev/null; }

export PATH=%cross-tools/bin:$PATH

export XARCH=x86-64
export LARCH=x86_64
export MARCH=$LARCH

export XHOST=$(gcc -dumpmachine)
export XTARGET=$LARCH-linux-musl

host=$XHOST
target=$XTARGET

libSuffix=64

multilib_options="--with-multilib-list=m64"
gcc_options="--with-arch=$XARCH --with-tune=generic"

export CFLAGS="-O2"
export CXXFLAGS=$CFLAGS

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
    return 0
}

apply_patches() {
	for patch in $1/*; do
		apply_patch $patch
	done
}
