#!/bin/bash

bench_build "c"

export PREPROCESS_WRAPPER="${BENCH_DIR}/cpu2017/bin/specperl -I ${BENCH_DIR}/cpu2017/bin/modules.specpp ${BENCH_DIR}/cpu2017/bin/harness/specpp"

cd $BENCH_DIR/imagick/src
make clean
make -j $(nproc --all)
mkdir -p $BENCH_DIR/imagick/run
mv imagick_s imagick.exe
cp imagick.exe ../run/
