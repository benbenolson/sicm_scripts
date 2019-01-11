#!/bin/bash

cd $SICM_DIR/examples/high/lulesh
source $SCRIPTS_DIR/all/offline_pebs.sh

pebs "128" "25" "hotset" "./lulesh2.0 -s 220 -i 20 -r 11 -b 0 -c 64 -p"
