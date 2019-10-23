#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build c

export PREPROCESS_WRAPPER="${BENCH_DIR}/cpu2017/bin/specperl -I ${BENCH_DIR}/cpu2017/bin/modules.specpp ${BENCH_DIR}/cpu2017/bin/harness/specpp"

cd $BENCH_DIR/cpu2017/benchmarks/657.xz_s/src
make clean
make -j $(nproc --all)
cp xz_s $BENCH_DIR/cpu2017/benchmarks/657.xz_s/run_test/
cp xz_s $BENCH_DIR/cpu2017/benchmarks/657.xz_s/run_train/
cp xz_s $BENCH_DIR/cpu2017/benchmarks/657.xz_s/run_ref/

