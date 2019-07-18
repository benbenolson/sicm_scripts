#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build fort

cd $BENCH_DIR/cam4/src
make clean
make -j $(nproc --all)
mkdir -p ../run
cp cam4_s ../run/cam4
