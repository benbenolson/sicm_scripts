#!/bin/bash

export SICM_DIR="/lustre/atlas/scratch/molson5/gen010/SICM"
source $SCRIPTS_DIR/all/bench_build.sh
bench_build c

# Compile Lulesh
cd $SICM_DIR/examples/high/test
make clean
make
