#!/bin/bash

cd $SICM_DIR/examples/high/test
source $SCRIPTS_DIR/all/pebs.sh

pebs "128" "./stream.exe"
