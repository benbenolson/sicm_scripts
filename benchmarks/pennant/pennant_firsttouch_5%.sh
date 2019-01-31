#!/bin/bash

cd $SICM_DIR/examples/high/pennant/run
source $SCRIPTS_DIR/all/firsttouch.sh
source $SCRIPTS_DIR/benchmarks/pennant/pennant_sizes.sh

firsttouch "5" "$LARGE"
