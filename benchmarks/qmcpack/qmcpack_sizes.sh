#!/bin/bash

SMALL="./qmcpack small.xml"
MEDIUM="./qmcpack medium.xml"
LARGE="./qmcpack large.xml"
OLD="./qmcpack old.xml"

SMALL_AEP="${SICM_ENV} ./qmcpack small_aep.xml"
MEDIUM_AEP="${SICM_ENV} ./qmcpack medium_aep.xml"
LARGE_AEP="${SICM_ENV} ./qmcpack large_aep.xml"
HUGE_AEP="${SICM_ENV} ./qmcpack huge_aep.xml"

function qmcpack_prerun {
  if [[ $SH_ARENA_LAYOUT = "SHARED_SITE_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  elif [[ $SH_ARENA_LAYOUT = "BIG_SMALL_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  else
    export JE_MALLOC_CONF="oversize_threshold:0"
  fi
  echo "Using JE_MALLOC_CONF='$JE_MALLOC_CONF'."
  #export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$(spack location -i llvm@7.0.1)/lib"
}

function qmcpack_setup {
  echo "qmcpack_setup"
  #echo "Adding to LD_LIBRARY_PATH: $(spack location -i llvm@7.0.1)/lib"
  #export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$(spack location -i llvm@7.0.1)/lib"
}
