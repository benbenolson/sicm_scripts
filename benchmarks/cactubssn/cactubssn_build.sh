#!/bin/bash

bench_build c
export SH_CONTEXT="0"

export PREPROCESS_WRAPPER="${BENCH_DIR}/cpu2017/bin/specperl -I ${BENCH_DIR}/cpu2017/bin/modules.specpp ${BENCH_DIR}/cpu2017/bin/harness/specpp"

# Compile Lulesh
cd $BENCH_DIR/cactubssn/src
make clean
make -j $(nproc --all)
mkdir -p ../run
mv cactuBSSN_s cactubssn.exe
cp cactubssn.exe ../run/
