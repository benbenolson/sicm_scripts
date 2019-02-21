#!/bin/bash
# Builds SICM with Spack.

. $SPACK_DIR/share/spack/setup-env.sh

spack uninstall -y sicm-high
cd $SICM_DIR

spack clean -sd spack.sicm-high
spack install -j 4 spack.sicm-high %gcc@7.2.0
