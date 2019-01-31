#!/bin/bash

export CRAYPE_LINK_TYPE=dynamic
source $SCRIPTS_DIR/all/bench_build.sh
bench_build c "-L$SICM_DIR/examples/high/qmcpack/deps/lib -L$SICM_DIR/examples/high/qmcpack/deps/lib64 -lfftw3 -lcblas -ltatlas -stdlib=libc++" "-I$SICM_DIR/examples/high/qmcpack/deps/include -stdlib=libc++"
export PATH="$SICM_DIR/examples/high/qmcpack/deps/bin:$PATH"

# Compile a newer version of CMake for QMCPACK
#cd $SICM_DIR/examples/high/qmcpack/deps
#if [[ ! -d cmake-3.12.4 ]]; then
#  if [[ ! -f cmake-3.12.4.tar.gz ]]; then
#    wget https://github.com/Kitware/CMake/releases/download/v3.12.4/cmake-3.12.4.tar.gz
#  fi
#  tar xf cmake-3.12.4.tar.gz
#  cd cmake-3.12.4
#  ./bootstrap --prefix=$SICM_DIR/examples/high/qmcpack/deps
#  make -j $(nproc --all)
#  make -j $(nproc --all) install
#fi
#
## Compile FFTW
#cd $SICM_DIR/examples/high/qmcpack/deps
#if [[ ! -d fftw-3.3.8 ]]; then
#  if [[ ! -f fftw-3.3.8.tar.gz ]]; then
#    wget http://www.fftw.org/fftw-3.3.8.tar.gz
#  fi
#  tar xf fftw-3.3.8.tar.gz
#  cd fftw-3.3.8
#  ./configure --prefix=$SICM_DIR/examples/high/qmcpack/deps --enable-shared
#  make -j $(nproc --all)
#  make -j $(nproc --all) install
#fi
#
## Compile Boost
#cd $SICM_DIR/examples/high/qmcpack/deps
#if [[ ! -d boost_1_69_0 ]]; then
#  if [[ ! -f boost_1_69_0.tar.gz ]]; then
#    wget https://dl.bintray.com/boostorg/release/1.69.0/source/boost_1_69_0.tar.gz
#  fi
#  tar xf boost_1_69_0.tar.gz
#  cd boost_1_69_0
#  ./bootstrap.sh --prefix=$SICM_DIR/examples/high/qmcpack/deps
#  ./b2 --clean-all
#  ./b2 -j$CORES
#  ./b2 install --prefix=$SICM_DIR/examples/high/qmcpack/deps
#fi
# Compile HDF5
#cd $SICM_DIR/examples/high/qmcpack/deps
#if [[ ! -d hdf5-1.10.4 ]]; then
#	if [[ ! -f hdf5-1.10.4.tar.gz ]]; then
#		wget https://s3.amazonaws.com/hdf-wordpress-1/wp-content/uploads/manual/HDF5/HDF5_1_10_4/hdf5-1.10.4.tar.gz
#	fi
#	tar xf hdf5-1.10.4.tar.gz
#	cd hdf5-1.10.4
#	rm -rf build
#	mkdir build
#	cd build
#	cmake -DCMAKE_INSTALL_PREFIX="$SICM_DIR/examples/high/qmcpack/deps" \
#	      -DCMAKE_C_COMPILER="$SICM_DIR/deps/bin/clang" \
#				-DCMAKE_CXX_COMPILER="$SICM_DIR/deps/bin/clang++" \
#		..
#	make -j $(nproc --all)
#	make install
#fi

# Compile ATLAS
#cd $SICM_DIR/examples/high/qmcpack/deps
#wget http://www.netlib.org/lapack/lapack-3.8.0.tar.gz
#if [[ ! -d ATLAS ]]; then
#	if [[ ! -f atlas3.10.3.tar.bz2 ]]; then
#		wget https://downloads.sourceforge.net/project/math-atlas/Stable/3.10.3/atlas3.10.3.tar.bz2
#	fi
#	tar xf atlas3.10.3.tar.bz2
#fi
#cd ATLAS
#rm -rf build
#mkdir build
#cd build
#../configure --prefix=$SICM_DIR/examples/high/qmcpack/deps --shared  --with-netlib-lapack-tarfile=$SICM_DIR/examples/high/qmcpack/deps/lapack-3.8.0.tar.gz
#make
#make install

# Compile QMCPACK
cd $SICM_DIR/examples/high/qmcpack/src
rm -rf build
mkdir build
cd build
cmake -DBUILD_UNIT_TESTS=False \
			-DBUILD_SANDBOX=False \
			-DBUILD_QMCTOOLS=False \
	    -DQMC_SYMLINK_TEST_FILES=False \
      -DQMC_MPI=False \
      -DQMC_ADIOS=False \
      -DCMAKE_CXX_COMPILER=${COMPILER_WRAPPER} \
      -DCMAKE_C_COMPILER=${COMPILER_WRAPPER} \
      -DCMAKE_CXX_FLAGS="-stdlib=libc++ -Wno-warnings -Wno-deprecated" \
      -DCMAKE_LINKER=${LD_WRAPPER} \
      -DCMAKE_CXX_LINK_EXECUTABLE="<CMAKE_LINKER> <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>" \
			-DCMAKE_AR=${AR_WRAPPER} \
			-DCMAKE_RANLIB=${RANLIB_WRAPPER} \
      ..
make -j $(nproc --all)
