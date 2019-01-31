#!/bin/bash

source $SCRIPTS_DIR/all/pebs.sh
cd $SICM_DIR/examples/high/fotonik3d/run
source $SCRIPTS_DIR/benchmarks/fotonik3d/fotonik3d_sizes.sh


pebs "128" "$SMALL"
