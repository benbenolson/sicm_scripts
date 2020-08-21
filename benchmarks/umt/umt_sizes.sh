#!/bin/bash

export SMALL="./lulesh2.0 -s 220 -i 12 -r 11 -b 0 -c 64 -p"
export MEDIUM="./lulesh2.0 -s 340 -i 12 -r 11 -b 0 -c 64 -p"
export LARGE="./lulesh2.0 -s 420 -i 12 -r 11 -b 0 -c 64 -p"
export OLD="./lulesh2.0 -s 220 -i 5 -r 11 -b 0 -c 64 -p"

export SMALL_AEP="${SICM_ENV} ./lulesh2.0 -s 220 -i 12 -r 11 -b 0 -c 64 -p"
export MEDIUM_AEP="${SICM_ENV} ./lulesh2.0 -s 400 -i 6 -r 11 -b 0 -c 64 -p"
export LARGE_AEP="${SICM_ENV} ./lulesh2.0 -s 690 -i 3 -r 11 -b 0 -c 64 -p"
export HUGE_AEP="${SICM_ENV} ./lulesh2.0 -s 780 -i 3 -r 11 -b 0 -c 64 -p"

function lulesh_prerun {
  if [[ $SH_ARENA_LAYOUT = "SHARED_SITE_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  elif [[ $SH_ARENA_LAYOUT = "BIG_SMALL_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  else
    export JE_MALLOC_CONF="oversize_threshold:0"
  fi
  echo "Using JE_MALLOC_CONF='$JE_MALLOC_CONF'."
}
