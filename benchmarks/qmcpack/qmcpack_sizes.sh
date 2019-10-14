#!/bin/bash

SMALL="./qmcpack small.xml"
MEDIUM="./qmcpack medium.xml"
LARGE="./qmcpack large.xml"
OLD="./qmcpack old.xml"

SMALL_AEP="./qmcpack small_aep.xml"
MEDIUM_AEP="./qmcpack medium_aep.xml"
LARGE_AEP="./qmcpack large_aep.xml"
HUGE_AEP="./qmcpack huge_aep.xml"

function qmcpack_prerun {
  if [[ $SH_ARENA_LAYOUT = "SHARED_SITE_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  elif [[ $SH_ARENA_LAYOUT = "BIG_SMALL_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  else
    export JE_MALLOC_CONF="oversize_threshold:0"
	fi
	echo "Using JE_MALLOC_CONF='$JE_MALLOC_CONF'."
}
