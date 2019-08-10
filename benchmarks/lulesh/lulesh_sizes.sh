#!/bin/bash

export SMALL="./lulesh2.0 -s 220 -i 12 -r 11 -b 0 -c 64 -p"
export MEDIUM="./lulesh2.0 -s 340 -i 12 -r 11 -b 0 -c 64 -p"
export LARGE="./lulesh2.0 -s 420 -i 12 -r 11 -b 0 -c 64 -p"
export OLD="./lulesh2.0 -s 220 -i 5 -r 11 -b 0 -c 64 -p"

export SMALL_AEP="./lulesh2.0 -s 220 -i 12 -r 11 -b 0 -c 64 -p"
export MEDIUM_AEP="./lulesh2.0 -s 520 -i 6 -r 11 -b 0 -c 64 -p"
export LARGE_AEP="./lulesh2.0 -s 690 -i 3 -r 11 -b 0 -c 64 -p"
export HUGE_AEP="./lulesh2.0 -s 780 -i 3 -r 11 -b 0 -c 64 -p"

function lulesh_old_pebs_128 {
  echo "Setting special parameters for this size and config."
  export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
}

function lulesh_medium_aep_pebs_128 {
  if [[ "$(hostname)" = "JF1121-080209T" ]]; then
    echo "Setting special parameters for this size and config."
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:2"
  fi
}

function lulesh_medium_aep_pebs_16 {
  if [[ "$(hostname)" = "JF1121-080209T" ]]; then
    echo "Setting special parameters for this size and config."
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:2"
  fi
}

function lulesh_medium_aep_cache_mode_pebs_128 {
  if [[ "$(hostname)" = "JF1121-080209T" ]]; then
    echo "Setting special parameters for this size and config."
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:2"
  fi
}

function lulesh_medium_aep_cache_mode_shared_site {
  if [[ "$(hostname)" = "JF1121-080209T" ]]; then
    echo "Setting special parameters for this size and config."
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:2"
  fi
}
