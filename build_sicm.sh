#!/bin/bash -l
# Builds SICM
. /opt/rh/devtoolset-7/enable
source ./all/vars.sh
source ${SCRIPTS_DIR}/all/args.sh

# Compile SICM.
cd ${SICM_PREFIX}/src/
cd sicm
rm -rf build && mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX=${SICM_PREFIX} \
  -DCMAKE_INSTALL_RPATH="${SICM_PREFIX}/lib" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DSICM_BUILD_HIGH_LEVEL=True \
  -DJEMALLOC_ROOT="${SICM_PREFIX}" \
  -DLIBPFM_INSTALL="${SICM_PREFIX}" \
  -DCMAKE_C_COMPILER="${SICM_PREFIX}/bin/clang" \
  -DCMAKE_CXX_COMPILER="${SICM_PREFIX}/bin/clang++" \
  -DCMAKE_CXX_FLAGS="-fPIC" \
  -DCMAKE_LINKER="${SICM_PREFIX}/bin/clang++" \
  ..
make -j$(nproc) VERBOSE=1
make install
cd ..

# Compile the "scripts"
cd ${SCRIPTS_DIR}/all
INCLUDE="-I${SICM_PREFIX}/include"
gcc -g -lm c/stat.c ${INCLUDE} -o stat
gcc -g c/memreserve.c -lnuma -lpthread ${INCLUDE} -o memreserve

#  -DCMAKE_C_FLAGS="-O1 -g -fsanitize=address -fno-omit-frame-pointer" \
#  -DCMAKE_CXX_FLAGS="-O1 -g -fsanitize=address -fno-omit-frame-pointer" \
