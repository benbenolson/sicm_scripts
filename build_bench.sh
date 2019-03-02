#!/bin/bash -l
# First argument is the benchmark name

source ./all/vars.sh
source ${SCRIPTS_DIR}/all/args.sh
source ${SCRIPTS_DIR}/all/bench_build.sh

if [[ ${#BENCHES[@]} = 0 ]]; then
  echo "You didn't specify a benchmark name. Aborting."
  exit 1
fi

export PATH="${SICM_PREFIX}/bin:${PATH}"
export LD_LIBRARY_PATH="${SICM_PREFIX}/lib:${LD_LIBRARY_PATH}"
export LIBRARY_PATH="${SICM_PREFIX}/lib:${LIBRARY_PATH}"
export CPATH="${SICM_PREFIX}/include:${CPATH}"
export CMAKE_PREFIX_PATH="${SICM_PREFIX}/:${CMAKE_PREFIX_PATH}"

export FC="${SICM_PREFIX}/bin/flang"
export F77="${SICM_PREFIX}/bin/flang"
export F90="${SICM_PREFIX}/bin/flang"

for BENCH in ${BENCHES[@]}; do

  echo "Compiling ${BENCH} with $SICM."

  # Clean up the source directory first
  cd $BENCH_DIR/${BENCH}/src
  rm *.o *.bc *.args *.mod contexts.txt nclones.txt nsites.txt buCG.txt .sicm_ir.bc

  ${SCRIPTS_DIR}/benchmarks/${BENCH}/${BENCH}_build.sh
done
