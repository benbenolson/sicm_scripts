#!/bin/bash

cd $SICM_DIR/examples/high/roms/run
source $SCRIPTS_DIR/all/offline_pebs.sh

pebs "128" "35" "knapsack" "./roms < short_ocean_benchmark3.in"
