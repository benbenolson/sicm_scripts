#!/bin/bash

export SICM_DIR="/lustre/atlas/scratch/molson5/gen010"
export CRAYPE_LINK_TYPE=dynamic

# Compile SICM
cd $SICM_DIR
make uninstall || true
make distclean || true
./autogen.sh
./configure --prefix=$SICM_DIR/deps --with-jemalloc=$SICM_DIR/deps --with-llvm=$($SICM_DIR/deps/bin/llvm-config --prefix) --with-libpfm=$SICM_DIR/deps
make clean
make -j5
make install
