#!/bin/bash

#export REF="sh -c '${SICM_ENV} valgrind --tool=callgrind --main-stacksize=134217728 ./cam4.exe'"
export REF="sh -c '${SICM_ENV} ./cam4.exe'"
#export REF="sh -c '${SICM_ENV} valgrind --tool=drd --exclusive-threshold=1 ./cam4.exe'"
export TEST="sh -c '${SICM_ENV} ./cam4.exe'"
export TRAIN="sh -c '${SICM_ENV} ./cam4.exe'"

function cam4_prerun {
  if [[ $SH_ARENA_LAYOUT = "SHARED_SITE_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  elif [[ $SH_ARENA_LAYOUT = "BIG_SMALL_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  else
    export JE_MALLOC_CONF="oversize_threshold:0"
  fi
  export OMP_STACKSIZE="256M"
  export SH_MAX_SITES="6000"
}

function cam4_setup {
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
  cp src/cam4.exe run/
}
