#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build c

# Compile Lulesh
cd $SICM_DIR/examples/high/lulesh
make clean
make -j $(nproc --all)
