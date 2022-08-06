#!/bin/sh

umask 0022
unalias -a

pushd() { command pushd "$1" > /dev/null; }
popd() { command popd "$1" > /dev/null; }

export PATH=%cross-tools/bin:$PATH

export XARCH=x86-64
export LARCH=x86_64
export MARCH=$LARCH
export XGCCARGS="--with-arch=$XARCH --with-tune=generic"
export XPURE64=$XARCH
export XTARGET=$LARCH-linux-musl
export XHOST=$(gcc -dumpmachine)
#export XHOST="$(echo $(gcc -dumpmachine) | sed -e 's/-[^-]*/-cross/')"

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
