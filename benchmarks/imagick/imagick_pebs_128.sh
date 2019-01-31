#!/bin/bash

source $SCRIPTS_DIR/all/pebs.sh
cd $SICM_DIR/examples/high/imagick/run
source $SCRIPTS_DIR/benchmarks/imagick/imagick_sizes.sh

pebs "128" "$SMALL"
