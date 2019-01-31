#!/bin/bash

array=(pennant)
for i in "${array[@]}"; do
  qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/${i}/${i}_firsttouch_ddr_exclusive_device.sh" -N "${i}" run.pbs
  qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/${i}/${i}_firsttouch_mcdram_exclusive_device.sh" -N "${i}" run.pbs
  #qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/${i}/${i}_firsttouch_ddr_shared_site.sh" -N "${i}" run.pbs
  #qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/${i}/${i}_firsttouch_mcdram_shared_site.sh" -N "${i}" run.pbs
done
