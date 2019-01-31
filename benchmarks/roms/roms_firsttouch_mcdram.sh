#!/bin/bash

cd $SICM_DIR/examples/high/roms/run
source $SCRIPTS_DIR/all/firsttouch_all.sh
source $SCRIPTS_DIR/benchmarks/roms/roms_sizes.sh

firsttouch "1" "$LARGE"
