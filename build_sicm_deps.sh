#!/bin/bash
. /opt/rh/devtoolset-7/enable
source ./all/vars.sh

# SYSTEM_C_COMPILER and SYSTEM_CXX_COMPILER needs to be at least GCC 7.2 to work.
SICM_DEPS_DIR="$SICM_PREFIX"
SYSTEM_C_COMPILER="/usr/bin/gcc"
SYSTEM_CXX_COMPILER="/usr/bin/g++"

mkdir -p ${SICM_DEPS_DIR}
cd ${SICM_DEPS_DIR}

# Grab Flang's toolchain.
mkdir -p src
cd src
if [ ! -d "llvm" ]; then
  git clone https://github.com/flang-compiler/llvm.git llvm
  (cd llvm && git checkout flang_20180921)
fi
if [ ! -d "flang" ]; then
  git clone https://github.com/flang-compiler/flang.git flang
  (cd flang && git checkout flang_20180921)
fi
if [ ! -d "flang-driver" ]; then
  git clone https://github.com/flang-compiler/flang-driver.git flang-driver
  (cd flang-driver && git checkout flang_20180921)
fi
if [ ! -d "openmp" ]; then
  git clone https://github.com/flang-compiler/openmp.git openmp
  (cd openmp && git checkout flang_20180921)
fi
if [ ! -d "sicm" ]; then
  git clone https://github.com/lanl/SICM.git sicm
  (cd sicm && git checkout high_dev)
fi
if [ ! -d "libpfm4" ]; then
  git clone https://git.code.sf.net/p/perfmon2/libpfm4 libpfm4
fi

# Common CMake arguments for the Flang toolchain
INSTALL_PREFIX=${SICM_DEPS_DIR}
CMAKE_OPTIONS="-DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DLLVM_CONFIG=$INSTALL_PREFIX/bin/llvm-config \
  -DCMAKE_CXX_COMPILER=$INSTALL_PREFIX/bin/clang++ \
  -DCMAKE_C_COMPILER=$INSTALL_PREFIX/bin/clang \
  -DCMAKE_Fortran_COMPILER=$INSTALL_PREFIX/bin/flang \
  -DLLVM_TARGETS_TO_BUILD=X86"
export PATH="${INSTALL_PREFIX}:${PATH}"

# Start with an easy one: libpfm4
cd libpfm4
make -j$(nproc)
cp -r include/* ${INSTALL_PREFIX}/include/
cp -r lib/libpfm* ${INSTALL_PREFIX}/lib/
cd ..

# Build Flang-patched LLVM
cd llvm
mkdir -p build && cd build
cmake $CMAKE_OPTIONS -DCMAKE_C_COMPILER=${SYSTEM_C_COMPILER} -DCMAKE_CXX_COMPILER=${SYSTEM_CXX_COMPILER} ..
make -j$(nproc)
make install
cd ../..

# Build Flang-patched Clang
cd flang-driver
mkdir -p build && cd build
cmake $CMAKE_OPTIONS -DCMAKE_C_COMPILER=${SYSTEM_C_COMPILER} -DCMAKE_CXX_COMPILER=${SYSTEM_CXX_COMPILER} ..
make -j$(nproc)
make install
cd ../..

# Build Flang-patched OpenMP
cd openmp
mkdir -p build && cd build
cmake $CMAKE_OPTIONS ..
make -j$(nproc)
make install
cd ../..

# Build Flang-patched libpgmath
cd flang/runtime/libpgmath
mkdir -p build && cd build
cmake $CMAKE_OPTIONS -DFLANG_LIBOMP=$INSTALL_PREFIX/lib/libomp.so -DFLANG_OPENMP_GPU_NVIDIA=OFF ..
make -j$(nproc)
make install
cd ../../../..

# Build Flang itself.
# Here, we'll need to grab SICM's patches and apply them.
cd flang
cp ../sicm/spack-repo/packages/sicm-high/getcpu_fix.patch .
cp ../sicm/spack-repo/packages/sicm-high/0.patch .
cp ../sicm/spack-repo/packages/sicm-high/1.patch .
cp ../sicm/spack-repo/packages/sicm-high/2.patch .
cp ../sicm/spack-repo/packages/sicm-high/3.patch .
patch -N -p1 < getcpu_fix.patch
patch -N -p1 < 0.patch
patch -N -p1 < 1.patch
patch -N -p1 < 2.patch
patch -N -p1 < 3.patch
mkdir -p build && cd build
cmake $CMAKE_OPTIONS -DFLANG_LIBOMP=$INSTALL_PREFIX/lib/libomp.so -DFLANG_OPENMP_GPU_NVIDIA=OFF ..
make -j$(nproc)
make install
cd ../..

# Grab source code for jemalloc
if [ ! -d "jemalloc" ]; then
  git clone https://github.com/jemalloc/jemalloc.git jemalloc
  (cd jemalloc && git checkout 5.2.0)
fi

# Build jemalloc
cd jemalloc
./autogen.sh
./configure --prefix=${SICM_DEPS_DIR} --with-jemalloc-prefix="je_"
make dist
make -j$(nproc)
make install
cd ../..
