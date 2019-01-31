#!/bin/bash

cd $SICM_DIR/examples/high/imagick/run
source $SCRIPTS_DIR/all/firsttouch_all_shared_site.sh
source $SCRIPTS_DIR/benchmarks/imagick/imagick_sizes.sh

firsttouch "0" "$SMALL"
