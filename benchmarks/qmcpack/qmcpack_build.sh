#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build c "-L$SICM_DIR/examples/high/qmcpack/deps/lib -L$SICM_DIR/examples/high/qmcpack/deps/lib64 -lfftw" "-I$SICM_DIR/examples/high/qmcpack/deps/include"
export PATH="$SICM_DIR/examples/high/qmcpack/deps/bin:$PATH"

# Compile a newer version of CMake for QMCPACK
cd $SICM_DIR/examples/high/qmcpack/deps
if [[ ! -d cmake-3.12.4 ]]; then
  if [[ ! -f cmake-3.12.4.tar.gz ]]; then
    wget https://github.com/Kitware/CMake/releases/download/v3.12.4/cmake-3.12.4.tar.gz
  fi
  tar xf cmake-3.12.4.tar.gz
  cd cmake-3.12.4
  ./bootstrap --prefix=$SICM_DIR/examples/high/qmcpack/deps
  make -j $(nproc --all)
  make -j $(nproc --all) install
fi

# Compile FFTW
cd $SICM_DIR/examples/high/qmcpack/deps
if [[ ! -d fftw-3.3.8 ]]; then
  if [[ ! -f fftw-3.3.8.tar.gz ]]; then
    wget http://www.fftw.org/fftw-3.3.8.tar.gz
  fi
  tar xf fftw-3.3.8.tar.gz
  cd fftw-3.3.8
  ./configure --prefix=$SICM_DIR/examples/high/qmcpack/deps
  make -j $(nproc --all)
  make -j $(nproc --all) install
fi

# Compile Boost
cd $SICM_DIR/examples/high/qmcpack/deps
if [[ ! -d boost_1_69_0 ]]; then
  if [[ ! -f boost_1_69_0.tar.gz ]]; then
    wget https://dl.bintray.com/boostorg/release/1.69.0/source/boost_1_69_0.tar.gz
  fi
  tar xf boost_1_69_0.tar.gz
  cd boost_1_69_0
  ./bootstrap.sh --prefix=$SICM_DIR/examples/high/qmcpack/deps
  ./b2 --clean-all
  ./b2 -j$CORES
  ./b2 install --prefix=$SICM_DIR/examples/high/qmcpack/deps
fi

# Compile QMCPACK
cd $SICM_DIR/examples/high/qmcpack/src
rm -rf build
mkdir build
cd build
cmake -DQMC_SYMLINK_TEST_FILES=False \
      -DCMAKE_CXX_COMPILER=${COMPILER_WRAPPER} \
      -DCMAKE_C_COMPILER=${COMPILER_WRAPPER} \
      ..
make -j $(nproc --all)
