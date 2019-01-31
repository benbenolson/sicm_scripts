#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build c

# Compile Lulesh
cd $SICM_DIR/examples/high/lulesh/src
make clean
make -j $(nproc --all)
cp lulesh2.0 ../run/lulesh2.0
