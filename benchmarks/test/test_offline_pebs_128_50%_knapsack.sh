#!/bin/bash

cd $SICM_DIR/examples/high/test
source $SCRIPTS_DIR/all/offline_pebs.sh

pebs "128" "50" "knapsack" "./stream.exe"
