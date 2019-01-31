#!/bin/bash

cd $SICM_DIR/examples/high/snap/run
source $SCRIPTS_DIR/all/offline_pebs.sh
source $SCRIPTS_DIR/benchmarks/snap/snap_sizes.sh

pebs "128" "25" "thermos" "$LARGE"
