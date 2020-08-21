#!/bin/bash
# On a Fedora 30 distro, I had to install the following packages:
# lapack, lapack-devel, fftw, fftw-devel, hdf5, hdf5-devel, boost, boost-devel
# On a Debian 10.0 distro, I had to install:
# libxml2-dev, libxml2, libboost-dev, libxml2, libhdf5-103, libhdf5-dev, libfftw3-dev, liblapack-dev, libblas-dev
# On a CentOS 7.7 machine, I had to install:
# lapack lapack-devel blas blas-devel centos-release-scl devtoolset-7-gcc* boost169 boost169-devel
# then had to do: . /opt/rh/devtoolset-7/enable

. /opt/rh/devtoolset-7/enable
source $SCRIPTS_DIR/all/bench_build.sh
bench_build c "" ""

export FFTW_INCLUDE_DIRS="/usr/include"
export FFTW_LIBRARY_DIRS="/usr/lib64/"
export HDF5_INCLUDE_DIRS="/usr/include/"
export HDF5_LIBRARY_DIRS="/usr/lib64/"
export BOOST_INCLUDE_DIRS="/usr/include/boost169/"
export SICM_COMPILER_ARGS="--gcc-toolchain=/opt/rh/devtoolset-7/root/usr/ -L/opt/rh/devtoolset-7/root/usr/lib/gcc/x86_64-redhat-linux/7/ -lstdc++_nonshared"
export CXXFLAGS="-lm ${SICM_COMPILER_ARGS}"

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
      -DENABLE_TIMERS=1 \
      -DQMC_CUDA=0 \
      -DCMAKE_CXX_COMPILER:PATH=${COMPILER_WRAPPER} \
      -DCMAKE_C_COMPILER:PATH=${COMPILER_WRAPPER} \
      -DCMAKE_C_FLAGS="-llapack -lblas -lfftw3 -lhdf5" \
      -DCMAKE_CXX_FLAGS="-Wno-#warnings -Wno-deprecated -Wno-#pragma-messages -llapack -lblas -lfftw3 -lhdf5 ${CXXFLAGS}" \
      -DCMAKE_LINKER:PATH=${LD_WRAPPER} \
      -DCMAKE_CXX_LINK_EXECUTABLE="<CMAKE_LINKER> -lfftw3 -lxml2 -llapack -lblas -lhdf5 <CMAKE_CXX_FLAGS> <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> ${SICM_COMPILER_ARGS} <OBJECTS> -o <TARGET> <LINK_LIBRARIES>" \
      -DCMAKE_AR:PATH=${AR_WRAPPER} \
      -DCMAKE_RANLIB:PATH="${RANLIB_WRAPPER}" \
      -DCMAKE_BUILD_WITH_INSTALL_RPATH=True \
      -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=True \
      -DHDF5_INCLUDE_DIRS="${HDF5_INCLUDE_DIRS}" \
      -DFFTW_INCLUDE_DIRS="${FFTW_INCLUDE_DIRS}" \
      -DFFTW_LIBRARY_DIRS="${FFTW_LIBRARY_DIRS}" \
      -DBoost_INCLUDE_DIR="${BOOST_INCLUDE_DIRS}" \
      ..
make -j $(nproc --all)
mkdir -p ../../run
cp bin/qmcpack ../../run/qmcpack
