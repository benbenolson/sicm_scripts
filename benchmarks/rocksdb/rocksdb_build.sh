#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build c

spack install -j80 gflags%clang@6.0.1
spack install -j80 snappy%clang@6.0.1
spack load gflags%clang@6.0.1
spack load snappy%clang@6.0.1

export CC="${COMPILER_WRAPPER}"
export CXX="${COMPILER_WRAPPER}"
export CXXFLAGS="-I$(spack location -i gflags%clang@6.0.1)/include -I$(spack location -i snappy%clang@6.0.1)/include"
export CFLAGS="-I$(spack location -i gflags%clang@6.0.1)/include -I$(spack location -i snappy%clang@6.0.1)/include"
export AR="${AR_WRAPPER}"
export LDFLAGS="$LDFLAGS -ldl -L$(spack location -i gflags%clang@6.0.1)/lib -L$(spack location -i snappy%clang@6.0.1)/lib"
export ROCKSDB_DISABLE_MALLOC_USABLE_SIZE="true"

cd $BENCH_DIR/rocksdb/src
make clean
DEBUG_LEVEL=0 make -j 80 static_lib db_bench
mkdir -p $BENCH_DIR/rocksdb/run
cp db_bench $BENCH_DIR/rocksdb/run/
