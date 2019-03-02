#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build c

cd $BENCH_DIR/test/src
${COMPILER_WRAPPER} -g -c -O0 test.c -o test.o
${LD_WRAPPER} -g test.o -lpthread -o test
cp test ../run
