#!/bin/bash

cd $SICM_DIR/examples/high/roms/run
source $SCRIPTS_DIR/all/offline_pebs.sh
source $SCRIPTS_DIR/benchmarks/roms/roms_sizes.sh

pebs "128" "25" "hotset" "$LARGE"
