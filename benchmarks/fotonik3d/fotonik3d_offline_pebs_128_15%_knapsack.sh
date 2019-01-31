#!/bin/bash

cd $SICM_DIR/examples/high/fotonik3d/run
source $SCRIPTS_DIR/all/offline_pebs.sh
source $SCRIPTS_DIR/benchmarks/fotonik3d/fotonik3d_sizes.sh


pebs "128" "15" "knapsack" "$LARGE"
