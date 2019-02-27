#!/bin/bash -l

# Get the generic report scripts in here
source $SCRIPTS_DIR/all/firsttouch.sh

echo "Loading Spack module of SICM..."
#. $SPACK_DIR/share/spack/setup-env.sh
module load sicm-high-develop-gcc-7.2.0-bz67eff

./all/report.pl "$@"
