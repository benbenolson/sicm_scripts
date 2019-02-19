#!/bin/bash

ARGS="$@"

qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR,BENCH_DIR=$BENCH_DIR" \
     -F '"'${ARGS}'"' $SCRIPTS_DIR/pbs_scripts/run.pbs
