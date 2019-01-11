#!/bin/bash

cd $SICM_DIR/examples/high/roms/run
source $SCRIPTS_DIR/all/firsttouch_all.sh

firsttouch "1" "./roms < short_ocean_benchmark3.in"
