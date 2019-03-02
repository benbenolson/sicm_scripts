#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build c

cd $BENCH_DIR/access-count/src
${COMPILER_WRAPPER} -g access_count.c -o access_count
mkdir -p ../run
cp access_count ../run/access_count
