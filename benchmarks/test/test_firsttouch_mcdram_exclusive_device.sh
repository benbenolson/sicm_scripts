#!/bin/bash

export SICM_DIR="/lustre/atlas/scratch/molson5/gen010/SICM"
cd $SICM_DIR/examples/high/test
source $SCRIPTS_DIR/all/firsttouch_all_exclusive_device.sh

firsttouch "1" "./stream.exe"
