#!/bin/bash

cd $SICM_DIR/examples/high/fotonik3d/run
source $SCRIPTS_DIR/all/firsttouch_all_exclusive_device.sh

firsttouch "1" "./fotonik3d"
