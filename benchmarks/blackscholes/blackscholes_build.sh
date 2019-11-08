#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build c

# Compile Lulesh
cd $BENCH_DIR/blackscholes/src
make clean
make -j $(nproc --all)
mkdir -p ../run
cp blackscholes ../run/blackscholes
