#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build fort

# Compile SNAP
cd $BENCH_DIR/snap/src
make clean
make -j $(nproc --all)
mkdir -p $BENCH_DIR/snap/run
cp $BENCH_DIR/snap/src/gsnap $BENCH_DIR/snap/run/snap
