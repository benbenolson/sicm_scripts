#!/bin/bash

cd $SICM_DIR/examples/high/imagick/run
source $SCRIPTS_DIR/all/firsttouch_all_exclusive_device.sh
source $SCRIPTS_DIR/benchmarks/imagick/imagick_sizes.sh

firsttouch "0" "./imagick -limit disk 0 refspeed_input.tga -resize 50% halfspeed_input.tga"
