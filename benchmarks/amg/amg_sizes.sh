#!/bin/bash

OLD="./amg -problem 2 -n 120 120 120"
SMALL="./amg -problem 2 -n 120 120 120"
MEDIUM="./amg -problem 2 -n 220 220 220"
LARGE="./amg -problem 2 -n 270 270 270"

SMALL_AEP="./amg -problem 2 -n 120 120 120"
MEDIUM_AEP="./amg -problem 2 -n 400 400 400"
LARGE_AEP="./amg -problem 2 -n 520 520 520"
HUGE_AEP="./amg -problem 2 -n 600 600 600"

function amg_medium_pebs_128 {
  export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:2"
}

function amg_large_pebs_128 {
  export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:2"
}

function amg_medium_firsttouch_all_shared_site_0 {
  export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:2"
}

function amg_large_firsttouch_all_shared_site_0 {
  export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:2"
}

function amg_medium_cache_mode_pebs_128 {
  export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:2"
}

function amg_large_cache_mode_pebs_128 {
  export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:2"
}

function amg_medium_cache_mode_shared_site {
  export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:2"
}

function amg_large_cache_mode_shared_site {
  export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:2"
}
