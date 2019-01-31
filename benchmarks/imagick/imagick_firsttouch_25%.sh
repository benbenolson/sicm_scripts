#!/bin/bash

cd $SICM_DIR/examples/high/imagick/run
source $SCRIPTS_DIR/all/firsttouch.sh
source $SCRIPTS_DIR/benchmarks/imagick/imagick_sizes.sh

firsttouch "25" "$LARGE"
