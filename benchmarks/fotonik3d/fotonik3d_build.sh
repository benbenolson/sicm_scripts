#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build "fort"

# Compile Lulesh
cd $BENCH_DIR/fotonik3d/src
make clean
make -j $(nproc --all)
mkdir -p $BENCH_DIR/fotonik3d/run
cp fotonik3d_s $BENCH_DIR/fotonik3d/run/fotonik3d
