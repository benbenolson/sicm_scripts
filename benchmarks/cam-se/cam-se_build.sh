#!/bin/bash
# On a Fedora 30 system, install the packages:
# mpich-devel, autoconf-archive
# In many cases, in order to satisfy the netcdf dep, you'll need to set NETCDF_PATH and NETCDF_MOD_PATH
# to be the directory in which libnetcdf.a and netcdf.mod live, respectively. You might also need to add
# some other dependencies, for example, where to find `mpif.h`. One example is below (works in Fedora 30)
# SYSTEM-SPECIFIC LIBRARY PATHS: EDIT THESE
export MPI_INCLUDE_DIR="/usr/include/mpich-x86_64/"

set -e
source $SCRIPTS_DIR/all/bench_build.sh
cd $BENCH_DIR/cam-se/src
export HOMME_ROOT="${PWD}"

cd ${HOMME_ROOT}

# Compile NetCDF
dep_build
cd $HOMME_ROOT/libs/netcdf-c-4.7.3
./configure --prefix=$HOMME_ROOT/libs
make -j $(nproc)
make install

# Compile NetCDF-Fortran
cd $HOMME_ROOT/libs/netcdf-fortran-4.5.2
./configure --prefix=$HOMME_ROOT/libs
make -j 1
make install

# Make sure the CAM-SE compilation can find these libraries
export NETCDF_PATH="$HOMME_ROOT/libs/lib"
export NETCDF_MOD_PATH="$HOMME_ROOT/libs/include"

# Get the environment into benchmark-building mode
bench_build c "" ""

# Compile CAM-SE
export RANLIB="${RANLIB_WRAPPER}"
export AR="${AR_WRAPPER}"
export FC="${COMPILER_WRAPPER}"
export CC="${COMPILER_WRAPPER}"
export F77="${COMPILER_WRAPPER}"
export F90="${COMPILER_WRAPPER}"
export CPP="${PREPROCESS_WRAPPER}"
export CFLAGS="-DTHREADED_OMP -DFORTRANUNDERSCORE -DHAVE_GETTIMEOFDAY -fopenmp -fno-rtti -I${MPI_INCLUDE_DIR}"
export FCFLAGS="$CFLAGS -fno-rtti -I${MPI_INCLUDE_DIR}"
export FFLAGS="$FCFLAGS -fno-rtti -I${MPI_INCLUDE_DIR}"
export F90FLAGS="$FCFLAGS"
export LDFLAGS="-lnetcdff -Wl,--allow-multiple-definition -fno-rtti"
export LIBS="$LDFLAGS"
export CONFARGS_PIO="MPIF90=${COMPILER_WRAPPER} MPICC=${COMPILER_WRAPPER} --enable-mpiio=no --enable-mpi2=no --enable-mpiserial=yes"
export CONFARGS_PRQ="NP=4 PLEV=26 --with-arch=Linux"

# PIO
cd $HOMME_ROOT/utils/pio
make clean
rm -rf *.args *.bc *.mod *.o
./configure $CONFARGS_PIO
make clean
make -j $(nproc)

# Timing library
cd $HOMME_ROOT/utils/timing
make clean
rm -rf *.o *.mod *.bc *.args
make -j $(nproc)

# Now compile and link the final executable
bench_build fort "" ""
cd $HOMME_ROOT/build/preqx
rm -rf *.o *.mod *.bc *.args
autoreconf -i
./configure $CONFARGS_PRQ
make -j $(nproc) depends
make -j $(nproc)
mkdir -p ${BENCH_DIR}/cam-se/run
cp preqx $BENCH_DIR/cam-se/run
