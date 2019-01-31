#!/bin/bash

array=(pennant)
for i in "${array[@]}"; do
  qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/${i}/${i}_pebs_128.sh" -N "${i}" run.pbs
done
