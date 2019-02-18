#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build c

# Compile Lulesh
cd $BENCH_DIR/stream/src
${COMPILER_WRAPPER} stream.c -o stream
mkdir -p ../run
cp stream ../run/stream
