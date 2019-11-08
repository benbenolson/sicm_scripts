#!/bin/bash

export MEDIUM_AEP="./blackscholes ${OMP_NUM_THREADS} in_100M.txt prices.txt"
export LARGE_AEP="./blackscholes ${OMP_NUM_THREADS} in_1B.txt prices.txt"

function blackscholes_prerun {
  if [[ $SH_ARENA_LAYOUT = "SHARED_SITE_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  elif [[ $SH_ARENA_LAYOUT = "BIG_SMALL_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  else
    export JE_MALLOC_CONF="oversize_threshold:0"
  fi
  echo "Using JE_MALLOC_CONF='$JE_MALLOC_CONF'."
}
