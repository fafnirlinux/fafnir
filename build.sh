#!/bin/sh

if [[ ! -d nya ]]; then
	git clone https://github.com/fafnirlinux/nya
fi

if [[ ! -d nya ]]; then
	echo "couldn't clone nya"
	exit 1
fi

cd nya
mkdir -p build
cd build
cmake ..
make -j$(nproc)
cp nya ../../pkg
cd ../../

if [[ ! -f pkg ]]; then
	exit 1
fi

if [[ ! -d src ]]; then
	mkdir -p src
	cd src
	git clone https://github.com/fafnirlinux/repo pkg
	mv pkg/stuff .
	cd ..
fi

if [[ ! -d src ]]; then
	echo "couldn't clone packages"
	exit 1
fi

if [[ ! -d toolchain ]]; then
	./scripts/toolchain.sh
fi

./pkg $1 $2
