#!/bin/sh

[[ ! -f built ]] && touch built

build() {
	grep -q $1 built && return
	./nya build $1 --config config.toolchain && echo $1 >> built && echo "" >> built
}

build openssl
build curl
build expat
build attr
build acl
build bzip2
build lzo
build zstd
build libarchive
build ncurses
build cmake
build libffi
build zlib
build xz
build libxml2
build ninja
build python3-setuptools
build llvm
build gettext
build bmake
build kernel-headers
build musl-headers
build binutils
build autoconf
build automake
build gawk
build perl
build samurai
build bc
build kmod
build gperf
build m4
build pkgconf
build musl
build python3
build bison
build gdbm
build libnsl
build libtirpc
build mpdecimal
build sqlite3
