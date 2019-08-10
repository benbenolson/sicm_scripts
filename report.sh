#!/bin/bash

source ${SCRIPTS_DIR}/all/args.sh
export PERLLIB="$(readlink -f ./all):$PERLLIB"
. $SPACK_DIR/share/spack/setup-env.sh
spack load $SICM@develop%gcc@7.2.0
export INC="`spack location -i $SICM`/include"

TEST_INPUT="
===== PROFILING INFORMATION =====
1 sites: 55
  Number of intervals: 108618
  First interval: 2
  Allocations size:
    Peak: 1536
===== END PROFILING INFORMATION =====
"
printf '%s\n' "$TEST_INPUT" | ${SCRIPTS_DIR}/all/report.pl "$@"
