#!/bin/sh

build() {
	./nya build $1 --config config.toolchain
}

build musl
