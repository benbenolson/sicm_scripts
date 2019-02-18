#!/bin/bash

spack uninstall -y sicm-high
cd $SICM_DIR

if [[ "$(hostname)" =~ percival-login.* ]]; then
  echo "hi there"
  spack clean -sd spack.sicm-high target=sandybridge
  spack install -j 4 spack.sicm-high target=sandybridge %gcc@7.2.0
else
  spack clean -sd spack.sicm-high
  spack install -j 4 spack.sicm-high %gcc@7.2.0
fi
