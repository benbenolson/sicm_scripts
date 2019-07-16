#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build fort

# Compile Lulesh
cd $BENCH_DIR/bwaves/src
make clean
make -j $(nproc --all)
mkdir -p ../run
cp speed_bwaves ../run/bwaves
