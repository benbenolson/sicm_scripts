#!/bin/bash

export SICM_DIR="/lustre/atlas/scratch/molson5/gen010/SICM"
source $SCRIPTS_DIR/all/bench_build.sh
bench_build fort

cd $SICM_DIR/examples/high/test_fort
make clean
make
