#!/bin/bash

# First argument is the PEBS frequency
# Second is the sampling rate
function prof_all_base {
  FREQ="$1"
  RATE="$2"

  export SH_MAX_SITES_PER_ARENA="5000"
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  
  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 1`

  # Value profiling
  export SH_PROFILE_ALL="1"
  export SH_MAX_SAMPLE_PAGES="2048"
  export SH_SAMPLE_FREQ="${FREQ}"
  export SH_PROFILE_RATE_NSECONDS=$(echo "${RATE} * 1000000" | bc)
  export SH_PROFILE_ALL_EVENTS="MEM_LOAD_UOPS_LLC_MISS_RETIRED:LOCAL_DRAM,MEM_LOAD_UOPS_RETIRED:LOCAL_PMM"
  
  eval "${PRERUN}"

  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
    export SH_PROFILE_OUTPUT_FILE="${DIR}/profile.txt"
    mkdir ${DIR}
    echo 1 | sudo tee /proc/sys/kernel/perf_event_paranoid
    drop_caches_start
    eval "${COMMAND}" &>> ${DIR}/stdout.txt
    drop_caches_end
  done
}

function prof_all_es {
  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export SH_PROFILE_EXTENT_SIZE="1"
  export SH_PROFILE_EXTENT_SIZE_SKIP_INTERVALS="$3"
  prof_all_base $@
}

function prof_all_es_debug {
  export SH_PRINT_PROFILE_INTERVALS="1"
  prof_all_es $@
}

function prof_all_rss {
  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export SH_PROFILE_RSS="1"
  export SH_PROFILE_RSS_SKIP_INTERVALS="$3"
  prof_all_base $@
}

function prof_all_rss_debug {
  export SH_PRINT_PROFILE_INTERVALS="1"
  prof_all_rss $@
}

function prof_all_rss_es {
  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export SH_PROFILE_RSS="1"
  export SH_PROFILE_RSS_SKIP_INTERVALS="$3"
  export SH_PROFILE_EXTENT_SIZE="1"
  export SH_PROFILE_EXTENT_SIZE_SKIP_INTERVALS="$3"
  prof_all_base $@
}

function prof_all_rss_es_debug {
  export SH_PRINT_PROFILE_INTERVALS="1"
  prof_all_rss_es $@
}

function prof_all_bss_rss {
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4096"
  export SH_PROFILE_RSS="1"
  export SH_PROFILE_RSS_SKIP_INTERVALS="$3"
  prof_all_base $@
}

function prof_all_bsl_rss {
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304"
  export SH_PROFILE_RSS="1"
  export SH_PROFILE_RSS_SKIP_INTERVALS="$3"
  
  prof_all_base $@
}

function prof_all_bsl_rss_debug {
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304"
  export SH_PROFILE_RSS="1"
  export SH_PROFILE_RSS_SKIP_INTERVALS="$3"
  export SH_PRINT_PROFILE_INTERVALS="1"
  
  prof_all_base $@
}

function prof_all_bsl_debug {
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304"
  export SH_PRINT_PROFILE_INTERVALS="1"
  
  prof_all_base $@
}

function prof_all_bss_es {
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4096"
  export SH_PROFILE_EXTENT_SIZE="1"
  export SH_PROFILE_EXTENT_SIZE_SKIP_INTERVALS="$3"
  
  prof_all_base $@
}

function prof_all_bsl_es {
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304"
  export SH_PROFILE_EXTENT_SIZE="1"
  export SH_PROFILE_EXTENT_SIZE_SKIP_INTERVALS="$3"
  
  prof_all_base $@
}

function prof_all {
  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  
  prof_all_base $@
}

function prof_all_bss {
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4096"
  
  prof_all_base $@
}

function prof_all_bsl {
  export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  export SH_BIG_SMALL_THRESHOLD="4194304"
  
  prof_all_base $@
}

function prof_all_bsl_nopoll {
  prof_all_bsl $@
}

function prof_all_bsl_rss_nopoll {
  prof_all_bsl_rss $@
}
