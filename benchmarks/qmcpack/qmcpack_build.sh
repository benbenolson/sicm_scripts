#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build c "" ""

# Get Spack into the environment and load Clang 6.0.1.
#spack load llvm@flang-20180921

# Also install an unpatched Flang. We need this because the SICM-patched
# Flang will try to look for "sh_" symbols, which we don't have.
#spack install -j1 flang@20180921 %gcc@7.2.0

# Make sure Clang is in the environment. Should bring in Flang, too.
#spack compiler find

# Have to manually add Flang and pgmath modules to the compiler listing.
#spack config edit compilers

# QMCPACK deps
spack install -j80 qmcpack@3.6.0 -phdf5 -mpi -qe +soa %clang@6.0.1 ^cmake@3.6.0 ^hdf5~hl~fortran~mpi ^fftw~mpi ^netlib-lapack@3.8.0

# The above QMCPACK compilation may fail, but we don't care, as long as the dependencies are installed.
# Now let's load them into the environment. This is the easiest way to do so without
# requiring the above QMCPACK installation to have succeeded.
for module in `module avail 2>&1 | grep "clang-6.0.1"`; do
  module load $module
done
module list

# Compile QMCPACK
cd $BENCH_DIR/qmcpack/src
rm -rf build
mkdir build
cd build
cmake -DBUILD_UNIT_TESTS=False \
      -DBUILD_SANDBOX=False \
      -DBUILD_QMCTOOLS=False \
      -DQMC_SYMLINK_TEST_FILES=False \
      -DQMC_MPI=False \
      -DQMC_ADIOS=False \
      -DENABLE_PHDF5=False \
      -DENABLE_SOA=1 \
      -DQMC_CUDA=0 \
      -DCMAKE_CXX_COMPILER:PATH=${COMPILER_WRAPPER} \
      -DCMAKE_C_COMPILER:PATH=${COMPILER_WRAPPER} \
      -DCMAKE_CXX_FLAGS="-Wno-warnings -Wno-deprecated -Wno-pragma-messages" \
      -DCMAKE_LINKER:PATH=${LD_WRAPPER} \
      -DCMAKE_CXX_LINK_EXECUTABLE="<CMAKE_LINKER> -lhdf5 -lxml2 -lfftw3 -llapack -lblas -Wl,-rpath,$(spack location -i hdf5)/lib -Wl,-rpath,$(spack location -i fftw)/lib -Wl,-rpath,$(spack location -i netlib-lapack)/lib -Wl,-rpath,$(spack location -i netlib-lapack)/lib64 <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>" \
      -DCMAKE_AR:PATH=${AR_WRAPPER} \
      -DCMAKE_RANLIB:PATH="${RANLIB_WRAPPER}" \
      -DCMAKE_BUILD_WITH_INSTALL_RPATH=True \
      -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=True \
      ..
make -j $(nproc --all)
mkdir -p ../../run
cp bin/qmcpack ../../run/qmcpack
