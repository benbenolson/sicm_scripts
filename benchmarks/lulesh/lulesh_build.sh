#!/bin/bash

bench_build c

cd ${BENCH_DIR}/lulesh/src
make clean
make -j $(nproc --all)
mkdir -p ../run
cp lulesh2.0 ../run/lulesh2.0
