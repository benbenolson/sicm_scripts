#!/bin/bash
# On a Fedora 30 distro, I had to install the following packages:
# lapack, lapack-devel, fftw, fftw-devel, hdf5, hdf5-devel, boost, boost-devel
# On a Debian 10.0 distro, I had to install:
# libxml2-dev, libxml2, libboost-dev, libxml2, libhdf5-103, libhdf5-dev, libfftw3-dev, liblapack-dev, libblas-dev

source $SCRIPTS_DIR/all/bench_build.sh
bench_build c "" ""

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
      -DCMAKE_C_FLAGS="-llapack -lblas -lfftw3 -lhdf5" \
      -DCMAKE_CXX_FLAGS="-Wno-warnings -Wno-deprecated -Wno-pragma-messages -llapack -lblas -lfftw3 -lhdf5" \
      -DCMAKE_LINKER:PATH=${LD_WRAPPER} \
      -DCMAKE_CXX_LINK_EXECUTABLE="<CMAKE_LINKER> -lfftw3 -lhdf5 -lxml2 -llapack -lblas <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>" \
      -DCMAKE_AR:PATH=${AR_WRAPPER} \
      -DCMAKE_RANLIB:PATH="${RANLIB_WRAPPER}" \
      -DCMAKE_BUILD_WITH_INSTALL_RPATH=True \
      -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=True \
      ..
make -j $(nproc --all)
mkdir -p ../../run
cp bin/qmcpack ../../run/qmcpack
