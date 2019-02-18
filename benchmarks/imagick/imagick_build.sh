#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build "c"

cd $BENCH_DIR/imagick/src
make clean
make -j $(nproc --all)
mkdir -p $BENCH_DIR/imagick/run
cp imagick_s $BENCH_DIR/imagick/run
