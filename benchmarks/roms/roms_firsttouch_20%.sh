#!/bin/bash

cd $SICM_DIR/examples/high/roms/run
source $SCRIPTS_DIR/all/firsttouch.sh

firsttouch "20" "./roms < short_ocean_benchmark3.in"
