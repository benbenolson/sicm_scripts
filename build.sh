#!/bin/bash -l
# Builds SICM with Spack.

source $SCRIPTS_DIR/all/args.sh

# Uninstall old installation
echo "Uninstalling SICM."
. $SPACK_DIR/share/spack/setup-env.sh
spack uninstall -y $SICM
cd $SICM_DIR

# Clean up and compile SICM
echo "Compiling and installing SICM."
spack clean -sd spack.$SICM
spack install --keep-stage -j 1 spack.$SICM %gcc@7.2.0

if ! $MEMSYS; then
  # Compile the "scripts"
  INCLUDE="-I$(spack location -i $SICM%gcc@7.2.0)/include"
  spack load $SICM%gcc@7.2.0
  cd $SCRIPTS_DIR/all
  gcc -g c/stat.c ${INCLUDE} -o stat
fi
