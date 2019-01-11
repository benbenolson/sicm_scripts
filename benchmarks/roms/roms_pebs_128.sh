#!/bin/bash

cd $SICM_DIR/examples/high/roms/run
source $SCRIPTS_DIR/all/pebs.sh

pebs "128" "./roms < short_ocean_benchmark3.in"
