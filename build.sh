#!/bin/sh

cd nya
mkdir -p build
cd build
if [[ ! -f Makefile ]]; then
	cmake ..
fi
make -j$(nproc)
cp nya ../../pkg
cd ../../

./pkg $1 $2