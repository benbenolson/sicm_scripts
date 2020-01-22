#!/bin/bash -l
# This is the general layout of packages that I want in Spack:
#   1. With the system compiler (e.g. an older version of GCC),
#      install *only* GCC 7.2.0.
#   2. Using GCC 7.2.0, compile:
#      - A patched version of Flang (LLVM 6.0.1) to use with SICM.
#      - An unpatched version of Flang (the same version) to compile deps.
#   3. Using the unpatched version of Flang, compile the benchmarks' dependencies.
#   4. Using the patched version of Flang, compile the benchmarks.

# We need a newer compiler than Debian Stable provides,
# so let's settle on 7.2.0 and use that for everything.
. $SPACK_DIR/share/spack/setup-env.sh
spack bootstrap
spack install gcc@7.2.0
spack load gcc@7.2.0
spack compiler find

export TMPDIR="${HOME}/tmp"
mkdir -p ${TMPDIR}

# Install an unpatched version of LLVM, for compiling dependencies
# that we don't want to transform with SICM.
spack install flang@20180921 %gcc@7.2.0
spack install -j1 flang@20180921 %gcc@7.2.0
spack load flang@20180921%gcc@7.2.0
spack load llvm-flang@20180921%gcc@7.2.0
spack compiler find
spack unload flang@20180921%gcc@7.2.0
spack unload llvm-flang@20180921%gcc@7.2.0

# Now that we've got the unpatched version of Flang, I haven't found a good
# way of automatically installing it as a compiler in Spack. Do this manually.
echo "I've installed an unpatched version of Flang. Please use another terminal to edit ${HOME}/.spack/linux/compilers.yaml"
echo "to include these paths under the spec 'clang@6.0.1'."
spack find flang@20180921 %gcc@7.2.0
read -p "Press 'Enter' to continue compiling dependencies..."

# For QMCPACK.
# We do this twice because sometimes some of these packages randomly fail, then subsequently succeed.
# Put these packages in a separate environment.
spack env create qmcpack_deps
spack env activate qmcpack_deps
spack install --no-checksum hdf5@1.10.6%clang@6.0.1~mpi boost@1.70.0%clang@6.0.1 bzip2@1.0.8%clang@6.0.1 fftw@3.3.8~mpi%clang@6.0.1 libiconv@1.16%clang@6.0.1 libxml2@2.9.9%clang@6.0.1 netlib-lapack@3.8.0%clang@6.0.1 xz@5.2.4%clang@6.0.1 zlib@1.2.11%clang@6.0.1
#spack install --no-checksum --only dependencies qmcpack@3.6.0 -phdf5 -mpi -qe +soa %clang@6.0.1 ^cmake@3.6.0 ^hdf5~mpi ^fftw~mpi ^netlib-lapack@3.8.0
#spack install --no-checksum --only dependencies qmcpack@3.6.0 -phdf5 -mpi -qe +soa %clang@6.0.1 ^cmake@3.6.0 ^hdf5~mpi ^fftw~mpi ^netlib-lapack@3.8.0
#spack remove qmcpack
spack env loads -m tcl -r --input-only qmcpack_deps
despacktivate

# For CAM-SE
spack env create cam-se_deps
spack env activate cam-se_deps
spack install -j1 netcdf-fortran@4.5.2~mpi ^hdf5~mpi ^netcdf-c~mpi %clang@6.0.1
spack install -j1 flang@20180921%gcc@7.2.0
spack install autoconf@2.63%gcc@7.2.0
spack install autoconf@2.69%gcc@7.2.0
spack env loads -m tcl -r --input-only cam-se_deps
despacktivate

# An example 'clang@6.0.1' entry in compilers.yaml:
#- compiler:
#    environment: {}
#    extra_rpaths:
#      - /home/molson5/spack/opt/spack/linux-centos7-x86_64/gcc-7.2.0/flang-20180921-cy2xp7t6btabeqlsmm4jco3yfb7a4v4g/lib
#      - /home/molson5/spack/opt/spack/linux-centos7-x86_64/gcc-7.2.0/pgmath-20180921-bkjp7p6ntggong4vnreo3s3cfngszboc
#    flags:
#      ldflags: -L/home/molson5/spack/opt/spack/linux-centos7-x86_64/gcc-7.2.0/flang-20180921-cy2xp7t6btabeqlsmm4jco3yfb7a4v4g/lib -lflang
#      fflags: -I/home/molson5/spack/opt/spack/linux-centos7-x86_64/gcc-7.2.0/flang-20180921-cy2xp7t6btabeqlsmm4jco3yfb7a4v4g/include
#    modules:
#      - flang-20180921-gcc-7.2.0-cy2xp7t
#      - pgmath-20180921-gcc-7.2.0-bkjp7p6
#      - llvm-flang-20180921-gcc-7.2.0-jd4sfpr
#    operating_system: centos7
#    paths:
#      cc: /home/molson5/spack/opt/spack/linux-centos7-x86_64/gcc-7.2.0/llvm-flang-20180921-jd4sfprjebe5vvlblpxjeoous7b4qccl/bin/clang
#      cxx: /home/molson5/spack/opt/spack/linux-centos7-x86_64/gcc-7.2.0/llvm-flang-20180921-jd4sfprjebe5vvlblpxjeoous7b4qccl/bin/clang++
#      f77: /home/molson5/spack/opt/spack/linux-centos7-x86_64/gcc-7.2.0/flang-20180921-cy2xp7t6btabeqlsmm4jco3yfb7a4v4g/bin/flang
#      fc: /home/molson5/spack/opt/spack/linux-centos7-x86_64/gcc-7.2.0/flang-20180921-cy2xp7t6btabeqlsmm4jco3yfb7a4v4g/bin/flang
#    spec: clang@6.0.1
#    target: x86_64
