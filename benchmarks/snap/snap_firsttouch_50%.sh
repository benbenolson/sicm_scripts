#!/bin/bash

cd $SICM_DIR/examples/high/snap/run
source $SCRIPTS_DIR/all/firsttouch.sh
source $SCRIPTS_DIR/benchmarks/snap/snap_sizes.sh

firsttouch "50" "$LARGE"
