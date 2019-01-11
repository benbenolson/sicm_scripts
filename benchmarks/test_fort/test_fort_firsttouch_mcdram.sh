#!/bin/bash

export SICM_DIR="/lustre/atlas/scratch/molson5/gen010/SICM"
cd $SICM_DIR/examples/high/test_fort
source $SCRIPTS_DIR/all/firsttouch_all.sh

firsttouch "1" "./test_fort.exe"
