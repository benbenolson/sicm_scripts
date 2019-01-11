#!/bin/bash

cd $SICM_DIR/examples/high/fotonik3d/run
source $SCRIPTS_DIR/all/offline_pebs.sh

pebs "128" "15" "knapsack" "./fotonik3d"
