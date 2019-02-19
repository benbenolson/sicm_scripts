#!/bin/bash

# Builds SICM with Spack. Also builds GNU Time.

spack uninstall -y sicm-high
cd $SICM_DIR

if [[ "$(hostname)" =~ percival-login.* ]]; then
  spack clean -sd spack.sicm-high target=sandybridge
  spack install -j 4 spack.sicm-high target=sandybridge %gcc@7.2.0
  spack install time@1.9 target=sandybridge
else
  spack clean -sd spack.sicm-high
  spack install -j 4 spack.sicm-high %gcc@7.2.0
  spack install time@1.9
fi
