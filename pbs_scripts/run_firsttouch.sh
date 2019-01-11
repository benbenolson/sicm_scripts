#!/bin/bash

array=(roms lulesh fotonik3d imagick)
for i in "${array[@]}"; do
  qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/$i/${i}_firsttouch_5%.sh" -N "${i}" run.pbs
  qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/$i/${i}_firsttouch_10%.sh" -N "${i}" run.pbs
  qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/$i/${i}_firsttouch_15%.sh" -N "${i}" run.pbs
  qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/$i/${i}_firsttouch_20%.sh" -N "${i}" run.pbs
  qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/$i/${i}_firsttouch_25%.sh" -N "${i}" run.pbs
  qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/$i/${i}_firsttouch_30%.sh" -N "${i}" run.pbs
  qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/$i/${i}_firsttouch_35%.sh" -N "${i}" run.pbs
  qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/$i/${i}_firsttouch_40%.sh" -N "${i}" run.pbs
  qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/$i/${i}_firsttouch_45%.sh" -N "${i}" run.pbs
  qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/$i/${i}_firsttouch_50%.sh" -N "${i}" run.pbs
done
