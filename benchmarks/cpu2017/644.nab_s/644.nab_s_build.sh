#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build c

export PREPROCESS_WRAPPER="${BENCH_DIR}/cpu2017/bin/specperl -I ${BENCH_DIR}/cpu2017/bin/modules.specpp ${BENCH_DIR}/cpu2017/bin/harness/specpp"

cd $BENCH_DIR/cpu2017/benchmarks/644.nab_s/src
make clean
make -j $(nproc --all)
cp nab_s $BENCH_DIR/cpu2017/benchmarks/644.nab_s/run_test/
cp nab_s $BENCH_DIR/cpu2017/benchmarks/644.nab_s/run_train/
cp nab_s $BENCH_DIR/cpu2017/benchmarks/644.nab_s/run_ref/

