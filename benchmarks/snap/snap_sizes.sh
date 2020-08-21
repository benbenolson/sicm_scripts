#!/bin/bash

export SMALL="./snap small.txt test.txt"
export MEDIUM="./snap medium.txt test.txt"
export LARGE="./snap large.txt test.txt"

export SMALL_AEP="${SICM_ENV} ./snap small_aep.txt test.txt"
export MEDIUM_AEP="${SICM_ENV} ./snap medium_aep.txt test.txt"
export LARGE_AEP="${SICM_ENV} ./snap large_aep.txt test.txt"
export HUGE_AEP="${SICM_ENV} ./snap huge_aep.txt test.txt"

function snap_prerun {
  if [[ $SH_ARENA_LAYOUT = "SHARED_SITE_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  elif [[ $SH_ARENA_LAYOUT = "BIG_SMALL_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  else
    export JE_MALLOC_CONF="oversize_threshold:0"
  fi
}
