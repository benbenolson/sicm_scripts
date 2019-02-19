#!/bin/bash
# First argument is the benchmark name

source $SCRIPTS_DIR/all/bench_build.sh

echo "Loading Spack module of SICM..."
. $SPACK_DIR/share/spack/setup-env.sh
module use "$(spack location -r)/share/spack/modules/cray-cnl6-sandybridge"
spack load pgmath
spack load flang@20180921 /h6rsfo
spack load llvm@flang-20180921
spack load sicm-high

# Clean up the source directory first
cd $BENCH_DIR/${1}/src
rm *.o *.bc *.args *.mod contexts.txt nclones.txt nsites.txt buCG.txt .sicm_ir.bc

$SCRIPTS_DIR/benchmarks/${1}/${1}_build.sh
