#!/bin/sh

export CC=gcc
export CXX=g++

export CFLAGS=-O2
export CXXFLAGS=-O2

export XARCH=x86-64
export LARCH=x86_64
export MARCH=$LARCH
export XGCCARGS="--with-arch=$XARCH --with-tune=generic"
export XPURE64=$XARCH
export XTARGET=$LARCH-linux-musl

export HOSTCC=$CC HOSTCXX=$CXX

alias make="make INFO_DEPS= infodir= ac_cv_prog_lex_root=lex.yy MAKEINFO=true"

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
