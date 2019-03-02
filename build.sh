#!/bin/bash -l
# Builds SICM with Spack.

source $SCRIPTS_DIR/all/args.sh

. $SPACK_DIR/share/spack/setup-env.sh
cd $SICM_DIR

if [[ $1 == "tools" ]]; then
  # Compile the "scripts"
  INCLUDE="-I$(spack location -i $SICM%gcc@7.2.0)/include"
  spack load $SICM%gcc@7.2.0
  cd $SCRIPTS_DIR/all
  gcc -g -lm c/stat.c ${INCLUDE} -o stat
  gcc -g c/memreserve.c ${INCLUDE} -lnuma -lpthread -o memreserve
else
  # Uninstall old installation
  cd $HOME
  spack find
  spack uninstall -y $SICM
  cd $SICM_DIR

  # Clean up and compile SICM
  spack clean -sd sicm-namespace.$SICM
  spack install --keep-stage -j 1 sicm-namespace.$SICM%gcc@7.2.0^python@2.7.16
fi
