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
