#!/bin/bash -l
# First argument is the benchmark name

source $SCRIPTS_DIR/all/bench_build.sh

echo "Loading Spack module of SICM..."
. $SPACK_DIR/share/spack/setup-env.sh
spack load pgmath
spack load flang@20180921 /a2g3n2ugv7xdhzkntxfzxainujapch5v
spack load llvm@flang-20180921
spack load sicm-high

# Clean up the source directory first
cd $BENCH_DIR/${1}/src
rm *.o *.bc *.args *.mod contexts.txt nclones.txt nsites.txt buCG.txt .sicm_ir.bc

$SCRIPTS_DIR/benchmarks/${1}/${1}_build.sh
