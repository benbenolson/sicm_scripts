#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build fort

export PREPROCESS_WRAPPER="${BENCH_DIR}/cpu2017/bin/specperl -I ${BENCH_DIR}/cpu2017/bin/modules.specpp ${BENCH_DIR}/cpu2017/bin/harness/specpp"

cd $BENCH_DIR/cpu2017/benchmarks/654.roms_s/src
make clean
make -j $(nproc --all)
cp sroms $BENCH_DIR/cpu2017/benchmarks/654.roms_s/run_test/roms_
cp sroms $BENCH_DIR/cpu2017/benchmarks/654.roms_s/run_train/roms_s
cp sroms $BENCH_DIR/cpu2017/benchmarks/654.roms_s/run_ref/roms_s

