#!/bin/bash -l
# First argument is the benchmark name

source $SCRIPTS_DIR/all/bench_build.sh

echo "Loading Spack module of SICM..."
. $SPACK_DIR/share/spack/setup-env.sh
module load pgmath-20180921-gcc-7.2.0-um2qwjd
module load flang-20180921-gcc-7.2.0-a2g3n2u
module load llvm-flang-20180921-gcc-7.2.0-f2bzfqn
# This is the hash for SICM built with the `dev` branch of `jemalloc`.
module load sicm-high-develop-gcc-7.2.0-ajlq464
#module load sicm-high-develop-gcc-7.2.0-k3wihar
#module load sicm-high-develop-gcc-7.2.0-yqtlckm

# Clean up the source directory first
cd $BENCH_DIR/${1}/src
rm *.o *.bc *.args *.mod contexts.txt nclones.txt nsites.txt buCG.txt .sicm_ir.bc

$SCRIPTS_DIR/benchmarks/${1}/${1}_build.sh
