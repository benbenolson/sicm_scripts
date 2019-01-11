#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build fort

# Compile roms
cd $SICM_DIR/examples/high/roms/src
make clean
make -j $(nproc --all)
cp sroms ../run/roms
