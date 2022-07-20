#!/bin/sh

cd nya_src/build
make -j$(nproc)
rm ../../nya
cp nya ../../
