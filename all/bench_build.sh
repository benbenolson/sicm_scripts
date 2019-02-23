#!/bin/bash

# First argument is "fort" or "c", which linker we should use
# Second argument is a list of linker flags to add, which are just appended
# Third argument is a list of compiler flags to add, which are just appended
function bench_build {
  # Use Spack to load SICM into the environment
  if [ "$1" = "fort" ]; then
    export LD_LINKER="flang $2 -g -Wno-unused-command-line-argument -Wl,-rpath,$(spack location -i llvm@flang-20180921)/lib -Wl,-rpath,$(spack location -i flang@20180921)/lib -Wl,-rpath,$(spack location -i pgmath)/lib"
  elif [ "$1" = "c" ]; then
    export LD_LINKER="clang++ $2 -g -Wno-unused-command-line-argument -Wl,-rpath,$(spack location -i llvm@flang-20180921)/lib"
  else
    echo "No linker specified. Aborting."
    exit
  fi

  # Define the variables for the compiler wrappers
  export LD_COMPILER="clang++ -Wno-unused-command-line-argument -Ofast -march=knl" # Compiles from .bc -> .o
  export CXX_COMPILER="clang++ $3 -g -Wno-unused-command-line-argument -Ofast -march=knl"
  export FORT_COMPILER="flang $3 -g -Mpreprocess -Wno-unused-command-line-argument -Ofast -march=knl -I$(spack location -i flang@20180921)/include"
  export C_COMPILER="clang -g $3 -Wno-unused-command-line-argument -Ofast -march=knl"
  export LLVMLINK="llvm-link"
  export OPT="opt"

  # Make sure the Makefiles find our wrappers
  export COMPILER_WRAPPER="compiler_wrapper.sh -g"
  export LD_WRAPPER="ld_wrapper.sh -g"
  export PREPROCESS_WRAPPER="clang -E -x c -w -P"
  export AR_WRAPPER="ar_wrapper.sh"
  export RANLIB_WRAPPER="ranlib_wrapper.sh"
}

# First argument is "fort" or "c", which linker we should use.
# For the default build, this will also be the compiler that we use. This should be fixed later to allow
# for multiple compilers.
# Second argument is a list of linker flags to add, which are just appended
function def_bench_build {
  if [ "$1" = "fort" ]; then
    export LD_WRAPPER="$SICM_DIR/deps/bin/flang $2 -g -Wno-unused-command-line-argument -L$SICM_DIR/deps/lib -Wl,-rpath,$SICM_DIR/deps/lib "
    export COMPILER_WRAPPER="$SICM_DIR/deps/bin/flang $3 -g -Wno-unused-command-line-argument -I$SICM_DIR/deps/include"
  elif [ "$1" = "c" ]; then
    export LD_WRAPPER="$SICM_DIR/deps/bin/clang++ $2 -g -Wno-unused-command-line-argument -L$SICM_DIR/deps/lib -Wl,-rpath,$SICM_DIR/deps/lib"
    export COMPILER_WRAPPER="$SICM_DIR/deps/bin/clang $3 -g -Wno-unused-command-line-argument -I$SICM_DIR/deps/include"
  else
    echo "No linker specified. Aborting."
    exit
  fi

  export PREPROCESS_WRAPPER="$SICM_DIR/bin/clang -E -x c -w -P"
}
