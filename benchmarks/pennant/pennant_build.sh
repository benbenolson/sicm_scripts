#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build c

export PREPROCESS_WRAPPER="${BENCH_DIR}/cpu2017/bin/specperl -I ${BENCH_DIR}/cpu2017/bin/modules.specpp ${BENCH_DIR}/cpu2017/bin/harness/specpp"

# Compile Pennant
cd $BENCH_DIR/pennant/src
make clean
make -j $(nproc --all)
mkdir $BENCH_DIR/pennant/run
cp $BENCH_DIR/pennant/src/build/pennant $BENCH_DIR/pennant/run
