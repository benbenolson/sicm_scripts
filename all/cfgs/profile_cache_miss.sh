#!/bin/bash

# First argument is the PEBS frequency
# Second is the sampling rate
# Third is skip intervals for capacity profiling
function profile_cache_miss_and_cap {
  FREQ="$1"
  RATE="$2"

  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"

  # Enable profiling
  export SH_PROFILE_ALL="1"
  export SH_PROFILE_RATE_NSECONDS=$(echo "$RATE * 1000000" | bc)
  export SH_PROFILE_ALL_EVENTS="MEM_LOAD_UOPS_RETIRED:L1_HIT,MEM_LOAD_UOPS_RETIRED:L2_HIT,MEM_LOAD_UOPS_RETIRED:L3_HIT,MEM_LOAD_UOPS_RETIRED:L3_MISS"
  export SH_MAX_SAMPLE_PAGES="512"
  export SH_SAMPLE_FREQ="${FREQ}"

  eval "${PRERUN}"

  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
    export SH_PROFILE_OUTPUT_FILE="${DIR}/profile.txt"
    mkdir ${DIR}
    echo 1 | sudo tee /proc/sys/kernel/perf_event_paranoid
    drop_caches
    eval "${COMMAND}" &>> ${DIR}/stdout.txt
  done
}

function profile_cache_miss_and_extent_size {
  export SH_PROFILE_EXTENT_SIZE="1"
  export SH_PROFILE_EXTENT_SIZE_SKIP_INTERVALS="$3"
  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 1`
  profile_cache_miss_and_cap $@
}

function profile_cache_miss_and_extent_size_intervals {
  export SH_PROFILE_INTERVALS="1"
  profile_cache_miss_and_extent_size $@
}
