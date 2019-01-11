#!/bin/bash

cd $SICM_DIR/examples/high/test_fort
source $SCRIPTS_DIR/all/firsttouch_all_exclusive_device.sh

firsttouch "1" "./test_fort.exe"
