#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build fort

cd $SICM_DIR/examples/high/test_fort
make clean
make
