#!/bin/bash

cd $SICM_DIR/examples/high/imagick/run
source $SCRIPTS_DIR/all/offline_pebs.sh

pebs "128" "35" "knapsack" "./imagick -limit disk 0 refspeed_input.tga -resize 817% -rotate -2.76 -shave 540x375 -alpha remove -auto-level -contrast-stretch 1x1% -colorspace Lab -channel R -equalize +channel -colorspace sRGB -define histogram:unique-colors=false -adaptive-blur 0x5 -despeckle -auto-gamma -adaptive-sharpen 55 -enhance -brightness-contrast 10x10 -resize 30% refspeed_output.tga"
