#!/bin/bash
set -e

source $SCRIPTS_DIR/all/bench_build.sh
cd $BENCH_DIR/cam-se/src
export HOMME_ROOT="${PWD}"

spack unload pgmath@20180921%gcc@7.2.0
spack unload flang-patched%gcc@7.2.0
spack unload llvm-flang@20180921%gcc@7.2.0
cd $SICM_DIR
spack unload $SICM%gcc@7.2.0
cd ${HOMME_ROOT}

# Load all of the modules that are in the cam-se_deps environment
for line in `cat ${HOME}/spack/var/spack/environments/cam-se_deps/loads`; do
  module load $line;
done
module list

# Compile MPI serial
mkdir -p ${HOMME_ROOT}/mpi-serial
cd ${HOMME_ROOT}/mpi-serial-src
./configure
make
# My favorite feature of this library is that the `install` target doesn't work,
# and since the source directory contains a `config.h` (which messes up our build),
# we need to install the library to somewhere else. Just manually copy stuff.
cp mpif.h ${HOMME_ROOT}/mpi-serial/
cp libmpi-serial.a ${HOMME_ROOT}/mpi-serial/
cd ${HOMME_ROOT}

# LAPACK
cd $HOMME_ROOT/libs/lapack
autoreconf -i
./configure
make clean
make -j 80

# BLAS
cd $HOMME_ROOT/libs/blas
autoreconf -i
./configure
make clean
make -j 80

# Unload default Flang and LLVM
spack unload flang@20180921%gcc@7.2.0
spack load pgmath@20180921%gcc@7.2.0
spack load flang-patched%gcc@7.2.0
spack load llvm-flang@20180921%gcc@7.2.0
cd $SICM_DIR
spack load $SICM%gcc@7.2.0
cd $HOMME_ROOT
bench_build c "" ""

# Hacky way to emulate the older versions of NetCDF. See, this version of CAM-SE
# was made before version 4.2 of NetCDF, which is when they split into completely
# separate C and Fortran interfaces. Since CAM-SE expects both Fortran libraries and
# C libraries to reside in the same directory, we need to construct a fake distribution
# of NetCDF in which both of them are together.
export NETCDF_FORTRAN_DIR=$(spack location -i netcdf-fortran %clang@6.0.1)
export NETCDF_C_DIR=$(spack location -i netcdf-c %clang@6.0.1)
if [[ -z ${NETCDF_FORTRAN_DIR} || -z ${NETCDF_C_DIR} ]]; then
  echo "Couldn't load netcdf-fortran or netcdf-c. Aborting."
  exit 1
fi
export NETCDF_PATH="${HOMME_ROOT}/netcdf"
mkdir -p ${NETCDF_PATH}
cp -r ${NETCDF_FORTRAN_DIR}/* ${NETCDF_PATH}/.
cp -r ${NETCDF_C_DIR}/* ${NETCDF_PATH}/.

# We need to trick CAM-SE (in particular, the lapack that it comes with) to use
# our AR_WRAPPER. It's ignoring the "AR" environment variable, so we'll
# just put an "ar" in our PATH right before compiling.
FAKE_AR_PATH="${HOMME_ROOT}/fake_ar_path"
mkdir -p ${FAKE_AR_PATH}
cp $(which ar_wrapper.sh) ${FAKE_AR_PATH}/ar
export PATH="${FAKE_AR_PATH}:${PATH}"

# Compile CAM-SE
export RANLIB="${RANLIB_WRAPPER}"
export AR="${AR_WRAPPER}"
export FC="${COMPILER_WRAPPER}"
export CC="${COMPILER_WRAPPER}"
export F77="${COMPILER_WRAPPER}"
export F90="${COMPILER_WRAPPER}"
export MPI_INC="-I${HOMME_ROOT}/mpi-serial"
export MPI_LIB="-L${HOMME_ROOT}/mpi-serial -lmpi-serial"
export CPP="${PREPROCESS_WRAPPER} ${MPI_INC}"
export CFLAGS="-DTHREADED_OMP -DFORTRANUNDERSCORE -DHAVE_GETTIMEOFDAY -fopenmp ${MPI_INC} -fno-rtti"
export FCFLAGS="$CFLAGS -fno-rtti"
export FFLAGS="$FCFLAGS -fno-rtti"
export F90FLAGS="$FCFLAGS"
export LDFLAGS="-L${NETCDF_PATH}/lib -lnetcdf -lnetcdff -Wl,-rpath,${NETCDF_PATH}/lib ${MPI_LIB} -Wl,--allow-multiple-definition -fno-rtti"
export LIBS="$LDFLAGS"
export CONFARGS_PIO="MPIF90=${COMPILER_WRAPPER} MPICC=${COMPILER_WRAPPER} --enable-mpiio=no --enable-mpi2=no --enable-mpiserial=yes"
export CONFARGS_PRQ="NP=4 PLEV=26 --with-arch=Linux --with-netcdf=${NETCDF_PATH}"

# Now put LAPACK and BLAS in the LDFLAGS
export LDFLAGS="${LDFLAGS} -L../../libs/lapack -llapack -L../../libs/blas -lblas"

# PIO
which pkg-config
echo "${NETCDF_PATH}"
cd $HOMME_ROOT/utils/pio
make clean
rm -rf *.args *.bc *.mod *.o
./configure $CONFARGS_PIO
make clean
make -j 80

# Timing library
cd $HOMME_ROOT/utils/timing
make clean
rm -rf *.o *.mod *.bc *.args
make -j 80

# Now compile and link the final executable
bench_build fort "" ""
cd $HOMME_ROOT
cd $HOMME_ROOT/build/preqx
rm -rf *.o *.mod *.bc *.args
autoreconf -i
./configure $CONFARGS_PRQ
make -j 80 depends
make -j 80
mkdir -p ${BENCH_DIR}/cam-se/run
cp preqx $BENCH_DIR/cam-se/run
