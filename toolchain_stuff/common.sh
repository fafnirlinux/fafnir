#!/bin/sh

export CC=gcc
export CXX=g++

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
