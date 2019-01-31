#!/bin/bash

cd $SICM_DIR/examples/high/pennant/run
source $SCRIPTS_DIR/all/offline_pebs.sh
source $SCRIPTS_DIR/benchmarks/pennant/pennant_sizes.sh

pebs "128" "40" "hotset" "$LARGE"
