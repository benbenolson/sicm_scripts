#!/bin/bash

cd $SICM_DIR/examples/high/imagick/run
source $SCRIPTS_DIR/all/firsttouch_all.sh
source $SCRIPTS_DIR/benchmarks/imagick/imagick_sizes.sh

firsttouch "1" "$LARGE"
