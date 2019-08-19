#!/bin/bash

# First argument is "fort" or "c", which linker we should use
# Second argument is a list of linker flags to add, which are just appended
# Third argument is a list of compiler flags to add, which are just appended
function bench_build {
  # Use Spack to load SICM into the environment
  if [ "$1" = "fort" ]; then
    if [[ "$(hostname)" = "JF1121-080209T" ]]; then
      export LD_LINKER="flang $2 -g -Wno-unused-command-line-argument -Wl,-rpath,$(spack location -i llvm@flang-20180921)/lib -Wl,-rpath,$(spack location -i flang-patched@20180921)/lib -Wl,-rpath,$(spack location -i pgmath)/lib"
    else
      export LD_LINKER="flang $2 -g -Wno-unused-command-line-argument -Wl,-rpath,$(spack location -i llvm@flang-20180921)/lib -Wl,-rpath,$(spack location -i flang-patched@20180921)/lib -Wl,-rpath,$(spack location -i pgmath)/lib"
    fi
  elif [ "$1" = "c" ]; then
    if [[ "$(hostname)" = "JF1121-080209T" ]]; then
      export LD_LINKER="clang++ $2 -g -Wno-unused-command-line-argument -L$(spack location -i flang-patched@20180921)/lib -lflang -lflangrti -Wl,-rpath,$(spack location -i llvm@flang-20180921)/lib -Wl,-rpath,$(spack location -i flang-patched@20180921)/lib -Wl,-rpath,$(spack location -i pgmath)/lib"
    else
      export LD_LINKER="clang++ $2 -g -Wno-unused-command-line-argument -Wl,-rpath,$(spack location -i llvm@flang-20180921)/lib -Wl,-rpath,$(spack location -i flang-patched@20180921)/lib -Wl,-rpath,$(spack location -i pgmath)/lib"
    fi
  else
    echo "No linker specified. Aborting."
    exit
  fi

  # Define the variables for the compiler wrappers
  export LD_COMPILER="clang++ -Wno-unused-command-line-argument -march=native" # Compiles from .bc -> .o
  export CXX_COMPILER="clang++ $3 -g -Wno-unused-command-line-argument -march=native"
  if [[ "$(hostname)" = "JF1121-080209T" ]]; then
    export FORT_COMPILER="flang $3 -g -Mpreprocess -Wno-unused-command-line-argument -march=native -I$(spack location -i flang-patched@20180921)/include"
  else
    export FORT_COMPILER="flang $3 -g -Mpreprocess -Wno-unused-command-line-argument -march=native -I$(spack location -i flang-patched@20180921)/include"
  fi
  export C_COMPILER="clang -g $3 -Wno-unused-command-line-argument -march=native"
  export LLVMLINK="llvm-link"
  export LLVMOPT="opt"

  # Make sure the Makefiles find our wrappers
  export COMPILER_WRAPPER="compiler_wrapper.sh -g"
  export LD_WRAPPER="ld_wrapper.sh -g"
  export PREPROCESS_WRAPPER="clang -E -x c -P"
  export AR_WRAPPER="ar_wrapper.sh"
  export RANLIB_WRAPPER="ranlib_wrapper.sh"
}
