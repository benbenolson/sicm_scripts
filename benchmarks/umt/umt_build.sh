#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh

export ROOT="${BENCH_DIR}/umt/src"

# For compiling dependencies, don't transform them.
spack load llvm@flang-20180921
spack load flang@20180921

# Compile the C/Fortran version first
mkdir -p ${ROOT}/mpi-serial
cd ${ROOT}/mpi-serial-src
./configure
make clean
make
cp mpif.h ${ROOT}/mpi-serial/
cp libmpi-serial.a ${ROOT}/mpi-serial/
cp mpi.h ${ROOT}/mpi-serial

# Compile the C++ version next
#mkdir -p ${ROOT}/mpi-serial-cxx
#cd ${ROOT}/mpi-serial-src-cxx
#export CC="clang++"
#./configure
#make clean
#make
#cp libmpi-serial.a ${ROOT}/mpi-serial-cxx/libmpi-serial-cxx.a

spack unload flang@20180921

bench_build c

cd ${ROOT}
make clean
make
cd Teton
make clean
make SuOlsonTest
cd ${ROOT}
mkdir -p ../run
cp Teton/SuOlsonTest ../run/
