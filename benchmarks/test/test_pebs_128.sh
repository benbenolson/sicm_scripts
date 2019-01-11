#!/bin/bash

export SICM_DIR="/lustre/atlas/scratch/molson5/gen010/SICM"
cd $SICM_DIR/examples/high/test
source $SCRIPTS_DIR/all/pebs.sh

pebs "128" "./stream.exe"
