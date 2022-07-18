#!/bin/sh

if [[ ! -d nya ]]; then
	git clone https://github.com/fafnirlinux/nya
fi

if [[ ! -d nya ]]; then
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
	exit 1
fi

./pkg $1 $2
