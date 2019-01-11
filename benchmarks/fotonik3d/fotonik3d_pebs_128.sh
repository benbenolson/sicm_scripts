#!/bin/bash

source $SCRIPTS_DIR/all/pebs.sh
cd $SICM_DIR/examples/high/fotonik3d/run

pebs "128" "./fotonik3d"
