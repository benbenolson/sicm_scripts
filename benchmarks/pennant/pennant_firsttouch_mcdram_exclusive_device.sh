#!/bin/bash

cd $SICM_DIR/examples/high/pennant/run
source $SCRIPTS_DIR/all/firsttouch_all_exclusive_device.sh
source $SCRIPTS_DIR/benchmarks/pennant/pennant_sizes.sh

firsttouch "1" "$LARGE"
