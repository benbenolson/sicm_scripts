#!/bin/bash

cd $SICM_DIR/examples/high/roms/run
source $SCRIPTS_DIR/all/offline_pebs.sh

pebs "128" "20" "hotset" "./roms < short_ocean_benchmark3.in"
