#!/bin/bash

function dep_build {
  echo "UNPATCHED_PREFIX: ${UNPATCHED_PREFIX}"
  # The idea here is to default to using the unpatched binaries/libraries,
  # but fall back to the patched ones.
  export PATH="${UNPATCHED_PREFIX}/bin:${SICM_PREFIX}/bin:${PATH}"
  export LD_LIBRARY_PATH="${UNPATCHED_PREFIX}/lib:${SICM_PREFIX}/lib:${LD_LIBRARY_PATH}"
  export LIBRARY_PATH="${UNPATCHED_PREFIX}/lib:${SICM_PREFIX}/lib:${LIBRARY_PATH}"
  export CPATH="${UNPATCHED_PREFIX}/include:${SICM_PREFIX}/include:${CPATH}"
  export CMAKE_PREFIX_PATH="${UNPATCHED_PREFIX}/:${SICM_PREFIX}/:${CMAKE_PREFIX_PATH}"
  export FC="${SICM_PREFIX}/bin/flang -L${UNPATCHED_PREFIX}/lib/"
  export F77="${SICM_PREFIX}/bin/flang -L${UNPATCHED_PREFIX}/lib/"
  export F90="${SICM_PREFIX}/bin/flang -L${UNPATCHED_PREFIX}/lib/"
  export CC="${SICM_PREFIX}/bin/clang -L${UNPATCHED_PREFIX}/lib/"
  export CXX="${SICM_PREFIX}/bin/clang++ -L${UNPATCHED_PREFIX}/lib/"
}

# First argument is "fort" or "c", which linker we should use
# Second argument is a list of linker flags to add, which are just appended
# Third argument is a list of compiler flags to add, which are just appended
function bench_build {
  export PATH="${SICM_PREFIX}/bin:${PATH}"
  export LD_LIBRARY_PATH="${SICM_PREFIX}/lib:${LD_LIBRARY_PATH}"
  export LIBRARY_PATH="${SICM_PREFIX}/lib:${LIBRARY_PATH}"
  export CPATH="${SICM_PREFIX}/include:${CPATH}"
  export CMAKE_PREFIX_PATH="${SICM_PREFIX}/:${CMAKE_PREFIX_PATH}"
  export FC="${SICM_PREFIX}/bin/flang"
  export F77="${SICM_PREFIX}/bin/flang"
  export F90="${SICM_PREFIX}/bin/flang"

  if [ "$1" = "fort" ]; then
    export LD_LINKER="flang ${SICM_COMPILER_ARGS} $2 -Wno-unused-command-line-argument -Wl,-rpath,${SICM_PREFIX}/lib -L${SICM_PREFIX}/lib -lflang -lflangrti -gdwarf-3 -ljemalloc"
  elif [ "$1" = "c" ]; then
    export LD_LINKER="clang++ ${SICM_COMPILER_ARGS} $2 -Wno-unused-command-line-argument -L${SICM_PREFIX}/lib -lflang -lflangrti -Wl,-rpath,${SICM_PREFIX}/lib -lsicm_runtime -gdwarf-3 -ldl -ljemalloc"
  else
    echo "No linker specified. Aborting."
    exit
  fi

  # Define the variables for the compiler wrappers
  export LD_COMPILER="clang++ -Wno-unused-command-line-argument -march=x86-64 -gdwarf-3 -L${SICM_PREFIX}/lib -lsicm_runtime -fopenmp" # Compiles from .bc -> .o
  export CXX_COMPILER="clang++ $3 -Wno-unused-command-line-argument -march=x86-64 -gdwarf-3 -I${SICM_PREFIX}/include -fopenmp"
  export FORT_COMPILER="flang $3  -Mpreprocess -Wno-unused-command-line-argument -march=x86-64 -I${SICM_PREFIX}/include -L${SICM_PREFIX}/lib -lflang -lflangrti -gdwarf-3 -fopenmp"
  export C_COMPILER="clang $3 -Wno-unused-command-line-argument -march=x86-64 -gdwarf-3 -I${SICM_PREFIX}/include -fopenmp"
  export LLVMLINK="llvm-link"
  export LLVMOPT="opt"

  # Make sure the Makefiles find our wrappers
  export COMPILER_WRAPPER="compiler_wrapper.sh ${SICM_COMPILER_ARGS} "
  export LD_WRAPPER="ld_wrapper.sh ${SICM_COMPILER_ARGS} "
  export PREPROCESS_WRAPPER="clang -E -x c -P "
  export AR_WRAPPER="ar_wrapper.sh "
  export RANLIB_WRAPPER="ranlib_wrapper.sh "
}

function bench_build_no_transform {
  bench_build $@
  export NO_TRANSFORM="yes"
}
