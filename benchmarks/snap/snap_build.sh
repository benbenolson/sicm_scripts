#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build fort

#export COMPILER_WRAPPER="gfortran"
#export PREPROCESS_WRAPPER="$SICM_DIR/deps/bin/clang -x c"
#export LD_WRAPPER="gfortran"

# Compile Lulesh
cd $SICM_DIR/examples/high/snap/src
make clean
make -j $(nproc --all)
cp gsnap ../run/snap
