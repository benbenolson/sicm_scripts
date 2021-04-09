#!/bin/bash
# This script relies on build_sicm_deps.sh having already been run.
# The reason for this is that we need a patch file from the SICM repo,
# and we also use the deps that we've already compiled in the patched directory.
source ./all/vars.sh

# SYSTEM_C_COMPILER and SYSTEM_CXX_COMPILER needs to be at least GCC 7.2 to work.
PATCHED_DEPS_DIR="$SICM_PREFIX"
UNPATCHED_DEPS_DIR="$UNPATCHED_PREFIX"
SYSTEM_C_COMPILER="/usr/bin/gcc"
SYSTEM_CXX_COMPILER="/usr/bin/g++"

mkdir -p ${UNPATCHED_DEPS_DIR}
cd ${UNPATCHED_DEPS_DIR}

# Grab Flang's toolchain.
mkdir -p src
cd src
if [ ! -d "flang" ]; then
  git clone https://github.com/flang-compiler/flang.git flang
  (cd flang && git checkout flang_20180921)
fi

# Common CMake arguments for the Flang toolchain
PATCHED_INSTALL_PREFIX=${PATCHED_DEPS_DIR}
INSTALL_PREFIX=${UNPATCHED_DEPS_DIR}
CMAKE_OPTIONS="-DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DLLVM_CONFIG=$PATCHED_INSTALL_PREFIX/bin/llvm-config \
  -DCMAKE_CXX_COMPILER=$PATCHED_INSTALL_PREFIX/bin/clang++ \
  -DCMAKE_C_COMPILER=$PATCHED_INSTALL_PREFIX/bin/clang \
  -DCMAKE_Fortran_COMPILER=$PATCHED_INSTALL_PREFIX/bin/flang \
  -DLLVM_TARGETS_TO_BUILD=X86"
export PATH="${PATCHED_INSTALL_PREFIX}:${INSTALL_PREFIX}:${PATH}"

# Build Flang-patched libpgmath
cd flang/runtime/libpgmath
mkdir -p build && cd build
cmake $CMAKE_OPTIONS -DFLANG_LIBOMP=$PATCHED_INSTALL_PREFIX/lib/libomp.so -DFLANG_OPENMP_GPU_NVIDIA=OFF ..
make -j$(nproc)
make install
cd ../../../..

# Build Flang itself.
# Here, we'll need to grab SICM's patches and apply them.
cd flang
cp ${PATCHED_INSTALL_PREFIX}/src/sicm/spack-repo/packages/sicm-high/getcpu_fix.patch .
patch -N -p1 < getcpu_fix.patch
# Crucially, we're not applying SICM's patches here.
mkdir -p build && cd build
cmake $CMAKE_OPTIONS -DFLANG_LIBOMP=$PATCHED_INSTALL_PREFIX/lib/libomp.so -DFLANG_OPENMP_GPU_NVIDIA=OFF ..
make -j$(nproc)
make install
cd ../..
