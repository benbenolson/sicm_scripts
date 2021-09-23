#!/bin/bash

bench_build fort

export PREPROCESS_WRAPPER="${BENCH_DIR}/cpu2017/bin/specperl -I ${BENCH_DIR}/cpu2017/bin/modules.specpp ${BENCH_DIR}/cpu2017/bin/harness/specpp"
export SH_CONTEXT="0"

cd $BENCH_DIR/cam4/src
make clean
make -j $(nproc --all)
mkdir -p ../run
mv cam4_s cam4.exe
cp cam4.exe ../run/
