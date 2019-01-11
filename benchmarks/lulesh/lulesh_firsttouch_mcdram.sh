#!/bin/bash

cd $SICM_DIR/examples/high/lulesh
source $SCRIPTS_DIR/all/firsttouch_all.sh

firsttouch "1" "./lulesh2.0 -s 220 -i 20 -r 11 -b 0 -c 64 -p"
