#!/bin/bash

bench_build fort

# For the CPU2017s
export PREPROCESS_WRAPPER="${BENCH_DIR}/cpu2017/bin/specperl -I ${BENCH_DIR}/cpu2017/bin/modules.specpp ${BENCH_DIR}/cpu2017/bin/harness/specpp"

# Compile Lulesh
cd $BENCH_DIR/bwaves/src
make clean
make -j $(nproc --all)
mkdir -p ../run
mv speed_bwaves bwaves.exe
cp bwaves.exe ../run/
