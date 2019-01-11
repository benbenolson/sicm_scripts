#!/bin/bash

cd $SICM_DIR/examples/high/fotonik3d/run
source $SCRIPTS_DIR/all/offline_pebs.sh

pebs "128" "45" "hotset" "./fotonik3d"
