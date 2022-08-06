#!/bin/sh

umask 0022
unalias -a

pushd() { command pushd "$1" > /dev/null; }
popd() { command popd "$1" > /dev/null; }

export PATH=%tools/bin:$PATH

export GCCARCH=x86-64
export ARCH=x86_64
export GCCARGS="--with-arch=$GCCARCH --with-tune=generic"
export TARGET=$ARCH-pc-linux-gnu
export TARGET32=i686-pc-linux-gnu
export HOST=$(gcc -dumpmachine)

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
