#!/bin/bash -l

# We need a newer compiler than Debian Stable provides
. $SPACK_DIR/share/spack/setup-env.sh
spack install gcc@7.2.0
spack load gcc@7.2.0
spack compiler find
