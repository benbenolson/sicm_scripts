#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build "c"

cd $SICM_DIR/examples/high/imagick/src
make clean
make -j $(nproc --all)
cp imagick_s $SICM_DIR/examples/high/imagick/run/imagick
