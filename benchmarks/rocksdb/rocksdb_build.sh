#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build c

export CC="${COMPILER_WRAPPER}"
export CXX="${COMPILER_WRAPPER}"
export AR="${AR_WRAPPER}"

cd $BENCH_DIR/rocksdb/src
make clean
make -j 80 static_lib
