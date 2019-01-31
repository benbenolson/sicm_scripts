#!/bin/bash

cd $SICM_DIR/examples/high/lulesh/run
source $SCRIPTS_DIR/all/firsttouch_all_shared_site.sh
source $SCRIPTS_DIR/benchmarks/lulesh/lulesh_sizes.sh

firsttouch "0" "$SMALL"
