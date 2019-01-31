#!/bin/bash

array=(pennant)
for i in "${array[@]}"; do
  qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/$i/${i}_offline_pebs_128_5%_thermos.sh" -N "${i}" run.pbs
  qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/$i/${i}_offline_pebs_128_10%_thermos.sh" -N "${i}" run.pbs
  qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/$i/${i}_offline_pebs_128_15%_thermos.sh" -N "${i}" run.pbs
  qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/$i/${i}_offline_pebs_128_20%_thermos.sh" -N "${i}" run.pbs
  qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/$i/${i}_offline_pebs_128_25%_thermos.sh" -N "${i}" run.pbs
  qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/$i/${i}_offline_pebs_128_30%_thermos.sh" -N "${i}" run.pbs
  qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/$i/${i}_offline_pebs_128_35%_thermos.sh" -N "${i}" run.pbs
  qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/$i/${i}_offline_pebs_128_40%_thermos.sh" -N "${i}" run.pbs
  qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/$i/${i}_offline_pebs_128_45%_thermos.sh" -N "${i}" run.pbs
  qsub -v "SICM_DIR=$SICM_DIR,SCRIPTS_DIR=$SCRIPTS_DIR" -F "$SCRIPTS_DIR/benchmarks/$i/${i}_offline_pebs_128_50%_thermos.sh" -N "${i}" run.pbs
done
