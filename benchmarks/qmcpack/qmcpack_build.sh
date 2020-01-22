#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build c "" ""

for line in `cat ${HOME}/spack/var/spack/environments/qmcpack_deps/loads`; do
  module load $line;
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
