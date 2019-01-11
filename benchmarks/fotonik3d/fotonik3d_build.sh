#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build "fort"

# Compile Lulesh
cd $SICM_DIR/examples/high/fotonik3d/src
make clean
make -j $(nproc --all)
cp fotonik3d_s $SICM_DIR/examples/high/fotonik3d/run/fotonik3d
