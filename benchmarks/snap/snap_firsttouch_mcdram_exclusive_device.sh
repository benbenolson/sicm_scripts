#!/bin/bash

cd $SICM_DIR/examples/high/snap/run
source $SCRIPTS_DIR/all/firsttouch_all_exclusive_device.sh
source $SCRIPTS_DIR/benchmarks/snap/snap_sizes.sh

firsttouch "1" "$LARGE"
