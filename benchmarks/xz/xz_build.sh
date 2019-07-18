#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build c

cd $BENCH_DIR/xz/src
make clean
make -j $(nproc --all)
mkdir -p ../run
cp xz_r ../run/xz
