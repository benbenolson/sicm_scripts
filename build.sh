#!/bin/bash
# Builds SICM with Spack.

source $SCRIPTS_DIR/all/args.sh

echo "Compiling $SICM."

. $SPACK_DIR/share/spack/setup-env.sh

spack uninstall -y $SICM
cd $SICM_DIR

spack clean -sd spack.$SICM
spack install --keep-stage -j 1 spack.$SICM %gcc@7.2.0
