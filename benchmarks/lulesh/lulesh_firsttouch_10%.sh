#!/bin/bash

cd $SICM_DIR/examples/high/lulesh/run
source $SCRIPTS_DIR/all/firsttouch.sh
source $SCRIPTS_DIR/benchmarks/lulesh/lulesh_sizes.sh

firsttouch "10" "$LARGE"
