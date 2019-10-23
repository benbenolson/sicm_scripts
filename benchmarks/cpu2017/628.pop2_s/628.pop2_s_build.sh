#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build fort

export PREPROCESS_WRAPPER="${BENCH_DIR}/cpu2017/bin/specperl -I ${BENCH_DIR}/cpu2017/bin/modules.specpp ${BENCH_DIR}/cpu2017/bin/harness/specpp"
export SH_CONTEXT=0

cd $BENCH_DIR/cpu2017/benchmarks/628.pop2_s/src
make clean
make -j $(nproc --all)
cp speed_pop2 $BENCH_DIR/cpu2017/benchmarks/628.pop2_s/run_test/pop2_s
cp speed_pop2 $BENCH_DIR/cpu2017/benchmarks/628.pop2_s/run_train/pop2_s
cp speed_pop2 $BENCH_DIR/cpu2017/benchmarks/628.pop2_s/run_ref/pop2_s

