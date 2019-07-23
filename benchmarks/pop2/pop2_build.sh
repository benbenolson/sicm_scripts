#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build fort

cd $BENCH_DIR/pop2/src
make clean
make -j $(nproc --all)
mkdir -p ../run
cp speed_pop2 ../run/pop2
