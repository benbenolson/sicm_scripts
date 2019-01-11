#!/bin/bash

cd $SICM_DIR/examples/high/roms/run
source $SCRIPTS_DIR/all/firsttouch_all_shared_site.sh

firsttouch "1" "./roms < short_ocean_benchmark3.in"
