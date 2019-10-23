#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build "c"

export PREPROCESS_WRAPPER="${BENCH_DIR}/cpu2017/bin/specperl -I ${BENCH_DIR}/cpu2017/bin/modules.specpp ${BENCH_DIR}/cpu2017/bin/harness/specpp"

cd $BENCH_DIR/cpu2017/benchmarks/638.imagick_s/src
make clean
make -j $(nproc --all)
cp imagick_s $BENCH_DIR/cpu2017/benchmarks/638.imagick_s/run_test/
cp imagick_s $BENCH_DIR/cpu2017/benchmarks/638.imagick_s/run_train/
cp imagick_s $BENCH_DIR/cpu2017/benchmarks/638.imagick_s/run_ref/
