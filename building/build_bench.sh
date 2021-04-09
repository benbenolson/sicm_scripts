#!/bin/bash -l
# This script builds a benchmark, using the `benchmarks/$BENCH/$BENCH_build.sh` scripts.

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${DIR}/../vars.sh
source ${SCRIPTS_DIR}/building/build_bench_utils.sh

if [[ ${#BENCHES[@]} = 0 ]]; then
  echo "You didn't specify a benchmark name. Aborting."
  exit 1
fi

for BENCH in ${BENCHES[@]}; do
  echo "Compiling ${BENCH} with $SICM."
  
  # Clean up the source directory first
  cd ${BENCH_DIR}/${BENCH}/src
  rm *.o *.bc *.args *.mod contexts.txt nclones.txt nsites.txt buCG.txt .sicm_ir.bc &> /dev/null

  source ${SCRIPTS_DIR}/benchmarks/${BENCH}/${BENCH}_build.sh
done
