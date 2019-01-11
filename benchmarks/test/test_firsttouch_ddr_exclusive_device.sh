#!/bin/bash

cd $SICM_DIR/examples/high/test
source $SCRIPTS_DIR/all/firsttouch_all_exclusive_device.sh

firsttouch "0" "./stream.exe"
