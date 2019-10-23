#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build fort

# For the CPU2017s
export PREPROCESS_WRAPPER="${BENCH_DIR}/cpu2017/bin/specperl -I ${BENCH_DIR}/cpu2017/bin/modules.specpp ${BENCH_DIR}/cpu2017/bin/harness/specpp"

# Compile bwaves
cd $BENCH_DIR/cpu2017/benchmarks/603.bwaves_s/src
make clean
make -j $(nproc --all)
cp speed_bwaves $BENCH_DIR/cpu2017/benchmarks/603.bwaves_s/run_ref/bwaves_s
cp speed_bwaves $BENCH_DIR/cpu2017/benchmarks/603.bwaves_s/run_train/bwaves_s
cp speed_bwaves $BENCH_DIR/cpu2017/benchmarks/603.bwaves_s/run_test/bwaves_s
