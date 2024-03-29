#!/bin/bash

bench_build c

export PREPROCESS_WRAPPER="${BENCH_DIR}/cpu2017/bin/specperl -I ${BENCH_DIR}/cpu2017/bin/modules.specpp ${BENCH_DIR}/cpu2017/bin/harness/specpp"

cd $BENCH_DIR/nab/src
make clean
make -j $(nproc --all)
mkdir -p ../run
mv nab_s nab.exe
cp nab.exe ../run/
