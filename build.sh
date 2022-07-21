#!/bin/sh

if [[ ! -d nya_src ]]; then
	git clone https://github.com/fafnirlinux/nya nya_src
fi

if [[ ! -d nya_src ]]; then
	echo "couldn't clone nya"
	exit 1
fi

cd nya_src
mkdir -p build
cd build
cmake ..
make -j$(nproc)
cp nya ../../
cd ../../

if [[ ! -f nya ]]; then
	exit 1
fi

if [[ ! -d src/pkg ]]; then
	mkdir -p src
	cd src
	git clone https://github.com/fafnirlinux/repo pkg
	[[ -d stuff ]] && rm -rf stuff
	mv pkg/stuff .
	cd ..
fi

if [[ ! -d src ]]; then
	exit 1
fi

./toolchain.sh
