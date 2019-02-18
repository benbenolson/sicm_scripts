#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build fort

# Compile roms
cd $BENCH_DIR/roms/src
make clean
make -j $(nproc --all)
mkdir -p $BENCH_DIR/roms/run
cp sroms ../run/roms
