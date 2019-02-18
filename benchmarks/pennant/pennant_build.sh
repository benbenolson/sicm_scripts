#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build c

# Compile Pennant
cd $BENCH_DIR/pennant/src
make clean
make -j $(nproc --all)
mkdir $BENCH_DIR/pennant/run
cp $BENCH_DIR/pennant/src/build/pennant $BENCH_DIR/pennant/run
