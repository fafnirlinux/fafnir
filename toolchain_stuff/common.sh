#!/bin/sh

export CC=clang
export CXX=clang++

export HOSTCC=$CC HOSTCXX=$CXX

xconfflags=

if [[ $STAGE = 0 ]]; then
	export machine=$($CC -dumpmachine)
	xconfflags="--host=$machine --target=$machine"
fi

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
