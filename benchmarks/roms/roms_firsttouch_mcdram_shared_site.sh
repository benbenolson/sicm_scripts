#!/bin/bash

cd $SICM_DIR/examples/high/roms/run
source $SCRIPTS_DIR/all/firsttouch_all_shared_site.sh
source $SCRIPTS_DIR/benchmarks/roms/roms_sizes.sh

firsttouch "1" "$SMALL"
