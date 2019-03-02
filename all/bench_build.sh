#!/bin/bash

# First argument is "fort" or "c", which linker we should use
# Second argument is a list of linker flags to add, which are just appended
# Third argument is a list of compiler flags to add, which are just appended
function bench_build {
  # Use Spack to load SICM into the environment
  if [ "$1" = "fort" ]; then
    export LD_LINKER="flang $2 -Wno-unused-command-line-argument -Wl,-rpath,${SICM_PREFIX}/lib -L${SICM_PREFIX}/lib -lflang -lflangrti -g"
  elif [ "$1" = "c" ]; then
    export LD_LINKER="clang++ $2 -Wno-unused-command-line-argument -L${SICM_PREFIX}/lib -lflang -lflangrti -Wl,-rpath,${SICM_PREFIX}/lib -g"
  else
    echo "No linker specified. Aborting."
    exit
  fi

  # Define the variables for the compiler wrappers
  export LD_COMPILER="clang++ -Wno-unused-command-line-argument -march=x86-64 -g" # Compiles from .bc -> .o
  export CXX_COMPILER="clang++ $3  -Wno-unused-command-line-argument -march=x86-64 -g"
  export FORT_COMPILER="flang $3  -Mpreprocess -Wno-unused-command-line-argument -march=x86-64 -I${SICM_PREFIX}/include -L${SICM_PREFIX}/lib -lflang -lflangrti -g"
  export C_COMPILER="clang  $3 -Wno-unused-command-line-argument -march=x86-64 -g"
  export LLVMLINK="llvm-link"
  export LLVMOPT="opt"

  # Make sure the Makefiles find our wrappers
  export COMPILER_WRAPPER="compiler_wrapper.sh "
  export LD_WRAPPER="ld_wrapper.sh "
  export PREPROCESS_WRAPPER="clang -E -x c -P "
  export AR_WRAPPER="ar_wrapper.sh "
  export RANLIB_WRAPPER="ranlib_wrapper.sh "
}

function bench_build_no_transform {
  bench_build $@
  export NO_TRANSFORM="yes"
}
