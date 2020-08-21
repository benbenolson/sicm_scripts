#!/bin/bash
# Is untarring this many files really necessary?

export REF="sh -c '${SICM_ENV} ./wrf.exe'"
export TEST="sh -c '${SICM_ENV} ./wrf.exe'"
export TRAIN="sh -c '${SICM_ENV} ./wrf.exe'"

function wrf_prerun {
  if [[ $SH_ARENA_LAYOUT = "SHARED_SITE_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  elif [[ $SH_ARENA_LAYOUT = "BIG_SMALL_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  else
    export JE_MALLOC_CONF="oversize_threshold:0"
  fi
  export SH_MAX_SITES="18100"
}

function wrf_setup {
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
  cp src/wrf.exe run/
}
