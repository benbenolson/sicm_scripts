#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build fort

export PREPROCESS_WRAPPER="${BENCH_DIR}/cpu2017/bin/specperl -I ${BENCH_DIR}/cpu2017/bin/modules.specpp ${BENCH_DIR}/cpu2017/bin/harness/specpp"
export SH_CONTEXT="0"

cd $BENCH_DIR/wrf/src
make clean
make -j $(nproc --all)
#./link.sh
mkdir -p ../run
mv wrf_s wrf.exe
cp wrf.exe ../run/
