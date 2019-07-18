#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build fort

cd $BENCH_DIR/pop2/src
make clean
make -j $(nproc --all)
mkdir -p ../run
cp pop2_s ../run/pop2
