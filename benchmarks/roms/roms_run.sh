#!/bin/bash

export REF="${SICM_ENV} ./roms.exe < ocean_benchmark3.in"
export TEST="${SICM_ENV} ./roms.exe < ocean_benchmark0.in"
export TRAIN="${SICM_ENV} ./roms.exe < ocean_benchmark1.in"

function roms_prerun {
  export SH_MAX_SITES="16000"
  
  # If OMP_NUM_THREADS isn't divisible by 2, then we know
  # that we've subtracted 1 from it (for example, the profiling
  # runs do this). This is unacceptable for ROMS because the
  # variables "NtileI" and "NtileJ" in its input files must multiply
  # to make a multiple of the number of threads. Therefore, let's add
  # 1 back to OMP_NUM_THREADS to make it divisible by 2. If this doesn't
  # work, edit ROMS' input files to meet that condition for your system.
  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS / 2`
  if [ $(( $OMP_NUM_THREADS % 2 )) -ne 0 ]; then
    echo "WARNING: Because this is ROMS, adding one back to OMP_NUM_THREADS even though it's likely a profiling run."
    export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS + 1`
  fi
  echo "ROMS OMP_NUM_THREADS: ${OMP_NUM_THREADS}"
}

function roms_setup {
  if [[ $SIZE = "ref" ]]; then
    rm -rf run
    cp -r run-ref run
  elif [[ $SIZE = "train" ]]; then
    rm -rf run
    cp -r run-train run
  elif [[ $SIZE = "test" ]]; then
    rm -rf run
    cp -r run-test run
  fi
  cp src/roms.exe run/
}
