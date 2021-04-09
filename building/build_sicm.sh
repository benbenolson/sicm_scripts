#!/bin/bash -l
# Builds SICM
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${DIR}/../vars.sh

# Compile SICM.
cd ${SICM_PREFIX}/src/
cd sicm
rm -rf build && mkdir -p build && cd build
PATH="${SICM_PREFIX}/bin:${PATH}"
LD_LIBRARY_PATH="${SICM_PREFIX}/lib:${LD_LIBRARY_PATH}"
cmake -DCMAKE_INSTALL_PREFIX=${SICM_PREFIX} \
  -DCMAKE_INSTALL_RPATH="${SICM_PREFIX}/lib" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DSICM_BUILD_HIGH_LEVEL=True \
  -DJEMALLOC_ROOT="${SICM_PREFIX}" \
  -DLIBPFM_INSTALL="${SICM_PREFIX}" \
  -DCMAKE_BUILD_TYPE=Debug \
  ..
make -j$(nproc) VERBOSE=1
make install
cd ..
