#!/bin/bash -l
# Builds SICM

source ./all/vars.sh
source ./all/args_nospack.sh

# Compile SICM.
cd ${SICM_PREFIX}/src/
cd sicm
rm -rf build && mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX=${SICM_PREFIX} \
  -DSICM_BUILD_HIGH_LEVEL=True \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DJEMALLOC_ROOT="${SICM_PREFIX}" \
  ..
make -j$(nproc)
make install
cd ..

# Compile the "scripts"
#INCLUDE="-I$(spack location -i $SICM%gcc@7.2.0)/include"
#spack load $SICM%gcc@7.2.0
#cd $SCRIPTS_DIR/all
#gcc -g -lm c/stat.c ${INCLUDE} -o stat
#gcc -g c/memreserve.c ${INCLUDE} -lnuma -lpthread -o memreserve
