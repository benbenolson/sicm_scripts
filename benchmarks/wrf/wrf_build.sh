#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build fort

cd $BENCH_DIR/wrf/src
make clean
make -j $(nproc --all)
mkdir -p ../run
cp wrf_s ../run/wrf
