#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build fort

export PREPROCESS_WRAPPER="${BENCH_DIR}/cpu2017/bin/specperl -I ${BENCH_DIR}/cpu2017/bin/modules.specpp ${BENCH_DIR}/cpu2017/bin/harness/specpp"
export SH_CONTEXT=1

cd $BENCH_DIR/cpu2017/benchmarks/621.wrf_s/src
make clean
make -j $(nproc --all)
cp wrf_s $BENCH_DIR/cpu2017/benchmarks/621.wrf_s/run_test/
cp wrf_s $BENCH_DIR/cpu2017/benchmarks/621.wrf_s/run_train/
cp wrf_s $BENCH_DIR/cpu2017/benchmarks/621.wrf_s/run_ref/
