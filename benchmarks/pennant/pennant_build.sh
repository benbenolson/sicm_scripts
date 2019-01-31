#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build c

# Compile Pennant
cd $SICM_DIR/examples/high/pennant/src
make clean
make -j $(nproc --all)
mkdir -p ../run
cp build/pennant ../run
