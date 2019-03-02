#!/bin/bash

export SMALL_AEP="${SICM_ENV} ./access_count 131072 1024 16 1"

function acess-count_prerun {
  if [[ $SH_ARENA_LAYOUT = "SHARED_SITE_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  elif [[ $SH_ARENA_LAYOUT = "BIG_SMALL_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  else
    export JE_MALLOC_CONF="oversize_threshold:0"
  fi
  echo "Using JE_MALLOC_CONF='$JE_MALLOC_CONF'."
}
