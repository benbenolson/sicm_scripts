#!/bin/bash

bench_build fort

# Compile SNAP
cd $BENCH_DIR/snap/src/src
make clean
make -j $(nproc --all)
mkdir -p $BENCH_DIR/snap/run
cp $BENCH_DIR/snap/src/src/gsnap $BENCH_DIR/snap/run/snap
